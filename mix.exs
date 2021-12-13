defmodule Shopping.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      releases: releases()
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test]}
    ]
  end

  defp aliases do
    [
      # run `mix setup` in all child apps
      setup: ["cmd mix setup"]
    ]
  end

  defp releases do
    [
      shopping_main: [
        applications: [shopping: :permanent, shopping_web: :permanent],
        include_executables_for: [:unix]
      ]
    ]
  end
end
