defmodule DemoWeb.Pages.AboutPage do
  @moduledoc """
  About page demonstrating pure markdown content with the new simplified system.
  """

  import DemoWeb.Helpers.ContentHelpers
  # use Phoenix.Component

  def page_metadata do
    %{
      title: "About FlyMapEx",
      description: "More about the FlyMapEx library and its capabilities.",
      nav_order: 1,
      keywords: "about, flymap, elixir, phoenix, documentation",
      slug: "about"
    }
  end

  def content(assigns) do
    ~s"""
    <%= convert_markdown("
    # About FlyMapEx

    FlyMapEx is a Phoenix LiveView library for displaying interactive world maps
    with Fly.io region markers. It provides components for visualizing node deployments
    across different regions with configurable styles, animations, and themes.

    ## Key Features

    - **Interactive World Maps**: SVG-based world map with precise region coordinates
    - **Region Markers**: Visual indicators for Fly.io regions with customizable styles
    - **Theming System**: Multiple predefined themes for different use cases
    - **Animation Support**: Configurable animations using CSS and SVG
    - **Responsive Design**: Works across different screen sizes and devices
    - **Multiple Themes**: Choose from dashboard, monitoring, presentation styles
    - **Real-time Updates**: LiveView integration for dynamic data
    - **Responsive Design**: Works on all screen sizes
    - **Easy Integration**: Simple component-based API

    ") %>
    <%= info_box(:primary, "Documentation",
      "Visit our GitHub repository for complete documentation and examples.") %>
      """
  end
end
