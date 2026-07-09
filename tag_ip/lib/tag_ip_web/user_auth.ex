defmodule TagIpWeb.UserAuth do
  use TagIpWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias TagIp.Accounts
  alias TagIp.Accounts.Scope

  @max_age 60 * 60 * 24 * 14
  @remember_me_cookie "_tag_ip_web_user_remember_me"
  @remember_me_OPTIONS [sign: true, max_age: @max_age, same_site: "Lax"]
  @remember_me_options @remember_me_OPTIONS

  # =========================================================
  # LOGIN
  # =========================================================

  def log_in_user(conn, user, params \\ %{}) do
    token = Accounts.generate_user_session_token(user)
    user_return_to = get_session(conn, :user_return_to)

    # preserve previous remember_me flag if present in session or provided in params
    remember_me = Map.get(params, "remember_me") == "true" || get_session(conn, :user_remember_me)

    # If we're re-authenticating and the current scope already
    # belongs to the same user, preserve the session (don't clear it).
    conn =
      case conn.assigns[:current_scope] do
        %Scope{user: %_{id: id}} when id == user.id -> conn
        _ -> renew_session(conn)
      end

    conn = put_token_in_session(conn, token)

    conn =
      if remember_me,
        do: maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}),
        else: conn

    conn = if remember_me, do: put_session(conn, :user_remember_me, true), else: conn

    conn
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  # =========================================================
  # REDIRECTION APRÈS LOGIN
  # =========================================================

  def signed_in_path(_conn) do
    ~p"/dashboard"
  end

  # =========================================================
  # REMEMBER ME
  # =========================================================

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    conn = put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
    conn |> put_session(:user_remember_me, true)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params), do: conn

  # =========================================================
  # LOGOUT
  # =========================================================

  def logout_user(conn) do
    user_token = get_session(conn, :user_token)

    if user_token do
      Accounts.delete_user_session_token(user_token)
    end

    if live_socket_id = get_session(conn, :live_socket_id) do
      TagIpWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: ~p"/users/log-in")
  end

  def log_out_user(conn), do: logout_user(conn)

  # Fetches the "scope" used throughout the app (wraps the user)
  def fetch_current_scope_for_user(conn, _opts) do
    conn = fetch_cookies(conn, signed: [@remember_me_cookie])
    {user_token, conn} = ensure_user_token(conn)

    if user_token do
      case Accounts.get_user_by_session_token(user_token) do
        {user, token_inserted_at} ->
          scope = Scope.for_user(user)

          # store token in session and mark remember_me when cookie present
          conn = put_token_in_session(conn, user_token)

          conn =
            if conn.cookies[@remember_me_cookie] || get_session(conn, :user_remember_me) do
              put_session(conn, :user_remember_me, true)
            else
              conn
            end

          # if remember_me is enabled and the token is older than 7 days, reissue
          conn =
            if get_session(conn, :user_remember_me) do
              age_seconds = DateTime.diff(DateTime.utc_now(), token_inserted_at, :second)

              if age_seconds > 7 * 24 * 60 * 60 do
                new_token = Accounts.generate_user_session_token(user)

                conn
                |> put_token_in_session(new_token)
                |> put_resp_cookie(@remember_me_cookie, new_token, @remember_me_options)
              else
                conn
              end
            else
              conn
            end

          assign(conn, :current_scope, scope)

        user when not is_nil(user) ->
          conn = put_token_in_session(conn, user_token)
          scope = Scope.for_user(user)
          assign(conn, :current_scope, scope)

        _ ->
          assign(conn, :current_scope, nil)
      end
    else
      assign(conn, :current_scope, nil)
    end
  end

  defp ensure_user_token(conn) do
    if token = get_session(conn, :user_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        {token, put_session(conn, :user_token, token)}
      else
        {nil, conn}
      end
    end
  end

  # =========================================================
  # LIVEVIEW AUTH
  # =========================================================

  def on_mount(:mount_current_scope, _params, session, socket) do
    {:cont, mount_current_scope(socket, session)}
  end

  def on_mount(:require_authenticated, _params, session, socket) do
    socket = mount_current_scope(socket, session)

    if socket.assigns.current_scope && socket.assigns.current_scope.user do
      {:cont, socket}
    else
      {:halt,
       socket
       |> Phoenix.LiveView.put_flash(:error, "Veuillez vous connecter pour accéder à cette page.")
       |> Phoenix.LiveView.redirect(to: ~p"/users/log-in")}
    end
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    socket = mount_current_scope(socket, session)

    if socket.assigns.current_scope && socket.assigns.current_scope.user do
      {:halt, Phoenix.LiveView.redirect(socket, to: signed_in_path(socket))}
    else
      {:cont, socket}
    end
  end

  def on_mount(:require_sudo_mode, _params, session, socket) do
    socket = mount_current_scope(socket, session)

    if socket.assigns.current_scope && socket.assigns.current_scope.user &&
         Accounts.sudo_mode?(socket.assigns.current_scope.user) do
      {:cont, socket}
    else
      {:halt,
       socket
       |> Phoenix.LiveView.put_flash(:error, "Action non autorisée. Veuillez vous reconnecter.")
       |> Phoenix.LiveView.redirect(to: ~p"/users/log-in")}
    end
  end

  defp mount_current_scope(socket, session) do
    Phoenix.Component.assign_new(socket, :current_scope, fn ->
      if user_token = session["user_token"] do
        Accounts.get_scope_by_token(user_token)
      end
    end)
  end

  # =========================================================
  # PROTECTION ROUTES
  # =========================================================

  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_scope] && conn.assigns.current_scope.user do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_scope] && conn.assigns.current_scope.user do
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

  # =========================================================
  # SESSION HELPERS
  # =========================================================

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
  end

  # =========================================================
  # DISCONNECT SESSIONS
  # =========================================================

  def disconnect_sessions(tokens) do
    Enum.each(tokens, fn t ->
      token = if is_map(t), do: Map.get(t, :token) || Map.get(t, "token"), else: t

      TagIpWeb.Endpoint.broadcast(
        "users_sessions:#{Base.url_encode64(token)}",
        "disconnect",
        %{}
      )
    end)
  end
end
