defmodule TagIpWeb.Router do
  use TagIpWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TagIpWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TagIpWeb do
    pipe_through :browser

    live "/", DashboardLive, :index
    live "/profils", ProfilMontageLive.Index, :index
    live "/profils/new", ProfilMontageLive.Form, :new
    live "/profils/:id/edit", ProfilMontageLive.Form, :edit
    live "/profils/:id", ProfilMontageLive.Show, :show

    live "/modeles", ModeleTraceurLive.Index, :index
    live "/modeles/new", ModeleTraceurLive.Form, :new
    live "/modeles/:id/edit", ModeleTraceurLive.Form, :edit
    live "/modeles/:id", ModeleTraceurLive.Show, :show

    live "/compatibilites", CompatibiliteLive.Index, :index
    live "/compatibilites/new", CompatibiliteLive.Form, :new
    live "/compatibilites/:id", CompatibiliteLive.Show, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", TagIpWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:tag_ip, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TagIpWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
