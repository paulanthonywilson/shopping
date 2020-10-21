defmodule Shopping.Repo do
  use Ecto.Repo,
    otp_app: :shopping,
    adapter: Ecto.Adapters.Postgres
end
