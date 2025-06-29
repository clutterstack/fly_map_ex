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

  ## Utilities

  - `FlyMapEx.Regions` - Region data and coordinate utilities
  - `FlyMapEx.Config` - Configuration, themes, and style helpers
  - `FlyMapEx.Adapters` - Data transformation helpers
  """

  use Phoenix.Component

  alias FlyMapEx.{Theme, Style, Nodes}
  alias FlyMapEx.Components.{WorldMap, LegendComponent}

  @doc """
  This is the main entry point for the library. It renders a card containing
  the world map and legend.

  ## Attributes

  * `marker_groups` - List of region/node group maps, each containing:
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
          style: [color: "#10b981", size: 8, animated: true],
          label: "Production Servers"
        },
        %{
          nodes: ["ams"],
          style: [color: "#ef4444", size: 10, animation: :bounce],
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
          style: FlyMapEx.Style.active(color: "#custom"),
          label: "Mixed Deployment"
        }
      ]} />

      # CSS variables for dynamic theming
      <div style="--primary: #ff6b6b;">
        <FlyMapEx.render marker_groups={[
          %{nodes: ["sjc"], style: [color: "var(--primary)", size: 8], label: "Dynamic"}
        ]} />
      </div>
  """
  attr(:marker_groups, :list, default: [])
  attr(:theme, :atom, default: :light)
  attr(:background, :map, default: nil)
  attr(:class, :string, default: "")
  attr(:selected_apps, :list, default: [])
  attr(:available_apps, :list, default: [])
  attr(:all_instances_data, :map, default: %{})
  attr(:show_regions, :boolean, default: nil)

  def render(assigns) do
    # Use custom background or theme background
    background = assigns.background || Theme.background(assigns.theme)

    # Normalize marker group styles
    normalized_groups = normalize_marker_groups(assigns.marker_groups)

    assigns =
      assigns
      |> assign(:background, background)
      |> assign(:marker_groups, normalized_groups)

    ~H"""
    <div class={@class}>
         <div class={"card bg-base-100"}>
      <div class="card-body">
        <div class="rounded-lg border overflow-hidden" style={"background-color: #{@background.land}"}>
          <WorldMap.render
            marker_groups={@marker_groups}
            colours={@background}
            show_regions={@show_regions}
          />
        </div>

        <LegendComponent.legend
          marker_groups={@marker_groups}
          selected_apps={@selected_apps}
          available_apps={@available_apps}
          all_instances_data={@all_instances_data}
          region_marker_colour={WorldMap.get_region_marker_color(@background)}
          marker_opacity={FlyMapEx.Config.marker_opacity()}
        />
      </div>
    </div>
    </div>
    """
  end

  # Private function to normalize marker groups and styles
  defp normalize_marker_groups(marker_groups) when is_list(marker_groups) do
    Enum.map(marker_groups, &normalize_marker_group/1)
  end

  defp normalize_marker_group(%{style: style} = group) when not is_nil(style) do
    # Normalize the style and process nodes
    normalized_style = Style.normalize(style)
    group = Map.put(group, :style, normalized_style)

    if Map.has_key?(group, :nodes) do
      Nodes.process_node_group(group)
    else
      group
    end
  end

  defp normalize_marker_group(group) do
    # No style specified - use default
    require Logger
    Logger.warning("Marker group missing style, using default: #{inspect(group)}")

    default_group = Map.put_new(group, :style, Style.normalize([]))

    if Map.has_key?(default_group, :nodes) do
      Nodes.process_node_group(default_group)
    else
      default_group
    end
  end
end
