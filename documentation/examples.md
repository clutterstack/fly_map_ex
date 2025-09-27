# FlyMapEx Examples

This document demonstrates various usage patterns for FlyMapEx. All examples are validated at compile-time and used in both the demo application and documentation.

## Table of Contents

- [Basic Usage](#basic-usage)
- [Marker Styles](#marker-styles)
- [Map Themes](#map-themes)

## Basic Usage

Place node markers using coordinates or Fly.io region codes.

## Add Markers to the Map
`<FlyMapEx.render />` renders an SVG map in the default layout and colour theme.
To place nodes on the map, supply the `:marker_groups` assign. `:marker_groups` is a list of maps. Each map contains, at the very least, a `:nodes` field with a list of positions for markers.

The location can be in the form of a coordinate tuple `{lat, long}` where negative values indicate southern latitudes and western longitudes.

* To add markers, you put a list of nodes in each marker group.
* At minimum, you have to give each node a map position.

Here's an example of a node group with one node in San Francisco and one somewhere in the ocean:

```heex
<FlyMapEx.render
    marker_groups={[
      %{
        nodes: [{37.8, -122.4}, {56, 3.6}]
      }
    ]}
  />
```
### Tips
- Coordinate tuples use standard WGS84 format: `{latitude, longitude}`
- Negative latitudes indicate southern hemisphere
- Negative longitudes indicate western hemisphere
### Related
- [Map Themes](theming)
- [WGS84 Coordinate System](https://en.wikipedia.org/wiki/World_Geodetic_System)
## Fly.io Region Codes
Use three-letter region codes that automatically resolve to exact coordinates for Fly.io infrastructure.

FlyMapEx includes built-in coordinates for all official Fly.io regions, so you can reference them by their standard codes like `"fra"`, `"sin"`, `"lhr"`, etc.

```heex
<FlyMapEx.render
    marker_groups={[
      %{
        nodes: ["fra", "sin"],
        label: "Global Regions"
      }
    ]}
  />
```
### Tips
- Custom regions like "dev" or "laptop" can be specified in your app config.
- All official Fly.io regions are supported out of the box
- Region codes are case-insensitive
### Related
- [Custom Regions](#custom_regions)
- [Fly.io Regions](https://fly.io/docs/reference/regions/)

*[View complete Basic Usage guide →](guides/basic_usage.md)*

## Marker Styles

Master visual customization and semantic meaning through FlyMapEx's comprehensive styling system.

## Automatic Colours
If you don't specify a group's marker styles, a different colour is automatically assigned to each group.

This provides instant visual distinction between different marker groups without requiring any styling configuration. FlyMapEx cycles through a carefully chosen colour palette that ensures good contrast and readability.

```heex
<FlyMapEx.render
    marker_groups={[
      %{
        nodes: ["sjc", "fra"],
        label: "Production Servers"
      },
      %{
        nodes: ["ams", "lhr"],
        label: "Staging Environment"
      },
      %{
        nodes: ["ord"],
        label: "Development"
      },
      %{
        nodes: ["nrt", "syd"],
        label: "Testing"
      }
    ]}
  />
```
### Tips
- Automatic colours follow a predefined sequence for consistency
- Each group gets a distinct colour automatically
- No configuration needed - just add your marker groups
### Related
- [Semantic Styling](#semantic)
- [Custom Styling](#custom)
## Semantic Styling
Preset marker styles to convey status and meaning at a glance.

Semantic styles provide predefined combinations of colour, animation, and visual effects that correspond to common operational states. This creates consistency across your application and makes status immediately recognizable.

```heex
<FlyMapEx.render
    marker_groups={[
      %{
        nodes: ["sjc", "fra"],
        style: :operational,
        label: "Production Servers"
      },
      %{
        nodes: ["ams", "lhr"],
        style: :warning,
        label: "Maintenance Mode"
      },
      %{
        nodes: ["ord"],
        style: :danger,
        label: "Failed Nodes"
      },
      %{
        nodes: ["nrt", "syd"],
        style: :inactive,
        label: "Offline Nodes"
      }
    ]}
  />
```
### Tips
- Semantic styles are consistent across your entire application
- Use :operational for healthy systems, :warning for issues, :danger for failures
- Combine with automatic colours for mixed scenarios
### Related
- [Mixed Approaches](#mixed)
- [Custom Styling](#custom)

*[View complete Marker Styles guide →](guides/marker_styling.md)*

## Map Themes

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
### Available Themes
| Theme | Description | Use Case |
|-------|-------------|----------|
| `:light` | Clean, bright theme with gray land masses and dark borders | Default theme, good for most applications |
| `:dark` | Dark background with subtle borders for dark mode interfaces | Dark mode applications, night-time usage |
| `:minimal` | Transparent backgrounds with subtle borders for overlays | Embedding in existing designs, overlay maps |
| `:cool` | Blue-toned theme suitable for technical applications | Technical dashboards, monitoring systems |
| `:warm` | Earth-toned theme with warm colours for friendly interfaces | Consumer applications, friendly interfaces |
| `:high_contrast` | Maximum contrast theme for accessibility | Accessibility compliance, vision assistance |
| `:responsive` | CSS variable-based theme that adapts to system preferences | Automatic light/dark mode switching |
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

*[View complete Map Themes guide →](guides/theming.md)*
