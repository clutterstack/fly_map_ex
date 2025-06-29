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
    Application.get_env(:fly_map_ex, :marker_opacity, 0.8)
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
    Application.get_env(:fly_map_ex, :animation_opacity_range, {0.3, 1.0})
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
end
