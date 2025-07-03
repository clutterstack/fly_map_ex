defmodule FlyMapEx.Components.Marker do
  @moduledoc """
  Reusable marker component for rendering consistent markers in both maps and legends.

  Supports all animation types with proper SVG animations.
  """

  use Phoenix.Component

  alias FlyMapEx.Components.GlowFilter

  @doc """
  Renders a marker with the given style and position.

  ## Attributes

  * `style` - Map containing marker styling (colour, size, animation, glow, etc.)
  * `mode` - :svg for map markers, :legend for legend indicators
  * `x` - X coordinate (for SVG positioning, ignored in legend mode)
  * `y` - Y coordinate (for SVG positioning, ignored in legend mode)
  * `size_override` - Optional size override for legend mode
  * `fill_override` - Optional fill override
  """
  attr(:style, :map, required: true)
  attr(:mode, :atom, default: :svg)
  attr(:size_override, :integer, default: nil)
  attr(:fill_override, :string, default: nil)
  attr(:x, :float, default: 0.0)
  attr(:y, :float, default: 0.0)
  attr(:dim, :float, default: 0.0)

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
    filter_id = "glow-#{:erlang.phash2({0.5 * assigns.dim, 0.5 * assigns.dim, colour})}"

    assigns
    |> assign(:filter_id, filter_id)
    |> assign(:glow_blur, FlyMapEx.Config.glow_blur_radius())
    |> assign(:glow_opacity, FlyMapEx.Config.glow_opacity())
  end

  defp assign_glow_props(assigns, false, _colour), do: assigns

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
      <%= if @glow do %>
        <defs>
          <GlowFilter.glow_filter filter_id={@filter_id} blur_radius={@glow_blur} />
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


  defp viewbox(size) do
    "0 0 #{size} #{size}"
  end
end
