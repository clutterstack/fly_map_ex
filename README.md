# FlyMap

A Phoenix LiveView library for displaying interactive world maps with Fly.io region markers.

## Features

- 🗺️ **Interactive SVG World Map** - Clean, scalable world map with Fly.io region coordinates
- 🎨 **Multiple Marker Types** - Support for different node states with customizable colors and animations
- 📊 **Built-in Progress Tracking** - Visual progress bars for acknowledgment tracking
- 🎭 **Predefined Themes** - Ready-to-use themes for different use cases
- ⚡ **Phoenix LiveView Compatible** - Real-time updates with PubSub integration
- 📱 **Responsive Design** - Works across different screen sizes
- ♿ **Accessibility** - High contrast themes and proper semantics

## Quick Start

Add to your Phoenix template:

```heex
<FlyMap.render 
  our_regions={["sjc"]}
  active_regions={["fra", "ams"]}
  expected_regions={["lhr", "ord"]}
/>
```

## Installation

Add to your `mix.exs`:

```elixir
def deps do
  [
    {:fly_map, "~> 0.1.0"}
  ]
end
```

## Usage Examples

### Basic Usage

```heex
<!-- Simple deployment visualization -->
<FlyMap.render 
  our_regions={["sjc"]}
  active_regions={["fra", "ams", "nrt"]}
/>
```

### With Progress Tracking

```heex
<!-- Show acknowledgment progress -->
<FlyMap.render
  expected_regions={["sjc", "fra", "ams"]}
  ack_regions={["sjc", "fra"]}
  show_progress={true}
/>
```

### Using Themes

```heex
<!-- Dashboard theme with compact size -->
<FlyMap.render
  our_regions={@deployment.local_regions}
  active_regions={@deployment.healthy_regions}
  theme={:dashboard}
/>

<!-- Dark theme for monitoring -->
<FlyMap.render
  our_regions={@local_regions}
  expected_regions={@all_regions}
  ack_regions={@responding_regions}
  theme={:dark}
/>
```

### Custom Styling

```heex
<!-- Custom colors and legend -->
<FlyMap.render
  our_regions={["sjc"]}
  active_regions={["fra"]}
  colors={%{
    our_nodes: "#00ff00",
    active_nodes: "#ffff00"
  }}
  legend_config={%{
    our_nodes_label: "Primary",
    active_nodes_label: "Secondary"
  }}
/>
```

### Data Adapters

```elixir
# In your LiveView or controller
def mount(_params, _session, socket) do
  # Extract regions from machine data
  machines = MyApp.FlyAPI.list_machines()
  active_regions = FlyMap.Adapters.from_machines(machines, "region")
  
  # Extract from node acknowledgments
  acks = MyApp.MessageTracker.get_acknowledgments()
  ack_regions = FlyMap.Adapters.from_acknowledgments(acks, :node_id)
  
  socket = assign(socket, 
    active_regions: active_regions,
    ack_regions: ack_regions
  )
  
  {:ok, socket}
end
```

## Components

### FlyMap.render/1

Main entry point - renders complete map with card, legend, and optional progress.

**Attributes:**
- `our_regions` - List of regions for local nodes (blue animated markers)
- `active_regions` - List of active regions (yellow markers)
- `expected_regions` - List of expected regions (orange animated markers)
- `ack_regions` - List of acknowledged regions (violet animated markers)
- `show_progress` - Show acknowledgment progress bar (default: false)
- `theme` - Apply predefined theme (`:dashboard`, `:monitoring`, `:dark`, etc.)
- `colors` - Override colors `%{our_nodes: "#color", ...}`
- `dimensions` - Override dimensions `%{width: 800, height: 400}`
- `legend_config` - Customize legend labels and visibility
- `class` - Additional CSS classes

### FlyMap.Components.WorldMap.render/1

Just the SVG world map without card wrapper.

### FlyMap.Components.WorldMapCard.render/1

Map with card styling, legend, and progress bar.

## Themes

### Available Themes

- `:dashboard` - Compact theme for dashboard widgets
- `:monitoring` - Default theme for monitoring applications  
- `:presentation` - Large theme for presentations
- `:minimal` - Clean minimal theme with reduced elements
- `:dark` - Dark theme for night mode interfaces

### Color Schemes

- `:default` - Blue, yellow, orange, violet
- `:cool` - Cool blues and teals
- `:warm` - Warm oranges and reds
- `:minimal` - Grayscale with subtle accents
- `:high_contrast` - High contrast for accessibility
- `:dark` - Dark theme colors
- `:neon` - Bright neon colors

### Custom Themes

```elixir
# Create custom theme
custom_theme = %{
  colors: FlyMap.Config.color_scheme(:cool),
  dimensions: FlyMap.Config.dimensions(:large),
  legend_config: %{
    our_nodes_label: "Primary Deployment",
    active_nodes_label: "Secondary Deployments"
  }
}

# Apply manually
<FlyMap.render {Map.merge(custom_theme, %{our_regions: ["sjc"]})} />
```

## Data Adapters

### FlyMap.Adapters

Helper functions for extracting regions from common data structures:

```elixir
# From node IDs or hostnames
FlyMap.Adapters.from_node_ids(["machine-1-sjc", "app-fra-2"])
# => ["sjc", "fra"]

# From machine data structures
machines = [%{"region" => "sjc"}, %{region: "fra"}]
FlyMap.Adapters.from_machines(machines)
# => ["sjc", "fra"]

# From acknowledgment data
acks = [%{node_id: "machine-sjc-1", status: :ok}]
FlyMap.Adapters.from_acknowledgments(acks, :node_id)
# => ["sjc"]

# Create deployment regions structure
deployment = %{
  local_region: "sjc",
  all_regions: ["sjc", "fra", "ams"],
  healthy_regions: ["sjc", "fra"],
  acknowledged_regions: ["sjc"]
}
FlyMap.Adapters.deployment_regions(deployment)
# => %{our_regions: ["sjc"], active_regions: ["fra"], ...}
```

## Regions

### FlyMap.Regions

Utilities for working with Fly.io region data:

```elixir
# List all valid regions
FlyMap.Regions.list()
# => ["ams", "iad", "atl", ...]

# Get coordinates
FlyMap.Regions.coordinates("sjc")
# => {-122, 37}

# Get human name
FlyMap.Regions.name("sjc")
# => "San Jose"

# Validate region
FlyMap.Regions.valid?("sjc")
# => true
```

## Real-time Updates

Integrate with Phoenix PubSub for live updates:

```elixir
defmodule MyAppWeb.DeploymentLive do
  use MyAppWeb, :live_view
  
  def mount(_params, _session, socket) do
    if connected?(socket) do
      MyApp.DeploymentTracker.subscribe()
    end
    
    {:ok, fetch_deployment_data(socket)}
  end
  
  def handle_info({:deployment_updated, data}, socket) do
    regions = FlyMap.Adapters.deployment_regions(data)
    {:noreply, assign(socket, regions)}
  end
  
  def render(assigns) do
    ~H"""
    <FlyMap.render
      our_regions={@our_regions}
      active_regions={@active_regions}
      expected_regions={@expected_regions}
      ack_regions={@ack_regions}
      show_progress={true}
      theme={:monitoring}
    />
    """
  end
end
```

## Browser Requirements

- Modern browsers with SVG support
- CSS animations support for marker animations
- No JavaScript required (pure SVG + CSS)

## Contributing

This library was extracted from the CorroPort project. Contributions welcome!

## License

MIT License