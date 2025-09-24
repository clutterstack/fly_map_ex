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
        interactive={true}
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
  alias Phoenix.LiveView.JS

  require Logger

  alias FlyMapEx.FlyRegions
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


  attr(:interactive, :boolean,
    default: true,
    doc: "Whether the legend should be interactive (clickable) or static display only."
  )

  attr(:on_toggle, :boolean,
    default: false,
    doc: "Whether to send toggle events to parent LiveView when using JS interactivity."
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
        interactive={true}
      />

      # Legend without region markers
      <.legend
        marker_groups={@marker_groups}
        selected_groups={@selected_groups}
        region_marker_colour="#94a3b8"
        marker_opacity={0.6}
        show_regions={false}
        interactive={true}
      />

  ## Interactive Events

  The legend uses client-side JavaScript for toggling marker groups, avoiding server round-trips.
  For integration with LiveView state, set `on_toggle={true}` to receive `"group_toggled"` events:

      def handle_event("group_toggled", %{"group_label" => group_label}, socket) do
        # Handle group toggle in your LiveView if needed
        {:noreply, socket}
      end

  ## Styling

  The component automatically adapts to the current theme and provides:
  - Hover effects on legend entries
  - Primary colour highlighting for selected groups
  - Checkmark icons for active selections
  - Responsive spacing and typography
  """
  def legend(%{marker_groups: marker_groups} = assigns) do
    # Ensure boolean values
    interactive = assigns[:interactive] != false
    on_toggle = assigns[:on_toggle] || false

    assigns =
      assigns
      |> assign(:all_legend_entries, marker_groups)
      |> assign(:interactive, interactive)
      |> assign(:on_toggle, on_toggle)

    ~H"""
    <!-- Enhanced Legend -->
    <div class="text-xs text-base-content/70 space-y-1">
      <div :for={group <- @all_legend_entries}>
        <%= if @interactive and Map.has_key?(group, :group_label) do %>
          <button
            class={[
              "flex items-start space-x-2 p-1 rounded transition-all duration-200 w-full text-left",
              "hover:bg-base-200/50 hover:shadow-sm",
              "focus:bg-base-200/70 focus:outline-none focus:ring-2 focus:ring-primary/50",
              "hover:border-base-content/10 border border-transparent"
            ]}
            aria-pressed="false"
            data-legend-group={String.replace(group.group_label, ~r/[^a-zA-Z0-9_-]/, "_")}
            phx-click={build_toggle_js_command(group.group_label, @on_toggle)}
          >
            <div class="flex-shrink-0 mt-0.5 p-0.5">
              <Marker.marker style={group.style} mode={:legend} />
            </div>
            <div class="flex-grow min-w-0">
              <div class="text-sm font-medium flex items-center text-base-content legend-text">
                <span>{group.label}:</span>
                <span class="text-xs text-base-content/60 ml-2">
                  {format_nodes_display(group.nodes, "none")}
                </span>
                <span class="sr-only legend-status">
                  <span class="group-visible-text">{group.label} group is visible. Press Enter or Space to hide.</span>
                  <span class="group-hidden-text hidden">{group.label} group is hidden. Press Enter or Space to show.</span>
                </span>
              </div>
            </div>
          </button>
        <% else %>
          <div class="flex items-start space-x-2 p-1 rounded transition-all duration-200 border border-transparent">
            <div class="flex-shrink-0 mt-0.5 p-0.5">
              <Marker.marker style={group.style} mode={:legend} />
            </div>
            <div class="flex-grow min-w-0">
              <div class="text-sm font-medium flex items-center text-base-content legend-text">
                <span>{group.label}:</span>
                <span class="text-xs text-base-content/60 ml-2">
                  {format_nodes_display(group.nodes, "none")}
                </span>
              </div>
            </div>
          </div>
        <% end %>
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
              (<%= FlyRegions.num_fly_regions %> regions)
            </span>
          </div>
        </div>
      </div>

      <div :if={@interactive && total_node_count(@marker_groups)!=0} class="flex items-center justify-between mb-1">
        (click to toggle group visibility)
        <div class="text-xs text-base-content/50">
          <%= total_node_count(@marker_groups) %> nodes
        </div>
      </div>
    </div>
    """
  end

  # Helper functions

  # Builds the JavaScript command for toggling marker group visibility.
  # This includes toggling CSS classes, updating ARIA attributes, and optionally sending events to the parent LiveView.
  defp build_toggle_js_command(group_label, on_toggle) do
    safe_group_label = String.replace(group_label, ~r/[^a-zA-Z0-9_-]/, "_")

    js_command =
      JS.toggle_class("group-hidden-#{safe_group_label}", to: "[data-group='#{safe_group_label}']")
      |> JS.toggle_class("legend-selected", to: "[data-legend-group='#{safe_group_label}']")
      |> JS.set_attribute({"aria-pressed", "true"}, to: "[data-legend-group='#{safe_group_label}'][aria-pressed='false']")
      |> JS.set_attribute({"aria-pressed", "false"}, to: "[data-legend-group='#{safe_group_label}'][aria-pressed='true']")
      |> JS.toggle_class("hidden", to: "[data-legend-group='#{safe_group_label}'] .group-visible-text")
      |> JS.toggle_class("hidden", to: "[data-legend-group='#{safe_group_label}'] .group-hidden-text")

    if on_toggle do
      # Send event to parent LiveView for integration
      js_command |> JS.push("group_toggled", value: %{group_label: group_label})
    else
      js_command
    end
  end

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
    case FlyRegions.name(region) do
      {:ok, name} -> name
      # Fall back to region code if no name found
      {:error, _} -> region
    end
  end

  # Calculates the total machine count across all marker groups.
  # Uses the explicit machine_count if provided, otherwise falls back to the number of nodes.
  defp total_node_count(marker_groups) do
    marker_groups
    |> Enum.map(fn group ->
      Map.get(group, :machine_count, length(group.nodes))
    end)
    |> Enum.sum()
  end
end
