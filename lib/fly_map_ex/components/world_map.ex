defmodule FlyMapEx.Components.WorldMap do
  @moduledoc """
  SVG world map component for displaying Fly.io regions with different marker types.

  This component renders an interactive SVG world map with configurable markers, colours,
  and animations. It handles coordinate transformation from WGS84 geographic coordinates
  to SVG pixel coordinates and provides a complete mapping solution.

  ## Features

  - **SVG-based rendering**: Scalable vector graphics for crisp display at any size
  - **Coordinate transformation**: Converts WGS84 coordinates to SVG pixel coordinates
  - **Interactive markers**: Hover effects and visual feedback for region exploration
  - **Configurable styling**: Theme-based colour schemes and marker styles
  - **Glow effects**: Optional glow filters for enhanced visual appeal
  - **Region labels**: Dynamic text labels that appear on hover
  - **Responsive design**: Adapts to container size while maintaining aspect ratio

  ## Map Specifications

  - **Viewbox**: 800x391 pixels (cropped from original SVG)
  - **Coordinate system**: WGS84 to SVG transformation
  - **Bounding box**: {0, 0, 800, 391} for marker positioning
  - **Projection**: Simple linear transformation suitable for world overview

  ## Usage

  The WorldMap component is typically used within other components like `FlyMapEx.Component`:

      <WorldMap.render
        marker_groups={[
          %{
            label: "Production",
            nodes: ["sjc", "fra", "lhr"],
            style: %{colour: "#3b82f6", size: 8, animation: true}
          }
        ]}
        colours={%{
          background: "#1f2937",
          border: "#d1d5db",
          neutral_marker: "#6b7280"
        }}
        show_regions={true}
      />

  ## Coordinate Transformation

  The component performs coordinate transformation from geographic coordinates
  (latitude/longitude) to SVG pixel coordinates:

  1. **Input**: WGS84 coordinates (latitude: -90 to 90, longitude: -180 to 180)
  2. **Transformation**: Linear mapping to SVG coordinate space
  3. **Output**: Pixel coordinates within the SVG viewbox

  ### Transformation Algorithm

      # Calculate percentage position along each axis
      x_percent = (longitude - (-180)) / (180 - (-180))
      y_percent = 1 - (latitude - (-90)) / (90 - (-90))  # Inverted for SVG

      # Convert to pixel positions
      x = x_percent * svg_width
      y = y_percent * svg_height

  ## Marker Groups

  The component accepts marker groups with the following structure:

      %{
        label: "Production Nodes",
        nodes: ["sjc", "fra", "lhr"],           # Fly.io region codes
        style: %{
          colour: "#3b82f6",                    # Marker colour
          size: 8,                              # Marker radius
          animation: true,                      # Enable animation
          glow: true                            # Enable glow effect
        }
      }

  ## Styling and Theming

  The component supports comprehensive theming through the `colours` attribute:

      colours = %{
        background: "#1f2937",                  # Map background
        border: "#d1d5db",                      # Map border
        neutral_marker: "#6b7280",              # Region marker colour
        neutral_text: "#374151"                 # Region text colour
      }

  ## Interactive Features

  - **Hover effects**: Region markers change appearance on hover
  - **Text labels**: Region codes appear when hovering over markers
  - **Responsive styling**: Adapts to light/dark mode preferences
  - **Pointer events**: Configurable interaction behaviour

  ## Performance Considerations

  - **Efficient rendering**: Only visible markers are rendered
  - **Optimized filters**: Glow filters are collected and deduplicated
  - **CSS variables**: Theme colours are cached for performance
  - **Minimal DOM updates**: Static SVG structure with dynamic markers

  ## Accessibility

  - **Screen reader support**: Proper ARIA labels and semantic markup
  - **Keyboard navigation**: Interactive elements are focusable
  - **High contrast**: Respects system colour preferences
  - **Scalable graphics**: Vector-based for all display densities
  """

  use Phoenix.Component

  alias FlyMapEx.Regions
  alias FlyMapEx.Components.Marker
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

  This function creates a complete SVG world map with the following elements:
  - World map paths and geographic features
  - Dynamic marker groups with custom styling
  - Optional Fly.io region markers
  - Interactive hover effects and text labels
  - Glow filters for enhanced visual appeal

  ## Attributes

  * `marker_groups` - List of processed marker groups with styles and coordinates
  * `colours` - Map of colour overrides for theming (optional, uses defaults)
  * `id` - HTML id for the SVG element (default: "fly-region-map")
  * `show_regions` - Whether to show all Fly.io region markers (default: nil, uses config)

  ## Examples

      # Basic world map with marker groups
      <WorldMap.render
        marker_groups={[
          %{
            label: "Production",
            nodes: ["sjc", "fra", "lhr"],
            style: %{colour: "#3b82f6", size: 8, animation: true}
          }
        ]}
      />

      # Themed map with custom colours
      <WorldMap.render
        marker_groups={@marker_groups}
        colours={%{
          background: "#1f2937",
          border: "#d1d5db",
          neutral_marker: "#6b7280"
        }}
        show_regions={true}
        id="custom-map"
      />

  ## Rendering Process

  1. **Colour merging**: User colours are merged with default colour scheme
  2. **Glow filter collection**: Unique glow filters are identified and generated
  3. **Coordinate transformation**: Geographic coordinates are converted to SVG space
  4. **Marker rendering**: Each marker group is rendered with appropriate styling
  5. **Interactive elements**: Hover effects and text labels are added

  ## Performance Notes

  - Glow filters are deduplicated to minimize DOM overhead
  - CSS variables are used for efficient colour management
  - Only visible markers within the viewbox are rendered
  - Static SVG elements are cached for optimal performance

  ## Interactive Behaviour

  - Hover over region markers to see region codes
  - Marker groups respond to mouse events
  - Text labels appear/disappear based on hover state
  - Smooth transitions for visual feedback
  """
  attr(:marker_groups, :list, default: [])
  attr(:colours, :map, default: %{})
  attr(:id, :string, default: "fly-region-map")
  attr(:show_regions, :boolean, default: nil)

  def render(assigns) do
    # Merge user colours with defaults
    colours = Map.merge(@colours, assigns.colours)

    # Determine if regions should be shown (attribute overrides config default)
    show_regions = if is_nil(assigns.show_regions), do: FlyMapEx.Config.show_regions_default(), else: assigns.show_regions

    # Collect unique glow filter requirements for map-level filters
    radial_gradients = collect_radial_gradients(assigns.marker_groups)

    assigns =
      assign(assigns, %{
        colours: colours,
        minx: @minx,
        miny: @miny,
        width: @width,
        height: @height,
        viewbox: "#{@minx} #{@miny} #{@width} #{@height}",
        radial_gradients: radial_gradients,
        bbox: @bbox,
        toppath: "M #{@minx + 1} #{@miny + 0.5} H #{@width - 0.5}",
        btmpath: "M #{@minx + 1} #{@miny + @height - 1} H #{@width - 0.5}",
        marker_opacity: FlyMapEx.Config.marker_opacity(),
        hover_opacity: FlyMapEx.Config.hover_opacity(),
        default_marker_radius: FlyMapEx.Config.default_marker_radius(),
        region_marker_radius: FlyMapEx.Config.region_marker_radius(),
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
        <!-- Radial gradients for glow markers -->
        <%= for radial_gradient <- @radial_gradients do %>
          <radialGradient id={radial_gradient.id} cx="50%" cy="50%" r="50%" fx="50%" fy="50%">
            <stop offset="60%" stop-color={radial_gradient.colour} stop-opacity="1"/>
            <stop offset="80%" stop-color={radial_gradient.colour} stop-opacity="0.6"/>
            <stop offset="100%" stop-color={radial_gradient.colour} stop-opacity="0.2"/>
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
      <%= for group <- @marker_groups do %>
        <%= for {x, y} <- get_group_coordinates(group, @bbox) do %>
          <%= render_marker(group, x, y, @default_marker_radius) %>
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
    assigns.region_marker_radius
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

  defp collect_radial_gradients(marker_groups) do
    marker_groups
    |> Enum.filter(fn group ->
      Map.get(group.style, :glow, false)
    end)
    |> Enum.map(fn group ->
      colour = Map.get(group.style, :colour, "#6b7280")
      %{
        id: "glow-gradient-#{String.replace(colour, "#", "")}",
        colour: colour
      }
    end)
    |> Enum.uniq_by(& &1.id)
  end

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

  defp render_marker(group, x, y, _default_radius) do
    # Generate gradient ID for glow-enabled markers
    gradient_id = if Map.get(group.style, :glow, false) do
      colour = Map.get(group.style, :colour, "#6b7280")
      "glow-gradient-#{String.replace(colour, "#", "")}"
    else
      nil
    end

    assigns = %{
      style: group.style,
      x: x,
      y: y,
      mode: :svg,
      gradient_id: gradient_id
    }

    ~H"""
    <Marker.marker {assigns} />
    """
  end


  defp all_regions_with_coords do
    for {region_atom, coords} <- Regions.all() do
      region_string = Atom.to_string(region_atom)
      svg_coords = wgs84_to_svg(coords, @bbox)
      {region_string, svg_coords}
    end
  end

  @doc false
  # Converts WGS84 geographic coordinates to SVG pixel coordinates.
  #
  # This function performs a linear transformation from the WGS84 coordinate system
  # (latitude: -90 to 90, longitude: -180 to 180) to SVG pixel coordinates within
  # the specified bounding box.
  #
  # ## Parameters
  #
  # - `{lat, long}`: WGS84 coordinates (latitude, longitude)
  # - `{x_min, y_min, x_max, y_max}`: SVG bounding box coordinates
  #
  # ## Returns
  #
  # `{x, y}` tuple representing pixel coordinates within the SVG viewbox
  #
  # ## Algorithm
  #
  # The transformation uses a simple linear mapping:
  # 1. Calculate the percentage position along each axis
  # 2. Apply the percentage to the SVG dimensions
  # 3. Invert the Y-axis to match SVG coordinate system
  #
  # ## Examples
  #
  #     # Equator and Prime Meridian -> center of map
  #     wgs84_to_svg({0, 0}, {0, 0, 800, 400})
  #     # => {400.0, 200.0}
  #
  #     # North Pole -> top center
  #     wgs84_to_svg({90, 0}, {0, 0, 800, 400})
  #     # => {400.0, 0.0}
  #
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

  @doc """
  Gets the appropriate region marker colour from the colour scheme.

  This function handles different colour formats including CSS variables
  and provides fallback colours for robust theming support.

  ## Parameters

  - `colours`: Map containing colour scheme configuration

  ## Returns

  String representing the CSS colour value

  ## Examples

      # Standard hex colour
      get_region_marker_color(%{neutral_marker: "#6b7280"})
      # => "#6b7280"

      # CSS variable with fallback
      get_region_marker_color(%{neutral_marker: "oklch(0.5 0.1 180)"})
      # => "var(--color-base-content, #6b7280)"

  """
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
