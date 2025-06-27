defmodule FlyMapEx.Components.WorldMapCard do
  @moduledoc """
  A complete world map card component with legend, progress tracking, and styling.

  Wraps the WorldMap component with additional UI elements including:
  - Interactive region legends with color coding
  - Card styling and responsive layout
  """

  use Phoenix.Component

  require Logger

  alias FlyMapEx.Components.WorldMap
  alias FlyMapEx.Regions

  @doc """
  Renders a world map card with regions, legend, and optional progress tracking.

  ## Attributes

  * `marker_groups` - List of region/node group maps, each containing:
    * `nodes` - List of nodes, each either a region code string or %{label: "", coordinates: {lat, long}}
    * `style_key` - Atom referencing a style (e.g., :success, :warning, :active)
    * `label` - Display label for this group
  * `background` - Map with background and border colours
  * `styles` - Map of available styles
  * `class` - Additional CSS classes for the card container
  """
  attr :marker_groups, :list, default: []
  attr :background, :map, default: %{}
  attr :styles, :map, default: %{}
  attr :class, :string, default: ""

  def render(assigns) do
    # Process marker groups and build data structures for rendering
    processed_groups = process_marker_groups(assigns.marker_groups, assigns.styles)

    # Extract progress information for pending vs completed groups
    pending_regions = find_regions_by_style(processed_groups, [:pending, :warning])
    completed_regions = find_regions_by_style(processed_groups, [:success, :completed])

    assigns = assign(assigns, %{
      processed_groups: processed_groups,
      pending_regions: pending_regions,
      completed_regions: completed_regions
    })

    # Logger.debug("@styles: #{inspect assigns.styles}")

    ~H"""
    <div class={"card bg-base-100 #{@class}"}>
      <div class="card-body">
        <div class="rounded-lg border overflow-hidden" style={"background-color: #{@background.land}"}>
          <WorldMap.render
            marker_groups={@processed_groups}
            colours={@background}
            group_styles={@styles}
          />
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
                style={"background-color: #{group.style.colour};"}
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
                    Nodes: {format_nodes_display(group.nodes, "none")}
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

  defp process_marker_groups(marker_groups, styles) do
    Enum.map(marker_groups, fn group ->
      style_key = Map.get(group, :style_key)
      style = Map.get(styles, style_key, %{color: "#888888", animated: false, label: "Unknown", base_size: 6, gradient: false, animation: :none})

      nodes = Map.get(group, :nodes, [])

      %{
        nodes: nodes,
        style_key: style_key,
        style: style,
        label: Map.get(group, :label, style.label),
        machine_count: Map.get(group, :machine_count, length(nodes))
      }
    end)
  end

  defp find_regions_by_style(processed_groups, style_keys) do
    processed_groups
    |> Enum.filter(fn group -> group.style_key in style_keys end)
    |> Enum.flat_map(fn group -> extract_region_codes(group.nodes) end)
    |> Enum.uniq()
  end

  # Helper to extract region codes from nodes for backward compatibility
  defp extract_region_codes(nodes) when is_list(nodes) do
    Enum.flat_map(nodes, fn
      %{label: label, coordinates: _} ->
        # For coordinate nodes, try to match back to region code
        # This is a best-effort for progress tracking compatibility
        case find_region_code_by_coordinates(label) do
          nil -> []
          code -> [code]
        end
      region_code when is_binary(region_code) ->
        [region_code]
      _ ->
        []
    end)
  end

  # Try to find region code by checking if label matches a known region name
  defp find_region_code_by_coordinates(label) do
    Regions.all()
    |> Enum.find(fn {code, _coords} ->
      Regions.name(Atom.to_string(code)) == label
    end)
    |> case do
      {code, _coords} -> Atom.to_string(code)
      nil -> nil
    end
  end

  defp format_nodes_display(nodes, empty_message) do
    # Convert nodes to display names
    display_names =
      nodes
      |> Enum.map(&node_display_name/1)
      |> Enum.reject(&is_nil/1)

    if display_names != [] do
      "(#{Enum.join(display_names, ", ")})"
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
      nil -> region  # Fall back to region code if no name found
      name -> name
    end
  end

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

  defp inactive_regions_count(processed_groups) do
    # Extract region codes from active nodes for Fly.io compatibility
    active_region_codes =
      processed_groups
      |> Enum.flat_map(fn group -> extract_region_codes(group.nodes) end)
      |> Enum.uniq()
      |> MapSet.new()

    all_regions =
      Regions.all()
      |> Map.keys()
      |> Enum.map(&Atom.to_string/1)
      |> MapSet.new()

    MapSet.difference(all_regions, active_region_codes)
    |> MapSet.size()
  end

  defp total_machine_count(processed_groups) do
    processed_groups
    |> Enum.map(fn group ->
      Map.get(group, :machine_count, length(group.nodes))
    end)
    |> Enum.sum()
  end
end
