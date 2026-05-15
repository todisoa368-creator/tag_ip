defmodule TagIp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias TagIp.Repo

  alias TagIp.Accounts.{User, UserToken, UserNotifier, Scope}

  ## Database getters

  @doc """
  Gets a user by email.
  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.
  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.
  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @spec register_user(
          :invalid
          | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: any()
  @doc """
  Registers a user.
  """
  def register_user(attrs) do
    %User{}
    |> User.email_changeset(attrs)
    |> Repo.insert()
  end

  ## Settings & Password Reset

  @doc """
  Delivers the reset password instructions to the given user.
  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Updates the user password.
  """
  def update_user_password(user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> update_user_and_delete_all_tokens()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.
  """
  def change_user_email(user, attrs \\ %{}, opts \\ []) do
    User.email_changeset(user, attrs, opts)
  end

  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs)
  end

  @doc """
  Updates the user email using the given token.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    Repo.transact(fn ->
      with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
           %UserToken{sent_to: email} <- Repo.one(query),
           {:ok, user} <- Repo.update(User.email_changeset(user, %{email: email})),
           {_count, _result} <-
             Repo.delete_all(from(UserToken, where: [user_id: ^user.id, context: ^context])) do
        {:ok, user}
      else
        _ -> {:error, :transaction_aborted}
      end
    end)
  end

  @doc """
  Delivers the update email instructions to the given user.
  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  ## Login & Session

  @doc """
  Envoie les instructions de connexion (Login).
  Appelle la fonction deliver_instructions/2 ajoutée dans le Notifier.
  """
  def deliver_login_instructions(%User{} = user, url_fun) when is_function(url_fun, 1) do
    UserNotifier.deliver_instructions(user, url_fun.("login-link"))
  end

  @doc """
  Récupère un utilisateur via un token de lien magique.
  """
  def get_user_by_magic_link_token(token) do
    case UserToken.verify_magic_link_token_query(token) do
      {:ok, query} -> Repo.one(query)
      _ -> nil
    end
  end

  @doc """
  Logique de connexion par lien magique.
  """
  def login_user_by_magic_link(token) do
    case get_user_by_magic_link_token(token) do
      {user, _token} -> {:ok, {user, []}}
      _ -> {:error, :invalid_token}
    end
  end

  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  def get_user_by_session_token(token) do
    case UserToken.verify_session_token_query(token) do
      {:ok, query} -> Repo.one(query)
      _ -> nil
    end
  end

  def delete_user_session_token(token) do
    Repo.delete_all(from(UserToken, where: [token: ^token, context: "session"]))
    :ok
  end

  ## Divers & Helpers

  def sudo_mode?(user, minutes \\ 10)

  def sudo_mode?(%User{authenticated_at: ts}, minutes) when is_struct(ts, DateTime) do
    cutoff = DateTime.utc_now() |> DateTime.add(-minutes, :minute)
    DateTime.after?(ts, cutoff)
  end

  def sudo_mode?(_user, _minutes), do: false

  @doc """
  Récupère le scope à partir d'un token.
  """
  def get_scope_by_token(nil), do: nil

  def get_scope_by_token(token) do
    case get_user_by_session_token(token) do
      {user, _token_inserted_at} -> Scope.for_user(user)
      _ -> nil
    end
  end

  @doc """
  AJOUTÉ : Changement de mot de passe requis pour les réglages utilisateurs.
  """
  def change_user_password(user, attrs \\ %{}, _opts \\ []) do
    User.password_changeset(user, attrs)
  end

  defp update_user_and_delete_all_tokens(changeset) do
    Repo.transact(fn ->
      with {:ok, user} <- Repo.update(changeset) do
        tokens_to_expire = Repo.all_by(UserToken, user_id: user.id)
        Repo.delete_all(from(t in UserToken, where: t.id in ^Enum.map(tokens_to_expire, & &1.id)))
        {:ok, {user, tokens_to_expire}}
      end
    end)
  end
end
