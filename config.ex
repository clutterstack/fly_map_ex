defmodule FlyMapEx.Config do
  @moduledoc """
  Configuration presets and themes for FlyMapEx components.

  Provides predefined color schemes, sizing options, and complete themes
  that can be easily applied to customize the appearance of the world map.
  """

  @doc """
  Get a predefined color scheme.

  ## Available Schemes

  * `:default` - Blue, yellow, orange, violet (current default)
  * `:cool` - Cool blues and teals
  * `:warm` - Warm oranges and reds
  * `:minimal` - Grayscale with subtle accents
  * `:high_contrast` - High contrast colors for accessibility
  * `:dark` - Dark theme colors
  * `:neon` - Bright neon colors

  ## Examples

      iex> FlyMapEx.Config.color_scheme(:cool)
      %{
        our_nodes: "#4f46e5",
        active_nodes: "#06b6d4",
        expected_nodes: "#0891b2",
        ack_nodes: "#6366f1"
      }
  """
  def color_scheme(:default) do
    %{
      our_nodes: "#77b5fe",      # Blue
      active_nodes: "#ffdc66",   # Yellow
      expected_nodes: "#ff8c42", # Orange
      ack_nodes: "#9d4edd",      # Plasma violet
      background: "#444444",     # Map background
      border: "#DAA520"          # Map border
    }
  end

  @doc """
  Get predefined group styles for different marker types.

  ## Available Styles

  * `:primary` - Blue animated markers for primary/local nodes
  * `:active` - Yellow markers for active/healthy nodes
  * `:expected` - Orange animated markers for expected/planned nodes
  * `:acknowledged` - Violet markers for acknowledged/responding nodes
  * `:secondary` - Green markers for secondary/backup nodes
  * `:warning` - Red markers for problematic nodes
  * `:inactive` - Gray markers for inactive nodes

  ## Examples

      iex> FlyMapEx.Config.group_styles()
      %{
        primary: %{color: "#77b5fe", animated: true, label: "Primary"},
        active: %{color: "#ffdc66", animated: false, label: "Active"},
        ...
      }
  """
  def group_styles() do
    %{
      primary: %{
        color: "#77b5fe",
        animated: true,
        label: "Primary"
      },
      active: %{
        color: "#ffdc66", 
        animated: false,
        label: "Active"
      },
      expected: %{
        color: "#ff8c42",
        animated: true,
        label: "Expected"
      },
      acknowledged: %{
        color: "#9d4edd",
        animated: false,
        label: "Acknowledged"
      },
      secondary: %{
        color: "#28a745",
        animated: false,
        label: "Secondary"
      },
      warning: %{
        color: "#dc3545",
        animated: true,
        label: "Warning"
      },
      inactive: %{
        color: "#6c757d",
        animated: false,
        label: "Inactive"
      }
    }
  end

  def color_scheme(:cool) do
    %{
      our_nodes: "#4f46e5",      # Indigo
      active_nodes: "#06b6d4",   # Cyan
      expected_nodes: "#0891b2", # Cyan darker
      ack_nodes: "#6366f1",      # Indigo lighter
      background: "#374151",     # Cool gray
      border: "#6b7280"          # Gray
    }
  end

  def color_scheme(:warm) do
    %{
      our_nodes: "#dc2626",      # Red
      active_nodes: "#f59e0b",   # Amber
      expected_nodes: "#ea580c", # Orange
      ack_nodes: "#e11d48",      # Rose
      background: "#451a03",     # Amber dark
      border: "#92400e"          # Amber
    }
  end

  def color_scheme(:minimal) do
    %{
      our_nodes: "#374151",      # Gray dark
      active_nodes: "#6b7280",   # Gray
      expected_nodes: "#9ca3af", # Gray light
      ack_nodes: "#111827",      # Gray darkest
      background: "#f9fafb",     # Gray lightest
      border: "#d1d5db"          # Gray border
    }
  end

  def color_scheme(:high_contrast) do
    %{
      our_nodes: "#000000",      # Black
      active_nodes: "#ffffff",   # White
      expected_nodes: "#ff0000", # Pure red
      ack_nodes: "#00ff00",      # Pure green
      background: "#ffffff",     # White
      border: "#000000"          # Black
    }
  end

  def color_scheme(:dark) do
    %{
      our_nodes: "#60a5fa",      # Blue light
      active_nodes: "#fbbf24",   # Yellow
      expected_nodes: "#fb923c", # Orange
      ack_nodes: "#a78bfa",      # Purple
      background: "#1f2937",     # Gray dark
      border: "#4b5563"          # Gray
    }
  end

  def color_scheme(:neon) do
    %{
      our_nodes: "#00ffff",      # Cyan bright
      active_nodes: "#ffff00",   # Yellow bright
      expected_nodes: "#ff8000", # Orange bright
      ack_nodes: "#ff00ff",      # Magenta bright
      background: "#000000",     # Black
      border: "#ffffff"          # White
    }
  end

  def color_scheme(_), do: color_scheme(:default)

  @doc """
  Get predefined dimension configurations.

  ## Available Sizes

  * `:small` - Compact size for dashboards
  * `:medium` - Standard size (default)
  * `:large` - Large size for detailed views
  * `:full` - Full viewport size

  ## Examples

      iex> FlyMapEx.Config.dimensions(:small)
      %{width: 400, height: 196, minx: 0, miny: 5}
  """
  def dimensions(:small) do
    %{
      width: 400,
      height: 196,
      minx: 0,
      miny: 5
    }
  end

  def dimensions(:medium) do
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

  def dimensions(:full) do
    %{
      width: 1600,
      height: 640,
      minx: 0,
      miny: 20
    }
  end

  def dimensions(_), do: dimensions(:medium)

  @doc """
  Get a complete theme configuration.

  Combines colors, dimensions, and legend settings for common use cases.

  ## Available Themes

  * `:dashboard` - Compact theme for dashboard widgets
  * `:monitoring` - Default theme for monitoring applications
  * `:presentation` - Large theme for presentations and displays
  * `:minimal` - Clean minimal theme
  * `:dark` - Dark theme

  ## Examples

      iex> FlyMapEx.Config.theme(:dashboard)
      %{
        colors: %{...},
        dimensions: %{...},
        legend_config: %{...}
      }
  """
  def theme(:dashboard) do
    %{
      colors: color_scheme(:cool),
      dimensions: dimensions(:small),
      group_styles: group_styles(),
      legend_config: %{
        our_nodes_label: "Local",
        active_nodes_label: "Active",
        expected_nodes_label: "Expected",
        ack_nodes_label: "OK"
      }
    }
  end

  def theme(:monitoring) do
    %{
      colors: color_scheme(:default),
      dimensions: dimensions(:medium),
      group_styles: group_styles(),
      legend_config: %{
        our_nodes_label: "Our nodes",
        active_nodes_label: "Active nodes",
        expected_nodes_label: "Expected nodes",
        ack_nodes_label: "Acknowledged"
      }
    }
  end

  def theme(:presentation) do
    %{
      colors: color_scheme(:warm),
      dimensions: dimensions(:large),
      group_styles: group_styles(),
      legend_config: %{
        our_nodes_label: "Primary Deployment",
        active_nodes_label: "Active Regions",
        expected_nodes_label: "Planned Regions",
        ack_nodes_label: "Responding Regions"
      }
    }
  end

  def theme(:minimal) do
    %{
      colors: color_scheme(:minimal),
      dimensions: dimensions(:medium),
      group_styles: group_styles(),
      legend_config: %{
        show_our_nodes: true,
        show_active_nodes: true,
        show_expected_nodes: false,
        show_ack_nodes: false,
        our_nodes_label: "Local",
        active_nodes_label: "Remote"
      }
    }
  end

  def theme(:dark) do
    %{
      colors: color_scheme(:dark),
      dimensions: dimensions(:medium),
      group_styles: group_styles(),
      legend_config: %{
        our_nodes_label: "Our nodes",
        active_nodes_label: "Active nodes",
        expected_nodes_label: "Expected nodes",
        ack_nodes_label: "Acknowledged"
      }
    }
  end

  def theme(_), do: theme(:monitoring)

  @doc """
  Apply a theme to a set of component attributes.

  Merges theme configuration with user-provided attributes, allowing
  for theme-based defaults with custom overrides.

  ## Examples

      iex> attrs = %{our_regions: ["sjc"], show_progress: true}
      iex> FlyMapEx.Config.apply_theme(attrs, :dashboard)
      %{
        our_regions: ["sjc"],
        show_progress: true,
        colors: %{...},
        dimensions: %{...},
        legend_config: %{...}
      }
  """
  def apply_theme(attrs, theme_name) when is_map(attrs) do
    theme_config = theme(theme_name)

    # Merge theme config with user attributes, giving priority to user settings
    Map.merge(theme_config, attrs)
  end

  def apply_theme(attrs, _), do: attrs
end
