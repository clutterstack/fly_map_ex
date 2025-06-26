defmodule FlyMapEx.Components.WorldMapCard do
  @moduledoc """
  A complete world map card component with legend, progress tracking, and styling.

  Wraps the WorldMap component with additional UI elements including:
  - Interactive region legends with color coding
  - Optional acknowledgment progress bar
  - Card styling and responsive layout
  """

  use Phoenix.Component

  require Logger

  alias FlyMapEx.Components.WorldMap
  alias FlyMapEx.Regions

  @doc """
  Renders a world map card with regions, legend, and optional progress tracking.

  ## Attributes

  * `region_groups` - List of region group maps, each containing:
    * `regions` - List of region codes for this group
    * `style_key` - Atom referencing a style (e.g., :success, :warning, :active)
    * `label` - Display label for this group
  * `show_progress` - Whether to show the acknowledgment progress bar (default: false)
  * `dimensions` - Map with width, height, and positioning
  * `background` - Map with background and border colors
  * `styles` - Map of available styles
  * `class` - Additional CSS classes for the card container
  """
  attr :region_groups, :list, default: []
  attr :show_progress, :boolean, default: false
  attr :dimensions, :map, default: %{}
  attr :background, :map, default: %{}
  attr :styles, :map, default: %{}
  attr :class, :string, default: ""

  def render(assigns) do
    # Process region groups and build data structures for rendering
    processed_groups = process_region_groups(assigns.region_groups, assigns.styles)

    # Extract progress information for pending vs completed groups
    pending_regions = find_regions_by_style(processed_groups, [:pending, :warning])
    completed_regions = find_regions_by_style(processed_groups, [:success, :completed])

    assigns = assign(assigns, %{
      processed_groups: processed_groups,
      pending_regions: pending_regions,
      completed_regions: completed_regions
    })

    Logger.debug("@styles: #{inspect assigns.styles}")

    ~H"""
    <div class={"card bg-base-100 #{@class}"}>
      <div class="card-body">
        <div class="rounded-lg border overflow-hidden" style={"background-color: #{@background.land}"}>
          <WorldMap.render
            region_groups={@processed_groups}
            dimensions={@dimensions}
            colours={@background}
            group_styles={@styles}
          />
        </div>

        <!-- Progress Tracking (only shown when requested) -->
        <div :if={@show_progress} class="mb-4">
          <div class="flex items-center justify-between text-sm mb-2">
            <span>Progress:</span>
            <div class="flex items-center gap-2 text-sm">
              <span class="badge badge-success badge-sm">
                {length(@completed_regions)} completed
              </span>
              <span class="badge badge-warning badge-sm">
                {length(@pending_regions)} pending
              </span>
            </div>
          </div>
          <div class="w-full bg-base-300 rounded-full h-2">
            <div
              class="h-2 rounded-full bg-gradient-to-r from-orange-500 to-emerald-500 transition-all duration-500"
              style={"width: #{calculate_progress_percentage(@pending_regions, @completed_regions)}%"}
            >
            </div>
          </div>
        </div>

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
                    Regions: {format_regions_display(group.regions, "none")}
                  </span>
                  <span :if={Map.has_key?(group, :machine_count)} class="bg-base-300 px-2 py-1 rounded text-xs">
                    {group.machine_count} machines
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Available regions without machines -->
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
                  Fly.io regions without machines (<%= inactive_regions_count(@processed_groups) %> regions)
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Helper functions

  defp process_region_groups(region_groups, styles) do
    Enum.map(region_groups, fn group ->
      style_key = Map.get(group, :style_key)
      style = Map.get(styles, style_key, %{color: "#888888", animated: false, label: "Unknown"})

      %{
        regions: Map.get(group, :regions, []),
        style_key: style_key,
        style: style,
        label: Map.get(group, :label, style.label),
        machine_count: Map.get(group, :machine_count, length(Map.get(group, :regions, [])))
      }
    end)
  end

  defp find_regions_by_style(processed_groups, style_keys) do
    processed_groups
    |> Enum.filter(fn group -> group.style_key in style_keys end)
    |> Enum.flat_map(fn group -> group.regions end)
    |> Enum.uniq()
  end

  defp calculate_progress_percentage(pending_regions, completed_regions) do
    total_regions = length(pending_regions) + length(completed_regions)
    if total_regions > 0 do
      round(length(completed_regions) / total_regions * 100)
    else
      0
    end
  end

  defp format_regions_display(regions, empty_message) do
    # Filter out empty/unknown regions and convert to display names
    display_regions =
      regions
      |> Enum.reject(&(&1 in ["", "unknown"]))
      |> Enum.map(&region_display_name/1)
      |> Enum.reject(&is_nil/1)

    if display_regions != [] do
      "(#{Enum.join(display_regions, ", ")})"
    else
      empty_message
    end
  end

  defp region_display_name(region) do
    case Regions.name(region) do
      nil -> region  # Fall back to region code if no name found
      name -> name
    end
  end

  defp total_active_regions(processed_groups) do
    processed_groups
    |> Enum.flat_map(fn group -> group.regions end)
    |> Enum.uniq()
    |> length()
  end

  defp total_available_regions() do
    Regions.all()
    |> map_size()
  end

  defp inactive_regions_count(processed_groups) do
    active_regions =
      processed_groups
      |> Enum.flat_map(fn group -> group.regions end)
      |> Enum.uniq()
      |> MapSet.new()

    all_regions =
      Regions.all()
      |> Map.keys()
      |> Enum.map(&Atom.to_string/1)
      |> MapSet.new()

    MapSet.difference(all_regions, active_regions)
    |> MapSet.size()
  end

  defp total_machine_count(processed_groups) do
    processed_groups
    |> Enum.map(fn group ->
      Map.get(group, :machine_count, length(group.regions))
    end)
    |> Enum.sum()
  end
end
