defmodule TagIp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias TagIp.Repo

  alias TagIp.Accounts.{User, UserToken, UserNotifier, Scope}

  ## =========================================================
  ## USERS GETTERS
  ## =========================================================

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)

    if User.valid_password?(user, password), do: user
  end

  def get_user!(id), do: Repo.get!(User, id)

  ## =========================================================
  ## REGISTRATION
  ## =========================================================

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  ## =========================================================
  ## PASSWORD RESET
  ## =========================================================

  def deliver_user_reset_password_instructions(%User{} = user, url_fun)
      when is_function(url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")

    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, url_fun.(encoded_token))
  end

  def update_user_password(user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> update_user_and_delete_all_tokens()
  end

  def change_user_email(user, attrs \\ %{}, opts \\ []) do
    User.email_changeset(user, attrs, opts)
  end

  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs)
  end

  ## =========================================================
  ## EMAIL UPDATE
  ## =========================================================

  def update_user_email(user, token) do
    context = "change:#{user.email}"

    Repo.transact(fn ->
      with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
           %UserToken{sent_to: email} <- Repo.one(query),
           {:ok, user} <- Repo.update(User.email_changeset(user, %{email: email})),
           {_count, _} <-
             Repo.delete_all(from(UserToken, where: [user_id: ^user.id, context: ^context])) do
        {:ok, user}
      else
        _ -> {:error, :transaction_aborted}
      end
    end)
  end

  def deliver_user_update_email_instructions(%User{} = user, current_email, url_fun)
      when is_function(url_fun, 1) do
    {encoded_token, user_token} =
      UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, url_fun.(encoded_token))
  end

  ## =========================================================
  ## LOGIN
  ## =========================================================

  def deliver_login_instructions(%User{} = user, url_fun)
      when is_function(url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "login")

    Repo.insert!(user_token)
    UserNotifier.deliver_instructions(user, url_fun.(encoded_token))
  end

  ## =========================================================
  ## MAGIC LINK LOGIN (FIXED)
  ## =========================================================

  def get_user_by_magic_link_token(token) do
    case UserToken.verify_magic_link_token_query(token) do
      {:ok, query} ->
        Repo.one(query)

      _ ->
        nil
    end
  end

  def login_user_by_magic_link(token) do
    case get_user_by_magic_link_token(token) do
      nil ->
        {:error, :not_found}

      {user, _user_token} ->
        if is_nil(user.confirmed_at) and user.hashed_password do
          raise "magic link log in is not allowed"
        end

        user =
          if is_nil(user.confirmed_at) do
            user |> User.confirm_changeset() |> Repo.update!()
          else
            user
          end

        # fetch and delete all login tokens for this user (one-time use)
        tokens =
          Repo.all(from(t in UserToken, where: t.user_id == ^user.id and t.context == "login"))

        Repo.delete_all(
          from(t in UserToken, where: t.user_id == ^user.id and t.context == "login")
        )

        {:ok, {user, tokens}}
    end
  end

  ## =========================================================
  ## SESSION TOKEN
  ## =========================================================

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
    Repo.delete_all(
      from(t in UserToken,
        where: t.token == ^token and t.context == "session"
      )
    )

    :ok
  end

  ## =========================================================
  ## RESET PASSWORD
  ## =========================================================

  def get_user_by_reset_password_token(token) do
    case UserToken.verify_reset_password_token_query(token) do
      {:ok, query} ->
        Repo.one(query)

      _ ->
        nil
    end
  end

  ## =========================================================
  ## PASSWORD CHANGE HELPERS
  ## =========================================================

  def change_user_password(user, attrs \\ %{}, opts \\ []) do
    User.password_changeset(user, attrs, opts)
  end

  defp update_user_and_delete_all_tokens(changeset) do
    Repo.transact(fn ->
      with {:ok, user} <- Repo.update(changeset) do
        tokens = Repo.all(from(t in UserToken, where: t.user_id == ^user.id))
        Repo.delete_all(from(t in UserToken, where: t.user_id == ^user.id))
        {:ok, {user, tokens}}
      end
    end)
  end

  ## =========================================================
  ## SUDO MODE
  ## =========================================================

  def sudo_mode?(user, minutes \\ 10)

  def sudo_mode?(%User{authenticated_at: ts}, minutes) when is_struct(ts, DateTime) do
    cutoff = DateTime.utc_now() |> DateTime.add(-minutes, :minute)
    DateTime.after?(ts, cutoff)
  end

  def sudo_mode?(_user, _minutes), do: false

  ## =========================================================
  ## SCOPE
  ## =========================================================

  def get_scope_by_token(nil), do: nil

  def get_scope_by_token(token) do
    case get_user_by_session_token(token) do
      {user, _token_inserted_at} ->
        Scope.for_user(user)

      user when not is_nil(user) ->
        Scope.for_user(user)

      _ ->
        nil
    end
  end
end
