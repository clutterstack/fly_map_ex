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

  - `FlyMapEx.node_map/1` - Complete map with card and legend.
  - `FlyMapEx.Components.WorldMap.render/1` - Just the SVG map

  ## Module Architecture

  ### Core Components
  - `FlyMapEx.node_map/1` - Main entry point with card layout (supports interactive and static modes)
  - `FlyMapEx.Component` - Stateful LiveView component with interactive legend
  - `FlyMapEx.StaticComponent` - Stateless component for non-interactive rendering
  - `FlyMapEx.Components.WorldMap` - SVG world map rendering
  - `FlyMapEx.Components.LegendComponent` - Legend with optional interactivity

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
  FlyMapEx.node_map/1 (main entry)
  ├── interactive: true  → FlyMapEx.LiveComponent (LiveComponent)
  ├── interactive: false → FlyMapEx.StaticComponent (Component)
  └── Both use:
      ├── FlyMapEx.Shared (shared logic)
      ├── FlyMapEx.Theme (theme colours)
      ├── FlyMapEx.Components.WorldMap
      │   ├── FlyMapEx.WorldMapPaths (geography)
      │   ├── FlyMapEx.Components.Marker (markers)
      │   │   └── FlyMapEx.Components.GlowFilter (effects)
      │   ├── FlyMapEx.Regions (coordinates)
      │   └── FlyMapEx.Nodes (data processing)
      └── FlyMapEx.Components.LegendComponent
          ├── interactive: true/false (conditional behavior)
          ├── FlyMapEx.Components.Marker (indicators)
          └── FlyMapEx.Regions (region info)
  ```

  ## Data Flow

  1. **Input Processing**: Raw marker groups → `FlyMapEx.Nodes` → normalized nodes
  2. **Style Application**: Style definitions → `FlyMapEx.Style` → resolved styles
  3. **Theme Resolution**: Theme names → `FlyMapEx.Theme` → colour schemes
  4. **Coordinate Transformation**: Region codes → `FlyMapEx.Regions` → lat/lng → SVG coordinates
  5. **Rendering**: Processed data → Components → SVG/HTML output

  ## Integration Patterns

  ### Basic Usage (Interactive - Default)
  ```elixir
  <FlyMapEx.node_map
    marker_groups={@groups}
    theme={:dark}
    show_regions={true}
  />
  ```

  ### Static Usage (Non-Interactive)
  ```elixir
  <FlyMapEx.node_map
    marker_groups={@groups}
    theme={:dark}
    show_regions={true}
    interactive={false}
  />
  ```

  ### Advanced Interactive Usage (Direct LiveComponent)
  ```elixir
  <.live_component
    module={FlyMapEx.LiveComponent}
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
    * `nodes` - List of nodes in one of four formats:
      * Region string: `"sjc"` (auto-label from region name)
      * Coordinate tuple: `{lat, lng}` (auto-label from coordinates)
      * Custom region label: `%{label: "Name", region: "sjc"}` (custom label with region lookup)
      * Custom coordinates: `%{label: "Name", coordinates: {lat, lng}}` (full control)
    * `style` - Style definition: direct map (%{colour: "#abc", size: 8}) or preset atom (:operational)
    * `label` - Display label for this group
  * `theme` - Background theme name (e.g., :dark, :minimal, :cool) or custom theme map
  * `class` - Additional CSS classes for the container
  * `show_regions` - Whether to show region markers (default: nil, uses config default)
  * `interactive` - Whether the component should be interactive (default: true)
    * `true` - Uses LiveComponent with toggleable legend
    * `false` - Uses static Component for better performance

  ## Examples

      # Direct style maps (primary interface)
      <FlyMapEx.node_map marker_groups={[
        %{
          nodes: ["sjc", "fra"],
          style: %{colour: "#10b981", size: 8},
          label: "Production Servers"
        },
        %{
          nodes: ["ams"],
          style: %{colour: "#ef4444", size: 10, animation: :pulse},
          label: "Critical Issues"
        }
      ]} theme={:dark} />

      # Using semantic presets
      <FlyMapEx.node_map marker_groups={[
        %{
          nodes: ["sjc", "fra"],
          style: :operational,
          label: "Healthy Nodes"
        },
        %{
          nodes: ["ams"],
          style: %{colour: "#ef4444", size: 12, animation: :pulse},
          label: "Failed Nodes"
        }
      ]} theme={:minimal} />

      # Mix of all node formats
      <FlyMapEx.node_map marker_groups={[
        %{
          nodes: [
            "sjc",                                           # Region string
            {40.7128, -74.0060},                            # Coordinate tuple
            %{label: "London Office", region: "lhr"},       # Custom region label
            %{label: "Custom Server", coordinates: {52.0, 13.0}}  # Custom coordinates
          ],
          style: %{colour: "#custom", size: 8},
          label: "Mixed Deployment"
        }
      ]} />

      # CSS variables for dynamic theming
      <div style="--primary: #ff6b6b;">
        <FlyMapEx.node_map marker_groups={[
          %{nodes: ["sjc"], style: %{colour: "var(--primary)", size: 8}, label: "Dynamic"}
        ]} />
      </div>
  """
  # Attributes for function component
  attr(:marker_groups, :list, default: [])
  attr(:theme, :any, default: nil)
  attr(:class, :string, default: "")
  attr(:initially_visible, :any, default: :all)
  attr(:available_apps, :list, default: [])
  attr(:all_instances_data, :map, default: %{})
  attr(:show_regions, :boolean, default: false)
  attr(:layout, :atom, default: nil)
  attr(:interactive, :boolean, default: true)

  def node_map(assigns) do
    # Choose between interactive and static components based on interactive attribute
    if assigns.interactive do
      ~H"""
      <.live_component
        module={FlyMapEx.LiveComponent}
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
    else
      ~H"""
      <FlyMapEx.StaticComponent.render
        marker_groups={@marker_groups}
        theme={@theme}
        class={@class}
        initially_visible={@initially_visible}
        show_regions={@show_regions}
        layout={@layout}
      />
      """
    end
  end
end
