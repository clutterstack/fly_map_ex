defmodule FlyMapEx.Config do
  @moduledoc """
  Application-wide configuration for FlyMapEx.

  Provides centralized configuration for opacity settings that apply
  across all marker groups and styles.
  """

  @doc """
  Base opacity for markers in their default state.

  Default: 1.0

  ## Examples

      iex> FlyMapEx.Config.marker_opacity()
      1.0

  """
  def marker_opacity do
    Application.get_env(:fly_map_ex, :marker_opacity, 1.0)
  end

  # Note: Hover opacity removed - use CSS :hover states instead

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

  ## Examples

      iex> FlyMapEx.Config.region_marker_radius()
      2

  """
  def region_marker_radius do
    Application.get_env(:fly_map_ex, :region_marker_radius, round(0.5 * default_marker_radius()))
  end

  # Note: Neutral marker colors are now handled by the Theme module

  @doc """
  Default visibility setting for Fly region markers.

  When true, shows small gray region markers for all Fly.io regions.
  When false, hides region markers completely.
  Default: true
  """
  def show_regions_default do
    Application.get_env(:fly_map_ex, :show_regions, false)
  end

  @doc """
  Animation duration for all animations in seconds.

  Default: "2s"
  """
  def animation_duration do
    Application.get_env(:fly_map_ex, :animation_duration, "2s")
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
  - marker_radius: base radius size

  Returns: string of animation values for SVG animate element
  """
  def pulse_radius_values(_context, marker_radius) do
    max_size = marker_radius + svg_pulse_size_delta()
    "#{marker_radius};#{max_size};#{marker_radius}"
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
    Application.get_env(:fly_map_ex, :layout_mode, :side_by_side)
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

  This is used as the fallback size for markers when style.size is not provided.
  Default: 8
  """
  def default_marker_radius do
    Application.get_env(:fly_map_ex, :default_marker_radius, 8)
  end

  @doc """
  Default theme for maps when no theme is specified.

  Available themes: :light, :dark, :minimal, :cool, :warm, :high_contrast, :responsive
  or custom theme maps.
  Default: :light
  """
  def default_theme do
    Application.get_env(:fly_map_ex, :default_theme, :light)
  end
end
