defmodule HapWeb.Router do
  use HapWeb, :router

  import HapWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HapWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:hap, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HapWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # ----------------------------------------------------------------------------------------------
  # API endpoints
  # ----------------------------------------------------------------------------------------------
  scope "/api", HapWeb.Api do
    pipe_through :api
    post "/events", Events, :create
  end

  # ----------------------------------------------------------------------------------------------
  # Authentication routes
  # ----------------------------------------------------------------------------------------------
  scope "/users", HapWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{HapWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/register", UserRegistrationLive, :new
      live "/log_in", UserLoginLive, :new
      live "/reset_password", UserForgotPasswordLive, :new
      live "/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/log_in", UserSessionController, :create
  end

  scope "/users", HapWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{HapWeb.UserAuth, :ensure_authenticated}] do
      live "/settings", UserSettingsLive, :edit
      live "/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/users", HapWeb do
    pipe_through [:browser]

    delete "/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{HapWeb.UserAuth, :mount_current_user}] do
      live "/confirm/:token", UserConfirmationLive, :edit
      live "/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  # ----------------------------------------------------------------------------------------------
  # The main application
  # ----------------------------------------------------------------------------------------------
  scope "/", HapWeb do
    pipe_through [:browser, :require_authenticated_user]
    get "/", PageController, :home
  end

  scope "/projects", HapWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :projects,
      on_mount: [{HapWeb.UserAuth, :ensure_authenticated}] do
      live "/", Projects.BrowseLive, :browse
      live "/:project_slug", Projects.ReadLive, :read
      live "/:project_slug/review", Projects.ReviewLive
    end
  end
end
