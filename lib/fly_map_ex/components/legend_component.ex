defmodule FlyMapEx.Components.LegendComponent do
  @moduledoc """
  Interactive legend component for the FlyMapEx world map.

  The LegendComponent provides a visual legend that displays marker groups with their
  corresponding colours, labels, and region information. It supports interactive
  functionality to toggle marker group visibility on the map.

  ## Features

  - **Interactive toggling**: Click on legend entries to show/hide marker groups
  - **Region information**: Displays active regions and total machine counts
  - **Visual feedback**: Highlights selected groups with primary colour styling
  - **Responsive design**: Adapts to different screen sizes with hover effects
  - **Fly.io regions**: Optional display of all available Fly.io regions

  ## Usage

  The legend component is typically used alongside `FlyMapEx.Components.WorldMap`
  to provide an interactive control panel for map visualization.

      <.legend
        marker_groups={@marker_groups}
        selected_groups={@selected_groups}
        region_marker_colour="#94a3b8"
        marker_opacity={0.6}
        show_regions={true}
        target={@myself}
      />

  ## Data Structure

  The `marker_groups` attribute expects a list of maps with the following structure:

      %{
        label: "Production Nodes",
        group_label: "production",
        nodes: ["sjc", "fra", "lhr"],
        style: %{colour: "#3b82f6", size: 8, animation: true},
        machine_count: 15  # Optional, defaults to length of nodes
      }

  ## Interactive Behaviour

  When a user clicks on a legend entry:
  1. A `"toggle_marker_group"` event is sent to the specified target
  2. The `phx-value-group-label` contains the group identifier
  3. The parent component should handle this event to update `selected_groups`
  4. Visual feedback is provided through colour changes and checkmarks

  ## Styling

  The component uses Tailwind CSS classes and adapts to the current theme.
  Selected groups are highlighted with primary colours, while inactive
  groups maintain subtle hover effects.
  """

  use Phoenix.Component

  require Logger

  alias FlyMapEx.Regions
  alias FlyMapEx.Components.Marker

  attr(:marker_groups, :list,
    required: true,
    doc:
      "List of marker groups to display in the legend. Each group should contain :label, :nodes, :style, and optionally :group_label and :machine_count."
  )

  attr(:selected_groups, :list,
    default: [],
    doc: "List of currently selected group labels. These groups will be highlighted in the legend."
  )

  attr(:region_marker_colour, :string,
    required: true,
    doc: "Hex colour code for the Fly.io regions marker (e.g., '#94a3b8')."
  )

  attr(:marker_opacity, :float,
    required: true,
    doc: "Opacity value for region markers, between 0.0 and 1.0."
  )

  attr(:show_regions, :boolean,
    required: true,
    doc: "Whether to show the 'All Fly.io Regions' entry in the legend."
  )

  attr(:target, :any,
    default: nil,
    doc:
      "Phoenix LiveView target for handling toggle events. Usually set to @myself in a LiveComponent."
  )

  attr(:interactive, :boolean,
    default: true,
    doc: "Whether the legend should be interactive (clickable) or static display only."
  )

  @doc """
  Renders the interactive legend component.

  This function creates a legend that displays marker groups with their visual
  representation, labels, and region information. Users can click on legend
  entries to toggle the visibility of marker groups on the map.

  ## Examples

      # Basic legend with marker groups
      <.legend
        marker_groups={[
          %{
            label: "Production",
            group_label: "prod",
            nodes: ["sjc", "fra"],
            style: %{colour: "#3b82f6", size: 8, animation: true}
          }
        ]}
        selected_groups={["prod"]}
        region_marker_colour="#94a3b8"
        marker_opacity={0.6}
        show_regions={true}
        target={@myself}
      />

      # Legend without region markers
      <.legend
        marker_groups={@marker_groups}
        selected_groups={@selected_groups}
        region_marker_colour="#94a3b8"
        marker_opacity={0.6}
        show_regions={false}
        target={@myself}
      />

  ## Interactive Events

  The legend sends `"toggle_marker_group"` events when users click on entries.
  Handle these events in your LiveView or LiveComponent:

      def handle_event("toggle_marker_group", %{"group-label" => group_label}, socket) do
        selected_groups = toggle_group_selection(socket.assigns.selected_groups, group_label)
        {:noreply, assign(socket, :selected_groups, selected_groups)}
      end

  ## Styling

  The component automatically adapts to the current theme and provides:
  - Hover effects on legend entries
  - Primary colour highlighting for selected groups
  - Checkmark icons for active selections
  - Responsive spacing and typography
  """
  def legend(%{marker_groups: marker_groups} = assigns) do
    assigns = assign(assigns, :all_legend_entries, marker_groups)

    ~H"""
    <!-- Enhanced Legend -->
        <div class="text-xs text-base-content/70 space-y-1">
          <div class="flex items-center justify-between mb-1">
            <h3 class="text-sm font-medium text-base-content">
              <%= if @interactive, do: "Legend (click to toggle group visibility)", else: "Legend" %>
            </h3>
            <div class="text-xs text-base-content/50">
              <%= total_active_regions(@marker_groups) %>/<%= total_available_regions() %> active regions, <%= total_machine_count(@marker_groups) %> items
            </div>
          </div>

          <div
            :for={group <- @all_legend_entries}
            class={[
              "flex items-start space-x-2 p-1 rounded transition-all duration-200",
              if(@interactive, do: "cursor-pointer", else: ""),
              if(@interactive, do: "hover:bg-base-200/50 hover:shadow-sm", else: ""),
              if(Map.has_key?(group, :group_label) and group.group_label in @selected_groups,
                do: "bg-primary/10 border border-primary/20",
                else: if(@interactive, do: "hover:border-base-content/10 border border-transparent", else: "border border-transparent"))
            ]}
            phx-click={if @interactive and Map.has_key?(group, :group_label), do: "toggle_marker_group", else: nil}
            phx-target={if @interactive, do: @target, else: nil}
            phx-value-group-label={if @interactive and Map.has_key?(group, :group_label), do: group.group_label, else: nil}
          >
            <div class="flex-shrink-0 mt-0.5 p-0.5">
                <Marker.marker style={group.style} mode={:legend} />
            </div>
            <div class="flex-grow min-w-0">
              <div class={[
                "text-sm font-medium flex items-center",
                if(Map.has_key?(group, :group_label) and group.group_label in @selected_groups,
                  do: "text-primary",
                  else: "text-base-content")
              ]}>
                <span>{group.label}:</span>
                <span class="text-xs text-base-content/60 ml-2">
                     {format_nodes_display(group.nodes, "none")}
                </span>
                <%= if @interactive and Map.has_key?(group, :group_label) and group.group_label in @selected_groups do %>
                  <svg class="inline w-3 h-3 ml-1 text-primary" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                  </svg>
                <% end %>
              </div>
            </div>
          </div>

          <!-- All Fly.io regions -->
          <div :if= {@show_regions} class="flex items-start space-x-2 p-1 rounded hover:bg-base-200/50">
            <div class="flex-shrink-0 mt-0.5">
              <span
                class="inline-block w-2 h-2 rounded-full"
                style={"background-color: #{@region_marker_colour}; opacity: #{@marker_opacity};"}
              ></span>
            </div>
            <div class="flex-grow min-w-0">
              <div class="text-sm font-medium text-base-content/60">
                Fly.io Regions
              </div>
              <div class="text-xs text-base-content/50">
                <span>
                  (<%= total_available_regions() %> regions)
                </span>
              </div>
            </div>
          </div>
        </div>
    """
  end

  # Helper functions

  @doc false
  # Formats a list of nodes for display in the legend.
  # Converts node structures to human-readable names and joins them with commas.
  # Returns the empty_message if no displayable nodes are found.
  defp format_nodes_display(nodes, empty_message) do
    # Convert nodes to display names
    display_names =
      nodes
      |> Enum.map(&node_display_name/1)
      |> Enum.reject(&is_nil/1)

    if display_names != [] do
      "#{Enum.join(display_names, ", ")}"
    else
      empty_message
    end
  end

  defp node_display_name(%{label: label}) when is_binary(label), do: label

  defp node_display_name(region_code) when is_binary(region_code) do
    region_display_name(region_code)
  end

  defp node_display_name(_), do: nil

  defp region_display_name(region) do
    case Regions.name(region) do
      {:ok, name} -> name
      # Fall back to region code if no name found
      {:error, _} -> region
    end
  end

  @doc false
  # Calculates the total number of unique active regions across all marker groups.
  # Used to display the "X/Y active regions" counter in the legend header.
  defp total_active_regions(marker_groups) do
    marker_groups
    |> Enum.flat_map(fn group -> group.nodes end)
    |> Enum.uniq()
    |> length()
  end

  @doc false
  # Returns the total number of available Fly.io regions.
  # Used to display the "X/Y active regions" counter in the legend header.
  defp total_available_regions() do
    Regions.all()
    |> map_size()
  end

  @doc false
  # Calculates the total machine count across all marker groups.
  # Uses the explicit machine_count if provided, otherwise falls back to the number of nodes.
  defp total_machine_count(marker_groups) do
    marker_groups
    |> Enum.map(fn group ->
      Map.get(group, :machine_count, length(group.nodes))
    end)
    |> Enum.sum()
  end
end
