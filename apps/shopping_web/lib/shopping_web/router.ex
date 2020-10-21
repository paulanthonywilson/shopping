defmodule ShoppingWeb.Router do
  use ShoppingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ShoppingWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShoppingWeb do
    pipe_through :browser
    
    live "/checklists", ChecklistLive.Index, :index
    live "/checklists/new", ChecklistLive.Index, :new
    live "/checklists/:id/edit", ChecklistLive.Index, :edit

    live "/checklists/:id", ChecklistLive.Show, :show
    live "/checklists/:id/show/edit", ChecklistLive.Show, :edit

    get "/", RootController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShoppingWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ShoppingWeb.Telemetry
    end
  end
end
