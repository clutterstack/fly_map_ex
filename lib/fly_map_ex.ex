defmodule FlyMapEx do
  @moduledoc """
  A library for displaying a world map with markers at given
  latitudes and longitudes.

  Provides Phoenix components and utilities for visualizing node deployments
  across Fly.io regions with different marker styles, animations, and legends.

  ## Usage

      # Basic interactive map
      <FlyMapEx.render marker_groups={[
        %{
          nodes: ["sjc", "fra"],
          style_key: :primary,
          label: "Production Servers"
        },
        %{
          nodes: ["ams"],
          style_key: :warning,
          label: "Critical Issues"
        }
      ]} theme={:dark} />

      # Static map (no interactivity)
      <FlyMapEx.render
        marker_groups={@groups}
        theme={:minimal}
        interactive={false}
      />

  ## Features

  - Interactive SVG world map with Fly.io region coordinates
  - Flexible styling system with semantic style names
  - Any number of custom marker groups
  - Built-in legends
  - Phoenix LiveView compatible
  - Responsive design

  ## Components

  - `FlyMapEx.render/1` - Main function component with optional interactivity.
  - `FlyMapEx.Components.WorldMap.render/1` - Just the SVG map

  ## Module Architecture

  ### Core Components
  - `FlyMapEx.render/1` - Main entry point function component with JS-based interactivity
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
  FlyMapEx.render/1 (main entry)
  ├── FlyMapEx.Shared (shared logic)
  ├── FlyMapEx.Theme (theme colours)
  ├── FlyMapEx.Components.WorldMap
  │   ├── FlyMapEx.WorldMapPaths (geography)
  │   ├── FlyMapEx.Components.Marker (markers)
  │   │   └── FlyMapEx.Components.GlowFilter (effects)
  │   ├── FlyMapEx.Regions (coordinates)
  │   └── FlyMapEx.Nodes (data processing)
  └── FlyMapEx.Components.LegendComponent
      ├── interactive: true/false (conditional JS behavior)
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

  ### Basic use (Interactive - Default)
  ```elixir
  <FlyMapEx.render
    marker_groups={@groups}
    theme={:dark}
    show_regions={true}
  />
  ```

  ### Static Usage (Non-Interactive)
  ```elixir
  <FlyMapEx.render
    marker_groups={@groups}
    theme={:dark}
    show_regions={true}
    interactive={false}
  />
  ```

  ### Advanced Interactive Usage
  ```elixir
  <FlyMapEx.render
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
  Renders a world map with markers and legend using Phoenix Component patterns.

  This is the main entry point for the library, providing a single function component
  with optional JS-based interactivity for legend toggles.

  ## Attributes

  * `marker_groups` - List of marker group maps, each containing:
    * `regions` - List of region codes (`"sjc"`) or coordinate maps (`%{label: "Name", coordinates: {lat, lng}}`)
    * `style_key` - Style key atom (`:primary`, `:active`, `:warning`, `:expected`, `:acknowledged`, `:secondary`, `:inactive`)
    * `label` - Display label for this group
  * `theme` - Background theme name (e.g., :dark, :minimal, :cool) or custom theme map
  * `class` - Additional CSS classes for the container
  * `show_regions` - Whether to show region markers (default: nil, uses config default)
  * `interactive` - Whether legend should be interactive with JS toggles (default: true)
  * `initially_visible` - Which groups to show initially (`:all`, `:none`, or list of labels)
  * `layout` - Layout mode (`:stacked` or `:side_by_side`)
  * `on_toggle` - Whether to send events to parent LiveView when groups are toggled (default: false)

  ## Examples

      # Basic interactive map
      <FlyMapEx.render marker_groups={[
        %{
          nodes: ["sjc", "fra"],
          style_key: :primary,
          label: "Production Servers"
        },
        %{
          nodes: ["ams"],
          style_key: :warning,
          label: "Critical Issues"
        }
      ]} theme={:dark} />

      # Static map (no interactivity)
      <FlyMapEx.render
        marker_groups={@groups}
        theme={:minimal}
        interactive={false}
      />

      # Interactive with parent integration
      <FlyMapEx.render
        marker_groups={@groups}
        theme={:dashboard}
        initially_visible={["production"]}
        on_toggle={true}
      />
  """
  # Attributes for function component
  attr(:marker_groups, :list, default: [])
  attr(:theme, :any, default: nil)
  attr(:class, :string, default: "")
  attr(:initially_visible, :any, default: :all)
  attr(:show_regions, :boolean, default: nil)
  attr(:layout, :atom, default: nil)
  attr(:interactive, :boolean, default: true)
  attr(:on_toggle, :boolean, default: false)

  def render(assigns) do
    alias FlyMapEx.{Theme, Shared}
    alias FlyMapEx.Components.{WorldMap, LegendComponent}

    # Extract initially_visible groups or default to all
    initially_visible = Map.get(assigns, :initially_visible, :all)

    # Normalize marker groups using shared logic
    normalized_groups = Shared.normalize_marker_groups(assigns.marker_groups || [])

    # Determine initial selected groups based on initially_visible
    selected_groups = Shared.determine_initial_selection(normalized_groups, initially_visible)

    # Use theme colours - theme can be atom or map
    map_theme = Theme.map_theme(assigns[:theme] || FlyMapEx.Config.default_theme())

    # Determine if regions should be shown
    show_regions = assigns.show_regions || FlyMapEx.Config.show_regions_default()
      # if is_nil(assigns[:show_regions]),
      #   do: FlyMapEx.Config.show_regions_default(),
      #   else: assigns.show_regions

    # Determine layout mode
    layout = assigns[:layout] || FlyMapEx.Config.layout_mode()

    # Filter visible groups based on selection (static for initial render)
    visible_groups = Shared.filter_visible_groups(normalized_groups, selected_groups)

    assigns =
      assigns
      |> assign(:marker_groups, normalized_groups)
      |> assign(:selected_groups, selected_groups)
      |> assign(:visible_groups, visible_groups)
      |> assign(:map_theme, map_theme)
      |> assign(:show_regions, show_regions)
      |> assign(:layout, layout)
      |> assign(:interactive, !!assigns[:interactive])

    ~H"""
    <div class={@class}>
      <div class="card bg-base-100">
        <div class="card-body">
          <div class={Shared.layout_container_class(@layout)}>
            <div class={Shared.map_container_class(@layout)}>
              <div class="rounded-lg border overflow-hidden" style={"background-color: #{@map_theme.land}"}>
                <WorldMap.render
                  marker_groups={@visible_groups}
                  colours={@map_theme}
                  show_regions={@show_regions}
                  interactive={@interactive}
                />
              </div>
            </div>

            <div class={Shared.legend_container_class(@layout)}>
              <LegendComponent.legend
                marker_groups={@marker_groups}
                selected_groups={@selected_groups}
                region_marker_colour={WorldMap.get_region_marker_color(@map_theme)}
                marker_opacity={FlyMapEx.Config.marker_opacity()}
                show_regions={@show_regions}
                interactive={@interactive}
                on_toggle={@on_toggle}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

end
