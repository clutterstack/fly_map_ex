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
  - Any number of custom marker groups
  - Built-in legends
  - Phoenix LiveView compatible
  - Responsive design

  ## Components

  - `FlyMapEx.render/1` - Complete map with card and legend.
  - `FlyMapEx.Components.WorldMap.render/1` - Just the SVG map

  ## Utilities

  - `FlyMapEx.Regions` - Region data and coordinate utilities
  - `FlyMapEx.Config` - Configuration, themes, and style helpers
  - `FlyMapEx.Adapters` - Data transformation helpers
  """

  use Phoenix.Component

  @doc """
  This is the main entry point for the library. It renders a card containing
  the world map and legend.

  ## Attributes

  * `marker_groups` - List of marker group maps, each containing:
    * `nodes` - List of nodes, each either a region code string or %{label: "", coordinates: {lat, long}}
    * `style` - Style definition (keyword list or map) or FlyMapEx.Style builder result
    * `label` - Display label for this group
  * `theme` - Background theme name (e.g., :dark, :minimal, :cool)
  * `background` - Custom background colors (overrides theme)
  * `class` - Additional CSS classes for the container
  * `show_regions` - Whether to show region markers (default: nil, uses config default)

  ## Examples

      # Inline style definitions
      <FlyMapEx.render marker_groups={[
        %{
          nodes: ["sjc", "fra"],
          style: [colour: "#10b981", size: 8],
          label: "Production Servers"
        },
        %{
          nodes: ["ams"],
          style: [colour: "#ef4444", size: 10, animation: :pulse],
          label: "Critical Issues"
        }
      ]} theme={:dark} />

      # Using style builder functions
      <FlyMapEx.render marker_groups={[
        %{
          nodes: ["sjc", "fra"],
          style: FlyMapEx.Style.success(),
          label: "Healthy Nodes"
        },
        %{
          nodes: ["ams"],
          style: FlyMapEx.Style.danger(size: 12),
          label: "Failed Nodes"
        }
      ]} theme={:minimal} />

      # Mix of region codes and coordinates
      <FlyMapEx.render marker_groups={[
        %{
          nodes: [
            %{label: "Custom Server", coordinates: {40.7128, -74.0060}},
            "fra"  # Mix with region codes
          ],
          style: FlyMapEx.Style.active(colour: "#custom"),
          label: "Mixed Deployment"
        }
      ]} />

      # CSS variables for dynamic theming
      <div style="--primary: #ff6b6b;">
        <FlyMapEx.render marker_groups={[
          %{nodes: ["sjc"], style: [colour: "var(--primary)", size: 8], label: "Dynamic"}
        ]} />
      </div>
  """
  # Legacy attributes for backward compatibility when used as function component
  attr(:marker_groups, :list, default: [])
  attr(:theme, :atom, default: :light)
  attr(:background, :map, default: nil)
  attr(:class, :string, default: "")
  attr(:initially_visible, :any, default: :all)
  attr(:available_apps, :list, default: [])
  attr(:all_instances_data, :map, default: %{})
  attr(:show_regions, :boolean, default: nil)
  attr(:layout, :atom, default: nil)

  def render(assigns) do
    # For backward compatibility, delegate to the new LiveView component
    # This allows existing code to continue working without changes
    ~H"""
    <.live_component
      module={FlyMapEx.Component}
      id={assigns[:id] || "fly-map-#{System.unique_integer([:positive])}"}
      marker_groups={@marker_groups}
      theme={@theme}
      background={@background}
      class={@class}
      initially_visible={@initially_visible}
      available_apps={@available_apps}
      all_instances_data={@all_instances_data}
      show_regions={@show_regions}
      layout={@layout}
    />
    """
  end

end
