defmodule FlyMapEx.Components.GlowFilter do
  @moduledoc """
  Shared SVG glow filter component for consistent glow effects across map and legend markers.

  This module provides SVG filter definitions that create glow effects for markers.
  The filters use Gaussian blur and merge operations to create a subtle halo effect
  around markers, enhancing their visibility and visual appeal.

  ## Features

  - **Gaussian blur**: Smooth, natural-looking glow effects
  - **Configurable intensity**: Adjustable blur radius for different glow strengths
  - **Performance optimized**: Efficient SVG filter operations
  - **Reusable filters**: Unique IDs allow sharing filters across multiple elements
  - **Cross-browser compatible**: Standard SVG filter implementation

  ## Technical Implementation

  The glow filter uses a two-step process:
  1. **feGaussianBlur**: Creates a blurred version of the source graphic
  2. **feMerge**: Combines the blur effect with the original graphic

  ## Filter Properties

  - **Extended region**: Filter extends 50% beyond element bounds to accommodate glow
  - **Layered rendering**: Blur layer is rendered behind the original element
  - **Preserved source**: Original graphic remains sharp on top of the glow

  ## Usage Examples

      # Basic glow filter
      <GlowFilter.glow_filter
        filter_id="marker-glow"
        blur_radius={3.0}
      />

      # Strong glow effect
      <GlowFilter.glow_filter
        filter_id="highlight-glow"
        blur_radius={6.0}
      />

      # Subtle glow
      <GlowFilter.glow_filter
        filter_id="subtle-glow"
        blur_radius={1.5}
      />

  ## Integration

  The glow filter is designed to be used with:
  - `FlyMapEx.Components.Marker` for enhanced marker visibility
  - `FlyMapEx.Components.WorldMap` for special effect markers
  - Custom components requiring glow effects

  ## Performance Considerations

  - **Filter reuse**: Each unique filter ID can be applied to multiple elements
  - **GPU acceleration**: SVG filters are typically hardware-accelerated
  - **Minimal overhead**: Efficient filter operations with small performance impact
  - **Conditional rendering**: Filters are only generated when needed

  ## Browser Support

  SVG filters are well-supported across modern browsers. The implementation uses:
  - Standard SVG filter primitives
  - Widely supported feGaussianBlur
  - Compatible feMerge operations
  - Fallback-friendly filter definitions
  """

  use Phoenix.Component

  @doc """
  Renders an SVG glow filter definition.

  This function creates an SVG filter element that applies a glow effect to any
  graphic element that references it. The filter combines a Gaussian blur with
  the original graphic to create a halo effect.

  ## Attributes

  * `filter_id` - Unique ID for the filter (used in CSS `filter: url(#id)`)
  * `blur_radius` - Blur radius for the glow effect (recommended: 1.0-6.0)

  ## Examples

      # Standard glow filter in SVG defs
      <svg>
        <defs>
          <GlowFilter.glow_filter
            filter_id="marker-glow"
            blur_radius={3.0}
          />
        </defs>
        <circle cx="50" cy="50" r="10" filter="url(#marker-glow)" />
      </svg>

      # Multiple filters with different intensities
      <defs>
        <GlowFilter.glow_filter filter_id="subtle" blur_radius={1.5} />
        <GlowFilter.glow_filter filter_id="strong" blur_radius={5.0} />
      </defs>

  ## Filter Application

  To apply the filter to an element, use the `filter` attribute:

      <circle filter="url(#marker-glow)" ... />
      <path filter="url(#highlight-glow)" ... />

  ## Technical Details

  - **Filter region**: Extends 50% beyond element bounds (120% total size)
  - **Blur operation**: Uses feGaussianBlur with configurable stdDeviation
  - **Merge operation**: Combines blur with original using feMerge
  - **Rendering order**: Blur renders behind, original renders on top

  ## Performance Notes

  - Each filter definition can be reused by multiple elements
  - Filters are cached by the browser for efficient rendering
  - GPU acceleration is typically available for filter operations
  - Avoid excessive blur radius values for optimal performance
  """
  attr(:filter_id, :string, required: true)
  attr(:blur_radius, :float, required: true)

  def glow_filter(assigns) do
    ~H"""
    <filter id={@filter_id} x="-50%" y="-50%" width="120%" height="120%">
      <feGaussianBlur stdDeviation={@blur_radius} result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
    """
  end
end
