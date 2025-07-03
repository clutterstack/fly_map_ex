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

  ## Module Architecture

  ### Core Components
  - `FlyMapEx.render/1` - Main entry point with card layout
  - `FlyMapEx.Component` - Stateful LiveView component with interactive legend
  - `FlyMapEx.Components.WorldMap` - SVG world map rendering
  - `FlyMapEx.Components.LegendComponent` - Interactive legend with group toggling

  ### Supporting Components
  - `FlyMapEx.Components.Marker` - Reusable marker rendering (map + legend)
  - `FlyMapEx.Components.GlowFilter` - SVG glow effects for markers
  - `FlyMapEx.WorldMapPaths` - Static SVG path definitions for world geography

  ### Data and Configuration
  - `FlyMapEx.Regions` - Fly.io region coordinates and name mapping
  - `FlyMapEx.Nodes` - Node normalization and processing utilities
  - `FlyMapEx.Theme` - Predefined colour themes and styling
  - `FlyMapEx.Style` - Marker style definitions and helpers
  - `FlyMapEx.Config` - Application-wide configuration settings
  - `FlyMapEx.Adapters` - Data transformation utilities

  ## Component Relationships

  ```
  FlyMapEx.render/1 (main entry)
  ├── FlyMapEx.Theme (theme colours)
  ├── FlyMapEx.Components.WorldMap
  │   ├── FlyMapEx.WorldMapPaths (geography)
  │   ├── FlyMapEx.Components.Marker (markers)
  │   │   └── FlyMapEx.Components.GlowFilter (effects)
  │   ├── FlyMapEx.Regions (coordinates)
  │   └── FlyMapEx.Nodes (data processing)
  └── FlyMapEx.Components.LegendComponent
      ├── FlyMapEx.Components.Marker (indicators)
      └── FlyMapEx.Regions (region info)

  FlyMapEx.Component (stateful alternative)
  ├── [same as above]
  └── [includes state management for interactive toggling]
  ```

  ## Data Flow

  1. **Input Processing**: Raw marker groups → `FlyMapEx.Nodes` → normalized nodes
  2. **Style Application**: Style definitions → `FlyMapEx.Style` → resolved styles
  3. **Theme Resolution**: Theme names → `FlyMapEx.Theme` → colour schemes
  4. **Coordinate Transformation**: Region codes → `FlyMapEx.Regions` → lat/lng → SVG coordinates
  5. **Rendering**: Processed data → Components → SVG/HTML output

  ## Integration Patterns

  ### Basic Usage (Stateless)
  ```elixir
  <FlyMapEx.render
    marker_groups={@groups}
    theme={:dark}
    show_regions={true}
  />
  ```

  ### Advanced Usage (Stateful)
  ```elixir
  <.live_component
    module={FlyMapEx.Component}
    id="interactive-map"
    marker_groups={@groups}
    theme={:dashboard}
    initially_visible={["production"]}
    on_toggle={true}
  />
  ```

  ### Direct Component Usage
  ```elixir
  <FlyMapEx.Components.WorldMap.render
    marker_groups={processed_groups}
    colours={theme_colours}
    show_regions={false}
  />
  ```
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
