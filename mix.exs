defmodule FlyMapEx.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/clutterstack/fly_map_ex"

  def project do
    [
      app: :fly_map_ex,
      version: @version,
      elixir: "~> 1.18.3",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "FlyMapEx",
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 1.0.17"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A Phoenix LiveView library for displaying interactive world maps with Fly.io region markers.

    Provides Phoenix components and utilities for visualizing node deployments across Fly.io regions
    with different marker styles, animations, and legends. Perfect for monitoring distributed applications
    and deployment status visualization.
    """
  end

  defp package do
    [
      name: "fly_map_ex",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"
      },
      maintainers: ["Your Name"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
