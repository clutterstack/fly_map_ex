defmodule FlyMapEx do
  @moduledoc """
  A library for displaying a world map with markers at given latitudes and longitudes.

  Provides Phoenix components and utilities for visualizing node locations with different marker styles, animations, and legends.

  ## Assets

  Run the Mix task to copy FlyMapEx assets into your Phoenix project:

      mix fly_map_ex.install

  The task copies CSS and JS files to `assets/vendor/fly_map_ex/`. Import them in
  your bundler:

      /* assets/css/app.css */
      @import '../vendor/fly_map_ex/fly_map_ex.css';

      // assets/js/app.js
      import { createRealTimeMapHook } from '../vendor/fly_map_ex/real_time_map_hook.js'

      const Hooks = {
        RealTimeMap: createRealTimeMapHook(socket)
      }

  Available JavaScript helpers:

  - `real_time_map_hook.js` - Phoenix LiveView hook for real-time marker updates
  - `map_coordinates.js` - Coordinate transformation utilities (WGS84 ↔ SVG)
  - `map_markers.js` - Client-side marker rendering and manipulation utilities
  """

  use Phoenix.Component

  @doc """
  Renders a world map with markers and legend using Phoenix Component patterns.

  This is the main entry point for the library, providing a single function component
  with optional JS-based interactivity for legend toggles.

  You can specify a marker location by a `{lat, long}` coordinate tuple, a Fly.io region code, or a named region you've configured for your application.

  ## Attributes

  * `marker_groups` - List of marker group maps, each containing:
    * `regions` - List of region codes (`"sjc"`) or coordinate maps (`%{label: "Name", coordinates: {lat, lng}}`)
    * `style` - Style map or preset atom (e.g., `:operational`, `:warning`, `%{colour: "#10b981", size: 6}`)
    * `label` - Display label for this group
  * `theme` - Background theme name (e.g., :dark, :minimal, :cool) or custom theme map
  * `class` - Additional CSS classes for the container
  * `show_regions` - Whether to show region markers (default: nil, uses config default)
  * `interactive` - Whether legend should be interactive with JS toggles (default: true)
  * `initially_visible` - Which groups to show initially (`:all`, `:none`, or list of labels)
  * `layout` - Layout mode (`:stacked` or `:side_by_side`)
  * `on_toggle` - Whether to send events to parent LiveView when groups are toggled (default: false)
  * `real_time` - Enable real-time updates via Phoenix channels (default: false)
  * `channel` - Channel topic for real-time updates (e.g., "map:room_id")
  * `update_throttle` - Milliseconds between client updates for throttling (default: 100)

  ## Examples

      # Basic interactive map
      <FlyMapEx.render marker_groups={[
        %{
          nodes: ["sjc", "fra"],
          style: :operational,
          label: "Production Servers"
        },
        %{
          nodes: ["ams"],
          style: :warning,
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

      # Real-time map with Phoenix channels
      <FlyMapEx.render
        marker_groups={@groups}
        theme={:responsive}
        real_time={true}
        channel="map:room_123"
        update_throttle={50}
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
  attr(:real_time, :boolean, default: false)
  attr(:channel, :string, default: nil)
  attr(:update_throttle, :integer, default: 100)

  def render(assigns) do
    alias FlyMapEx.{Theme, Shared, JSON}
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

    # Real-time configuration
    real_time_enabled = !!assigns[:real_time]
    channel_topic = assigns[:channel] || "map:default"
    update_throttle = assigns[:update_throttle] || 100

    # Generate map ID for real-time targeting
    map_id = "fly-region-map-#{:erlang.unique_integer([:positive])}"

    assigns =
      assigns
      |> assign(:marker_groups, normalized_groups)
      |> assign(:selected_groups, selected_groups)
      |> assign(:visible_groups, visible_groups)
      |> assign(:map_theme, map_theme)
      |> assign(:show_regions, show_regions)
      |> assign(:layout, layout)
      |> assign(:interactive, !!assigns[:interactive])
      |> assign(:real_time_enabled, real_time_enabled)
      |> assign(:channel_topic, channel_topic)
      |> assign(:update_throttle, update_throttle)
      |> assign(:map_id, map_id)

    ~H"""
    <div class={["fly-map-container", @class]}>
      <div class="fly-map-body" {if @real_time_enabled, do: [
        id: "real-time-map-#{@map_id}",
        "phx-hook": "RealTimeMap",
        "data-channel": @channel_topic,
        "data-map-id": @map_id,
        "data-initial-state": JSON.encode!(%{
          marker_groups: Shared.convert_coordinates_for_json(@marker_groups),
          theme: @map_theme,
          config: %{
            bbox: %{minX: 0, minY: 0, maxX: 800, maxY: 391},
            update_throttle: @update_throttle
          }
        }),
        "data-progressive-enhancement": "true"
      ], else: []}>
        <div class={Shared.layout_container_class(@layout)}>
          <div class={Shared.map_container_class(@layout)}>
            <div class="fly-map-map-wrapper">
              <WorldMap.render
                marker_groups={@visible_groups}
                colours={@map_theme}
                show_regions={@show_regions}
                interactive={@interactive}
                id={@map_id}
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
    """
  end
end
