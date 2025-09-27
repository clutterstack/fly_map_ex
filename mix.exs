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
      {:ex_doc, "~> 0.38", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end

  defp description do
    """
    A Phoenix LiveView library for displaying interactive world maps with Fly.io region markers.

    Provides Phoenix components and utilities for visualizing node deployments across Fly.io regions
    with different marker styles, animations, and legends.
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
      source_ref: "v#{@version}",
      extra_section: "GUIDES",
      extras: ["README.md"],
      # extras: [
      #   {"README.md", title: "Home"},
      #   "guides.gen.md"
      # ],
      source_url: @source_url,
      # groups_for_extras: [
      #   "Start here": [
      #     "documentation/intro.md",
      #     "documentation/features.md"
      #   ]
      # ]
    ]
  end
end
