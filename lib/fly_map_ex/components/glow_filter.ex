defmodule FlyMapEx.Components.GlowFilter do
  @moduledoc """
  Shared SVG glow filter component for consistent glow effects across map and legend markers.
  """

  use Phoenix.Component

  @doc """
  Renders an SVG glow filter definition.

  ## Attributes

  * `filter_id` - Unique ID for the filter
  * `blur_radius` - Blur radius for the glow effect
  """
  attr(:filter_id, :string, required: true)
  attr(:blur_radius, :float, required: true)

  def glow_filter(assigns) do
    ~H"""
    <filter id={@filter_id} x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation={@blur_radius} result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
    """
  end
end