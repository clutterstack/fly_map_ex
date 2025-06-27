defmodule FlyMapEx do
  @moduledoc """
  A library for displaying a world map with markers at given
  latitudes and longitudes.

  Provides Phoenix components and utilities for visualizing node deployments
  across Fly.io regions with different marker styles, animations, and legends.

  ## Usage


  ## Features

  - Interactive SVG world map with Fly.io region coordinates
  - Flexible styling system with semantic style names
  - Any number of custom node groups
  - Built-in legends
  - Phoenix LiveView compatible
  - Responsive design

  ## Components

  - `FlyMapEx.render/1` - Complete map with card and legend.
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
  alias FlyMapEx.Nodes

  @doc """
  This is the main entry point for the library. It renders a card containing
  the world map and legend.

  ## Attributes

  * `marker_groups` - List of region/node group maps, each containing:
    * `regions` - List of region codes for this group (legacy, deprecated - use `nodes`)
    * `nodes` - List of nodes, each either a region code string or %{label: "", coordinates: {lat, long}}
    * `style_key` - Atom referencing a style (e.g., :success, :warning, :active)
    * `label` - Display label for this group
  * `theme` - Theme name (e.g., :modern, :dark)
  * `class` - Additional CSS classes for the container
  * `custom_styles` - Map of custom style overrides (optional)

  ## Examples

      # Easy usage with helper function
      marker_groups = FlyMapEx.Config.build_marker_groups([
        {"Running Servers", ["sjc", "fra"], :success},
        {"Stopped Servers", ["ams"], :inactive}
      ])
      <FlyMapEx.render marker_groups={marker_groups} theme={:modern} />

      # Manual marker groups (legacy format)
      <FlyMapEx.render marker_groups={[
        %{regions: ["sjc"], style_key: :success, label: "Production"},
        %{regions: ["fra", "ams"], style_key: :warning, label: "Staging"}
      ]} theme={:dark} />

      # New node format with coordinates
      <FlyMapEx.render marker_groups={[
        %{
          nodes: [
            %{label: "Production Server", coordinates: {40.7128, -74.0060}},
            %{label: "Backup Server", coordinates: {51.5074, -0.1278}}
          ],
          style_key: :success,
          label: "Production"
        },
        %{
          nodes: ["sjc", "fra"],  # Can still mix region codes
          style_key: :warning,
          label: "Staging"
        }
      ]} theme={:modern} />



      # With custom styling and app config themes
      <FlyMapEx.render
        marker_groups={[%{nodes: ["sjc"], style_key: :my_custom_theme, label: "Custom"}]}
        theme={:modern}
      />
  """
  attr :marker_groups, :list, default: []
  attr :theme, :atom, default: :light
  attr :class, :string, default: ""
  attr :custom_styles, :map, default: %{}

  def render(assigns) do
    # Apply theme configuration
    theme_config = Config.theme(assigns.theme)

    # Merge theme styles with custom overrides
    final_styles = Map.merge(theme_config.styles, assigns.custom_styles)

    # Normalize marker groups to support both legacy and new node formats
    normalized_groups = normalize_marker_groups(assigns.marker_groups)

    assigns = assigns
      |> assign(:marker_groups, normalized_groups)
      |> assign(:background, theme_config.background)
      |> assign(:styles, final_styles)

    ~H"""
    <div class={@class}>
      <WorldMapCard.render
        marker_groups={@marker_groups}
        background={@background}
        styles={@styles}
      />
    </div>
    """
  end

  # Private function to normalize marker groups for backward compatibility
  defp normalize_marker_groups(marker_groups) when is_list(marker_groups) do
    Enum.map(marker_groups, &normalize_region_group/1)
  end

  defp normalize_region_group(%{nodes: nodes} = group) when is_list(nodes) do
    # Already using new format
    Nodes.process_node_group(group)
  end

  defp normalize_region_group(%{regions: regions} = group) when is_list(regions) do
    # Legacy format - convert regions to nodes
    group
    |> Map.put(:nodes, regions)
    |> Map.delete(:regions)
    |> Nodes.process_node_group()
  end

  defp normalize_region_group(group) do
    # No nodes or regions specified - return as is
    group
  end
end
