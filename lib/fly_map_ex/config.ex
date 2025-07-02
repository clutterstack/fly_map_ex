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

  Default: "2s"
  """
  def pulse_duration do
    Application.get_env(:fly_map_ex, :pulse_duration, "2s")
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

  Default: 4 (adds 4 pixels to base radius during pulse)
  """
  def svg_pulse_size_delta do
    Application.get_env(:fly_map_ex, :svg_pulse_size_delta, 3)
  end

  @doc """
  Size multiplier for legend marker radius relative to base size.

  Default: 0.7 (legend markers are 70% of base size)
  """
  def legend_size_ratio do
    Application.get_env(:fly_map_ex, :legend_size_ratio, 0.7)
  end

  @doc """
  Generates pulse animation values for radius based on context and base size.

  ## Parameters
  - context: :svg or :legend
  - base_size: base radius size

  Returns: string of animation values for SVG animate element
  """
  def pulse_radius_values(context, base_size) do
    case context do
      :svg ->
        max_size = base_size + svg_pulse_size_delta()
        "#{base_size};#{max_size};#{base_size}"
      :legend ->
        min_size = base_size * legend_size_ratio()
        "#{min_size};#{base_size};#{min_size}"
    end
  end

  @doc """
  Generates opacity animation values string from the configured range.

  Returns: string of animation values for SVG animate element
  """
  def opacity_animation_values do
    {min_opacity, max_opacity} = animation_opacity_range()
    "#{min_opacity};#{max_opacity};#{min_opacity}"
  end
end
