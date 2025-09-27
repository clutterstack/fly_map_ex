# Map Themes

Control overall visual presentation and branding with FlyMapEx's comprehensive theming system.

## Built-in Theme Presets
Seven ready-to-use themes that control map background colours, borders, and neutral elements.

Each preset is carefully designed for specific use cases, from clean light interfaces to dark mode applications and high-contrast accessibility requirements.

```heex
<FlyMapEx.render
    marker_groups={[
      %{
        nodes: ["sjc", "fra", "ams"],
        style: %{colour: "#3b82f6", size: 8},
        label: "Production Servers"
      },
      %{
        nodes: ["lhr", "syd"],
        style: %{colour: "#f59e0b", size: 8},
        label: "Staging Environment"
      }
    ]}
    theme={:dark}
  />
```
### Tips
- Start with :responsive for automatic light/dark adaptation
- Use :high_contrast for accessibility compliance
- Test themes with your actual marker colours
- Consider your application's overall design system
### Related
- [Custom Themes](#custom)
- [Configuration](#configuration)
## Custom Theme Creation
Two approaches for creating custom themes: inline theme maps or config-registered themes.

Custom themes give you complete control over the map's visual appearance, allowing perfect integration with your brand colours and design system.

```heex
<FlyMapEx.render
    marker_groups={[
      %{
        nodes: ["sjc", "fra"],
        style: %{colour: "#10b981", size: 8},
        label: "Primary Services"
      },
      %{
        nodes: ["ams", "lhr"],
        style: %{colour: "#f59e0b", size: 8},
        label: "Secondary Services"
      }
    ]}
    theme={%{
      land: "#f8fafc",
      ocean: "#e2e8f0",
      border: "#475569",
      neutral_marker: "#64748b",
      neutral_text: "#334155"
    }}
  />
```
### Method 1: Inline Custom Theme
```heex
<FlyMapEx.render
  marker_groups={@groups}
  theme=%{
    land: "#f8fafc",
    ocean: "#e2e8f0",
    border: "#475569",
    neutral_marker: "#64748b",
    neutral_text: "#334155"
  }
/>
```
### Method 2: Config-Registered Themes
```elixir
# config/config.exs
config :fly_map_ex, :custom_themes,
  corporate: %{
    land: "#f8fafc",
    ocean: "#e2e8f0",
    border: "#475569",
    neutral_marker: "#64748b",
    neutral_text: "#334155"
  },
  sunset: %{
    land: "#fef3c7",
    ocean: "#fbbf24",
    border: "#d97706",
    neutral_marker: "#b45309",
    neutral_text: "#92400e"
  }

# Usage
<FlyMapEx.render theme={:corporate} />
```
### Tips
- Use hex codes for precise colour control
- Test themes with both light and dark marker colours
- Consider colour accessibility and contrast
- Config-registered themes are reusable across your application
### Related
- [Theme Presets](#presets)
- [Configuration](#configuration)
## Application-Level Theme Configuration
Set default themes and create custom theme registries in your application config.

Application-level configuration allows you to establish consistent theming across your entire application while supporting environment-specific customization.

```heex
<FlyMapEx.render
    marker_groups={[
      %{
        nodes: ["sjc", "fra", "ams"],
        style: %{colour: "#3b82f6", size: 8},
        label: "Production Environment"
      }
    ]}
    theme={:responsive}
  />
```
### Complete Configuration Example
```elixir
# config/config.exs
config :fly_map_ex,
  default_theme: :responsive,
  custom_themes: %{
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
  }
```
### Tips
- Use :responsive as your default for broad compatibility
- Register brand themes in config for consistency
- Environment-specific configs help with testing
- Override at the component level for special cases
### Related
- [Theme Presets](#presets)
- [Custom Themes](#custom)
- [Marker Styling](marker_styling.md)