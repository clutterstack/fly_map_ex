defmodule FlyMap.Components.WorldMapCard do
  @moduledoc """
  A complete world map card component with legend, progress tracking, and styling.
  
  Wraps the WorldMap component with additional UI elements including:
  - Interactive region legends with color coding
  - Optional acknowledgment progress bar
  - Card styling and responsive layout
  """
  
  use Phoenix.Component
  
  alias FlyMap.Components.WorldMap
  alias FlyMap.Regions
  
  @doc """
  Renders a world map card with regions, legend, and optional progress tracking.
  
  ## Attributes
  
  * `our_regions` - List of region codes for "our nodes" (blue animated markers)
  * `active_regions` - List of region codes for active nodes (yellow markers)
  * `expected_regions` - List of region codes for expected nodes (orange animated markers) 
  * `ack_regions` - List of region codes for acknowledged nodes (violet animated markers)
  * `show_progress` - Whether to show the acknowledgment progress bar (default: false)
  * `colors` - Map of color overrides (optional)
  * `class` - Additional CSS classes for the card container
  * `legend_config` - Map with legend customization options
  """
  attr :our_regions, :list, default: []
  attr :active_regions, :list, default: []
  attr :expected_regions, :list, default: []
  attr :ack_regions, :list, default: []
  attr :show_progress, :boolean, default: false
  attr :colors, :map, default: %{}
  attr :dimensions, :map, default: %{}
  attr :class, :string, default: ""
  attr :legend_config, :map, default: %{}
  
  def render(assigns) do
    # Set up default colors with any user overrides
    default_colors = %{
      our_nodes: "#77b5fe",
      active_nodes: "#ffdc66", 
      expected_nodes: "#ff8c42",
      ack_nodes: "#9d4edd"
    }
    colors = Map.merge(default_colors, assigns.colors)
    
    # Set up legend configuration
    default_legend = %{
      show_our_nodes: true,
      show_active_nodes: true,
      show_expected_nodes: true,
      show_ack_nodes: true,
      our_nodes_label: "Our nodes",
      active_nodes_label: "Active nodes", 
      expected_nodes_label: "Expected nodes",
      ack_nodes_label: "Acknowledged nodes"
    }
    legend_config = Map.merge(default_legend, assigns.legend_config)
    
    assigns = assign(assigns, %{
      colors: colors,
      legend_config: legend_config
    })
    
    ~H"""
    <div class={"card bg-base-100 #{@class}"}>
      <div class="card-body">
        <div class="rounded-lg border">
          <WorldMap.render
            our_regions={@our_regions}
            active_regions={@active_regions}
            expected_regions={@expected_regions}
            ack_regions={@ack_regions}
            colors={@colors}
            dimensions={@dimensions}
          />
        </div>

        <!-- Acknowledgment Progress (only shown when requested) -->
        <div :if={@show_progress} class="mb-4">
          <div class="flex items-center justify-between text-sm mb-2">
            <span>Acknowledgment Progress:</span>
            <div class="flex items-center gap-2 text-sm">
              <span class="badge badge-success badge-sm">
                {length(@ack_regions)} acknowledged
              </span>
              <span class="badge badge-warning badge-sm">
                {length(@expected_regions)} expected
              </span>
            </div>
          </div>
          <div class="w-full bg-base-300 rounded-full h-2">
            <div
              class="h-2 rounded-full bg-gradient-to-r from-orange-500 to-violet-500 transition-all duration-500"
              style={"width: #{calculate_progress_percentage(@expected_regions, @ack_regions)}%"}
            >
            </div>
          </div>
        </div>

        <!-- Legend -->
        <div class="text-sm text-base-content/70 space-y-2">
          <!-- Our nodes legend -->
          <div :if={@legend_config.show_our_nodes} class="flex items-center">
            <span class="inline-block w-3 h-3 rounded-full mr-2" style={"background-color: #{@colors.our_nodes};"}>
            </span>
            {@legend_config.our_nodes_label}
            {format_regions_display(@our_regions, "(none)")}
          </div>

          <!-- Active nodes legend -->
          <div :if={@legend_config.show_active_nodes} class="flex items-center">
            <span class="inline-block w-3 h-3 rounded-full mr-2" style={"background-color: #{@colors.active_nodes};"}>
            </span>
            {@legend_config.active_nodes_label}
            {format_regions_display(@active_regions, "(none)")}
          </div>

          <!-- Expected nodes legend -->
          <div :if={@legend_config.show_expected_nodes} class="flex items-center">
            <span class="inline-block w-3 h-3 rounded-full mr-2" style={"background-color: #{@colors.expected_nodes};"}>
            </span>
            {@legend_config.expected_nodes_label}
            {format_regions_display(@expected_regions, "(none)")}
          </div>

          <!-- Acknowledged nodes legend -->
          <div :if={@legend_config.show_ack_nodes} class="flex items-center">
            <span class="inline-block w-3 h-3 rounded-full mr-2" style={"background-color: #{@colors.ack_nodes};"}>
            </span>
            {@legend_config.ack_nodes_label}
            {format_regions_display(@ack_regions, "(none)")}
          </div>
        </div>
      </div>
    </div>
    """
  end
  
  # Helper functions
  
  defp calculate_progress_percentage(expected_regions, ack_regions) do
    if length(expected_regions) > 0 do
      round(length(ack_regions) / length(expected_regions) * 100)
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
end