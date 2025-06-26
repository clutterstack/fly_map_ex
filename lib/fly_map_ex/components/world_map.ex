defmodule FlyMapEx.Components.WorldMap do
  @moduledoc """
  SVG world map component for displaying Fly.io regions with different marker types.

  Renders an interactive SVG world map with configurable markers, colours, and animations.
  """

  use Phoenix.Component

  alias FlyMapEx.Regions
  alias FlyMapEx.WorldMapPaths

  # Default map dimensions and styling
  @default_bbox {0, 0, 800, 391}
  @default_minx 0
  @default_miny 10
  @default_width 800
  @default_height 320

  # Default color scheme
  @default_colours %{
    our_nodes: "#77b5fe",      # Blue for our nodes
    active_nodes: "#ffdc66",   # Yellow for active nodes
    expected_nodes: "#ff8c42", # Orange for expected nodes
    ack_nodes: "#9d4edd",      # Plasma violet for acknowledged nodes
    background: "#444444",     # Map background
    border: "#DAA520"          # Map border
  }

  @doc """
  Renders the SVG world map with dynamic region group markers.

  ## Attributes

  * `region_groups` - List of processed region groups with styles
  * `colours` - Map of color overrides (optional)
  * `dimensions` - Map with width/height overrides (optional)
  * `group_styles` - Map of group styles configuration (optional)
  * `id` - HTML id for the SVG element (default: "fly-region-map")
  """
  attr :region_groups, :list, default: []
  attr :colours, :map, default: %{}
  attr :dimensions, :map, default: %{}
  attr :group_styles, :map, default: %{}
  attr :id, :string, default: "fly-region-map"

  def render(assigns) do
    # Merge user colours with defaults
    colours = Map.merge(@default_colours, assigns.colours)

    # Setup dimensions
    {minx, miny, width, height} = get_dimensions(assigns.dimensions)
    viewbox = "#{minx} #{miny} #{width} #{height}"

    # Generate gradients for all groups with animation
    animated_groups = Enum.filter(assigns.region_groups, & &1.style.animated)

    assigns = assign(assigns, %{
      colours: colours,
      minx: minx,
      miny: miny,
      width: width,
      height: height,
      viewbox: viewbox,
      animated_groups: animated_groups,
      toppath: "M #{minx + 1} #{miny + 0.5} H #{width - 0.5}",
      btmpath: "M #{minx + 1} #{miny + height - 1} H #{width - 0.5}"
    })

    ~H"""
    <svg
      viewBox={@viewbox}
      stroke-linecap="round"
      stroke-linejoin="round"
      xmlns="http://www.w3.org/2000/svg"
      id={@id}
    >
      <defs>
        <!-- Dynamic gradients for animated groups -->
        <%= for group <- @animated_groups do %>
          <radialGradient id={"#{group.style_key}Gradient"} cx="50%" cy="50%" r="50%" fx="50%" fy="50%">
            <stop offset="60%" stop-color={group.style.color} stop-opacity="1" />
            <stop offset="80%" stop-color={group.style.color} stop-opacity="0.6" />
            <stop offset="100%" stop-color={group.style.color} stop-opacity="0.2" />
          </radialGradient>
        <% end %>
      </defs>

      <style>
        circle {
          pointer-events: none;
        }
        .region-group text {
          opacity: 0;
          stroke: {@colours.background};
          fill: {@colours.background};
          transition: opacity 0.2s;
          pointer-events: none;
          user-select: none;
        }
        .region-group:hover text,
        .region-group.active text {
          opacity: 1;
        }
        .region-group circle {
          stroke: transparent;
          fill: {@colours.background};
          stroke-width: 8;
          pointer-events: all;
          opacity: 0.3;
        }
        .region-group:hover circle {
          stroke: {@colours.border};
          fill: {@colours.border};
          opacity: 0.8;
        }
      </style>

      <!-- World map background -->
      <WorldMapPaths.render colours={@colours} />

      <!-- Map borders -->
      <path d={@toppath} stroke={@colours.border} stroke-width="1" />
      <path d={@btmpath} stroke={@colours.border} stroke-width="1" />

      <!-- All regions as interactive elements -->
      <%= for {region, {x, y}} <- all_regions_with_coords() do %>
        <g class="region-group" id={"region-#{region}"}>
          <circle cx={x} cy={y} r="2" opacity="0.3" />
          <text x={x} y={y - 8} text-anchor="middle" font-size="20">{region}</text>
        </g>
      <% end %>

      <!-- Dynamic region group markers -->
      <%= for group <- @region_groups do %>
        <%= for {x, y} <- region_coordinates(group.regions) do %>
          <%= if group.style.animated do %>
            <circle cx={x} cy={y} stroke="none" fill={"url(##{group.style_key}Gradient)"}>
              <animate attributeName="r" values="6;10;6" dur="3s" repeatCount="indefinite" />
            </circle>
          <% else %>
            <circle cx={x} cy={y} r="6" fill={group.style.color} opacity="0.9" />
          <% end %>
        <% end %>
      <% end %>
    </svg>
    """
  end

  # Private functions

  defp get_dimensions(user_dimensions) do
    width = Map.get(user_dimensions, :width, @default_width)
    height = Map.get(user_dimensions, :height, @default_height)
    minx = Map.get(user_dimensions, :minx, @default_minx)
    miny = Map.get(user_dimensions, :miny, @default_miny)

    {minx, miny, width, height}
  end


  defp region_coordinates(regions) do
    regions
    |> Enum.map(&Regions.coordinates/1)
    |> Enum.map(&wgs84_to_svg(&1, @default_bbox))
  end

  defp all_regions_with_coords do
    for {region_atom, coords} <- Regions.all() do
      region_string = Atom.to_string(region_atom)
      svg_coords = wgs84_to_svg(coords, @default_bbox)
      {region_string, svg_coords}
    end
  end

  defp wgs84_to_svg({long, lat}, {x_min, y_min, x_max, y_max}) do
    svg_width = x_max - x_min
    svg_height = y_max - y_min

    bounds = %{min_long: -180, max_long: 180, min_lat: -90, max_lat: 90}

    # Calculate percentage position along each axis
    x_percent = (long - bounds.min_long) / (bounds.max_long - bounds.min_long)
    # Note the inversion for y-axis since SVG's y increases downward
    y_percent = 1 - (lat - bounds.min_lat) / (bounds.max_lat - bounds.min_lat)

    # Convert to pixel positions
    x = x_percent * svg_width
    y = y_percent * svg_height

    {x, y}
  end

end
