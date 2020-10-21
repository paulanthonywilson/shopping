defmodule Shopping.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Shopping.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Shopping.PubSub}
      # Start a worker by calling: Shopping.Worker.start_link(arg)
      # {Shopping.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Shopping.Supervisor)
  end
end
