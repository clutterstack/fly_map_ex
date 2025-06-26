defmodule FlyMapEx.Config do
  @moduledoc """
  Configuration presets and themes for FlyMapEx components.

  Provides a unified style system that supports any number of custom node groups
  with semantic style names that work for any domain.
  """

  @doc """
  Get the complete set of predefined style definitions.

  ## Available Styles

  * `:primary` - Main/important items (blue, animated)
  * `:secondary` - Supporting items (green, static)
  * `:success` - Successful/healthy items (green, static)
  * `:warning` - Items needing attention (orange, animated)
  * `:danger` - Critical/failed items (red, animated)
  * `:info` - Informational items (blue, static)
  * `:active` - Currently active items (yellow, animated)
  * `:inactive` - Disabled/offline items (gray, static)
  * `:pending` - Items in progress (orange, animated)
  * `:completed` - Finished items (teal, static)
  * `:error` - Error state items (red, animated)
  * `:neutral` - Default/unknown items (gray, static)

  ## Examples

      iex> FlyMapEx.Config.style_definitions()[:primary]
      %{color: "#3b82f6", animated: true, label: "Primary"}

      # Create region groups with semantic styles
      region_groups = [
        %{regions: ["sjc", "fra"], style_key: :active, label: "Running Machines"},
        %{regions: ["lhr"], style_key: :inactive, label: "Stopped Machines"}
      ]
  """
  def style_definitions() do
    %{
      primary: %{
        color: "#3b82f6",    # Blue-500
        animated: true,
        label: "Primary"
      },
      secondary: %{
        color: "#10b981",   # Emerald-500
        animated: false,
        label: "Secondary"
      },
      success: %{
        color: "#059669",   # Emerald-600
        animated: false,
        label: "Success"
      },
      warning: %{
        color: "#d97706",   # Amber-600
        animated: true,
        label: "Warning"
      },
      danger: %{
        color: "#dc2626",   # Red-600
        animated: true,
        label: "Danger"
      },
      info: %{
        color: "#0ea5e9",   # Sky-500
        animated: false,
        label: "Info"
      },
      active: %{
        color: "#eab308",   # Yellow-500
        animated: true,
        label: "Active"
      },
      inactive: %{
        color: "#6b7280",   # Gray-500
        animated: false,
        label: "Inactive"
      },
      pending: %{
        color: "#f59e0b",   # Amber-500
        animated: true,
        label: "Pending"
      },
      completed: %{
        color: "#14b8a6",   # Teal-500
        animated: false,
        label: "Completed"
      },
      error: %{
        color: "#ef4444",   # Red-500
        animated: true,
        label: "Error"
      },
      neutral: %{
        color: "#9ca3af",   # Gray-400
        animated: false,
        label: "Neutral"
      }
    }
  end

  @doc """
  Helper function to easily create region groups with semantic styling.

  Takes a list of tuples {label, regions, style_key} and returns properly
  formatted region groups for use with FlyMapEx components.

  ## Examples

      # Simple usage
      groups = FlyMapEx.Config.build_region_groups([
        {"Started Machines", ["sjc", "fra"], :success},
        {"Stopped Machines", ["lhr", "ams"], :inactive},
        {"Pending Restart", ["yyz"], :warning}
      ])

      # Usage with FlyMapEx
      FlyMapEx.render(region_groups: groups, theme: :modern)
  """
  def build_region_groups(group_specs) when is_list(group_specs) do
    Enum.map(group_specs, fn
      {label, regions, style_key} when is_binary(label) and is_list(regions) and is_atom(style_key) ->
        %{
          regions: regions,
          style_key: style_key,
          label: label
        }

      invalid ->
        raise ArgumentError, "Invalid group spec: #{inspect(invalid)}. Expected {label, regions, style_key}"
    end)
  end


  @doc """
  Get predefined dimension configurations.

  ## Available Sizes

  * `:compact` - Small size for widgets and dashboards
  * `:standard` - Default medium size
  * `:large` - Large size for detailed views
  * `:fullscreen` - Maximum size for presentations

  ## Examples

      iex> FlyMapEx.Config.dimensions(:compact)
      %{width: 400, height: 196, minx: 0, miny: 5}
  """
  def dimensions(:compact) do
    %{
      width: 400,
      height: 196,
      minx: 0,
      miny: 5
    }
  end

  def dimensions(:standard) do
    %{
      width: 800,
      height: 320,
      minx: 0,
      miny: 10
    }
  end

  def dimensions(:large) do
    %{
      width: 1200,
      height: 480,
      minx: 0,
      miny: 15
    }
  end

  def dimensions(:fullscreen) do
    %{
      width: 1600,
      height: 640,
      minx: 0,
      miny: 20
    }
  end

  # Legacy aliases for backward compatibility during transition
  def dimensions(:small), do: dimensions(:compact)
  def dimensions(:medium), do: dimensions(:standard)
  def dimensions(:full), do: dimensions(:fullscreen)
  def dimensions(_), do: dimensions(:standard)

  @doc """
  Get background and border color schemes for themes.

  ## Available Schemes

  * `:light` - Light background theme
  * `:dark` - Dark background theme
  * `:cool` - Cool blues and grays
  * `:warm` - Warm earth tones
  * `:minimal` - Clean grayscale
  * `:high_contrast` - High contrast for accessibility

  ## Examples

      iex> FlyMapEx.Config.background_scheme(:dark)
      %{land: "#1f2937", border: "#4b5563"}
  """
  def background_scheme(:light) do
    %{
      land: "#888888",
      ocean: "#aaaaaa",
      border: "#0f172a",  # Slate-900 - Very dark for better contrast
    }
  end

  def background_scheme(:dark) do
    %{
      land: "#0f172a",  # Slate-900 - Very dark for better contrast
      ocean: "#aaaaaa",
      border: "#334155"       # Slate-700 - Subtle border
      # "#DAA520"
    }
  end

  def background_scheme(:cool) do
    %{
      land: "#f1f5f9",  # Slate-100
      ocean: "#aaaaaa",
      border: "#64748b"       # Slate-500
    }
  end

  def background_scheme(:warm) do
    %{
      land: "#fef7ed",  # Orange-50
      ocean: "#aaaaaa",
      border: "#c2410c"       # Orange-700
    }
  end

  def background_scheme(:minimal) do
    %{
      land: "#ffffff",  # White
      ocean: "#aaaaaa",
      border: "#e5e7eb"       # Gray-200
    }
  end

  def background_scheme(:high_contrast) do
    %{
      land: "#ffffff",  # White
      ocean: "#aaaaaa",
      border: "#000000"       # Black
    }
  end

  def background_scheme(_), do: background_scheme(:light)

  @doc """
  Get a complete theme configuration.

  Themes now focus on visual styling and are label-agnostic.
  Your region groups provide the labels and data.

  ## Available Themes

  * `:compact` - Small size for widgets
  * `:standard` - Default medium size theme
  * `:large` - Large size for detailed views
  * `:dark` - Dark background theme
  * `:minimal` - Clean minimal theme
  * `:modern` - Modern styling with cool colors

  ## Examples

      # Theme provides visual styling
      theme_config = FlyMapEx.Config.theme(:modern)

      # Your region groups provide the data and labels
      region_groups = [
        %{regions: ["sjc"], style_key: :success, label: "Running"},
        %{regions: ["fra"], style_key: :inactive, label: "Stopped"}
      ]

      # Combine them
      FlyMapEx.render(region_groups: region_groups, theme: :modern)
  """
  def theme(:compact) do
    %{
      dimensions: dimensions(:compact),
      background: background_scheme(:light),
      styles: style_definitions()
    }
  end

  def theme(:standard) do
    %{
      dimensions: dimensions(:standard),
      background: background_scheme(:light),
      styles: style_definitions()
    }
  end

  def theme(:large) do
    %{
      dimensions: dimensions(:large),
      background: background_scheme(:light),
      styles: style_definitions()
    }
  end

  def theme(:dark) do
    %{
      dimensions: dimensions(:standard),
      background: background_scheme(:dark),
      styles: style_definitions()
    }
  end

  def theme(:minimal) do
    %{
      dimensions: dimensions(:standard),
      background: background_scheme(:minimal),
      styles: style_definitions()
    }
  end

  def theme(:modern) do
    %{
      dimensions: dimensions(:standard),
      background: background_scheme(:cool),
      styles: style_definitions()
    }
  end

  # Legacy themes for backward compatibility during transition
  def theme(:dashboard), do: theme(:compact)
  def theme(:monitoring), do: theme(:standard)
  def theme(:presentation), do: theme(:large)
  def theme(_), do: theme(:standard)

  @doc """
  Apply a theme to a set of component attributes.

  Merges theme configuration with user-provided attributes, allowing
  for theme-based defaults with custom overrides.

  ## Examples

      iex> attrs = %{region_groups: groups, show_progress: true}
      iex> FlyMapEx.Config.apply_theme(attrs, :modern)
      %{
        region_groups: groups,
        show_progress: true,
        dimensions: %{...},
        land: %{...},
        styles: %{...}
      }
  """
  def apply_theme(attrs, theme_name) when is_map(attrs) do
    theme_config = theme(theme_name)

    # Merge theme config with user attributes, giving priority to user settings
    Map.merge(theme_config, attrs)
  end

  def apply_theme(attrs, _), do: attrs
end
