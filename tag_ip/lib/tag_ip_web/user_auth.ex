defmodule TagIpWeb.UserAuth do
  use TagIpWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias TagIp.Accounts
  alias TagIp.Accounts.Scope

  # Paramètres des cookies
  @max_cookie_age_in_days 14
  @remember_me_cookie "_tag_ip_web_user_remember_me"
  @remember_me_options [
    sign: true,
    max_age: @max_cookie_age_in_days * 24 * 60 * 60,
    same_site: "Lax"
  ]

  @session_reissue_age_in_days 7

  @doc """
  Connecte l'utilisateur.
  """
  def log_in_user(conn, user, params \\ %{}) do
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> create_or_extend_session(user, params)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  @doc """
  Déconnecte l'utilisateur.
  """
  def log_out_user(conn) do
    user_token = get_session(conn, :user_token)
    user_token && Accounts.delete_user_session_token(user_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      TagIpWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session(nil)
    |> delete_resp_cookie(@remember_me_cookie, @remember_me_options)
    |> redirect(to: ~p"/users/log-in")
  end

  @doc """
  Récupère l'utilisateur actuel via la session ou le cookie.
  """
  def fetch_current_user(conn, _opts) do
    with {token, conn} <- ensure_user_token(conn),
         {user, token_inserted_at} <- Accounts.get_user_by_session_token(token) do
      conn
      |> assign(:current_scope, Scope.for_user(user))
      |> maybe_reissue_user_session_token(user, token_inserted_at)
    else
      _ -> assign(conn, :current_scope, Scope.for_user(nil))
    end
  end

  def fetch_current_scope_for_user(conn, opts) do
    fetch_current_user(conn, opts)
  end

  defp ensure_user_token(conn) do
    if token = get_session(conn, :user_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        {token, conn |> put_token_in_session(token) |> put_session(:user_remember_me, true)}
      else
        nil
      end
    end
  end

  defp maybe_reissue_user_session_token(conn, user, token_inserted_at) do
    token_age = DateTime.diff(DateTime.utc_now(:second), token_inserted_at, :day)

    if token_age >= @session_reissue_age_in_days do
      create_or_extend_session(conn, user, %{})
    else
      conn
    end
  end

  defp create_or_extend_session(conn, user, params) do
    token = Accounts.generate_user_session_token(user)
    remember_me = get_session(conn, :user_remember_me)

    conn
    |> renew_session(user)
    |> put_token_in_session(token)
    |> maybe_write_remember_me_cookie(token, params, remember_me)
  end

  defp renew_session(conn, user) do
    current_user = conn.assigns[:current_scope] && conn.assigns.current_scope.user

    if current_user && user && current_user.id == user.id do
      conn
    else
      delete_csrf_token()

      conn
      |> configure_session(renew: true)
      |> clear_session()
    end
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}, _),
    do: write_remember_me_cookie(conn, token)

  defp maybe_write_remember_me_cookie(conn, token, _params, true),
    do: write_remember_me_cookie(conn, token)

  defp maybe_write_remember_me_cookie(conn, _token, _params, _), do: conn

  defp write_remember_me_cookie(conn, token) do
    conn
    |> put_session(:user_remember_me, true)
    |> put_resp_cookie(@remember_me_cookie, token, @remember_me_options)
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, user_session_topic(token))
  end

  def disconnect_sessions(tokens) do
    Enum.each(tokens, fn %{token: token} ->
      TagIpWeb.Endpoint.broadcast(user_session_topic(token), "disconnect", %{})
    end)
  end

  defp user_session_topic(token), do: "users_sessions:#{Base.url_encode64(token)}"

  # --- CALLBACKS LIVEVIEW (on_mount) ---

  def on_mount(:mount_current_user, params, session, socket) do
    on_mount(:mount_current_scope, params, session, socket)
  end

  def on_mount(:mount_current_scope, _params, session, socket) do
    {:cont,
     Phoenix.Component.assign_new(socket, :current_scope, fn ->
       if token = session["user_token"] do
         case Accounts.get_user_by_session_token(token) do
           {user, _token_inserted_at} -> Scope.for_user(user)
           _ -> nil
         end
       end
     end)}
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, _session, socket) do
    if socket.assigns[:current_scope] && socket.assigns.current_scope.user do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/dashboard")}
    else
      {:cont, socket}
    end
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    if socket.assigns[:current_scope] && socket.assigns.current_scope.user do
      {:cont, socket}
    else
      if token = session["user_token"] do
        case Accounts.get_user_by_session_token(token) do
          {user, _token_inserted_at} ->
            {:cont, Phoenix.Component.assign(socket, :current_scope, Scope.for_user(user))}

          _ ->
            {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/users/log-in")}
        end
      else
        {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/users/log-in")}
      end
    end
  end

  def on_mount(:require_authenticated, params, session, socket) do
    on_mount(:ensure_authenticated, params, session, socket)
  end

  def on_mount(:require_sudo_mode, _params, session, socket) do
    if token = session["user_token"] do
      case Accounts.get_user_by_session_token(token) do
        {user, _token_inserted_at} ->
          if Accounts.sudo_mode?(user) do
            {:cont, socket}
          else
            {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/users/log-in")}
          end

        _ ->
          {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/users/log-in")}
      end
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/users/log-in")}
    end
  end

  # --- HELPERS DE REDIRECTION ---

  @doc "Définit où aller après la connexion (Page d'accueil Dashboard)."
  def signed_in_path(%Plug.Conn{assigns: %{current_scope: %Scope{user: %Accounts.User{}}}}) do
    ~p"/dashboard"
  end

  def signed_in_path(_), do: ~p"/dashboard"

  @doc """
  Plug pour les routes nécessitant une connexion.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns.current_scope && conn.assigns.current_scope.user do
      conn
    else
      conn
      |> put_flash(:error, "Veuillez vous connecter pour accéder à cette page.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/users/log-in")
      |> halt()
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn
end
