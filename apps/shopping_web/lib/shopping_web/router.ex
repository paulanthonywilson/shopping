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
    live "/checklists/:id/show/edit", ChecklistLive.Show, :edit

    get "/", RootController, :index
  end

  scope "/", ShoppingWeb do
    pipe_through :browser

    get "/authorise", RootController, :authorise
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShoppingWeb do
  #   pipe_through :api
  # end

  import Phoenix.LiveDashboard.Router

  scope "/" do
    pipe_through [:browser, :authorisation]
    live_dashboard "/dashboard", metrics: ShoppingWeb.Telemetry
  end
end
