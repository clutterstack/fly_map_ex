defmodule FlyMapEx do
  @moduledoc """
  A library for displaying interactive world maps with Fly.io region markers.

  Provides Phoenix components and utilities for visualizing node deployments
  across Fly.io regions with different marker styles, animations, and legends.

  ## Usage

      # Basic usage with region lists
      <FlyMapEx.render
        our_regions={["sjc", "fra"]}
        expected_regions={["ams", "lhr"]}
        active_regions={["ord", "dfw"]}
        ack_regions={["sjc"]}
      />

      # With custom colors and progress tracking
      <FlyMapEx.render
        our_regions={["sjc"]}
        expected_regions={["ams", "lhr"]}
        ack_regions={["sjc"]}
        show_progress={true}
        colors={%{our_nodes: "#00ff00", expected_nodes: "#ff0000"}}
      />

  ## Features

  - Interactive SVG world map with Fly.io region coordinates
  - Multiple marker types with configurable colors and animations
  - Built-in legends and progress tracking
  - Phoenix LiveView compatible
  - Responsive design

  ## Components

  - `FlyMapEx.render/1` - Complete map with card, legend, and progress
  - `FlyMapEx.Components.WorldMap.render/1` - Just the SVG map
  - `FlyMapEx.Components.WorldMapCard.render/1` - Map with card wrapper

  ## Utilities

  - `FlyMapEx.Regions` - Region data and coordinate utilities
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
    * `style_key` - Atom referencing a style from group_styles config (e.g., :primary, :active)
    * `label` - Display label for this group (optional, falls back to style label)
  * `show_progress` - Whether to show acknowledgment progress bar (default: false)
  * `colors` - Map of color overrides (optional)
  * `class` - Additional CSS classes for the container
  * `legend_config` - Map with legend customization options
  * `group_styles` - Map of custom group styles (optional, uses theme defaults)

  ## Examples

      # Basic usage with region groups
      <FlyMapEx.render region_groups={[
        %{regions: ["sjc"], style_key: :primary, label: "Our Node"},
        %{regions: ["fra", "ams"], style_key: :active, label: "Active Regions"}
      ]} />

      # With progress tracking
      <FlyMapEx.render
        region_groups={[
          %{regions: ["sjc", "fra"], style_key: :expected},
          %{regions: ["sjc"], style_key: :acknowledged}
        ]}
        show_progress={true}
      />

      # With custom styling
      <FlyMapEx.render
        region_groups={[%{regions: ["sjc"], style_key: :primary}]}
        colors={%{primary: "#00ff00"}}
        class="my-custom-map"
      />
  """
  attr :region_groups, :list, default: []
  attr :show_progress, :boolean, default: false
  attr :colors, :map, default: %{}
  attr :dimensions, :map, default: %{}
  attr :class, :string, default: ""
  attr :legend_config, :map, default: %{}
  attr :group_styles, :map, default: %{}
  attr :theme, :atom, default: nil

  def render(assigns) do
    # Apply theme if specified
    assigns = if assigns.theme do
      theme_config = Config.theme(assigns.theme)

      # Merge theme with user overrides, preserving user settings
      assigns
      |> assign(:colors, Map.merge(theme_config.colors, assigns.colors))
      |> assign(:dimensions, Map.merge(theme_config.dimensions, assigns.dimensions))
      |> assign(:legend_config, Map.merge(theme_config.legend_config, assigns.legend_config))
      |> assign(:group_styles, Map.merge(theme_config.group_styles, assigns.group_styles))
    else
      assigns
    end

    ~H"""
    <div class={@class}>
      <WorldMapCard.render
        region_groups={@region_groups}
        show_progress={@show_progress}
        colors={@colors}
        dimensions={@dimensions}
        legend_config={@legend_config}
        group_styles={@group_styles}
      />
    </div>
    """
  end
end
