defmodule LocalvoreCredoChecks.Mixfile do
  use Mix.Project

  def project do
    [app: :localvore_credo_checks,
     version: "0.1.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:credo, "~> 0.7", only: [:dev, :test]},
      {:faker, "~> 0.6", only: [:dev, :test]}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]
end
