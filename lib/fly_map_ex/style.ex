defmodule FlyMapEx.Style do

  require Logger

  @moduledoc """
  Style utilities for FlyMapEx markers.

  Provides style normalization, preset management, and color cycling utilities
  for marker styling. The primary interface is direct style maps.

  ## Primary Interface: Direct Style Maps

  The preferred way to define marker styles:

      %{nodes: ["sjc"], style: %{colour: "#10b981", size: 8}, label: "Production"}
      %{nodes: ["fra"], style: %{color: "#ef4444", size: 6, animation: :pulse}, label: "Critical"}
      %{nodes: ["ams"], style: %{colour: :blue, size: 8}, label: "Named Color"}
      %{nodes: ["ord"], style: %{colour: "var(--primary)", size: 10, glow: true}, label: "CSS Variable"}

  ## Semantic Presets

  Use configurable semantic presets for common states:

      %{nodes: ["sjc"], style: :operational, label: "Running"}
      %{nodes: ["fra"], style: :warning, label: "Degraded"}
      %{nodes: ["ams"], style: :danger, label: "Failed"}
      %{nodes: ["ord"], style: :inactive, label: "Offline"}

  ## Non-Semantic Styling

  For groups without specific semantic meaning, use color cycling or named colors:

      # Named colors for predictable styling
      groups = [
        %{nodes: ["sjc"], style: FlyMapEx.Style.named_colours(:blue), label: "App 1"},
        %{nodes: ["fra"], style: FlyMapEx.Style.named_colours(:green), label: "App 2"},
        %{nodes: ["ams"], style: FlyMapEx.Style.named_colours(:purple), label: "App 3"}
      ]

      # Automatic color cycling for dynamic groups
      groups = [
        %{nodes: ["sjc"], style: FlyMapEx.Style.cycle(0), label: "App 1"},
        %{nodes: ["fra"], style: FlyMapEx.Style.cycle(1), label: "App 2"},
        %{nodes: ["ams"], style: FlyMapEx.Style.cycle(2), label: "App 3"}
      ]

  ## Configuration

  Override default semantic presets in your config.exs:

      config :fly_map_ex, :default_presets,
        operational: %{colour: "#custom-green", size: 6},
        warning: %{colour: "#custom-amber", size: 6},
        danger: %{colour: "#custom-red", size: 6, animation: :pulse},
        inactive: %{colour: "#custom-gray", size: 4}

  Define custom presets for reusability:

      config :fly_map_ex, :style_presets,
        brand_primary: %{colour: "#your-brand", size: 8, animation: :pulse},
        monitoring_alert: %{colour: "#ff6b6b", size: 10, glow: true}
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

  @named_colours %{
    blue: "#2563eb",
    green:
    "#16a34a",
    red:
    "#dc2626",
    purple:
    "#9333ea",
    orange:
    "#ea580c",
    cyan:
    "#0891b2",
    yellow:
    "#ca8a04",
    pink:
    "#db2777",
    teal:
    "#0d9488",
    lime:
    "#65a30d",
    amber:
    "#d97706",
    indigo:
    "#4338ca"
  }

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

    defaults = [size: FlyMapEx.Config.default_marker_radius(), animation: :none, glow: false]
    merged_opts = Keyword.merge(defaults, opts)

    %{
      colour: colour,
      size: Keyword.get(merged_opts, :size),
      animation: Keyword.get(merged_opts, :animation),
      glow: Keyword.get(merged_opts, :glow),
      __source__: {:cycle, [index], opts}
    }
  end

  @doc """
  Get a non-semantic style by named colour.

  Useful for consistent styling when you want predictable colours.

  ## Examples

      FlyMapEx.Style.named_colours(:blue)
      FlyMapEx.Style.named_colours(:green, size: 8)
  """
  def named_colours(colour_name, opts \\ []) when is_atom(colour_name) do
    colour = @named_colours[colour_name]

    defaults = [size: FlyMapEx.Config.default_marker_radius(), animation: :none, glow: false]
    merged_opts = Keyword.merge(defaults, opts)

    %{
      colour: colour,
      size: Keyword.get(merged_opts, :size),
      animation: Keyword.get(merged_opts, :animation),
      glow: Keyword.get(merged_opts, :glow),
      __source__: {:named_colours, [colour_name], opts}
    }
  end

  # Note: FlyMapEx.Style.custom/2 has been removed.
  # Use direct style maps instead: %{colour: "#3b82f6", size: 10, animation: :pulse}

  @doc """
  Get a user-defined style preset from application configuration.

  User-defined presets can be configured in config.exs like:

      config :fly_map_ex, :style_presets,
        brand_primary: [colour: "#your-brand", size: 8, animation: :pulse],
        monitoring_alert: [colour: "#ff6b6b", size: 10, glow: true],
        dashboard_info: [colour: "#4dabf7", size: 6]

  ## Examples

      FlyMapEx.Style.preset(:brand_primary)
      FlyMapEx.Style.preset(:monitoring_alert)

  Returns `nil` if the preset is not found.
  """
  def preset(preset_name) when is_atom(preset_name) do
    case get_user_preset(preset_name) do
      nil -> nil
      preset_opts when is_list(preset_opts) ->
        colour = Keyword.get(preset_opts, :colour) || Keyword.get(preset_opts, :color)
        if colour do
          opts = Keyword.delete(preset_opts, :colour) |> Keyword.delete(:color)
          # Convert keyword list to map with defaults
          style_map = %{
            colour: colour,
            size: Keyword.get(opts, :size, 4),
            animation: Keyword.get(opts, :animation, :none),
            glow: Keyword.get(opts, :glow, false),
            __source__: {:preset, [preset_name], preset_opts}
          }
          style_map
        else
          nil
        end
      preset_map when is_map(preset_map) ->
        colour = Map.get(preset_map, :colour) || Map.get(preset_map, :color)
        if colour do
          # Normalize to ensure all required fields
          normalized = normalize(preset_map)
          %{normalized | __source__: {:preset, [preset_name], preset_map}}
        else
          nil
        end
    end
  end

  # Get a user-defined preset from application configuration.
  defp get_user_preset(preset_name) when is_atom(preset_name) do
    Application.get_env(:fly_map_ex, :style_presets, %{})
    |> case do
      presets when is_map(presets) -> Map.get(presets, preset_name)
      _ -> nil
    end
  end

  # Get a default semantic preset.
  defp get_default_preset(preset_name) when is_atom(preset_name) do
    # Get user-configured defaults or fall back to built-in defaults
    configured_defaults = Application.get_env(:fly_map_ex, :default_presets, %{})

    case Map.get(configured_defaults, preset_name) do
      nil -> get_builtin_preset(preset_name)
      custom_preset -> normalize(custom_preset)  # Ensure proper format
    end
  end

  # Built-in default presets - these are the fallback values
  defp get_builtin_preset(:operational) do
    %{
      colour: "#10b981",
      size: 4,
      animation: :none,
      glow: false
    }
  end

  defp get_builtin_preset(:warning) do
    %{
      colour: "#f59e0b",
      size: 4,
      animation: :none,
      glow: false
    }
  end

  defp get_builtin_preset(:danger) do
    %{
      colour: "#ef4444",
      size: 4,
      animation: :pulse,
      glow: false
    }
  end

  defp get_builtin_preset(:inactive) do
    %{
      colour: "#6b7280",
      size: 4,
      animation: :none,
      glow: false
    }
  end

  defp get_builtin_preset(_), do: nil

  # Private helper function to resolve color values, supporting named colors and hex strings.
  # Named colors can be referenced as atoms and will be resolved to their hex values.
  defp resolve_colour_value(colour) when is_atom(colour) do
    Map.get(@named_colours, colour)
  end

  defp resolve_colour_value(colour) when is_binary(colour) do
    colour
  end

  defp resolve_colour_value(_), do: nil

  # Note: Hard-coded style functions have been removed.
  # Use direct style maps: %{colour: "#10b981", size: 8}
  # Or configured presets: style: :operational
  # Semantic presets (:operational, :warning, :danger, :inactive) are now configurable.


  @doc """
  Normalize a style definition to ensure all required fields are present.

  Primary interface accepts direct style maps, with fallback to configured presets.
  This function handles the conversion from style formats to the standard
  style map format expected by the rendering components.

  ## Direct Style Maps (Primary Interface)

  The preferred way to define styles:

      %{colour: "#10b981", size: 8}
      %{color: "#ef4444", size: 6, animation: :pulse}
      %{colour: "var(--primary)", size: 10, glow: true}

  ## Preset Resolution

  Style atoms resolve to configured presets:

  * Default semantic presets: `:operational`, `:warning`, `:danger`, `:inactive`
  * User-defined presets (configured in :style_presets)
  * Unknown atoms fall back to `:operational` preset

  ## Examples

      FlyMapEx.Style.normalize(%{colour: "#10b981", size: 8})
      FlyMapEx.Style.normalize(:operational)  # resolves from config
      FlyMapEx.Style.normalize(:my_brand_primary)  # user-defined preset
  """
  def normalize(style) when is_map(style) do
    # Handle both colour/color keys and resolve named colors
    colour = Map.get(style, :colour) || Map.get(style, :color)
    resolved_colour = resolve_colour_value(colour)

    # Apply defaults for missing properties
    defaults = %{
      colour: resolved_colour || "#6b7280",
      size: Map.get(style, :size, 4),
      animation: Map.get(style, :animation, :none),
      glow: Map.get(style, :glow, false)
    }

    # Preserve any additional properties from the input style
    Map.merge(defaults, Map.delete(Map.delete(style, :colour), :color))
  end

  def normalize(style_atom) when is_nil(style_atom) do
    Logger.error("style_atom was nil;; something isn't right")
  end

  def normalize(style_atom) when is_atom(style_atom) do
    # Check for user-defined presets first, then fall back to default presets
    case preset(style_atom) do
      nil ->
        # Check default semantic presets
        case get_default_preset(style_atom) do
          nil -> get_default_preset(:operational)  # ultimate fallback
          preset_style -> preset_style
        end
      preset_style -> preset_style
    end
  end

  def normalize(_), do: get_default_preset(:operational)
end
