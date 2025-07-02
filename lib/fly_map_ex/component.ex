defmodule FlyMapEx.Component do
  @moduledoc """
  Stateful LiveView component for FlyMapEx that manages its own selection state.
  
  This component handles group visibility toggling internally, eliminating the need
  for parent LiveViews to manage selection state and event handlers.
  """
  
  use Phoenix.LiveComponent
  
  alias FlyMapEx.{Theme, Style, Nodes}
  alias FlyMapEx.Components.{WorldMap, LegendComponent}
  
  @impl true
  def mount(socket) do
    {:ok, socket}
  end
  
  @impl true
  def update(assigns, socket) do
    # Extract initially_visible groups or default to all
    initially_visible = Map.get(assigns, :initially_visible, :all)
    
    # Normalize marker groups
    normalized_groups = normalize_marker_groups(assigns.marker_groups || [])
    
    # Determine initial selected groups based on initially_visible
    selected_groups = determine_initial_selection(normalized_groups, initially_visible)
    
    # Use custom background or theme background
    background = assigns[:background] || Theme.background(assigns[:theme] || :light)
    
    # Determine if regions should be shown
    show_regions = if is_nil(assigns[:show_regions]), do: FlyMapEx.Config.show_regions_default(), else: assigns.show_regions
    
    # Determine layout mode
    layout = assigns[:layout] || FlyMapEx.Config.layout_mode()
    
    socket =
      socket
      |> assign(:marker_groups, normalized_groups)
      |> assign(:selected_groups, selected_groups)
      |> assign(:background, background)
      |> assign(:show_regions, show_regions)
      |> assign(:class, assigns[:class] || "")
      |> assign(:layout, layout)
      |> assign(:on_toggle, assigns[:on_toggle])
    
    {:ok, socket}
  end
  
  @impl true
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
              <div class="rounded-lg border overflow-hidden" style={"background-color: #{@background.land}"}>
                <WorldMap.render
                  marker_groups={@visible_groups}
                  colours={@background}
                  show_regions={@show_regions}
                />
              </div>
            </div>
            
            <div class={legend_container_class(@layout)}>
              <LegendComponent.legend
                marker_groups={@marker_groups}
                selected_groups={@selected_groups}
                region_marker_colour={WorldMap.get_region_marker_color(@background)}
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
    Enum.map(marker_groups, &normalize_marker_group/1)
  end

  defp normalize_marker_group(%{style: style} = group) when not is_nil(style) do
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

  defp normalize_marker_group(group) do
    # No style specified - use default
    require Logger
    Logger.warning("Marker group missing style, using default: #{inspect(group)}")

    default_group = Map.put_new(group, :style, Style.normalize([]))
    
    # Add group_label from label if not already present (for toggle functionality)
    default_group = add_group_label_if_needed(default_group)

    if Map.has_key?(default_group, :nodes) do
      Nodes.process_marker_group_legacy(default_group)
    else
      default_group
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
        nil -> true  # Groups without group_label are always shown
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