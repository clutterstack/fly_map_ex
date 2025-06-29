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
end