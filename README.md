# FlyMapEx

A Phoenix LiveView library for displaying interactive world maps with Fly.io region markers.

## Overview

FlyMapEx provides Phoenix components and utilities for visualizing node deployments across Fly.io regions with different marker styles, animations, and legends. Perfect for monitoring distributed applications and deployment status visualization.

## Features

- Interactive SVG world map with Fly.io region coordinates
- Multiple marker types with configurable colors and animations
- Built-in legends and progress tracking
- Phoenix LiveView compatible
- Responsive design
- Predefined themes and color schemes
- Custom styling support

## Installation

Add `fly_map_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fly_map_ex, "~> 0.1.0"}
  ]
end
```

## Usage

### Basic Usage

```heex
<FlyMapEx.render region_groups={[
  %{regions: ["sjc"], style_key: :primary, label: "Our Node"},
  %{regions: ["fra", "ams"], style_key: :active, label: "Active Regions"}
]} />
```

### With Progress Tracking

```heex
<FlyMapEx.render
  region_groups={[
    %{regions: ["sjc", "fra"], style_key: :expected},
    %{regions: ["sjc"], style_key: :acknowledged}
  ]}
  show_progress={true}
/>
```

### With Themes

```heex
<FlyMapEx.render
  region_groups={[%{regions: ["sjc"], style_key: :primary}]}
  theme={:dashboard}
/>
```

### Custom Styling

```heex
<FlyMapEx.render
  region_groups={[%{regions: ["sjc"], style_key: :primary}]}
  colors={%{primary: "#00ff00"}}
  class="my-custom-map"
/>
```

## Components

### FlyMapEx.render/1

The main entry point component that renders a complete world map with regions, legend, and optional progress tracking.

#### Attributes

- `region_groups` - List of region group maps, each containing:
  - `regions` - List of region codes for this group
  - `style_key` - Atom referencing a style from group_styles config (e.g., :primary, :active)
  - `label` - Display label for this group (optional, falls back to style label)
- `show_progress` - Whether to show acknowledgment progress bar (default: false)
- `colors` - Map of color overrides (optional)
- `dimensions` - Map with width/height overrides (optional)
- `class` - Additional CSS classes for the container
- `legend_config` - Map with legend customization options
- `group_styles` - Map of custom group styles (optional, uses theme defaults)
- `theme` - Predefined theme name (optional)

### FlyMapEx.Components.WorldMap.render/1

Just the SVG map component without card wrapper.

### FlyMapEx.Components.WorldMapCard.render/1

Map with card wrapper, legend, and progress tracking.

## Configuration

### Themes

FlyMapEx includes several predefined themes:

- `:dashboard` - Compact theme for dashboard widgets
- `:monitoring` - Default theme for monitoring applications
- `:presentation` - Large theme for presentations and displays
- `:minimal` - Clean minimal theme
- `:dark` - Dark theme

### Color Schemes

Available color schemes:

- `:default` - Blue, yellow, orange, violet
- `:cool` - Cool blues and teals
- `:warm` - Warm oranges and reds
- `:minimal` - Grayscale with subtle accents
- `:high_contrast` - High contrast colors for accessibility
- `:dark` - Dark theme colors
- `:neon` - Bright neon colors

### Group Styles

Available marker styles:

- `:primary` - Blue animated markers for primary/local nodes
- `:active` - Yellow markers for active/healthy nodes
- `:expected` - Orange animated markers for expected/planned nodes
- `:acknowledged` - Violet markers for acknowledged/responding nodes
- `:secondary` - Green markers for secondary/backup nodes
- `:warning` - Red markers for problematic nodes
- `:inactive` - Gray markers for inactive nodes

## Utilities

### FlyMapEx.Regions

Provides region data and coordinate utilities:

- `list/0` - Returns all available Fly.io region codes
- `coordinates/1` - Get coordinates for a region code
- `name/1` - Get human-readable name for a region code
- `display_name/1` - Get formatted display name for regions
- `valid?/1` - Validate if a region code is known

### FlyMapEx.Config

Configuration presets and themes:

- `color_scheme/1` - Get predefined color schemes
- `group_styles/0` - Get marker style configurations
- `dimensions/1` - Get predefined dimension configurations
- `theme/1` - Get complete theme configurations

### FlyMapEx.Adapters

Data transformation helpers for converting various data formats to the expected region group format.

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
  # Convert to region groups for display
  region_groups = FlyMapEx.Adapters.from_machine_tuples(
    machines, 
    "Running Machines", 
    :primary
  )
  
  socket = assign(socket, region_groups: region_groups)
  {:noreply, socket}
end
```

### DNS Machine Discovery

Parse Fly.io DNS TXT records containing machine data:

```elixir
# Example DNS TXT record: "683d314fdd4d68 yyz,568323e9b54dd8 lhr"
machines = FlyMapEx.Adapters.from_fly_dns_txt("683d314fdd4d68 yyz,568323e9b54dd8 lhr")
# Returns: [{"683d314fdd4d68", "yyz"}, {"568323e9b54dd8", "lhr"}]

# Convert to region groups with counts
region_groups = FlyMapEx.Adapters.from_machine_tuples(machines, "Active", :primary)
# Returns: [
#   %{regions: ["yyz"], style_key: :primary, label: "Active (1)"},
#   %{regions: ["lhr"], style_key: :primary, label: "Active (1)"}
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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.