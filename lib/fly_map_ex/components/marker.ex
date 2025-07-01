defmodule FlyMapEx.Components.Marker do
  @moduledoc """
  Reusable marker component for rendering consistent markers in both maps and legends.

  Supports all animation types with proper SVG animations.
  """

  use Phoenix.Component

  @doc """
  Renders a marker with the given style and position.

  ## Attributes

  * `style` - Map containing marker styling (colour, size, animation, glow, etc.)
  * `x` - X coordinate (for SVG positioning, ignored in legend mode)
  * `y` - Y coordinate (for SVG positioning, ignored in legend mode)
  * `mode` - :svg for map markers, :legend for legend indicators
  * `size_override` - Optional size override for legend mode
  * `fill_override` - Optional fill override
  """
  attr(:style, :map, required: true)
  attr(:x, :float, default: 0.0)
  attr(:y, :float, default: 0.0)
  attr(:mode, :atom, default: :svg)
  attr(:size_override, :integer, default: nil)
  attr(:fill_override, :string, default: nil)

  def marker(assigns) do
    assigns = assign_marker_props(assigns)

    case assigns.mode do
      :legend -> render_legend_marker(assigns)
      :svg -> render_svg_marker(assigns)
    end
  end

  defp assign_marker_props(assigns) do
    style = assigns.style
    base_size = assigns.size_override || Map.get(style, :size, 6)
    animation = Map.get(style, :animation, :none)
    colour = assigns.fill_override || Map.get(style, :colour, "#6b7280")
    glow = Map.get(style, :glow, false)

    # Get the marker's base opacity (1.0 for static, or animation range for animated)
    marker_opacity = case animation do
      :none -> FlyMapEx.Config.marker_opacity()
      _ -> 
        {_, max_opacity} = FlyMapEx.Config.animation_opacity_range()
        max_opacity
    end

    assigns
    |> assign(:base_size, base_size)
    |> assign(:animation, animation)
    |> assign(:colour, colour)
    |> assign(:glow, glow)
    |> assign(:glow_size, base_size * 2.2)
    |> assign(:marker_opacity, marker_opacity)
    |> assign(:glow_id, "glow-#{:erlang.unique_integer([:positive])}")
    |> assign_animation_props(animation)
  end

  defp assign_animation_props(assigns, animation) when animation in [:pulse, :fade] do
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
      anim when anim in [:pulse, :fade] ->
        dur = if anim == :pulse, do: FlyMapEx.Config.pulse_duration(), else: FlyMapEx.Config.fade_duration()
        %{
          attributeName: "opacity",
          values: FlyMapEx.Config.opacity_animation_values(),
          dur: dur,
          repeatCount: "indefinite"
        }
      _ -> nil
    end
  end


  defp render_legend_marker(assigns) do
    assigns =
      assigns
      |> assign(:radius_attrs, build_radius_animation_attributes(:legend, assigns.base_size, assigns.animation))
      |> assign(:opacity_attrs, build_opacity_animation_attributes(assigns.animation))
      |> assign(:static_radius, assigns.base_size * FlyMapEx.Config.legend_size_ratio())
      |> assign(:glow_radius, assigns.glow_size * FlyMapEx.Config.legend_size_ratio())

    ~H"""
    <svg class="inline-block" width={@base_size * 2} height={@base_size * 2} viewBox={viewbox(@base_size)}>
      <%= if @glow do %>
        <defs>
          <radialGradient id={@glow_id} cx="50%" cy="50%" r="50%">
            <stop offset="0%" stop-color={@colour} stop-opacity="1" />
            <stop offset="45%" stop-color={@colour} stop-opacity="0.7" />
            <stop offset="100%" stop-color={@colour} stop-opacity="0" />
          </radialGradient>
        </defs>
      <% end %>
      <circle 
        cx={@base_size} 
        cy={@base_size} 
        r={if @glow, do: @glow_radius, else: @static_radius} 
        stroke="none" 
        fill={if @glow, do: "url(##{@glow_id})", else: @colour}
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
    </svg>
    """
  end

  defp render_svg_marker(assigns) do
    assigns =
      assigns
      |> assign(:radius_attrs, build_radius_animation_attributes(:svg, assigns.base_size, assigns.animation))
      |> assign(:opacity_attrs, build_opacity_animation_attributes(assigns.animation))
      |> assign(:css_class, if(assigns.animation == :none, do: "marker-group static", else: "marker-group animated"))

    ~H"""
    <g class={@css_class}>
      <%= if @glow do %>
        <defs>
          <radialGradient id={@glow_id} cx="50%" cy="50%" r="50%">
            <stop offset="0%" stop-color={@colour} stop-opacity="1" />
            <stop offset="45%" stop-color={@colour} stop-opacity="0.7" />
            <stop offset="100%" stop-color={@colour} stop-opacity="0" />
          </radialGradient>
        </defs>
      <% end %>
      <circle 
        cx={@x} 
        cy={@y} 
        r={if @glow, do: @glow_size, else: @base_size} 
        stroke="none" 
        fill={if @glow, do: "url(##{@glow_id})", else: @colour}
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
    total = size * 2
    "0 0 #{total} #{total}"
  end
end
