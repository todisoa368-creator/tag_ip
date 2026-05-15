defmodule TagIpWeb.Router do
  use TagIpWeb, :router
  import TagIpWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TagIpWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  # --- ZONE SÉCURISÉE : L'utilisateur DOIT être connecté ---
  scope "/", TagIpWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated,
      on_mount: [
        {TagIpWeb.UserAuth, :mount_current_scope},
        {TagIpWeb.UserAuth, :ensure_authenticated}
      ] do
      # Dashboard
      live "/", DashboardLive.Index, :index
      live "/dashboard", DashboardLive.Index, :index

      # Gestion des Profils de Montage
      live "/profils", ProfilMontageLive.Index, :index
      live "/profils/new", ProfilMontageLive.Form, :new
      live "/profils/:id/edit", ProfilMontageLive.Form, :edit
      live "/profils/:id", ProfilMontageLive.Show, :show

      # Gestion des Modèles de Traceurs
      live "/modeles", ModeleTraceurLive.Index, :index
      live "/modeles/new", ModeleTraceurLive.Form, :new
      live "/modeles/:id/edit", ModeleTraceurLive.Form, :edit
      live "/modeles/:id", ModeleTraceurLive.Show, :show

      # Compatibilités
      live "/compatibilites", CompatibiliteLive.Index, :index
      live "/compatibilites/new", CompatibiliteLive.Index, :new
      live "/compatibilites/:id", CompatibiliteLive.Show, :show

      # Paramètres utilisateur
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  # --- ZONE PUBLIQUE : Pour entrer dans l'application ---
  scope "/", TagIpWeb do
    pipe_through [:browser]

    live_session :redirect_if_authenticated,
      on_mount: [
        {TagIpWeb.UserAuth, :mount_current_scope},
        {TagIpWeb.UserAuth, :redirect_if_user_is_authenticated}
      ] do
      live "/users/log-in", UserLive.Login, :new
      live "/users/register", UserLive.Registration, :new
      live "/users/reset_password", UserLive.ForgotPassword, :new
      live "/users/reset_password/:token", UserLive.ResetPassword, :edit
    end

    get "/users/log-in/:token", UserSessionController, :magic_link
    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
