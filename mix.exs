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
      extras: [
        "README.md",
        "documentation/guides/basic_usage.md",
        "documentation/guides/marker_styling.md",
        "documentation/guides/theming.md"
      ],
      groups_for_extras: [
        "Getting Started": ["README.md"],
        "Guides": [
          "documentation/guides/basic_usage.md",
          "documentation/guides/marker_styling.md",
          "documentation/guides/theming.md"
        ]
      ],
      source_url: @source_url,
      before_closing_head_tag: &docs_before_closing_head_tag/1,
      before_closing_body_tag: &docs_before_closing_body_tag/1
    ]
  end

  defp docs_before_closing_head_tag(:html) do
    """
    <style>
    /* Ensure code examples are properly styled */
    .content pre code {
      white-space: pre;
      word-wrap: normal;
    }
    </style>
    """
  end

  defp docs_before_closing_head_tag(_), do: ""

  defp docs_before_closing_body_tag(:html) do
    """
    <script>
    // Add copy buttons to code blocks
    document.addEventListener('DOMContentLoaded', function() {
      document.querySelectorAll('pre code').forEach(function(code) {
        const button = document.createElement('button');
        button.textContent = 'Copy';
        button.style.cssText = 'position:absolute;top:0.5rem;right:0.5rem;padding:0.25rem 0.5rem;font-size:0.75rem;';
        button.onclick = function() {
          navigator.clipboard.writeText(code.textContent);
          button.textContent = 'Copied!';
          setTimeout(() => button.textContent = 'Copy', 2000);
        };
        code.parentElement.style.position = 'relative';
        code.parentElement.appendChild(button);
      });
    });
    </script>
    """
  end

  defp docs_before_closing_body_tag(_), do: ""
end
