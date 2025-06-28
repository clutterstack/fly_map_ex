defmodule FlyMapEx.Components.LegendComponent do
  @moduledoc """
  The legend to go with the WorldMap.
  """

  use Phoenix.Component

  require Logger

  alias FlyMapEx.Components.{WorldMap, WorldMapCard}
  alias FlyMapEx.Regions

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

          <div :for={group <- @processed_groups} class="flex items-start space-x-3 p-2 rounded-lg hover:bg-base-200/50">
            <div class="flex-shrink-0 mt-1">
              <span
                class={"inline-block w-3 h-3 rounded-full #{if group.style.animated, do: "animate-pulse"}"}
                style={"background-color: #{group.style.color};"}
              >
              </span>
            </div>
            <div class="flex-grow min-w-0">
              <div class="font-medium text-base-content">
                {group.label}
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
