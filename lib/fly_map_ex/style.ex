defmodule FlyMapEx.Style do
  @moduledoc """
  Style builder functions for FlyMapEx markers.
  
  Provides a clean API for creating marker styles without predefined presets.
  Styles are defined inline or built using semantic helper functions.
  
  ## Basic Usage
  
      # Inline style definition
      %{nodes: ["sjc"], style: [color: "#3b82f6", size: 8], label: "Custom"}
      
      # Using builder functions
      %{nodes: ["fra"], style: FlyMapEx.Style.success(), label: "Healthy"}
      %{nodes: ["ams"], style: FlyMapEx.Style.danger(size: 12), label: "Critical"}
  
  ## CSS Variables
  
  Styles support CSS custom properties for dynamic theming:
  
      %{nodes: ["sjc"], style: [color: "var(--primary)", size: 8], label: "Dynamic"}
  """
  
  @doc """
  Build a custom style with explicit parameters.
  
  ## Options
  
  * `color` - Hex color string or CSS variable (required)
  * `size` - Base marker size in pixels (default: 6)
  * `animated` - Whether marker should animate (default: false)
  * `animation` - Animation type: :none, :pulse, :bounce, :fade (default: :none)
  * `gradient` - Whether to use gradient fill (default: false)
  
  ## Examples
  
      FlyMapEx.Style.custom("#3b82f6", size: 10, animated: true)
      FlyMapEx.Style.custom("var(--danger-color)", animation: :bounce)
  """
  def custom(color, opts \\ []) do
    %{
      color: color,
      size: Keyword.get(opts, :size, 6),
      animated: Keyword.get(opts, :animated, false),
      animation: Keyword.get(opts, :animation, :none),
      gradient: Keyword.get(opts, :gradient, false)
    }
  end
  
  @doc """
  Success/healthy state style - green, static.
  """
  def success(opts \\ []) do
    custom("#10b981", Keyword.merge([size: 6, animated: false], opts))
  end
  
  @doc """
  Warning state style - orange, pulsing.
  """
  def warning(opts \\ []) do
    custom("#f59e0b", Keyword.merge([size: 7, animated: true, animation: :pulse, gradient: true], opts))
  end
  
  @doc """
  Danger/error state style - red, bouncing.
  """
  def danger(opts \\ []) do
    custom("#ef4444", Keyword.merge([size: 9, animated: true, animation: :bounce, gradient: true], opts))
  end
  
  @doc """
  Active/running state style - blue, pulsing.
  """
  def active(opts \\ []) do
    custom("#3b82f6", Keyword.merge([size: 8, animated: true, animation: :pulse, gradient: true], opts))
  end
  
  @doc """
  Inactive/stopped state style - gray, static.
  """
  def inactive(opts \\ []) do
    custom("#6b7280", Keyword.merge([size: 5, animated: false], opts))
  end
  
  @doc """
  Pending/processing state style - yellow, fading.
  """
  def pending(opts \\ []) do
    custom("#eab308", Keyword.merge([size: 7, animated: true, animation: :fade, gradient: true], opts))
  end
  
  @doc """
  Info/neutral state style - light blue, static.
  """
  def info(opts \\ []) do
    custom("#0ea5e9", Keyword.merge([size: 6, animated: false], opts))
  end
  
  @doc """
  Normalize a style definition to ensure all required fields are present.
  
  Accepts either a keyword list or map, returns a normalized map.
  
  ## Examples
  
      iex> FlyMapEx.Style.normalize([color: "#000", size: 10])
      %{color: "#000", size: 10, animated: false, animation: :none, gradient: false}
      
      iex> FlyMapEx.Style.normalize(%{color: "#fff"})
      %{color: "#fff", size: 6, animated: false, animation: :none, gradient: false}
  """
  def normalize(style) when is_list(style) do
    style |> Enum.into(%{}) |> normalize()
  end
  
  def normalize(style) when is_map(style) do
    defaults = %{
      color: "#6b7280",
      size: 6,
      animated: false,
      animation: :none,
      gradient: false
    }
    
    Map.merge(defaults, style)
  end
  
  @doc """
  Validate a style definition.
  
  Ensures the style has valid values for all fields.
  """
  def validate!(style) do
    normalized = normalize(style)
    
    unless is_binary(normalized.color) do
      raise ArgumentError, "Style color must be a string, got: #{inspect(normalized.color)}"
    end
    
    unless is_integer(normalized.size) and normalized.size > 0 do
      raise ArgumentError, "Style size must be a positive integer, got: #{inspect(normalized.size)}"
    end
    
    unless is_boolean(normalized.animated) do
      raise ArgumentError, "Style animated must be a boolean, got: #{inspect(normalized.animated)}"
    end
    
    unless normalized.animation in [:none, :pulse, :bounce, :fade] do
      raise ArgumentError, "Style animation must be one of [:none, :pulse, :bounce, :fade], got: #{inspect(normalized.animation)}"
    end
    
    unless is_boolean(normalized.gradient) do
      raise ArgumentError, "Style gradient must be a boolean, got: #{inspect(normalized.gradient)}"
    end
    
    normalized
  end
  
  @doc """
  Convert a style definition to CSS custom properties.
  
  Useful for dynamic theming at runtime.
  
  ## Examples
  
      iex> FlyMapEx.Style.to_css_vars(FlyMapEx.Style.success(), "primary")
      "--primary-color: #10b981; --primary-size: 6px; --primary-animated: false;"
  """
  def to_css_vars(style, prefix) do
    normalized = normalize(style)
    
    [
      "--#{prefix}-color: #{normalized.color}",
      "--#{prefix}-size: #{normalized.size}px", 
      "--#{prefix}-animated: #{normalized.animated}",
      "--#{prefix}-animation: #{normalized.animation}",
      "--#{prefix}-gradient: #{normalized.gradient}"
    ]
    |> Enum.join("; ")
    |> Kernel.<>(";")
  end
end