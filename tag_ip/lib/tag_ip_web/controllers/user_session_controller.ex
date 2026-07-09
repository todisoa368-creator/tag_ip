defmodule TagIpWeb.UserSessionController do
  use TagIpWeb, :controller

  alias TagIp.Accounts
  alias TagIpWeb.UserAuth

  # =========================================================
  # LOGIN (EMAIL + PASSWORD)
  # =========================================================

  def create(conn, params) do
    create(conn, params, fn -> "Bienvenue sur l'application de gestion des profils de montage" end)
  end

  defp create(conn, %{"user" => user_params}, info_fun) do
    %{"email" => email, "password" => password} = user_params

    case Accounts.get_user_by_email_and_password(email, password) do
      nil ->
        conn
        |> put_flash(:error, "Email ou mot de passe invalide")
        |> redirect(to: ~p"/users/log-in")

      user ->
        session_days = TagIp.Accounts.UserToken.session_validity_days()

        conn
        |> put_flash(:info, info_fun.() <> " Session: #{session_days} jours.")
        |> UserAuth.log_in_user(user, user_params)
    end
  end

  # =========================================================
  # UPDATE PASSWORD
  # =========================================================

  def update_password(conn, %{"user" => user_params} = params) do
    user = conn.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    {:ok, {_user, expired_tokens}} =
      Accounts.update_user_password(user, user_params)

    UserAuth.disconnect_sessions(expired_tokens)

    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, fn -> "Mot de passe mis à jour !" end)
  end

  # =========================================================
  # LOGOUT
  # =========================================================

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Déconnexion réussie.")
    |> UserAuth.logout_user()
  end
end
