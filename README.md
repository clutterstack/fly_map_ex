# FlyMapEx

A Phoenix LiveView library for displaying interactive world maps with styled markers representing node deployments across regions.

Provides comprehensive utilities for visualizing Fly.io region deployments with configurable styles, animations, and themes.

## Overview

FlyMapEx provides Phoenix LiveView components for creating interactive world maps with markers representing nodes, servers, or deployments. It supports both Fly.io region codes and custom geographic coordinates with a powerful theming and styling system.

## Features

- Interactive SVG world map with hover effects
- Support for Fly.io region codes and custom coordinates `{lat, lng}`
- Semantic marker styles (operational, warning, danger, inactive)
- Color cycling system for multiple marker groups
- Configurable animations (pulse, fade)
- Built-in themes (light, dark, minimal, cool, warm, high contrast)
- Real-time data integration with LiveView
- Machine discovery utilities for Fly.io deployments
- Comprehensive styling API with gradients and custom colors

## Installation

Add `fly_map_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fly_map_ex, "~> 0.1.0"}
  ]
end
```

## Basic usage

### Interactive mode (default - existing behavior)
  <FlyMapEx.render marker_groups={@groups} theme={:dark} />

  ### Static mode (new non-interactive version)  
  <FlyMapEx.render marker_groups={@groups} theme={:dark} interactive={false} />

  ### Direct component usage
  <FlyMapEx.StaticComponent.render marker_groups={@groups} theme={:dark} />

```heex
<FlyMapEx.render marker_groups={[
  %{
    nodes: ["sjc"],
    style: FlyMapEx.Style.operational(),
    label: "Production Server"
  },
  %{
    nodes: ["fra", "ams"],
    style: FlyMapEx.Style.warning(),
    label: "Staging Servers"
  }
]} />
```

### With Themes

```heex
<FlyMapEx.render
  marker_groups={[%{
    nodes: ["sjc"],
    style: FlyMapEx.Style.operational(),
    label: "Production"
  }]}
  theme={:dark}
/>
```

### Custom Coordinates and Styling

```heex
<FlyMapEx.render
  marker_groups={[%{
    nodes: [
      %{label: "NYC Office", coordinates: {40.7128, -74.0060}},
      "sjc"
    ],
    style: FlyMapEx.Style.custom("#00ff00", size: 10, animation: :pulse),
    label: "Global Infrastructure"
  }]}
  map_theme{%{land: "#1f2937", ocean: "#111827"}}
  class="my-custom-map"
/>
```

## Components

### FlyMapEx.render/1

The main entry point component that renders a complete world map with regions, legend, and optional progress tracking.

#### Attributes

- `marker_groups` (required) - List of marker group maps, each containing:
  - `nodes` - List of region codes or coordinate maps
  - `style` - Style definition (FlyMapEx.Style function result, map, or keyword list)
  - `label` - Display label for this group
- `theme` - Background theme (`:light`, `:dark`, `:minimal`, `:cool`, `:warm`, `:high_contrast`)
- `background` - Custom background color map (overrides theme)
- `class` - Additional CSS classes for the container
- `show_regions` - Boolean to show/hide Fly.io region markers
- `selected_apps` - List for app-specific functionality
- `available_apps` - List for app-specific functionality
- `all_instances_data` - Map for app-specific functionality

### FlyMapEx.Components.WorldMap.render/1

Just the SVG map component without card wrapper.

**Parameters:**
- `marker_groups` - List of processed marker groups
- `colours` - Map of color overrides
- `id` - HTML id for SVG element
- `show_regions` - Boolean for region marker visibility

## Configuration

### Background Themes

FlyMapEx includes predefined background themes:
- `:light` - Light background with dark borders
- `:dark` - Dark background with subtle borders
- `:transparent` - Transparent background with neutral borders
- `:cool` - Cool blue tones
- `:warm` - Warm earth tones
- `:high_contrast` - Maximum contrast for accessibility

### Application Configuration

Set in `config.exs`:

```elixir
config :fly_map_ex,
  marker_opacity: 0.8,
  show_regions: true,
  marker_base_radius: 2,
  animation_opacity_range: {0.3, 1.0}
```

### Style System

#### Semantic Styles

```elixir
FlyMapEx.Style.operational()  # Green, animated (healthy/running)
FlyMapEx.Style.warning()      # Amber, static with gradient (degraded)
FlyMapEx.Style.danger()       # Red, bouncing animation (failed/critical)
FlyMapEx.Style.inactive()     # Gray, small and static (stopped/offline)
FlyMapEx.Style.primary()      # Blue, static with gradient
FlyMapEx.Style.secondary()    # Teal, static
FlyMapEx.Style.info()         # Light blue, static
```

#### Color Cycling

```elixir
FlyMapEx.Style.cycle(0)  # Blue
FlyMapEx.Style.cycle(1)  # Emerald
FlyMapEx.Style.cycle(2)  # Amber
# Cycles through 10 predefined colors
```

#### Custom Styles

```elixir
FlyMapEx.Style.custom("#3b82f6", size: 10, animated: true, animation: :pulse)
```


 1. Application Configuration

  Configure global defaults in your config/config.exs:

  config :fly_map_ex,
    marker_opacity: 0.9,
    marker_base_radius: 3,
    neutral_marker_light: "#your-brand-color"

  2. Custom Style Modules

  Create your own style builders:

  defmodule MyApp.MapStyles do
    def brand_primary(opts \\ []) do
      FlyMapEx.Style.custom(
        "#your-brand-color",
        Keyword.merge([size: 8, animated: true, animation: :pulse], opts)
      )
    end
  end

  # Usage
  %{nodes: ["sjc"], style: MyApp.MapStyles.brand_primary(), label: "Primary"}

  3. CSS Variable Theming

  Use CSS variables for dynamic theming:

  %{nodes: ["sjc"], style: [colour: "var(--primary-color)"], label: "Dynamic"}

  The system supports atoms, maps, keyword lists, and builder functions for maximum flexibility.


#### Inline Styles

```elixir
style: [color: "#10b981", size: 8, animated: true]
style: %{color: "#ef4444", animation: :pulse}
```

#### Style Options

- `color` - Hex color string or CSS variable (required)
- `size` - Base marker size in pixels (default: 6)
- `animation` - Animation type: `:pulse`, `:fade` (default: `:none`)
- `gradient` - Boolean for gradient fill (default: false)

## Utilities

### FlyMapEx.Regions

Provides region data and coordinate utilities:

- `list/0` - Returns all available Fly.io region codes
- `coordinates/1` - Get coordinates for a region code
- `name/1` - Get human-readable name for a region code
- `display_name/1` - Get formatted display name for regions
- `valid?/1` - Validate if a region code is known

### FlyMapEx.Config

Configuration utilities:

- `marker_opacity/0` - Get configured marker opacity
- `show_regions_default/0` - Get default region visibility
- `animation_opacity_range/0` - Get animation opacity range

### FlyMapEx.Theme

Background theme utilities:

- `get/1` - Get theme configuration by name
- `responsive_map_theme/0` - CSS custom properties for DaisyUI

### FlyMapEx.Adapters

Data transformation helpers for converting various data formats to the expected marker group format.

## Supported Fly.io Regions

The library includes coordinates and names for all current Fly.io regions including:

Amsterdam (ams), Ashburn (iad), Atlanta (atl), Bogotá (bog), Boston (bos), Bucharest (otp), Chicago (ord), Dallas (dfw), Denver (den), Ezeiza (eze), Frankfurt (fra), Guadalajara (gdl), Hong Kong (hkg), Johannesburg (jnb), London (lhr), Los Angeles (lax), Madrid (mad), Miami (mia), Montreal (yul), Mumbai (bom), Paris (cdg), Phoenix (phx), Querétaro (qro), Rio de Janeiro (gig), San Jose (sjc), Santiago (scl), Sao Paulo (gru), Seattle (sea), Secaucus (ewr), Singapore (sin), Stockholm (arn), Sydney (syd), Tokyo (nrt), Toronto (yyz), Warsaw (waw)

## Demo Application

A complete demo application is included in the `demo/` directory that showcases real-time machine discovery using Fly.io's internal DNS.

### Running the Demo

```bash
cd demo
mix deps.get
mix phx.server
```

Visit http://localhost:4000 and click "View Machine Map Demo" to see FlyMapEx in action.

### Real-time Machine Discovery

The demo uses Fly.io's internal DNS to discover running machines:

```elixir
# In your LiveView
def mount(_params, _session, socket) do
  # Discover machines periodically
  {:ok, _pid} = Demo.MachineDiscovery.start_periodic_discovery(
    "my-app-name", 
    self(), 
    30_000  # 30 second intervals
  )
  
  {:ok, socket}
end

def handle_info({:machines_updated, {:ok, machines}}, socket) do
  # Convert to marker groups for display
  marker_groups = FlyMapEx.Adapters.from_machine_tuples(
    machines, 
    "Running Machines", 
    :operational
  )
  
  socket = assign(socket, marker_groups: marker_groups)
  {:noreply, socket}
end
```

### DNS Machine Discovery



Parse Fly.io DNS TXT records containing machine data:

```elixir
# Example DNS TXT record: "683d314fdd4d68 yyz,568323e9b54dd8 lhr"
machines = FlyMapEx.Adapters.from_fly_dns_txt("683d314fdd4d68 yyz,568323e9b54dd8 lhr")
# Returns: [{"683d314fdd4d68", "yyz"}, {"568323e9b54dd8", "lhr"}]

# Convert to marker groups with counts
marker_groups = FlyMapEx.Adapters.from_machine_tuples(machines, "Active", :operational)
# Returns: [
#   %{nodes: ["yyz"], style: FlyMapEx.Style.operational(), label: "Active (1)", machine_count: 1},
#   %{nodes: ["lhr"], style: FlyMapEx.Style.operational(), label: "Active (1)", machine_count: 1}
# ]
```

## Development

### Running Tests

```bash
mix test
```

### Building Documentation

```bash
mix docs
```

## License

MIT License - see LICENSE file for details.