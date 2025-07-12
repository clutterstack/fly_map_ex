defmodule FlyMapEx.StaticComponent do
  @moduledoc """
  Static (non-interactive) component for FlyMapEx world map rendering.

  This component provides a stateless world map with legend that displays
  all marker groups without interactive toggling. It's designed for use cases
  where interactivity is not needed, providing better performance and simpler
  mental model compared to the LiveComponent version.

  ## Features

  - **Stateless rendering**: No state management or event handling overhead
  - **Performance optimized**: Uses Phoenix.Component instead of LiveComponent
  - **Static legend**: Shows all groups without toggle functionality
  - **Theme support**: Full theme integration like the interactive version
  - **Flexible layouts**: Supports stacked and side-by-side layouts
  - **Responsive design**: Adapts to different screen sizes

  ## Usage

  This component accepts the same attributes as FlyMapEx.Component but renders
  everything as static content:

      <FlyMapEx.StaticComponent.render
        marker_groups={[
          %{
            label: "Production",
            nodes: ["sjc", "fra", "lhr"],
            style: :primary
          },
          %{
            label: "Development", 
            nodes: ["ams", "nrt"],
            style: :secondary
          }
        ]}
        theme={:dark}
        layout={:side_by_side}
        show_regions={false}
        class="my-custom-class"
      />

  ## Attributes

  - `marker_groups` (required): List of marker groups to display
  - `theme`: Theme preset or custom theme map
  - `layout`: Layout mode (`:stacked` or `:side_by_side`)
  - `initially_visible`: Which groups to show (`:all`, `:none`, or list of labels)
  - `show_regions`: Whether to show all Fly.io regions
  - `class`: Additional CSS classes for the container

  ## Data Structure

  Marker groups follow the same structure as the interactive component:

      %{
        label: "Production Nodes",           # Display name
        group_label: "production",           # Optional: unique identifier
        nodes: ["sjc", "fra", "lhr"],       # List of Fly.io region codes
        style: :primary,                     # Style preset or custom style map
        machine_count: 15                    # Optional: explicit machine count
      }

  ## Performance Benefits

  - No LiveComponent process overhead
  - No state management or event handling
  - Faster initial rendering
  - Lower memory usage
  - Simpler component lifecycle

  ## When to Use

  Choose StaticComponent when:
  - Legend interactivity is not needed
  - Performance is critical
  - Component is used in non-LiveView contexts
  - Simpler mental model is preferred

  Choose the interactive Component when:
  - Users need to toggle marker groups
  - Dynamic filtering is required
  - Event callbacks are needed
  """

  use Phoenix.Component

  alias FlyMapEx.{Theme, Shared}
  alias FlyMapEx.Components.{WorldMap, LegendComponent}

  @doc """
  Renders the static world map component.

  This function creates a complete world map with legend using the same
  visual styling as the interactive version, but without any state management
  or event handling.

  ## Attributes

  All attributes are the same as FlyMapEx.Component except for interactive
  behavior which is not applicable.

  ## Examples

      # Basic static map
      <.render
        marker_groups={@marker_groups}
        theme={:dashboard}
      />

      # Themed static map with custom layout
      <.render
        marker_groups={@marker_groups}
        theme={:dark}
        layout={:side_by_side}
        initially_visible={["production", "staging"]}
        show_regions={true}
        class="my-custom-map"
      />

  ## Processing

  The component processes marker groups using the same logic as the interactive
  version, ensuring consistent behavior and styling between both implementations.
  """
  attr(:marker_groups, :list, required: true)
  attr(:theme, :any, default: nil)
  attr(:layout, :atom, default: nil)
  attr(:initially_visible, :any, default: :all)
  attr(:show_regions, :boolean, default: nil)
  attr(:class, :string, default: "")

  def render(assigns) do
    # Extract initially_visible groups or default to all
    initially_visible = Map.get(assigns, :initially_visible, :all)

    # Normalize marker groups using shared logic
    normalized_groups = Shared.normalize_marker_groups(assigns.marker_groups || [])

    # Determine initial selected groups based on initially_visible
    selected_groups = Shared.determine_initial_selection(normalized_groups, initially_visible)

    # Use theme colours - theme can be atom or map
    map_theme = Theme.map_theme(assigns[:theme] || FlyMapEx.Config.default_theme())

    # Determine if regions should be shown
    show_regions =
      if is_nil(assigns[:show_regions]),
        do: FlyMapEx.Config.show_regions_default(),
        else: assigns.show_regions

    # Determine layout mode
    layout = assigns[:layout] || FlyMapEx.Config.layout_mode()

    # Filter visible groups based on static selection
    visible_groups = Shared.filter_visible_groups(normalized_groups, selected_groups)

    assigns =
      assigns
      |> assign(:marker_groups, normalized_groups)
      |> assign(:selected_groups, selected_groups)
      |> assign(:visible_groups, visible_groups)
      |> assign(:map_theme, map_theme)
      |> assign(:show_regions, show_regions)
      |> assign(:layout, layout)

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
                interactive={false}
                target={nil}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end