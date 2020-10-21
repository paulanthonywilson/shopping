# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :shopping,
  ecto_repos: [Shopping.Repo]

config :shopping_web,
  ecto_repos: [Shopping.Repo],
  generators: [context_app: :shopping]

# Configures the endpoint
config :shopping_web, ShoppingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nvGSFZN9Y+P/1xuvl50BlsUWb4x8nWNbcZrUrhbdlsX8i7jQAl5KsYTIDk6/FroD",
  render_errors: [view: ShoppingWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Shopping.PubSub,
  live_view: [signing_salt: "FG5UUb51"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
