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
    plug :fetch_current_scope_for_user
  end

  # =========================================================
  # ZONE SÉCURISÉE — TOUS UTILISATEURS AUTHENTIFIÉS
  # =========================================================

  scope "/", TagIpWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [
        {TagIpWeb.UserAuth, :mount_current_scope},
        {TagIpWeb.UserAuth, :require_authenticated}
      ] do
      # Dashboard
      live "/", DashboardLive.Index, :index
      live "/dashboard", DashboardLive.Index, :index

      # Settings
      live "/users/settings", UserLive.Settings, :edit

      live "/users/settings/confirm-email/:token",
           UserLive.Settings,
           :confirm_email

      # Profils de montage
      live "/profils", ProfilMontageLive.Index, :index
      live "/profils/new", ProfilMontageLive.Form, :new
      live "/profils/:id", ProfilMontageLive.Show, :show
      live "/profils/:id/edit", ProfilMontageLive.Form, :edit

      # Modèles de traceurs
      live "/modeles", ModeleTraceurLive.Index, :index
      live "/modeles/new", ModeleTraceurLive.Form, :new
      live "/modeles/:id", ModeleTraceurLive.Show, :show
      live "/modeles/:id/edit", ModeleTraceurLive.Form, :edit

      # Compatibilités
      live "/compatibilites", CompatibiliteLive.Index, :index
      live "/compatibilites/new", CompatibiliteLive.Index, :new
      live "/compatibilites/assistant", CompatibiliteLive.Assistant, :index
      live "/compatibilites/:id", CompatibiliteLive.Show, :show

      # Organisations
      live "/organisations", OrganisationLive.Index, :index
      live "/organisations/new", OrganisationLive.Form, :new
      live "/organisations/:id/edit", OrganisationLive.Form, :edit

      # Référentiels
      live "/referentiels", ReferenceLive.Index, :index
    end

    get "/export/profils.csv", ExportController, :profils
    get "/export/modeles.csv", ExportController, :modeles
    post "/users/update-password", UserSessionController, :update_password
  end

  # =========================================================
  # ZONE PUBLIQUE
  # =========================================================

  scope "/", TagIpWeb do
    pipe_through [:browser]

    live_session :redirect_if_authenticated,
      on_mount: [
        {TagIpWeb.UserAuth, :mount_current_scope},
        {TagIpWeb.UserAuth, :redirect_if_user_is_authenticated}
      ] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/reset_password", UserLive.ForgotPassword, :new

      live "/users/reset_password/:token",
           UserLive.ResetPassword,
           :edit
    end

    post "/users/log-in",
         UserSessionController,
         :create

    delete "/users/log-out",
           UserSessionController,
           :delete
  end
end
