defmodule Auth.CheckAuth do
  @behaviour Plug

  alias Phoenix.Controller
  alias Plug.Conn

  @one_year_in_seconds 60 * 60 * 24 * 365

  @impl true
  def init(opts) do
    opts
  end

  @impl true
  def call(conn, _opts) do
    conn = Conn.fetch_cookies(conn, encrypted: ["authorised"])

    if conn.cookies["authorised"] do
      conn
    else
      %{request_path: path} = conn

      conn
      |> Conn.put_session(:original_path, path)
      |> Controller.redirect(to: "/authorise")
      |> Conn.halt()
    end
  end

  def authorise(conn) do
    original_path = Conn.get_session(conn, :original_path) || "/"

    conn
    |> Conn.put_session(:original_path, nil)
    |> Conn.put_resp_cookie("authorised", true, encrypt: true, max_age: @one_year_in_seconds)
    |> Controller.redirect(to: original_path)
  end
end
