defmodule FlyMapEx.Components.LegendComponent do
  @moduledoc """
  The legend to go with the WorldMap.
  """

  use Phoenix.Component

  require Logger

  alias FlyMapEx.Regions
  alias FlyMapEx.Components.Marker

  attr(:marker_groups, :list, required: true)
  attr(:selected_groups, :list, default: [])
  attr(:region_marker_colour, :string, required: true)
  attr(:marker_opacity, :float, required: true)
  attr(:show_regions, :boolean, required: true)
  attr(:target, :any, default: nil)

  def legend(%{marker_groups: marker_groups} = assigns) do
    assigns = assign(assigns, :all_legend_entries, marker_groups)

    ~H"""
    <!-- Enhanced Legend -->
        <div class="text-xs text-base-content/70 space-y-1">
          <div class="flex items-center justify-between mb-1">
            <h3 class="text-sm font-medium text-base-content">Legend (click to toggle group visibility)</h3>
            <div class="text-xs text-base-content/50">
              <%= total_active_regions(@marker_groups) %>/<%= total_available_regions() %> active regions, <%= total_machine_count(@marker_groups) %> items
            </div>
          </div>

          <div
            :for={group <- @all_legend_entries}
            class={[
              "flex items-start space-x-2 p-1 rounded cursor-pointer transition-all duration-200",
              "hover:bg-base-200/50 hover:shadow-sm",
              if(Map.has_key?(group, :group_label) and group.group_label in @selected_groups,
                do: "bg-primary/10 border border-primary/20",
                else: "hover:border-base-content/10 border border-transparent")
            ]}
            phx-click={if Map.has_key?(group, :group_label), do: "toggle_marker_group", else: nil}
            phx-target={@target}
            phx-value-group-label={if Map.has_key?(group, :group_label), do: group.group_label, else: nil}
          >
            <div class="flex-shrink-0 mt-0.5">
              <div class={[
                if(Map.has_key?(group, :group_label) and group.group_label in @selected_groups, do: "ring-2 ring-primary/30 rounded-full p-0.5")
              ]}>
                <Marker.marker style={group.style} mode={:legend} size_override={6} />
              </div>
            </div>
            <div class="flex-grow min-w-0">
              <div class={[
                "text-sm font-medium flex items-center",
                if(Map.has_key?(group, :group_label) and group.group_label in @selected_groups,
                  do: "text-primary",
                  else: "text-base-content")
              ]}>
                <span>{group.label}</span>
                <span class="text-xs text-base-content/60 ml-1">
                  • nodes: {format_nodes_display(group.nodes, "none")}
                </span>
                <%= if Map.has_key?(group, :group_label) and group.group_label in @selected_groups do %>
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
      {:error, _} -> region  # Fall back to region code if no name found
    end
  end

  defp total_active_regions(marker_groups) do
    marker_groups
    |> Enum.flat_map(fn group -> group.nodes end)
    |> Enum.uniq()
    |> length()
  end

  defp total_available_regions() do
    Regions.all()
    |> map_size()
  end

  defp total_machine_count(marker_groups) do
    marker_groups
    |> Enum.map(fn group ->
      Map.get(group, :machine_count, length(group.nodes))
    end)
    |> Enum.sum()
  end

end
