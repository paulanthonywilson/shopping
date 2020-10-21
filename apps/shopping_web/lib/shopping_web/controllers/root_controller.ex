defmodule ShoppingWeb.RootController do
  @moduledoc """
  Just redirects to conversations
  """
  use ShoppingWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/checklists")
  end
end
