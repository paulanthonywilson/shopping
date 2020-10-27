defmodule ShoppingWeb.RootController do
  @moduledoc """
  Just redirects to conversations
  """
  use ShoppingWeb, :controller

  alias Auth.CheckAuth
  alias Plug.{BasicAuth, Crypto}

  def index(conn, _params) do
    redirect(conn, to: "/checklists")
  end

  def authorise(conn, _params) do
    with {user, pass} <- BasicAuth.parse_basic_auth(conn),
         true <- check_username_password(user, pass) do
      CheckAuth.authorise(conn)
    else
      _ ->
        conn
        |> BasicAuth.request_basic_auth()
        |> halt()
    end
  end

  defp check_username_password(user, pass) do
    Crypto.secure_compare(user, auth_credential(:auth_user)) &&
      Crypto.secure_compare(pass, auth_credential(:auth_password))
  end

  defp auth_credential(key), do: Application.fetch_env!(:shopping_web, key)
end
