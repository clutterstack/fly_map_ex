defmodule FlyMapEx.Components.WorldMap do
  @moduledoc """
  SVG world map component for displaying Fly.io regions with different marker types.

  Renders an interactive SVG world map with configurable markers, colours, and animations.
  """

  use Phoenix.Component

  alias FlyMapEx.Regions
  alias FlyMapEx.WorldMapPaths

  # Map dims determined by svg and some cropping
  @bbox {0, 0, 800, 391}
  @minx 0
  @miny 10
  @width 800
  @height 320

  # Default colour scheme
  @colours %{
    # Blue for our nodes
    our_nodes: "#77b5fe",
    # Yellow for active nodes
    active_nodes: "#ffdc66",
    # Orange for expected nodes
    expected_nodes: "#ff8c42",
    # Plasma violet for acknowledged nodes
    ack_nodes: "#9d4edd",
    # Map background
    background: "#444444",
    # Map border
    border: "#DAA520"
  }

  @doc """
  Renders the SVG world map with dynamic marker group markers.

  ## Attributes

  * `marker_groups` - List of processed marker groups with styles
  * `colours` - Map of colour overrides (optional)
  * `group_styles` - Map of group styles configuration (optional)
  * `id` - HTML id for the SVG element (default: "fly-region-map")
  * `show_regions` - Whether to show region markers (default: nil, uses config default)
  """
  attr(:marker_groups, :list, default: [])
  attr(:colours, :map, default: %{})
  attr(:id, :string, default: "fly-region-map")
  attr(:show_regions, :boolean, default: nil)

  def render(assigns) do
    # Merge user colours with defaults
    colours = Map.merge(@colours, assigns.colours)

    # Generate gradients for all groups with gradients enabled
    gradient_groups =
      Enum.filter(assigns.marker_groups, fn group ->
        Map.get(group.style, :gradient, false)
      end)

    # Determine if regions should be shown (attribute overrides config default)
    show_regions = if is_nil(assigns.show_regions), do: FlyMapEx.Config.show_regions_default(), else: assigns.show_regions

    assigns =
      assign(assigns, %{
        colours: colours,
        minx: @minx,
        miny: @miny,
        width: @width,
        height: @height,
        viewbox: "#{@minx} #{@miny} #{@width} #{@height}",
        gradient_groups: gradient_groups,
        bbox: @bbox,
        toppath: "M #{@minx + 1} #{@miny + 0.5} H #{@width - 0.5}",
        btmpath: "M #{@minx + 1} #{@miny + @height - 1} H #{@width - 0.5}",
        marker_opacity: FlyMapEx.Config.marker_opacity(),
        hover_opacity: FlyMapEx.Config.hover_opacity(),
        marker_base_radius: FlyMapEx.Config.marker_base_radius(),
        region_marker_radius: round(0.5*FlyMapEx.Config.marker_base_radius()),
        show_regions: show_regions
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
        <!-- Dynamic gradients for groups with gradient enabled -->
        <%= for {group, index} <- Enum.with_index(@gradient_groups) do %>
          <radialGradient id={"gradient#{index}"} cx="50%" cy="50%" r="50%" fx="50%" fy="50%">
            <stop offset="40%" stop-color={group.style.colour} stop-opacity="1" />
            <stop offset="70%" stop-color={group.style.colour} stop-opacity="0.7" />
            <stop offset="100%" stop-color={group.style.colour} stop-opacity="0.2" />
          </radialGradient>
        <% end %>
      </defs>

      <style>
        /* Generated at <%= DateTime.utc_now() |> DateTime.to_string() %> */
        svg {
          --marker-opacity: <%= @marker_opacity %>;
          --hover-opacity: <%= @hover_opacity %>;
          --neutral-marker-color: <%= get_region_marker_color(@colours) %>;
          --neutral-text-color: <%= get_region_text_color(@colours) %>;
          /* Fallback colors when CSS variables fail */
          --fallback-neutral-marker: #6b7280;
          --fallback-neutral-text: #374151;
        }
        /* Dark mode fallbacks */
        @media (prefers-color-scheme: dark) {
          svg {
            --fallback-neutral-marker: #9ca3af;
            --fallback-neutral-text: #d1d5db;
          }
        }
        svg circle {
          pointer-events: none;
        }
        .region-text-group text {
          opacity: 0;
          stroke: none;
          fill: var(--neutral-text-color);
          transition: opacity 0.2s;
          pointer-events: none;
          user-select: none;
        }
        <%= for {region, _coords} <- all_regions_with_coords() do %>
        .region-<%= region %>:hover ~ .text-<%= region %> text {
          opacity: 1;
        }
        <% end %>
        .region-text-group.active text {
          opacity: 1;
        }
        .region-group circle {
          stroke: transparent;
          fill: var(--neutral-marker-color);
          stroke-width: 8;
          pointer-events: all;
          opacity: var(--marker-opacity);
        }
        .marker-group.static circle {
          opacity: var(--marker-opacity);
        }
        .marker-group.animated circle {
          /* Animated markers control their own opacity */
        }
        .region-group:hover circle {
          stroke: {@colours.border};
          fill: {@colours.border};
          opacity: var(--hover-opacity);
        }
      </style>

      <!-- World map svg from WorldMapPaths component -->
      <WorldMapPaths.render colours={@colours} />

      <!-- Map borders -->
      <path d={@toppath} stroke={@colours.border} stroke-width="1" />
      <path d={@btmpath} stroke={@colours.border} stroke-width="1" />

      <!-- Optional markers showing all Fly.io regions -->
      <%= if @show_regions do %>
        <.fly_region_markers region_marker_radius={@region_marker_radius} />
      <% end %>

      <!-- Dynamic marker group markers -->
      <%= for {group, group_index} <- Enum.with_index(@marker_groups) do %>
        <%= for {x, y} <- get_group_coordinates(group, @bbox) do %>
          <%= render_marker(group, group_index, x, y, @gradient_groups, @marker_base_radius) %>
        <% end %>
      <% end %>

      <!-- All regions as interactive elements -->
      <%= if @show_regions do %>
        <.fly_region_hover_text />
      <% end %>

    </svg>
    """
  end

  attr :region_marker_radius, :integer, default: 2

  def fly_region_markers(assigns) do
    ~H"""
    <%= for {region, {x, y}} <- all_regions_with_coords() do %>
      <g class={"region-group region-#{region}"} id={"region-#{region}"}>
        <circle cx={x} cy={y} r={@region_marker_radius} />
      </g>
    <% end %>
    """
  end

  def fly_region_hover_text(%{} = assigns) do
    ~H"""
    <%= for {region, {x, y}} <- all_regions_with_coords() do %>
      <g class={"region-text-group text-#{region}"} id={"region-text-#{region}"}>
        <text x={x} y={y - 8} text-anchor="middle" font-size="20">{region}</text>
      </g>
    <% end %>
    """
  end

  # Private functions

  defp get_group_coordinates(group, bbox) do
    cond do
      Map.has_key?(group, :nodes) -> node_coordinates(group.nodes, bbox)
      Map.has_key?(group, :markers) -> marker_coordinates(group.markers, bbox)
      true -> []
    end
  end

  defp node_coordinates(nodes, bbox) when is_list(nodes) do
    nodes
    |> Enum.map(&coords_lookup/1)
    |> Enum.map(&wgs84_to_svg(&1, bbox))
  end

  defp marker_coordinates(markers, bbox) when is_list(markers) do
    markers
    |> Enum.map(&marker_coords_lookup/1)
    |> Enum.map(&wgs84_to_svg(&1, bbox))
  end

  defp coords_lookup(%{coordinates: coords}), do: coords

  defp coords_lookup(region_code) when is_binary(region_code) do
    case Regions.coordinates(region_code) do
      {:ok, coords} -> coords
      {:error, _} -> {-190, 0}  # Off-screen fallback
    end
  end

  defp marker_coords_lookup(%{lat: lat, lng: lng}), do: {lat, lng}
  defp marker_coords_lookup(%{"lat" => lat, "lng" => lng}), do: {lat, lng}
  defp marker_coords_lookup(marker) when is_map(marker) do
    # Handle alternative key formats
    lat = marker[:lat] || marker["lat"] || marker[:latitude] || marker["latitude"]
    lng = marker[:lng] || marker["lng"] || marker[:longitude] || marker["longitude"]
    {lat, lng}
  end

  defp render_marker(group, _group_index, x, y, gradient_groups, default_radius) do
    base_size = Map.get(group.style, :size, default_radius)
    animation = Map.get(group.style, :animation, :none)
    gradient = Map.get(group.style, :gradient, false)

    fill =
      if gradient do
        # Find this group's gradient index
        gradient_index = Enum.find_index(gradient_groups, fn g -> g == group end)
        if gradient_index, do: "url(#gradient#{gradient_index})", else: group.style.colour
      else
        group.style.colour
      end

    case animation do
      :pulse ->
        {min_opacity, max_opacity} = FlyMapEx.Config.animation_opacity_range()
        assigns = %{x: x, y: y, fill: fill, base_size: base_size, min_opacity: min_opacity, max_opacity: max_opacity}

        ~H"""
        <g class="marker-group animated">
          <circle cx={@x} cy={@y} stroke="none" fill={@fill}>
            <animate attributeName="r" values={"#{@base_size};#{@base_size + 4};#{@base_size}"} dur="2s" repeatCount="indefinite" />
            <animate attributeName="opacity" values={"#{@min_opacity};#{@max_opacity};#{@min_opacity}"} dur="2s" repeatCount="indefinite" />
          </circle>
        </g>
        """

      :bounce ->
        assigns = %{x: x, y: y, fill: fill, base_size: base_size}

        ~H"""
        <g class="marker-group static">
          <circle cx={@x} cy={@y} stroke="none" fill={@fill}>
            <animate attributeName="r" values={"#{@base_size};#{@base_size + 6};#{@base_size};#{@base_size + 2};#{@base_size}"} dur="1.5s" repeatCount="indefinite" />
          </circle>
        </g>
        """

      :fade ->
        {min_opacity, max_opacity} = FlyMapEx.Config.animation_opacity_range()
        assigns = %{x: x, y: y, fill: fill, base_size: base_size, min_opacity: min_opacity, max_opacity: max_opacity}

        ~H"""
        <g class="marker-group animated">
          <circle cx={@x} cy={@y} r={@base_size} stroke="none" fill={@fill}>
            <animate attributeName="opacity" values={"#{@min_opacity};#{@max_opacity};#{@min_opacity}"} dur="3s" repeatCount="indefinite" />
          </circle>
        </g>
        """

      # :none or any other value
      _ ->
        assigns = %{x: x, y: y, fill: fill, base_size: base_size}

        ~H"""
        <g class="marker-group static">
          <circle cx={@x} cy={@y} r={@base_size} fill={@fill} />
        </g>
        """
    end
  end

  defp all_regions_with_coords do
    for {region_atom, coords} <- Regions.all() do
      region_string = Atom.to_string(region_atom)
      svg_coords = wgs84_to_svg(coords, @bbox)
      {region_string, svg_coords}
    end
  end

  defp wgs84_to_svg({lat, long}, {x_min, y_min, x_max, y_max}) do
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

  # Helper function to get the appropriate region marker color
  def get_region_marker_color(colours) do
    case Map.get(colours, :neutral_marker) do
      "oklch" <> _ ->
        # For CSS variables, provide fallback that inherits from document
        "var(--color-base-content, #6b7280)"
      color when is_binary(color) -> color
      _ -> Map.get(colours, :background, "#6b7280")
    end
  end

  # Helper function to get the appropriate region text color
  defp get_region_text_color(colours) do
    case Map.get(colours, :neutral_text) do
      "oklch" <> _ ->
        # For CSS variables, provide fallback that inherits from document
        "var(--color-base-content, #374151)"
      color when is_binary(color) -> color
      _ -> Map.get(colours, :background, "#374151")
    end
  end
end
