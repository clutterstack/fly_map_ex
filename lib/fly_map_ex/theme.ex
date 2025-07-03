defmodule FlyMapEx.Theme do
  @moduledoc """
  Map colour themes for FlyMapEx components.

  This module provides predefined colour themes for FlyMapEx maps, allowing for
  consistent visual styling across different use cases. Themes control the map
  background, borders, and neutral elements, while marker styles are defined
  separately using `FlyMapEx.Style`.

  ## Features

  - **Predefined themes**: Light, dark, minimal, cool, warm, and high contrast
  - **Custom themes**: Support for application-specific colour schemes
  - **Responsive themes**: CSS variable-based themes that adapt to system preferences
  - **Accessibility**: High contrast theme for improved readability
  - **Flexibility**: Easy theme switching and customization

  ## Theme Components

  Each theme defines colours for:
  - **Land**: Background colour for land masses
  - **Ocean**: Background colour for water bodies
  - **Border**: Colour for country borders and map edges
  - **Neutral marker**: Default colour for region markers
  - **Neutral text**: Colour for text labels and region names

  ## Usage Examples

  ### Basic Theme Usage

      # Use predefined theme
      <FlyMapEx.render marker_groups={groups} theme={:dark} />

      # Use with FlyMapEx.Component
      <.live_component
        module={FlyMapEx.Component}
        id="map"
        marker_groups={@groups}
        theme={:cool}
      />

  ### Manual Theme Application

      # Get theme colours directly
      theme_colours = FlyMapEx.Theme.map_theme(:warm)
      
      <FlyMapEx.Components.WorldMap.render
        marker_groups={@groups}
        colours={theme_colours}
      />

  ### Custom Theme Configuration

  Define custom themes in your application configuration:

      # config/config.exs
      config :fly_map_ex, :custom_themes,
        corporate: %{
          land: "#f8fafc",
          ocean: "#e2e8f0",
          border: "#475569",
          neutral_marker: "#64748b",
          neutral_text: "#334155"
        },
        brand: %{
          land: "#fef3c7",
          ocean: "#fed7aa",
          border: "#d97706",
          neutral_marker: "#92400e",
          neutral_text: "#451a03"
        }

      # Usage in templates
      <FlyMapEx.render marker_groups={groups} theme={:corporate} />

  ### Responsive Theme Usage

  Use CSS variable-based themes for automatic light/dark mode support:

      # Manual responsive theme
      responsive_colours = FlyMapEx.Theme.responsive_map_theme()
      
      <FlyMapEx.Components.WorldMap.render
        marker_groups={@groups}
        colours={responsive_colours}
      />

  ## Available Themes

  ### Light Theme (`:light`)
  Clean, bright theme suitable for most applications.

  ### Dark Theme (`:dark`)
  Dark background with subtle borders, ideal for dark mode interfaces.

  ### Minimal Theme (`:minimal`)
  Transparent backgrounds with subtle borders, perfect for overlay use.

  ### Cool Theme (`:cool`)
  Blue-toned theme with cool colours, suitable for technical applications.

  ### Warm Theme (`:warm`)
  Earth-toned theme with warm colours, ideal for friendly interfaces.

  ### High Contrast Theme (`:high_contrast`)
  Maximum contrast theme for accessibility compliance.

  ## Integration with CSS Frameworks

  The theme system integrates well with CSS frameworks like Tailwind CSS and DaisyUI:

      # Use with DaisyUI theme switching
      <div data-theme="dark">
        <FlyMapEx.render marker_groups={groups} theme={:dark} />
      </div>

  ## Performance Considerations

  - Themes are statically defined for optimal performance
  - CSS variables enable efficient runtime theme switching
  - Minimal memory footprint with shared colour definitions
  - No runtime theme computation overhead

  ## Customization Guidelines

  When creating custom themes:
  1. Ensure sufficient contrast between land and ocean colours
  2. Choose border colours that provide clear definition
  3. Select neutral marker colours that are visible on all backgrounds
  4. Test themes in both light and dark environments
  5. Consider accessibility requirements for colour choices
  """

  @doc """
  Get a map colour scheme by name or return a custom theme map.

  ## Available Themes

  * `:light` - Light with dark borders
  * `:dark` - Dark with subtle borders
  * `:cool` - Cool blue tones
  * `:warm` - Warm earth tones
  * `:high_contrast` - Maximum contrast for accessibility
  * `:responsive` - CSS variable-based theme for automatic light/dark adaptation

  ## Examples

      iex> FlyMapEx.Theme.map_theme(:dark)
      %{land: "#0f172a", ocean: "#aaaaaa", border: "#334155", neutral_marker: "#9ca3af", neutral_text: "#d1d5db"}

      iex> FlyMapEx.Theme.map_theme(:light)
      %{land: "#888888", ocean: "#aaaaaa", border: "#0f172a", neutral_marker: "#6b7280", neutral_text: "#374151"}

      iex> FlyMapEx.Theme.map_theme(%{land: "#custom", ocean: "#custom"})
      %{land: "#custom", ocean: "#custom"}

      iex> FlyMapEx.Theme.map_theme(:responsive)
      %{land: "oklch(var(--color-base-100) / 1)", ocean: "oklch(var(--color-base-200) / 1)", border: "oklch(var(--color-base-300) / 1)", neutral_marker: "oklch(var(--color-base-content) / 0.6)", neutral_text: "oklch(var(--color-base-content) / 0.8)"}
  """
  def map_theme(theme) when is_map(theme), do: theme

  def map_theme(:light) do
    %{
      land: "#888888",
      ocean: "#aaaaaa",
      border: "#0f172a",
      neutral_marker: "#6b7280",
      neutral_text: "#374151"
    }
  end

  def map_theme(:dark) do
    %{
      land: "#0f172a",
      ocean: "#aaaaaa",
      border: "#334155",
      neutral_marker: "#9ca3af",
      neutral_text: "#d1d5db"
    }
  end

  def map_theme(:minimal) do
    %{
      land: "transparent",
      ocean: "transparent",
      border: "#b5b7bb",
      neutral_marker: "#aba2a0",
      neutral_text: "#374151"
    }
  end

  def map_theme(:cool) do
    %{
      land: "#f1f5f9",
      ocean: "#aaaaaa",
      border: "#64748b",
      neutral_marker: "#64748b",
      neutral_text: "#334155"
    }
  end

  def map_theme(:warm) do
    %{
      land: "#fef7ed",
      ocean: "#aaaaaa",
      border: "#c2410c",
      neutral_marker: "#92400e",
      neutral_text: "#451a03"
    }
  end

  def map_theme(:high_contrast) do
    %{
      land: "#ffffff",
      ocean: "#aaaaaa",
      border: "#000000",
      neutral_marker: "#404040",
      neutral_text: "#000000"
    }
  end

  def map_theme(theme_name) when is_atom(theme_name) do
    case theme_name do
      :responsive -> responsive_map_theme()
      _ ->
        case get_custom_theme(theme_name) do
          nil -> map_theme(FlyMapEx.Config.default_theme())
          custom_theme -> custom_theme
        end
    end
  end

  def map_theme(_), do: map_theme(FlyMapEx.Config.default_theme())

  @doc """
  Create a custom theme map for advanced users.

  This function validates that the theme map contains all required keys
  and provides sensible defaults for missing values.

  ## Required Keys

  * `:land` - Background colour for land masses
  * `:ocean` - Background colour for water bodies
  * `:border` - Colour for country borders
  * `:neutral_marker` - Default colour for region markers
  * `:neutral_text` - Colour for text labels

  ## Examples

      iex> FlyMapEx.Theme.custom_theme(%{
      ...>   land: "#f8fafc",
      ...>   ocean: "#e2e8f0",
      ...>   border: "#475569",
      ...>   neutral_marker: "#64748b",
      ...>   neutral_text: "#334155"
      ...> })
      %{
        land: "#f8fafc",
        ocean: "#e2e8f0",
        border: "#475569",
        neutral_marker: "#64748b",
        neutral_text: "#334155"
      }

      # Partial theme with defaults
      iex> FlyMapEx.Theme.custom_theme(%{land: "#custom"})
      %{
        land: "#custom",
        ocean: "#aaaaaa",
        border: "#0f172a",
        neutral_marker: "#6b7280",
        neutral_text: "#374151"
      }
  """
  def custom_theme(theme_map) when is_map(theme_map) do
    defaults = map_theme(FlyMapEx.Config.default_theme())
    Map.merge(defaults, theme_map)
  end

  @doc """
  Get a custom theme from application configuration.
  
  Custom themes can be defined in config.exs like:
  
      config :fly_map_ex, :custom_themes,
        corporate: %{
          land: "#f8fafc",
          ocean: "#e2e8f0", 
          border: "#475569",
          neutral_marker: "#64748b",
          neutral_text: "#334155"
        }
  
  ## Examples
  
      iex> FlyMapEx.Theme.get_custom_theme(:corporate)
      nil
  """
  def get_custom_theme(theme_name) do
    Application.get_env(:fly_map_ex, :custom_themes, %{})
    |> Map.get(theme_name)
  end

  @doc """
  Get a responsive map_theme that adapts to CSS theme variables.

  This uses CSS custom properties that automatically change
  based on the current DaisyUI theme.

  ## Examples

      iex> FlyMapEx.Theme.responsive_map_theme()
      %{
        land: "oklch(var(--color-base-100) / 1)",
        ocean: "oklch(var(--color-base-200) / 1)",
        border: "oklch(var(--color-base-300) / 1)",
        neutral_marker: "oklch(var(--color-base-content) / 0.6)",
        neutral_text: "oklch(var(--color-base-content) / 0.8)"
      }
  """
  def responsive_map_theme do
    %{
      land: "oklch(var(--color-base-100) / 1)",
      ocean: "oklch(var(--color-base-200) / 1)",
      border: "oklch(var(--color-base-300) / 1)",
      neutral_marker: "oklch(var(--color-base-content) / 0.6)",
      neutral_text: "oklch(var(--color-base-content) / 0.8)"
    }
  end
end
