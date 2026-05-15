defmodule TagIpWeb.UserSessionController do
  use TagIpWeb, :controller

  alias TagIp.Accounts
  alias TagIpWeb.UserAuth

  def create(conn, %{"_action" => "confirmed"} = params) do
    create(conn, params, fn -> "Compte confirmé avec succès." end)
  end

  def create(conn, params) do
    create(conn, params, fn -> "Bienvenue sur TAG-Monitor !" end)
  end

  # magic link login
  defp create(conn, %{"user" => %{"token" => token} = user_params}, info_fun) do
    case Accounts.login_user_by_magic_link(token) do
      {:ok, {user, tokens_to_disconnect}} ->
        UserAuth.disconnect_sessions(tokens_to_disconnect)

        session_days = TagIp.Accounts.UserToken.session_validity_days()

        conn
        |> put_flash(:info, info_fun.() <> " Votre session expire dans #{session_days} jours.")
        |> UserAuth.log_in_user(user, user_params)
        |> redirect(to: ~p"/dashboard")

      _ ->
        conn
        |> put_flash(:error, "Le lien est invalide ou a expiré.")
        |> redirect(to: ~p"/users/log-in")
    end
  end

  # email + password login
  defp create(conn, %{"user" => user_params}, info_fun) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      session_days = TagIp.Accounts.UserToken.session_validity_days()

      conn
      |> put_flash(:info, info_fun.() <> " Votre session expire dans #{session_days} jours.")
      |> UserAuth.log_in_user(user, user_params)
      |> redirect(to: ~p"/dashboard")
    else
      conn
      |> put_flash(:error, "Email ou mot de passe invalide")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log-in")
    end
  end

  def magic_link(conn, %{"token" => token}) do
    create(conn, %{"user" => %{"token" => token}}, fn -> "Connexion réussie !" end)
  end

  def update_password(conn, %{"user" => user_params} = params) do
    user = conn.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)
    {:ok, {_user, expired_tokens}} = Accounts.update_user_password(user, user_params)

    UserAuth.disconnect_sessions(expired_tokens)

    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, fn -> "Mot de passe mis à jour !" end)
  end

  def delete(conn, _params) do
    scope = conn.assigns[:current_scope]

    message =
      if scope && scope.user do
        "Déconnexion réussie. À bientôt #{scope.user.email} !"
      else
        "Déconnexion réussie."
      end

    conn
    |> put_flash(:info, message)
    |> UserAuth.log_out_user()
  end

  def redirect_to_login(conn, _params) do
    conn
    |> redirect(to: ~p"/users/log-in")
    |> halt()
  end
end
