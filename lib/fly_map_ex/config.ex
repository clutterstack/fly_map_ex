defmodule FlyMapEx.Config do
  @moduledoc """
  Application-wide configuration for FlyMapEx.

  Provides centralized configuration for opacity settings that apply
  across all marker groups and styles.
  """

  @doc """
  Base opacity for markers in their default state.

  Default: 0.8
  """
  def marker_opacity do
    Application.get_env(:fly_map_ex, :marker_opacity, 1.0)
  end

  @doc """
  Opacity for markers in hover state.

  Default: 1.0
  """
  def hover_opacity do
    Application.get_env(:fly_map_ex, :hover_opacity, 1.0)
  end

  @doc """
  Opacity range for animated markers as {min, max} tuple.
  Used by pulse and fade animations.

  Default: {0.3, 1.0}
  """
  def animation_opacity_range do
    Application.get_env(:fly_map_ex, :animation_opacity_range, {0.5, 1.0})
  end

  @doc """
  Base radius for marker circles in pixels.

  Default: 2
  """
  def marker_base_radius do
    Application.get_env(:fly_map_ex, :marker_base_radius, 2)
  end

  @doc """
  Neutral colour for Fly region markers in light mode.

  This colour should contrast well with light backgrounds.
  Default: "#6b7280" (medium gray)
  """
  def neutral_marker_light do
    Application.get_env(:fly_map_ex, :neutral_marker_light, "#6b7280")
  end

  @doc """
  Neutral colour for Fly region markers in dark mode.

  This colour should contrast well with dark backgrounds.
  Default: "#9ca3af" (light gray)
  """
  def neutral_marker_dark do
    Application.get_env(:fly_map_ex, :neutral_marker_dark, "#9ca3af")
  end

  @doc """
  Neutral colour for Fly region marker text in light mode.

  Default: "#374151" (dark gray)
  """
  def neutral_text_light do
    Application.get_env(:fly_map_ex, :neutral_text_light, "#374151")
  end

  @doc """
  Neutral colour for Fly region marker text in dark mode.

  Default: "#d1d5db" (light gray)
  """
  def neutral_text_dark do
    Application.get_env(:fly_map_ex, :neutral_text_dark, "#d1d5db")
  end

  @doc """
  Default visibility setting for Fly region markers.

  When true, shows small gray region markers for all Fly.io regions.
  When false, hides region markers completely.
  Default: true
  """
  def show_regions_default do
    Application.get_env(:fly_map_ex, :show_regions, true)
  end

  @doc """
  Animation duration for pulse animations in seconds.

  Default: "2.5s"
  """
  def pulse_duration do
    Application.get_env(:fly_map_ex, :pulse_duration, "2.5s")
  end

  @doc """
  Animation duration for fade animations in seconds.

  Default: "3s"
  """
  def fade_duration do
    Application.get_env(:fly_map_ex, :fade_duration, "3s")
  end

  @doc """
  Size multiplier for pulse animation radius changes in SVG context.

  Default: 2 (adds 2 pixels to base radius during pulse)
  """
  def svg_pulse_size_delta do
    Application.get_env(:fly_map_ex, :svg_pulse_size_delta, 2)
  end

  @doc """
  Generates pulse animation values for radius based on context and base size.

  ## Parameters
  - base_size: base radius size

  Returns: string of animation values for SVG animate element
  """
  def pulse_radius_values(context, base_size) do
        max_size = base_size + svg_pulse_size_delta()
        "#{base_size};#{max_size};#{base_size}"
  end

  @doc """
  Generates opacity animation values string from the configured range.

  Returns: string of animation values for SVG animate element
  """
  def opacity_animation_values do
    {min_opacity, max_opacity} = animation_opacity_range()
    "#{min_opacity};#{max_opacity};#{min_opacity}"
  end

  @doc """
  Default layout mode for the map and legend.

  - :stacked - Legend below the map (default)
  - :side_by_side - Legend beside the map with 65% width for map, 35% for legend

  Default: :stacked
  """
  def layout_mode do
    Application.get_env(:fly_map_ex, :layout_mode, :stacked)
  end

  @doc """
  Blur radius for glow effects in pixels.

  Controls how spread out the glow effect appears around markers.
  Default: 2
  """
  def glow_blur_radius do
    Application.get_env(:fly_map_ex, :glow_blur_radius, 2)
  end

  @doc """
  Opacity for glow effects.

  Controls how transparent/opaque the glow appears.
  Default: 0.6
  """
  def glow_opacity do
    Application.get_env(:fly_map_ex, :glow_opacity, 0.6)
  end

  @doc """
  Size multiplier for glow effects relative to marker size.

  Determines how much larger the glow is compared to the base marker.
  Default: 1.5
  """
  def glow_size_multiplier do
    Application.get_env(:fly_map_ex, :glow_size_multiplier, 1.5)
  end

  @doc """
  Size multiplier for legend marker SVG containers relative to marker size.

  Determines how much larger the legend SVG container is compared to the base marker.
  This affects the visual size of legend markers.
  Default: 2.0
  """
  def legend_container_multiplier do
    Application.get_env(:fly_map_ex, :legend_container_multiplier, 2.0)
  end

  @doc """
  Default marker size in pixels when no size is specified in style.

  This is used as the fallback size for markers when neither size_override
  nor style.size is provided.
  Default: 6
  """
  def default_marker_size do
    Application.get_env(:fly_map_ex, :default_marker_size, 6)
  end
end
