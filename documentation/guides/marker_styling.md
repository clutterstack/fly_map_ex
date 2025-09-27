# Marker Styles

Master visual customization and semantic meaning through FlyMapEx's comprehensive styling system.

## Table of Contents

- [Automatic Colours](#automatic-colours)
- [Semantic Styling](#semantic-styling)
- [Direct Style Maps](#direct-style-maps)
- [Mixed Approaches](#mixed-approaches)

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
## Direct Style Maps
Define fully custom marker styles using direct style maps - the primary interface for custom styling.

Custom style maps give you complete control over marker appearance, allowing you to match your brand colours, create unique visual hierarchies, or implement custom status indicators.

```heex
<FlyMapEx.render
    marker_groups={[
      %{
        nodes: ["sjc", "fra"],
        style: %{
          colour: "#8b5cf6",
          size: 8,
          animation: :pulse,
          glow: true
        },
        label: "Custom Group"
      }
    ]}
  />
```
### Custom Style Example
```elixir
%{
  nodes: ["sjc", "fra"],
  style: %{
    colour: "#8b5cf6",    # hex, named colour, or CSS variable
    size: 8,             # radius in pixels
    animation: :pulse,   # :none, :pulse, :fade
    glow: true           # boolean for glow effect
  },
  label: "Custom Group"
}
```
### Style Parameters
| Parameter | Description | Examples |
|-----------|-------------|----------|
| `colour/color` | Hex codes, named colours (:blue), CSS variables (var(--primary)) | #8b5cf6, :blue, var(--primary-colour) |
| `size` | Marker radius in pixels (default: 4) | 4, 8, 12 |
| `animation` | :none, :pulse, :fade (default: :none) | :none, :pulse, :fade |
| `glow` | Boolean for enhanced visibility (default: false) | true, false |
### Tips
- Use hex codes for precise colour control
- CSS variables enable dynamic theming
- Animations draw attention - use sparingly
- Glow effects improve visibility on busy maps
### Related
- [Mixed Approaches](#mixed)
- [Map Themes](theming)
## Mixed Approaches
Combine different styling methods in one configuration for complex real-world scenarios.

Real applications often need a mix of styling approaches - semantic styles for core monitoring, automatic colours for organization, and custom styles for special cases. FlyMapEx handles this seamlessly.

```heex
<FlyMapEx.render
    marker_groups={[
      %{
        nodes: ["ams", "lhr"],
        style: :warning,
        label: "Maintenance Mode"
      },
      %{
        nodes: ["sjc", "fra"],
        style: %{
          colour: "#8b5cf6",
          size: 8,
          animation: :pulse,
          glow: true
        },
        label: "Custom Group"
      }
    ]}
  />
```
### Tips
- Start with semantic styles for core functionality
- Add cycling and custom styles as needed
- Maintain visual hierarchy with consistent sizing
- Use animations strategically to guide attention
### Related
- [Semantic Styling](#semantic)
- [Custom Styling](#custom)
- [Basic Usage](basic_usage)