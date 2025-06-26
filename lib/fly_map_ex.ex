defmodule FlyMapEx do
  @moduledoc """
  A library for displaying interactive world maps with Fly.io region markers.

  Provides Phoenix components and utilities for visualizing node deployments
  across Fly.io regions with different marker styles, animations, and legends.

  ## Usage

      # Basic usage with region groups
      region_groups = FlyMapEx.Config.build_region_groups([
        {"Running Machines", ["sjc", "fra"], :success},
        {"Stopped Machines", ["ams", "lhr"], :inactive},
        {"Pending Restart", ["yyz"], :warning}
      ])
      
      <FlyMapEx.render
        region_groups={region_groups}
        theme={:modern}
      />

      # Manual region groups
      <FlyMapEx.render
        region_groups={[
          %{regions: ["sjc"], style_key: :success, label: "Production"},
          %{regions: ["fra"], style_key: :warning, label: "Staging"}
        ]}
        theme={:dark}
      />

  ## Features

  - Interactive SVG world map with Fly.io region coordinates
  - Flexible styling system with semantic style names
  - Any number of custom node groups
  - Built-in legends and progress tracking
  - Phoenix LiveView compatible
  - Responsive design

  ## Components

  - `FlyMapEx.render/1` - Complete map with card, legend, and progress
  - `FlyMapEx.Components.WorldMap.render/1` - Just the SVG map
  - `FlyMapEx.Components.WorldMapCard.render/1` - Map with card wrapper

  ## Utilities

  - `FlyMapEx.Regions` - Region data and coordinate utilities
  - `FlyMapEx.Config` - Configuration, themes, and style helpers
  - `FlyMapEx.Adapters` - Data transformation helpers
  """

  use Phoenix.Component

  alias FlyMapEx.Components.WorldMapCard
  alias FlyMapEx.Config

  @doc """
  Renders a complete world map with regions, legend, and optional progress tracking.

  This is the main entry point for the library. It renders a card containing
  the world map, legend, and optional progress tracking.

  ## Attributes

  * `region_groups` - List of region group maps, each containing:
    * `regions` - List of region codes for this group
    * `style_key` - Atom referencing a style (e.g., :success, :warning, :active)
    * `label` - Display label for this group
  * `theme` - Theme name (e.g., :modern, :dark, :compact)
  * `show_progress` - Whether to show acknowledgment progress bar (default: false)
  * `class` - Additional CSS classes for the container
  * `custom_styles` - Map of custom style overrides (optional)

  ## Examples

      # Easy usage with helper function
      region_groups = FlyMapEx.Config.build_region_groups([
        {"Running Servers", ["sjc", "fra"], :success},
        {"Stopped Servers", ["ams"], :inactive}
      ])
      <FlyMapEx.render region_groups={region_groups} theme={:modern} />

      # Manual region groups
      <FlyMapEx.render region_groups={[
        %{regions: ["sjc"], style_key: :success, label: "Production"},
        %{regions: ["fra", "ams"], style_key: :warning, label: "Staging"}
      ]} theme={:dark} />

      # With progress tracking
      <FlyMapEx.render
        region_groups={[
          %{regions: ["sjc", "fra"], style_key: :pending, label: "Deploying"},
          %{regions: ["sjc"], style_key: :success, label: "Deployed"}
        ]}
        show_progress={true}
        theme={:compact}
      />

      # With custom styling
      <FlyMapEx.render
        region_groups={[%{regions: ["sjc"], style_key: :primary, label: "Main"}]}
        custom_styles={%{primary: %{color: "#00ff00", animated: true}}}
        theme={:modern}
      />
  """
  attr :region_groups, :list, default: []
  attr :theme, :atom, default: :standard
  attr :show_progress, :boolean, default: false
  attr :class, :string, default: ""
  attr :custom_styles, :map, default: %{}

  def render(assigns) do
    # Apply theme configuration
    theme_config = Config.theme(assigns.theme)
    
    # Merge theme styles with custom overrides
    final_styles = Map.merge(theme_config.styles, assigns.custom_styles)
    
    assigns = assigns
      |> assign(:dimensions, theme_config.dimensions)
      |> assign(:background, theme_config.background)
      |> assign(:styles, final_styles)

    ~H"""
    <div class={@class}>
      <WorldMapCard.render
        region_groups={@region_groups}
        show_progress={@show_progress}
        dimensions={@dimensions}
        background={@background}
        styles={@styles}
      />
    </div>
    """
  end
end
