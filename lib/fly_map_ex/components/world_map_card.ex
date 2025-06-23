defmodule FlyMapEx.Components.WorldMapCard do
  @moduledoc """
  A complete world map card component with legend, progress tracking, and styling.

  Wraps the WorldMap component with additional UI elements including:
  - Interactive region legends with color coding
  - Optional acknowledgment progress bar
  - Card styling and responsive layout
  """

  use Phoenix.Component

  alias FlyMapEx.Components.WorldMap

  @doc """
  Renders a world map card with regions, legend, and optional progress tracking.

  ## Attributes

  * `region_groups` - List of region group maps, each containing:
    * `regions` - List of region codes for this group
    * `style_key` - Atom referencing a style from group_styles config (e.g., :primary, :active)
    * `label` - Display label for this group (optional, falls back to style label)
  * `show_progress` - Whether to show the acknowledgment progress bar (default: false)
  * `colors` - Map of color overrides (optional)
  * `class` - Additional CSS classes for the card container
  * `legend_config` - Map with legend customization options
  * `group_styles` - Map of group styles configuration
  """
  attr :region_groups, :list, default: []
  attr :show_progress, :boolean, default: false
  attr :colors, :map, default: %{}
  attr :dimensions, :map, default: %{}
  attr :class, :string, default: ""
  attr :legend_config, :map, default: %{}
  attr :group_styles, :map, default: %{}

  def render(assigns) do
    # Process region groups and build data structures for rendering
    processed_groups = process_region_groups(assigns.region_groups, assigns.group_styles)

    # Extract progress information for expected vs acknowledged groups
    expected_regions = find_regions_by_style(processed_groups, [:expected])
    acknowledged_regions = find_regions_by_style(processed_groups, [:acknowledged])

    assigns = assign(assigns, %{
      processed_groups: processed_groups,
      expected_regions: expected_regions,
      acknowledged_regions: acknowledged_regions
    })

    ~H"""
    <div class={"card bg-base-100 #{@class}"}>
      <div class="card-body">
        <div class="rounded-lg border">
          <WorldMap.render
            region_groups={@processed_groups}
            colors={@colors}
            dimensions={@dimensions}
            group_styles={@group_styles}
          />
        </div>

        <!-- Acknowledgment Progress (only shown when requested) -->
        <div :if={@show_progress} class="mb-4">
          <div class="flex items-center justify-between text-sm mb-2">
            <span>Acknowledgment Progress:</span>
            <div class="flex items-center gap-2 text-sm">
              <span class="badge badge-success badge-sm">
                {length(@acknowledged_regions)} acknowledged
              </span>
              <span class="badge badge-warning badge-sm">
                {length(@expected_regions)} expected
              </span>
            </div>
          </div>
          <div class="w-full bg-base-300 rounded-full h-2">
            <div
              class="h-2 rounded-full bg-gradient-to-r from-orange-500 to-violet-500 transition-all duration-500"
              style={"width: #{calculate_progress_percentage(@expected_regions, @acknowledged_regions)}%"}
            >
            </div>
          </div>
        </div>

        <!-- Dynamic Legend -->
        <div class="text-sm text-base-content/70 space-y-2">
          <div :for={group <- @processed_groups} class="flex items-center">
            <span
              class={"inline-block w-3 h-3 rounded-full mr-2 #{if group.style.animated, do: "animate-pulse"}"}
              style={"background-color: #{group.style.color};"}
            >
            </span>
            {group.label}
            {format_regions_display(group.regions, "(none)")}
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Helper functions

  defp process_region_groups(region_groups, group_styles) do
    Enum.map(region_groups, fn group ->
      style_key = Map.get(group, :style_key)
      style = Map.get(group_styles, style_key, %{color: "#888888", animated: false, label: "Unknown"})

      %{
        regions: Map.get(group, :regions, []),
        style_key: style_key,
        style: style,
        label: Map.get(group, :label, style.label)
      }
    end)
  end

  defp find_regions_by_style(processed_groups, style_keys) do
    processed_groups
    |> Enum.filter(fn group -> group.style_key in style_keys end)
    |> Enum.flat_map(fn group -> group.regions end)
    |> Enum.uniq()
  end

  defp calculate_progress_percentage(expected_regions, ack_regions) do
    if length(expected_regions) > 0 do
      round(length(ack_regions) / length(expected_regions) * 100)
    else
      0
    end
  end
end
