defmodule FlyMapEx.Component do
  @moduledoc """
  Stateful LiveView component for FlyMapEx that manages its own selection state.

  This component provides a complete, self-contained world map with legend that
  handles group visibility toggling internally, eliminating the need for parent
  LiveViews to manage selection state and event handlers.

  ## Features

  - **Stateful management**: Automatically manages marker group visibility state
  - **Interactive legend**: Built-in legend with click-to-toggle functionality
  - **Theme support**: Integrates with FlyMapEx.Theme for consistent styling
  - **Flexible layouts**: Supports stacked and side-by-side layouts
  - **Event callbacks**: Optional callbacks for group toggle events
  - **Responsive design**: Adapts to different screen sizes

  ## Usage

  ### Basic Usage

  The simplest way to use the component is with just marker groups:

      <.live_component
        module={FlyMapEx.Component}
        id="world-map"
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
      />

  ### Advanced Configuration

      <.live_component
        module={FlyMapEx.Component}
        id="world-map"
        marker_groups={@marker_groups}
        theme={:dark}
        layout={:side_by_side}
        initially_visible={["production", "staging"]}
        show_regions={false}
        class="my-custom-class"
        on_toggle={true}
      />

  ## Attributes

  - `marker_groups` (required): List of marker groups to display
  - `theme`: Theme preset (`:light`, `:dark`, `:dashboard`, etc.) or custom theme map
  - `layout`: Layout mode (`:stacked` or `:side_by_side`)
  - `initially_visible`: Which groups to show initially (`:all`, `:none`, or list of labels)
  - `show_regions`: Whether to show all Fly.io regions
  - `class`: Additional CSS classes for the container
  - `on_toggle`: Whether to send group toggle events to parent

  ## Data Structure

  Marker groups should follow this structure:

      %{
        label: "Production Nodes",           # Display name
        group_label: "production",           # Optional: unique identifier for toggling
        nodes: ["sjc", "fra", "lhr"],       # List of Fly.io region codes
        style: :primary,                     # Style preset or custom style map
        machine_count: 15                    # Optional: explicit machine count
      }

  If `group_label` is not provided, it will be automatically generated from `label`.

  ## Event Handling

  When `on_toggle` is set to `true`, the component will send messages to the parent
  LiveView when users toggle marker groups:

      def handle_info({:group_toggled, group_label, visible?}, socket) do
        # Handle group toggle event
        # group_label: string identifier of the toggled group
        # visible?: boolean indicating if group is now visible
        {:noreply, socket}
      end

  ## Layout Modes

  ### Stacked Layout (Default)
  Map and legend are stacked vertically, suitable for most applications.

  ### Side-by-Side Layout
  Map and legend are placed side by side on larger screens, with responsive
  fallback to stacked layout on smaller screens.

  ## Theming

  The component integrates with FlyMapEx.Theme to provide consistent styling:

      # Use predefined themes
      theme: :dark
      theme: :dashboard
      theme: :monitoring

  ## State Management

  The component maintains its own state for:
  - Currently visible marker groups
  - Map theme configuration
  - Layout settings
  - Region visibility

  This eliminates the need for parent LiveViews to manage these concerns,
  making integration simpler and more maintainable.

  ## Performance Considerations

  - Marker groups are normalized once during update
  - Theme colours are cached in component state
  - Only visible groups are rendered on the map
  - Legend state is managed efficiently with minimal re-renders
  """

  use Phoenix.LiveComponent

  alias FlyMapEx.{Theme, Style, Nodes}
  alias FlyMapEx.Components.{WorldMap, LegendComponent}

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  @doc """
  Updates the component state when assigns change.

  This function is called whenever the parent LiveView updates the component's
  assigns. It handles:
  - Normalizing marker groups with style and node processing
  - Determining initial visibility based on `initially_visible` setting
  - Applying theme configuration
  - Setting up layout and region visibility options

  ## Parameters

  - `assigns`: Map of assigns from the parent LiveView
  - `socket`: Current component socket

  ## Returns

  `{:ok, updated_socket}`

  ## Key Assigns Processed

  - `marker_groups`: Normalized and processed for rendering
  - `initially_visible`: Determines which groups are visible on load
  - `theme`: Applied to create map theme configuration (atom or map)
  - `show_regions`: Controls Fly.io region visibility
  - `layout`: Sets the component layout mode
  - `on_toggle`: Configures event callback behaviour
  """
  def update(assigns, socket) do
    # Extract initially_visible groups or default to all
    initially_visible = Map.get(assigns, :initially_visible, :all)

    # Normalize marker groups
    normalized_groups = normalize_marker_groups(assigns.marker_groups || [])

    # Determine initial selected groups based on initially_visible
    selected_groups = determine_initial_selection(normalized_groups, initially_visible)

    # Use theme colours - theme can be atom or map
    map_theme = Theme.map_theme(assigns[:theme] || FlyMapEx.Config.default_theme())

    # Determine if regions should be shown
    show_regions =
      if is_nil(assigns[:show_regions]),
        do: FlyMapEx.Config.show_regions_default(),
        else: assigns.show_regions

    # Determine layout mode
    layout = assigns[:layout] || FlyMapEx.Config.layout_mode()

    socket =
      socket
      |> assign(:marker_groups, normalized_groups)
      |> assign(:selected_groups, selected_groups)
      |> assign(:map_theme, map_theme)
      |> assign(:show_regions, show_regions)
      |> assign(:class, assigns[:class] || "")
      |> assign(:layout, layout)
      |> assign(:on_toggle, assigns[:on_toggle])

    {:ok, socket}
  end

  @impl true
  @doc """
  Handles marker group toggle events from the legend.

  This function is called when users click on legend entries to toggle
  the visibility of marker groups. It updates the component's selection
  state and optionally sends a callback message to the parent LiveView.

  ## Parameters

  - `%{"group-label" => group_label}`: Event params containing the group identifier
  - `socket`: Current component socket

  ## Returns

  `{:noreply, updated_socket}`

  ## Behaviour

  - If the group is currently selected, it will be deselected
  - If the group is not selected, it will be selected
  - If `on_toggle` is configured, sends `{:group_toggled, group_label, visible?}` to parent
  """
  def handle_event("toggle_marker_group", %{"group-label" => group_label}, socket) do
    selected_groups = socket.assigns.selected_groups

    new_selected_groups =
      if group_label in selected_groups do
        List.delete(selected_groups, group_label)
      else
        [group_label | selected_groups]
      end

    socket = assign(socket, :selected_groups, new_selected_groups)

    # Call optional callback if provided
    if socket.assigns.on_toggle do
      send(self(), {:group_toggled, group_label, group_label in new_selected_groups})
    end

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    # Filter visible groups based on selected_groups
    visible_groups = filter_visible_groups(assigns.marker_groups, assigns.selected_groups)

    assigns = assign(assigns, :visible_groups, visible_groups)

    ~H"""
    <div class={@class}>
      <div class="card bg-base-100">
        <div class="card-body">
          <div class={layout_container_class(@layout)}>
            <div class={map_container_class(@layout)}>
              <div class="rounded-lg border overflow-hidden" style={"background-color: #{@map_theme.land}"}>
                <WorldMap.render
                  marker_groups={@visible_groups}
                  colours={@map_theme}
                  show_regions={@show_regions}
                />
              </div>
            </div>

            <div class={legend_container_class(@layout)}>
              <LegendComponent.legend
                marker_groups={@marker_groups}
                selected_groups={@selected_groups}
                region_marker_colour={WorldMap.get_region_marker_color(@map_theme)}
                marker_opacity={FlyMapEx.Config.marker_opacity()}
                show_regions={@show_regions}
                target={@myself}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Private functions moved from FlyMapEx module

  defp normalize_marker_groups(marker_groups) when is_list(marker_groups) do
    marker_groups
    |> Enum.with_index()
    |> Enum.map(fn {group, index} -> normalize_marker_group(group, index) end)
  end

  defp normalize_marker_group(%{style: style} = group, _index) when not is_nil(style) do
    # Normalize the style and process nodes
    normalized_style = Style.normalize(style)
    group = Map.put(group, :style, normalized_style)

    # Add group_label from label if not already present (for toggle functionality)
    group = add_group_label_if_needed(group)

    if Map.has_key?(group, :nodes) do
      Nodes.process_marker_group_legacy(group)
    else
      group
    end
  end

  defp normalize_marker_group(group, index) do
    # No style specified - automatically assign using Style.cycle/1
    cycled_style = Style.cycle(index)
    group = Map.put(group, :style, cycled_style)

    # Add group_label from label if not already present (for toggle functionality)
    group = add_group_label_if_needed(group)

    if Map.has_key?(group, :nodes) do
      Nodes.process_marker_group_legacy(group)
    else
      group
    end
  end

  defp determine_initial_selection(marker_groups, :all) do
    # Select all groups that have a group_label
    marker_groups
    |> Enum.filter(&Map.has_key?(&1, :group_label))
    |> Enum.map(& &1.group_label)
  end

  defp determine_initial_selection(_marker_groups, :none), do: []

  defp determine_initial_selection(_marker_groups, labels) when is_list(labels), do: labels

  defp filter_visible_groups(marker_groups, selected_groups) when is_list(selected_groups) do
    # Only show groups that are selected (have group_label in selected_groups)
    # If selected_groups is empty, no groups will be visible
    Enum.filter(marker_groups, fn group ->
      case Map.get(group, :group_label) do
        # Groups without group_label are always shown
        nil -> true
        group_label -> group_label in selected_groups
      end
    end)
  end

  defp filter_visible_groups(marker_groups, _), do: marker_groups

  # Helper function to add group_label from label if not already present
  defp add_group_label_if_needed(group) do
    if Map.has_key?(group, :group_label) do
      group
    else
      case Map.get(group, :label) do
        nil -> group
        label -> Map.put(group, :group_label, label)
      end
    end
  end

  # Layout helper functions
  defp layout_container_class(:side_by_side) do
    "flex flex-col lg:flex-row gap-4"
  end

  defp layout_container_class(_) do
    "space-y-4"
  end

  defp map_container_class(:side_by_side) do
    "lg:w-[65%] flex-shrink-0"
  end

  defp map_container_class(_) do
    ""
  end

  defp legend_container_class(:side_by_side) do
    "lg:w-[35%] flex-shrink-0"
  end

  defp legend_container_class(_) do
    ""
  end
end
