defmodule TagIp.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TagIp.Accounts` context.
  """

  import Ecto.Query

  alias TagIp.Accounts
  alias TagIp.Accounts.Scope

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def unconfirmed_user_fixture(attrs \\ %{}) do
    email = attrs[:email] || unique_user_email()

    %TagIp.Accounts.User{}
    |> Ecto.Changeset.cast(%{email: email}, [:email])
    |> Ecto.Changeset.validate_required([:email])
    |> Ecto.Changeset.validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/,
      message: "doit contenir un @ et aucun espace"
    )
    |> Ecto.Changeset.unique_constraint(:email)
    |> TagIp.Repo.insert!()
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Accounts.register_user()

    now = DateTime.utc_now(:second)
    user |> Ecto.Changeset.change(confirmed_at: now) |> TagIp.Repo.update!()
  end

  def user_scope_fixture do
    user = user_fixture()
    user_scope_fixture(user)
  end

  def user_scope_fixture(user) do
    Scope.for_user(user)
  end

  def set_password(user) do
    {:ok, {user, _expired_tokens}} =
      Accounts.update_user_password(user, %{password: valid_user_password()})

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")

    body =
      case captured_email do
        %{text_body: text} -> text
        %{body: body} when is_binary(body) -> body
      end

    [_, token | _] = String.split(body, "[TOKEN]")
    token
  end

  def override_token_authenticated_at(token, authenticated_at) when is_binary(token) do
    TagIp.Repo.update_all(
      from(t in Accounts.UserToken,
        where: t.token == ^token
      ),
      set: [authenticated_at: authenticated_at]
    )
  end

  def generate_user_magic_link_token(user) do
    {encoded_token, user_token} = Accounts.UserToken.build_email_token(user, "login")
    TagIp.Repo.insert!(user_token)
    {encoded_token, user_token.token}
  end

  def offset_user_token(token, amount_to_add, unit) do
    dt = DateTime.add(DateTime.utc_now(:second), amount_to_add, unit)

    TagIp.Repo.update_all(
      from(ut in Accounts.UserToken, where: ut.token == ^token),
      set: [inserted_at: dt, authenticated_at: dt]
    )
  end
end
