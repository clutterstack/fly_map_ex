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
      :svg -> render_marker_svg(assigns)
    end
  end

  defp assign_marker_props(assigns) do
    style = assigns.style
    base_size = assigns.size_override || Map.get(style, :size, 6)
    animation = Map.get(style, :animation, :none)
    colour = assigns.fill_override || Map.get(style, :colour, "#6b7280")
    glow = Map.get(style, :glow, false)

    assigns
    |> assign(:base_size, base_size)
    |> assign(:animation, animation)
    |> assign(:colour, colour)
    |> assign(:glow, glow)
    |> assign(:glow_size, base_size * FlyMapEx.Config.glow_size_multiplier())
    |> assign_animation_props(animation)
    |> assign_glow_props(glow, colour)
  end

  defp assign_glow_props(assigns, true, colour) do
    # Generate unique filter ID to avoid conflicts between markers
    filter_id = "glow-#{:erlang.phash2({assigns.x, assigns.y, colour})}"
    
    assigns
    |> assign(:filter_id, filter_id)
    |> assign(:glow_blur, FlyMapEx.Config.glow_blur_radius())
    |> assign(:glow_opacity, FlyMapEx.Config.glow_opacity())
  end

  defp assign_glow_props(assigns, false, _colour), do: assigns

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


  defp render_legend_marker(assigns) do
    assigns =
      assigns
      |> assign(:radius_attrs, build_radius_animation_attributes(:legend, assigns.base_size, assigns.animation))
      |> assign(:opacity_attrs, build_opacity_animation_attributes(assigns.animation))
      |> assign(:css_class, if(assigns.animation == :none, do: "marker-group static", else: "marker-group animated"))
      |> assign(:x, assigns.base_size)
      |> assign(:y, assigns.base_size)

    ~H"""
    <svg class="inline-block" width={@base_size * 2} height={@base_size * 2} viewBox={viewbox(@base_size)}>
      <%= if @glow do %>
        <defs>
          <.render_glow_filter {assigns} />
        </defs>
      <% end %>
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
      <%= if @glow do %>
        <!-- Glow effect background circle -->
        <circle
          cx={@x}
          cy={@y}
          r={@glow_size}
          stroke="none"
          fill={@colour}
          opacity={@glow_opacity}
          filter={"url(##{@filter_id})"}
        />
      <% end %>
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

  defp render_glow_filter(assigns) do
    ~H"""
    <filter id={@filter_id} x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation={@glow_blur} result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
    """
  end

  defp viewbox(size) do
    total = size * 2
    "0 0 #{total} #{total}"
  end
end
