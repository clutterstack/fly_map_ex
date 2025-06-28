defmodule FlyMapEx.Components.WorldMapCard do
  @moduledoc """
  A complete world map card component with legend, progress tracking, and styling.

  Wraps the WorldMap component with additional UI elements including:
  - Interactive region legends with color coding
  - Card styling and responsive layout
  """

  use Phoenix.Component

  require Logger

  alias FlyMapEx.Components.{WorldMap, LegendComponent}
  alias FlyMapEx.Regions

  @doc """
  Renders a world map card with regions, legend, and optional progress tracking.

  ## Attributes

  * `marker_groups` - List of region/node group maps, each containing:
    * `nodes` - List of nodes, each either a region code string or %{label: "", coordinates: {lat, long}}
    * `style` - Style definition (normalized map with color, size, etc.)
    * `label` - Display label for this group
  * `background` - Map with background and border colours
  * `class` - Additional CSS classes for the card container
  """
  attr(:marker_groups, :list, default: [])
  attr(:background, :map, default: %{})
  attr(:class, :string, default: "")
  attr(:selected_apps, :list, default: [])
  attr(:available_apps, :list, default: [])
  attr(:all_instances_data, :map, default: %{})

  def render(assigns) do
    # Process marker groups (they're already normalized by the main component)
    processed_groups = assigns.marker_groups

    # Extract progress information for pending vs completed groups
    # amber/orange colors
    pending_regions = find_regions_by_color(processed_groups, ["#f59e0b", "#d97706"])
    # green/teal colors
    completed_regions = find_regions_by_color(processed_groups, ["#10b981", "#14b8a6"])

    assigns =
      assign(assigns, %{
        processed_groups: processed_groups,
        pending_regions: pending_regions,
        completed_regions: completed_regions
      })

    ~H"""
    <div class={"card bg-base-100 #{@class}"}>
      <div class="card-body">
        <div class="rounded-lg border overflow-hidden" style={"background-color: #{@background.land}"}>
          <WorldMap.render
            marker_groups={@processed_groups}
            colours={@background}
          />
        </div>

        <LegendComponent.legend 
          processed_groups={@processed_groups} 
          selected_apps={@selected_apps}
          available_apps={@available_apps}
          all_instances_data={@all_instances_data} 
        />
      </div>
    </div>
    """
  end


  # Helper functions

  defp find_regions_by_color(processed_groups, colors) do
    processed_groups
    |> Enum.filter(fn group -> group.style.color in colors end)
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

  def format_nodes_display(nodes, empty_message) do
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
      # Fall back to region code if no name found
      nil -> region
      name -> name
    end
  end
end
