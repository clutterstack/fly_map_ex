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

  def legend(%{processed_groups: processed_groups} = assigns) do
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
            :for={group <- @processed_groups} 
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
end
