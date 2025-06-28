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
    custom(
      "#f59e0b",
      Keyword.merge([size: 7, animated: true, animation: :pulse, gradient: true], opts)
    )
  end

  @doc """
  Danger/error state style - red, bouncing.
  """
  def danger(opts \\ []) do
    custom(
      "#ef4444",
      Keyword.merge([size: 9, animated: true, animation: :bounce, gradient: true], opts)
    )
  end

  @doc """
  Active/running state style - blue, pulsing.
  """
  def active(opts \\ []) do
    custom(
      "#3b82f6",
      Keyword.merge([size: 8, animated: true, animation: :pulse, gradient: true], opts)
    )
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
    custom(
      "#eab308",
      Keyword.merge([size: 7, animated: true, animation: :fade, gradient: true], opts)
    )
  end

  @doc """
  Info/neutral state style - light blue, static.
  """
  def info(opts \\ []) do
    custom("#0ea5e9", Keyword.merge([size: 6, animated: false], opts))
  end

  @doc """
  Primary state style - blue, pulsing.
  """
  def primary(opts \\ []) do
    custom(
      "#2563eb",
      Keyword.merge([size: 8, animated: true, animation: :pulse, gradient: true], opts)
    )
  end

  @doc """
  Expected state style - orange, pulsing.
  Alias for warning style for backward compatibility.
  """
  def expected(opts \\ []) do
    warning(opts)
  end

  @doc """
  Acknowledged state style - green, static.
  Alias for success style for backward compatibility.
  """
  def acknowledged(opts \\ []) do
    success(opts)
  end

  @doc """
  Secondary state style - teal, static.
  """
  def secondary(opts \\ []) do
    custom("#14b8a6", Keyword.merge([size: 6, animated: false], opts))
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
end
