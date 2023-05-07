defmodule ShoppingWeb.Router do
  use ShoppingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ShoppingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authorisation do
    plug Auth.CheckAuth
  end

  scope "/", ShoppingWeb do
    case Mix.env() do
      :test ->
        pipe_through :browser

      _ ->
        pipe_through [:browser, :authorisation]
    end

    live "/checklists", ChecklistLive.Index, :index
    live "/checklists/new", ChecklistLive.Index, :new
    live "/checklists/:id/edit", ChecklistLive.Index, :edit

    live "/checklists/:id", ChecklistLive.Show, :show

    live "/checklists/:id/items/:item_id", ChecklistLive.Show, :edit

    get "/", RootController, :home
  end

  scope "/", ShoppingWeb do
    pipe_through :browser

    get "/authorise", RootController, :authorise
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShoppingWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:shopping, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ShoppingWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
