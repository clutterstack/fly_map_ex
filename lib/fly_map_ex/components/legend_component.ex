defmodule FlyMapEx.Components.LegendComponent do
  @moduledoc """
  The legend to go with the WorldMap.
  """

  use Phoenix.Component

  require Logger

  alias FlyMapEx.Regions

  attr(:marker_groups, :list, required: true)
  attr(:selected_groups, :list, default: [])
  attr(:available_apps, :list, default: [])
  attr(:all_instances_data, :map, default: %{})
  attr(:region_marker_colour, :string, required: true)
  attr(:marker_opacity, :float, required: true)
  attr(:show_regions, :boolean, required: true)
  attr(:target, :any, default: nil)

  def legend(%{marker_groups: marker_groups} = assigns) do
    # Create legend entries - use app-based logic if available_apps provided, otherwise use marker_groups directly
    all_legend_entries =
      if assigns.available_apps != [] do
        create_all_app_legend_entries(
          assigns.available_apps,
          assigns.all_instances_data,
          marker_groups
        )
      else
        # For generic usage, show the marker groups as-is
        marker_groups
      end

    assigns = assign(assigns, :all_legend_entries, all_legend_entries)

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
              <span
                class={[
                  "inline-block w-2 h-2 rounded-full",
                  if(Map.get(group.style, :animated, false), do: "animate-pulse"),
                  if(Map.has_key?(group, :group_label) and group.group_label in @selected_groups, do: "ring-2 ring-primary/30")
                ]}
                style={"background-color: #{Map.get(group.style, :colour, "#6b7280")};"}
              >
              </span>
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

  defp create_all_app_legend_entries(available_apps, all_instances_data, marker_groups) do
    # Create a map of group_label -> existing group for selected apps
    existing_groups =
      marker_groups
      |> Enum.filter(&Map.has_key?(&1, :group_label))
      |> Enum.into(%{}, fn group -> {group.group_label, group} end)

    # Create legend entries for all available apps
    available_apps
    |> Enum.map(fn app_name ->
      case Map.get(existing_groups, app_name) do
        nil ->
          # App is not selected, create a placeholder entry
          create_unselected_app_entry(app_name, all_instances_data)

        existing_group ->
          # App is selected, use the existing group
          existing_group
      end
    end)
  end

  defp create_unselected_app_entry(app_name, all_instances_data) do
    # Get machine data for this app
    case Map.get(all_instances_data, app_name) do
      {:ok, machines} ->
        nodes = machines |> Enum.map(fn {_id, region} -> region end) |> Enum.uniq()
        machine_count = length(machines)

        label =
          case machine_count do
            1 -> "#{app_name} (1 machine)"
            n -> "#{app_name} (#{n} machines)"
          end

        # Use a muted style for unselected apps
        %{
          nodes: nodes,
          # muted gray
          style: %{colour: "#94a3b8", size: 6, animated: false},
          label: label,
          group_label: app_name,
          machine_count: machine_count
        }

      _ ->
        # No machine data available
        %{
          nodes: [],
          # very light gray
          style: %{colour: "#e2e8f0", size: 4, animated: false},
          label: "#{app_name} (no machines)",
          group_label: app_name,
          machine_count: 0
        }
    end
  end
end
