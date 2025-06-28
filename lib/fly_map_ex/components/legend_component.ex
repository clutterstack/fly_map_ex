defmodule FlyMapEx.Components.LegendComponent do
  @moduledoc """
  The legend to go with the WorldMap.
  """

  use Phoenix.Component

  require Logger

  alias FlyMapEx.Components.{WorldMap, WorldMapCard}
  alias FlyMapEx.Regions

  attr(:processed_groups, :list, required: true)
  attr(:selected_apps, :list, default: [])
  attr(:available_apps, :list, default: [])
  attr(:all_instances_data, :map, default: %{})

  def legend(%{processed_groups: processed_groups} = assigns) do
    # Create legend entries for all available apps
    all_legend_entries = create_all_app_legend_entries(assigns.available_apps, assigns.all_instances_data, processed_groups)
    
    assigns = assign(assigns, :all_legend_entries, all_legend_entries)
    ~H"""
    <!-- Enhanced Legend -->
        <div class="text-sm text-base-content/70 space-y-3">
          <div class="flex items-center justify-between mb-2">
            <h3 class="font-semibold text-base-content">Legend</h3>
            <div class="text-xs text-base-content/50">
              <%= total_active_regions(@processed_groups) %>/<%= total_available_regions() %> active regions, <%= total_machine_count(@processed_groups) %> items
            </div>
          </div>

          <div 
            :for={group <- @all_legend_entries} 
            class={[
              "flex items-start space-x-3 p-2 rounded-lg cursor-pointer transition-all duration-200",
              "hover:bg-base-200/50 hover:shadow-sm",
              if(Map.has_key?(group, :app_name) and group.app_name in @selected_apps, 
                do: "bg-primary/10 border border-primary/20", 
                else: "hover:border-base-content/10 border border-transparent")
            ]}
            phx-click={if Map.has_key?(group, :app_name), do: "toggle_marker_group", else: nil}
            phx-value-app={if Map.has_key?(group, :app_name), do: group.app_name, else: nil}
          >
            <div class="flex-shrink-0 mt-1">
              <span
                class={[
                  "inline-block w-3 h-3 rounded-full",
                  if(group.style.animated, do: "animate-pulse"),
                  if(Map.has_key?(group, :app_name) and group.app_name in @selected_apps, do: "ring-2 ring-primary/30")
                ]}
                style={"background-color: #{group.style.color};"}
              >
              </span>
            </div>
            <div class="flex-grow min-w-0">
              <div class={[
                "font-medium",
                if(Map.has_key?(group, :app_name) and group.app_name in @selected_apps, 
                  do: "text-primary", 
                  else: "text-base-content")
              ]}>
                {group.label}
                <%= if Map.has_key?(group, :app_name) and group.app_name in @selected_apps do %>
                  <svg class="inline w-4 h-4 ml-1 text-primary" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                  </svg>
                <% end %>
              </div>
              <div class="text-xs text-base-content/60 mt-1">
                <div class="flex items-center space-x-4">
                  <span>
                    Nodes: {WorldMapCard.format_nodes_display(group.nodes, "none")}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Available regions with or without Machines -->
          <div class="flex items-start space-x-3 p-2 rounded-lg hover:bg-base-200/50 opacity-75">
            <div class="flex-shrink-0 mt-1">
              <span class="inline-block w-2 h-2 rounded-full bg-gray-400 opacity-30"></span>
            </div>
            <div class="flex-grow min-w-0">
              <div class="font-medium text-base-content/60">
                Available Regions
              </div>
              <div class="text-xs text-base-content/50 mt-1">
                <span>
                  Fly.io regions  (<%= total_available_regions() %> regions)
                </span>
              </div>
            </div>
          </div>
        </div>
    """

  end

  # Helper functions


  defp total_active_regions(processed_groups) do
    processed_groups
    |> Enum.flat_map(fn group -> group.nodes end)
    |> Enum.uniq()
    |> length()
  end

  defp total_available_regions() do
    Regions.all()
    |> map_size()
  end

  defp total_machine_count(processed_groups) do
    processed_groups
    |> Enum.map(fn group ->
      Map.get(group, :machine_count, length(group.nodes))
    end)
    |> Enum.sum()
  end

  defp create_all_app_legend_entries(available_apps, all_instances_data, processed_groups) do
    # Create a map of app_name -> existing group for selected apps
    existing_groups = 
      processed_groups
      |> Enum.filter(& Map.has_key?(&1, :app_name))
      |> Enum.into(%{}, fn group -> {group.app_name, group} end)

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
        
        label = case machine_count do
          1 -> "#{app_name} (1 machine)"
          n -> "#{app_name} (#{n} machines)"
        end

        # Use a muted style for unselected apps
        %{
          nodes: nodes,
          style: %{color: "#94a3b8", size: 6, animated: false}, # muted gray
          label: label,
          app_name: app_name,
          machine_count: machine_count
        }
      
      _ ->
        # No machine data available
        %{
          nodes: [],
          style: %{color: "#e2e8f0", size: 4, animated: false}, # very light gray
          label: "#{app_name} (no machines)",
          app_name: app_name,
          machine_count: 0
        }
    end
  end
end
