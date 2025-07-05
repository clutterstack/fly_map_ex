defmodule FlyMapEx.Style do
  @moduledoc """
  Style builder functions for FlyMapEx markers.

  Provides semantic styles for common states, non-semantic color cycling for multiple
  groups, and custom style building capabilities.

  ## Semantic Styles

  For markers with clear meaning:

      %{nodes: ["sjc"], style: FlyMapEx.Style.operational(), label: "Running"}
      %{nodes: ["fra"], style: FlyMapEx.Style.warning(), label: "Degraded"}
      %{nodes: ["ams"], style: FlyMapEx.Style.danger(), label: "Failed"}

  ## Non-Semantic Color Cycling

  For multiple groups without specific meaning:

      groups = [
        %{nodes: ["sjc"], style: FlyMapEx.Style.cycle(0), label: "App 1"},
        %{nodes: ["fra"], style: FlyMapEx.Style.cycle(1), label: "App 2"},
        %{nodes: ["ams"], style: FlyMapEx.Style.cycle(2), label: "App 3"}
      ]

  ## Custom Styles

      %{nodes: ["sjc"], style: FlyMapEx.Style.custom("#3b82f6", size: 8), label: "Custom"}
      %{nodes: ["fra"], style: [color: "var(--primary)", size: 6], label: "CSS Variable"}
  """

  # Colour palette for non-semantic cycling - maximum visual distinction
  @cycle_colours [
    # bright blue
    "#2563eb",
    # bright green
    "#16a34a",
    # bright red
    "#dc2626",
    # bright purple
    "#9333ea",
    # bright orange
    "#ea580c",
    # bright cyan
    "#0891b2",
    # bright yellow
    "#ca8a04",
    # bright pink
    "#db2777",
    # bright teal
    "#0d9488",
    # bright lime
    "#65a30d",
    # bright amber
    "#d97706",
    # bright indigo
    "#4338ca"
  ]

  @doc """
  Get the available non-semantic colours for cycling.

  Returns a list of hex colour strings that provide good visual distinction
  when used for multiple groups without semantic meaning.

  ## Examples

      iex> FlyMapEx.Style.colors()
      ["#3b82f6", "#10b981", "#f59e0b", ...]
  """
  def colours, do: @cycle_colours

  @doc """
  Get a non-semantic style by cycling through predefined colours.

  Useful when you have multiple groups but don't want to assign semantic meaning.
  Colours are chosen to provide good visual distinction.

  ## Examples

      FlyMapEx.Style.cycle(0)  # blue
      FlyMapEx.Style.cycle(1)  # emerald
      FlyMapEx.Style.cycle(10) # blue again (wraps around)
  """
  def cycle(index, opts \\ []) when is_integer(index) do
    colour = Enum.at(@cycle_colours, rem(index, length(@cycle_colours)))
    result = custom(colour, Keyword.merge([size: FlyMapEx.Config.default_marker_radius()], opts))
    Map.put(result, :__source__, {:cycle, [index], opts})
  end

  @doc """
  Build a custom style with explicit parameters.

  ## Options

  * `colour` - Hex colour string or CSS variable (required)
  * `size` - Base marker size in pixels (default: 6)
  * `animation` - Animation type: :none, :pulse, :fade (default: :none)
  * `glow` - Whether to add a glow effect around the marker (default: false)

  ## Examples

      FlyMapEx.Style.custom("#3b82f6", size: 10)
      FlyMapEx.Style.custom("var(--danger-colour)", animation: :pulse, glow: true)
  """
  def custom(colour, opts \\ []) do
    %{
      colour: colour,
      size: Keyword.get(opts, :size, FlyMapEx.Config.default_marker_radius()),
      animation: Keyword.get(opts, :animation, :none),
      glow: Keyword.get(opts, :glow, false),
      __source__: {:custom, [colour], opts}
    }
  end

  # Core semantic styles

  @doc """
  Operational/healthy state style - green, subtle animation.

  Use for nodes that are running normally and healthy.
  """
  def operational(opts \\ []) do
    result =
      custom(
        "#10b981",
        Keyword.merge([size: 4, animation: :none, glow: false], opts)
      )

    %{result | __source__: {:operational, [], opts}}
  end

  @doc """
  Warning/degraded state style - amber, static without glow.

  Use for nodes that are running but experiencing issues.
  """
  def warning(opts \\ []) do
    result =
      custom(
        "#f59e0b",
        Keyword.merge([size: 4, animation: :none, glow: false], opts)
      )

    %{result | __source__: {:warning, [], opts}}
  end

  @doc """
  Danger/failed state style - red, gentle pulse animation.

  Use for nodes that are failed or experiencing critical issues.
  """
  def danger(opts \\ []) do
    result =
      custom(
        "#ef4444",
        Keyword.merge([size: 4, animation: :pulse, glow: false], opts)
      )

    %{result | __source__: {:danger, [], opts}}
  end

  @doc """
  Inactive/stopped state style - gray, small and static.

  Use for nodes that are intentionally stopped or offline.
  """
  def inactive(opts \\ []) do
    result = custom("#6b7280", Keyword.merge([size: 4, animation: :none], opts))
    %{result | __source__: {:inactive, [], opts}}
  end

  # Additional useful styles

  @doc """
  Primary accent style - blue, static without glow.

  General purpose primary accent color.
  """
  def primary(opts \\ []) do
    result =
      custom(
        "#3b82f6",
        Keyword.merge([size: 4, animation: :none, glow: false], opts)
      )

    %{result | __source__: {:primary, [], opts}}
  end

  @doc """
  Secondary accent style - teal, static.

  General purpose secondary accent color.
  """
  def secondary(opts \\ []) do
    result = custom("#14b8a6", Keyword.merge([size: 4, animation: :none], opts))
    %{result | __source__: {:secondary, [], opts}}
  end

  @doc """
  Info/neutral state style - light blue, static.

  For informational or neutral states.
  """
  def info(opts \\ []) do
    result = custom("#0ea5e9", Keyword.merge([size: 4, animation: :none], opts))
    %{result | __source__: {:info, [], opts}}
  end

  # Backward compatibility aliases (deprecated)

  @doc """
  Active state style - alias for operational.

  **Deprecated**: Use `operational/1` instead.
  """
  def active(opts \\ []) do
    operational(opts)
  end

  @doc """
  Success state style - alias for operational.

  **Deprecated**: Use `operational/1` instead.
  """
  def success(opts \\ []) do
    operational(opts)
  end

  @doc """
  Normalize a style definition to ensure all required fields are present.

  Accepts style atoms, keyword lists, maps, or functions, and returns a normalized map.
  This function handles the conversion from various style formats to the standard
  style map format expected by the rendering components.

  ## Style Atom Resolution

  Resolves semantic and non-semantic style atoms:

  * `:operational`, `:warning`, `:danger`, `:inactive` - Core semantic styles
  * `:primary`, `:secondary`, `:info` - General purpose styles
  * `:active`, `:success` - Backward compatibility (map to `:operational`)
  * Unknown atoms fall back to `:info` style

  ## Examples


  """
  def normalize(style_atom) when is_atom(style_atom) do
    case style_atom do
      :operational -> operational()
      :warning -> warning()
      :danger -> danger()
      :inactive -> inactive()
      :primary -> primary()
      :secondary -> secondary()
      :info -> info()
      # Backward compatibility
      :active -> operational()
      :success -> operational()
      :acknowledged -> operational()
      :expected -> warning()
      # Fallback
      _ -> info()
    end
  end

  def normalize(style) when is_list(style) do
    style |> Enum.into(%{}) |> normalize()
  end

  def normalize(style) when is_map(style) do
    defaults = %{
      colour: "#6b7280",
      size: 4,
      animation: :none,
      glow: false
    }

    Map.merge(defaults, style)
  end

  def normalize(_), do: info()
end
