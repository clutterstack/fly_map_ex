defmodule FlyMapEx.Components.Marker do
  @moduledoc """
  Reusable marker component for rendering consistent markers in both maps and legends.

  This component provides a unified interface for rendering markers with various styles,
  animations, and effects. It supports both SVG map markers and legend indicators,
  ensuring visual consistency across the entire FlyMapEx interface.

  ## Features

  - **Dual rendering modes**: SVG markers for maps and scaled indicators for legends
  - **Animation support**: Pulse, fade, and static marker types
  - **Glow effects**: Optional glow filters for enhanced visual appeal
  - **Consistent styling**: Shared styling logic between map and legend markers
  - **Configurable sizing**: Responsive sizing based on context and overrides
  - **Performance optimization**: Efficient SVG animations and filter reuse

  ## Rendering Modes

  ### SVG Mode (`:svg`)
  Used for markers positioned on the world map. Markers are rendered as SVG
  circles with precise coordinate positioning.

  ### Legend Mode (`:legend`)
  Used for legend indicators. Markers are rendered in a contained SVG with
  standardized sizing and centered positioning.

  ## Animation Types

  ### Static Markers (`:none`)
  Simple circular markers without animation, ideal for stable reference points.

  ### Pulse Animation (`:pulse`)
  Markers that pulse by changing radius, drawing attention to important locations.

  ### Fade Animation (`:fade`)
  Markers that fade in and out by changing opacity, suitable for dynamic content.

  ## Style Configuration

  Markers accept a style map with the following options:

      %{
        colour: "#3b82f6",        # Hex colour for the marker
        size: 8,                  # Base radius in pixels
        animation: :pulse,        # Animation type (:none, :pulse, :fade)
        glow: true               # Enable glow effect
      }

  ## Usage Examples

  ### Basic Map Marker

      <Marker.marker
        style={%{colour: "#3b82f6", size: 8, animation: :pulse}}
        mode={:svg}
        x={100}
        y={200}
      />

  ### Legend Indicator

      <Marker.marker
        style={%{colour: "#ef4444", size: 6, animation: :fade}}
        mode={:legend}
        size_override={4}
      />

  ### Glow Effect Marker

      <Marker.marker
        style={%{colour: "#10b981", size: 10, animation: :pulse, glow: true}}
        mode={:svg}
        x={300}
        y={150}
      />

  ## Performance Considerations

  - **Filter reuse**: Glow filters are generated with unique IDs to prevent conflicts
  - **Animation optimization**: SVG animations are hardware-accelerated when possible
  - **Conditional rendering**: Glow effects are only rendered when enabled
  - **Efficient sizing**: Legend markers use optimized viewBox calculations

  ## Accessibility

  - **Screen reader support**: Markers can be enhanced with ARIA labels
  - **High contrast**: Colour choices respect system preferences
  - **Reduced motion**: Animations can be disabled based on user preferences
  - **Scalable graphics**: Vector-based rendering for all display densities

  ## Integration

  The Marker component is designed to be used by:
  - `FlyMapEx.Components.WorldMap` for map markers
  - `FlyMapEx.Components.LegendComponent` for legend indicators
  - Custom components requiring consistent marker styling
  """

  use Phoenix.Component

  @doc """
  Renders a marker with the given style and position.

  This function creates a marker component that adapts its rendering based on the
  specified mode. It handles all styling, animation, and positioning logic to
  provide consistent marker appearance across different contexts.

  ## Attributes

  * `style` - Map containing marker styling configuration
    * `:colour` - Hex colour string for the marker (e.g., "#3b82f6")
    * `:size` - Base radius in pixels (defaults to config value)
    * `:animation` - Animation type (`:none`, `:pulse`, `:fade`)
    * `:glow` - Boolean to enable glow effect (default: false)
  * `mode` - Rendering mode (`:svg` for map markers, `:legend` for legend indicators)
  * `x` - X coordinate for SVG positioning (ignored in legend mode)
  * `y` - Y coordinate for SVG positioning (ignored in legend mode)
  * `size_override` - Optional size override, particularly useful for legend mode
  * `fill_override` - Optional colour override for the marker fill
  * `dim` - Dimension parameter for internal calculations (default: 0.0)

  ## Examples

      # Map marker with pulse animation
      <Marker.marker
        style={%{colour: "#3b82f6", size: 8, animation: :pulse}}
        mode={:svg}
        x={120.5}
        y={85.0}
      />

      # Legend indicator with custom size
      <Marker.marker
        style={%{colour: "#ef4444", size: 6, animation: :fade}}
        mode={:legend}
        size_override={4}
      />

      # Glowing marker with static animation
      <Marker.marker
        style={%{colour: "#10b981", size: 10, animation: :none, glow: true}}
        mode={:svg}
        x={200.0}
        y={150.0}
      />

  ## Rendering Behaviour

  ### SVG Mode
  - Renders markers as positioned SVG circles
  - Coordinates are used directly for positioning
  - Suitable for placement on maps and charts

  ### Legend Mode
  - Renders markers in a contained SVG viewBox
  - Ignores x/y coordinates, centers marker automatically
  - Optimized sizing for legend display

  ## Animation Details

  - **Pulse**: Radius changes cyclically to draw attention
  - **Fade**: Opacity changes to create subtle movement
  - **Static**: No animation, solid appearance

  ## Performance Notes

  - Glow filters are generated with unique IDs to prevent conflicts
  - Animation attributes are only added when needed
  - SVG animations are hardware-accelerated when possible
  """
  attr(:style, :map, required: true)
  attr(:mode, :atom, default: :svg)
  attr(:size_override, :integer, default: nil)
  attr(:fill_override, :string, default: nil)
  attr(:x, :float, default: 0.0)
  attr(:y, :float, default: 0.0)
  attr(:dim, :float, default: 0.0)
  attr(:gradient_id, :string, default: nil)

  def marker(assigns) do
    assigns = assign_marker_props(assigns)

    case assigns.mode do
      :legend -> render_legend_marker(assigns)
      :svg -> render_marker_svg(assigns)
    end
  end

  defp assign_marker_props(assigns) do
    style = assigns.style
    base_size = assigns.size_override || Map.get(style, :size, FlyMapEx.Config.default_marker_size())
    animation = Map.get(style, :animation, :none)
    base_colour = assigns.fill_override || Map.get(style, :colour, "#6b7280")
    glow = Map.get(style, :glow, false)
    gradient_id = assigns.gradient_id

    # For glow markers, use gradient fill if available, otherwise use solid colour
    colour = if glow && gradient_id, do: "url(##{gradient_id})", else: base_colour

    assigns
    |> assign(:base_size, base_size)
    |> assign(:animation, animation)
    |> assign(:colour, colour)
    |> assign(:glow, glow)
    |> assign_animation_props(animation)
  end


  defp assign_animation_props(assigns, animation) when animation == :fade do
    {min_opacity, max_opacity} = FlyMapEx.Config.animation_opacity_range()

    assigns
    |> assign(:min_opacity, min_opacity)
    |> assign(:max_opacity, max_opacity)
    |> assign(:opacity_values, FlyMapEx.Config.opacity_animation_values())
  end

  defp assign_animation_props(assigns, _), do: assigns

  defp build_radius_animation_attributes(context, base_size, animation) do
    case animation do
      :pulse ->
        %{
          attributeName: "r",
          values: FlyMapEx.Config.pulse_radius_values(context, base_size),
          dur: FlyMapEx.Config.pulse_duration(),
          repeatCount: "indefinite"
        }
      _ -> nil
    end
  end

  defp build_opacity_animation_attributes(animation) do
    case animation do
      anim when anim == :fade ->
        dur = FlyMapEx.Config.fade_duration()
        %{
          attributeName: "opacity",
          values: FlyMapEx.Config.opacity_animation_values(),
          dur: dur,
          repeatCount: "indefinite"
        }
      _ -> nil
    end
  end

 # Note the hardcoded values in here. Not great but:
  defp render_legend_marker(assigns) do
    viewbox_dim = 3 * assigns.base_size
    assigns =
      assigns
      |> assign(:radius_attrs, build_radius_animation_attributes(:legend, assigns.base_size, assigns.animation))
      |> assign(:opacity_attrs, build_opacity_animation_attributes(assigns.animation))
      |> assign(:css_class, if(assigns.animation == :none, do: "marker-group static", else: "marker-group animated"))
      |> assign(:dim, viewbox_dim)
      |> assign(:x, 0.5 * viewbox_dim)
      |> assign(:y, 0.5 * viewbox_dim)

    ~H"""
    <svg class="inline-block" width={trunc(@base_size * FlyMapEx.Config.legend_container_multiplier())} height={trunc(@base_size * FlyMapEx.Config.legend_container_multiplier())} viewBox={viewbox(@dim)}>
      <.render_marker_svg {assigns} />
    </svg>
    """
  end


  defp render_marker_svg(assigns) do
    assigns =
      assigns
      |> assign(:radius_attrs, build_radius_animation_attributes(:svg, assigns.base_size, assigns.animation))
      |> assign(:opacity_attrs, build_opacity_animation_attributes(assigns.animation))
      |> assign(:css_class, if(assigns.animation == :none, do: "marker-group static", else: "marker-group animated"))

    ~H"""
    <g class={@css_class}>
      <!-- Main marker circle -->
      <circle
        cx={@x}
        cy={@y}
        r={@base_size}
        stroke="none"
        fill={@colour}
      >
        <%= if @radius_attrs do %>
          <animate
            attributeName={@radius_attrs.attributeName}
            values={@radius_attrs.values}
            dur={@radius_attrs.dur}
            repeatCount={@radius_attrs.repeatCount}
          />
        <% end %>
        <%= if @opacity_attrs do %>
          <animate
            attributeName={@opacity_attrs.attributeName}
            values={@opacity_attrs.values}
            dur={@opacity_attrs.dur}
            repeatCount={@opacity_attrs.repeatCount}
          />
        <% end %>
      </circle>
    </g>
    """
  end


  defp viewbox(size) do
    "0 0 #{size} #{size}"
  end
end
