# FlyMapEx

The FlyMapEx library provides a function component to display markers on a simple SVG world map, with or without a legend. It's meant to be simple to use, with a few configuration options. 

Use latitude and longitude, Fly.io region codes, or custom-configured named locations to position nodes on the map. 

You can also customise map colours, marker styles, node and group names, and layout.

FlyMapEx is not a comprehensive mapping library. Check out the [Livebook MapLibre integration](https://livebook.dev/integrations/maplibre/) and Michał Strzelczyk's [_Creating interactive maps with Phoenix LiveView_](https://medium.com/@mich.strzelczyk/creating-interactive-maps-with-phoenix-liveview-1148f8e7dd33) for on-ramps to more sophisticated mapping using [MapLibre](https://maplibre.org/maplibre-style-spec/).

## Features

- Interactive SVG world map with hover effects
- Support for Fly.io region codes and custom coordinates `{lat, lng}`
- Direct style maps and configurable semantic presets (operational, warning, danger, inactive)
- Color cycling system for multiple marker groups
- Configurable animations (pulse, fade)
- Built-in themes (light, dark, minimal, cool, warm, high contrast)
- **Real-time marker updates via Phoenix channels** ⚡ NEW
- **Client-side rendering for sub-100ms updates** ⚡ NEW
- **Progressive enhancement with graceful fallback** ⚡ NEW
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

Then copy the bundled CSS/JS assets into your Phoenix project:

```
mix fly_map_ex.install
```

Import them in your asset pipeline (adjust paths for your setup):

```css
/* assets/css/app.css */
@import '../vendor/fly_map_ex/css/fly_map_ex.css';
```

```javascript
// assets/js/app.js
import { Socket } from 'phoenix'
import { createRealTimeMapHook } from '../vendor/fly_map_ex/js/real_time_map_hook.js'

const socket = new Socket('/socket')
socket.connect()

const Hooks = { RealTimeMap: createRealTimeMapHook(socket) }
```

## Basic Usage

### Interactive mode (default)

```heex
<FlyMapEx.render marker_groups={@groups} theme={:dark} />
```

### Static mode (non-interactive)

```heex
<FlyMapEx.render marker_groups={@groups} theme={:dark} interactive={false} />
```

```heex
<FlyMapEx.render marker_groups={[
  %{
    nodes: ["sjc"],
    style_key: :primary,
    label: "Production Server"
  },
  %{
    nodes: ["fra", "ams"],
    style_key: :warning,
    label: "Staging Servers"
  }
]} />
```

### With Themes

```heex
<FlyMapEx.render
  marker_groups={[%{
    nodes: ["sjc"],
    style_key: :primary,
    label: "Production"
  }]}
  theme={:dark}
/>
```

### Real-Time Mode

```heex
<FlyMapEx.render
  marker_groups={@groups}
  theme={:responsive}
  real_time={true}
  channel="map:room_123"
  update_throttle={50}
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
    style_key: :primary,
    label: "Global Infrastructure"
  }]}
  theme={:dark}
  class="my-custom-map"
/>
```

## Components

### FlyMapEx.render/1

The main entry point component that renders a complete world map with regions, legend, and optional interactivity.

#### Attributes

- `marker_groups` (required) - List of marker group maps, each containing:
  - `regions` - List of region codes or coordinate maps
  - `style_key` - Style key (`:primary`, `:active`, `:warning`, etc.)
  - `label` - Display label for this group
- `interactive` - Boolean to enable/disable client-side legend toggles (default: true)
- `on_toggle` - Boolean to send events to parent LiveView when toggling groups (default: false)
- `theme` - Background theme (`:light`, `:dark`, `:minimal`, `:cool`, `:warm`, `:high_contrast`)
- `background` - Custom background color map (overrides theme)
- `class` - Additional CSS classes for the container
- `show_regions` - Boolean to show/hide Fly.io region markers
- **`real_time`** ⚡ NEW - Boolean to enable real-time updates via Phoenix channels (default: false)
- **`channel`** ⚡ NEW - Channel topic for real-time updates (e.g., "map:room_id")
- **`update_throttle`** ⚡ NEW - Milliseconds between client updates for throttling (default: 100)
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

## Real-Time Features ⚡ NEW

FlyMapEx now supports real-time marker updates via Phoenix channels for sub-100ms performance improvements over traditional LiveView rendering.

### Benefits

- **Performance**: Sub-100ms marker updates vs 200-500ms server round-trips
- **Scalability**: Handle thousands of markers without LiveView rerenders
- **Bandwidth Efficiency**: Only send coordinate/style deltas, not entire DOM tree
- **Progressive Enhancement**: Falls back gracefully to server rendering when JS fails
- **Backward Compatible**: Existing server rendering unchanged by default

### Setup

1. **Enable channels in your application**:

```elixir
# lib/my_app_web/endpoint.ex
socket "/socket", MyAppWeb.UserSocket,
  websocket: true,
  longpoll: false
```

2. **Create user socket**:

```elixir
# lib/my_app_web/channels/user_socket.ex
defmodule MyAppWeb.UserSocket do
  use Phoenix.Socket

  channel "map:*", MyAppWeb.MapChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
```

3. **Create map channel**:

```elixir
# lib/my_app_web/channels/map_channel.ex
defmodule MyAppWeb.MapChannel do
  use Phoenix.Channel

  @impl true
  def join("map:" <> _room_id, _payload, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("state_sync", %{"client_state" => client_state}, socket) do
    {:reply, {:ok, %{status: "sync_acknowledged"}}, socket}
  end
end
```

4. **Add real-time hook to JavaScript**:

```javascript
// assets/js/app.js
import { Socket } from 'phoenix'
import { createRealTimeMapHook } from '../vendor/fly_map_ex/js/real_time_map_hook.js'

const socket = new Socket('/socket')
socket.connect()

const Hooks = {
  RealTimeMap: createRealTimeMapHook(socket)
}

const liveSocket = new LiveSocket('/live', Socket, {
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})
```

### Usage

```heex
<FlyMapEx.render
  marker_groups={@groups}
  theme={:responsive}
  real_time={true}
  channel="map:#{@room_id}"
  update_throttle={50}
/>
```

### Broadcasting Updates

```elixir
# Broadcast marker state updates
DemoWeb.MapChannel.broadcast_marker_state("map:room_123", %{
  marker_groups: updated_groups,
  theme: new_theme
})

# Broadcast incremental updates
DemoWeb.MapChannel.broadcast_marker_update("map:room_123", %{
  group_id: "production",
  markers: new_markers
})

# Broadcast theme changes
DemoWeb.MapChannel.broadcast_theme_change("map:room_123", %{
  theme: %{land: "#fff", ocean: "#eee"}
})
```

### Graceful Fallback

Real-time mode includes comprehensive fallback mechanisms:

- **Browser compatibility**: Falls back if WebSocket/Phoenix unavailable
- **Network conditions**: Uses server rendering on slow connections
- **Error recovery**: Automatic reconnection with exponential backoff
- **State synchronization**: Client/server state sync on reconnect

## Configuration

### Background Themes

FlyMapEx includes predefined background themes:
- `:light` - Light background with dark borders
- `:dark` - Dark background with subtle borders
- `:minimal` - Transparent backgrounds with neutral borders
- `:cool` - Cool blue tones
- `:warm` - Warm earth tones
- `:high_contrast` - Maximum contrast for accessibility
- `:responsive` - Uses `--fly-map-*` CSS variables defined by the host app

### Application Configuration

Set in `config.exs`:

```elixir
config :fly_map_ex,
  marker_opacity: 0.8,
  show_regions: true,
  marker_base_radius: 2,
  animation_opacity_range: {0.3, 1.0}
```

### Custom Regions

Add supplementary region codes with display names and coordinates so they can
be referenced alongside Fly.io regions:

```elixir
config :fly_map_ex, :custom_regions,
  "dev" => %{name: "Developer Laptop", coordinates: {47.6062, -122.3321}},
  "nyc-office" => %{name: "NYC Office", coordinates: {40.7128, -74.0060}}
```

Retrieve these at runtime with `FlyMapEx.Config.custom_regions/0` or list the
codes with `FlyMapEx.Config.custom_region_codes/0`. Validation for examples and
component helpers honours this configuration.

### Style System

#### Semantic Styles

```elixir
FlyMapEx.Style.operational()  # Green, animated (healthy/running)
FlyMapEx.Style.warning()      # Amber, static with gradient (degraded)
FlyMapEx.Style.danger()       # Red, bouncing animation (failed/critical)
FlyMapEx.Style.inactive()     # Gray, small and static (stopped/offline)
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
FlyMapEx.Style.custom("#3b82f6", size: 10, animation: :pulse)
```

#### User-Defined Presets

Define reusable style presets in your application configuration:

```elixir
# config/config.exs
config :fly_map_ex, :style_presets,
  brand_primary: [colour: "#your-brand", size: 8, animation: :pulse],
  monitoring_alert: [colour: "#ff6b6b", size: 10, glow: true],
  dashboard_info: [colour: "#4dabf7", size: 6]

# Usage
%{nodes: ["sjc"], style: :brand_primary, label: "Production"}
# Or explicitly
%{nodes: ["sjc"], style: FlyMapEx.Style.preset(:brand_primary), label: "Production"}
```

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

### FlyMapEx.FlyRegions

Provides region data and coordinate utilities:

- `fly_regions/0` - Returns all available region codes (including custom) with coordinates
- `coordinates/1` - Get coordinates for a region code
- `name/1` - Fetch the display name for a region code
- `valid?/1` - Predicate for whether a region is known

### FlyMapEx.Config

Configuration utilities:

- `marker_opacity/0` - Get configured marker opacity
- `show_regions_default/0` - Get default region visibility
- `animation_opacity_range/0` - Get animation opacity range
- `custom_regions/0` - Access configured custom regions
- `custom_region_codes/0` - List custom region IDs

### FlyMapEx.Theme

Background theme utilities:

- `map_theme/1` - Get theme configuration by name or map
- `responsive_map_theme/0` - CSS custom property-based theme (uses `--fly-map-*` vars)

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

## Module Architecture

  ### Core Components
  - `FlyMapEx.render/1` - Main entry point function component with JS-based interactivity
  - `FlyMapEx.Components.WorldMap` - SVG world map rendering
  - `FlyMapEx.Components.LegendComponent` - Legend with optional interactivity

  ### Supporting Components
  - `FlyMapEx.Components.Marker` - Reusable marker rendering (map + legend)
  - `FlyMapEx.Components.GlowFilter` - SVG glow effects for markers
  - `FlyMapEx.WorldMapPaths` - Static SVG path definitions for world geography

  ### Data and Configuration
  - `FlyMapEx.Regions` - Fly.io region coordinates and name mapping
  - `FlyMapEx.Nodes` - Node normalization and processing utilities
  - `FlyMapEx.Theme` - Predefined colour themes and styling
  - `FlyMapEx.Style` - Marker style definitions and helpers
  - `FlyMapEx.Config` - Application-wide configuration settings
  - `FlyMapEx.Adapters` - Data transformation utilities

  ## Component Relationships

  ```
  FlyMapEx.render/1 (main entry)
  ├── FlyMapEx.Shared (shared logic)
  ├── FlyMapEx.Theme (theme colours)
  ├── FlyMapEx.Components.WorldMap
  │   ├── FlyMapEx.WorldMapPaths (geography)
  │   ├── FlyMapEx.Components.Marker (markers)
  │   │   └── FlyMapEx.Components.GlowFilter (effects)
  │   ├── FlyMapEx.Regions (coordinates)
  │   └── FlyMapEx.Nodes (data processing)
  └── FlyMapEx.Components.LegendComponent
      ├── interactive: true/false (conditional JS behavior)
      ├── FlyMapEx.Components.Marker (indicators)
      └── FlyMapEx.Regions (region info)
  ```

  ## Data Flow

  1. **Input Processing**: Raw marker groups → `FlyMapEx.Nodes` → normalized nodes
  2. **Style Application**: Style definitions → `FlyMapEx.Style` → resolved styles
  3. **Theme Resolution**: Theme names → `FlyMapEx.Theme` → colour schemes
  4. **Coordinate Transformation**: Region codes → `FlyMapEx.Regions` → lat/lng → SVG coordinates
  5. **Rendering**: Processed data → Components → SVG/HTML output

  ## Integration Patterns

  ### Basic use (Interactive - Default)
  ```elixir
  <FlyMapEx.render
    marker_groups={@groups}
    theme={:dark}
    show_regions={true}
  />
  ```

  ### Static Usage (Non-Interactive)
  ```elixir
  <FlyMapEx.render
    marker_groups={@groups}
    theme={:dark}
    show_regions={true}
    interactive={false}
  />
  ```

  ### Advanced Interactive Usage
  ```elixir
  <FlyMapEx.render
    marker_groups={@groups}
    theme={:dashboard}
    initially_visible={["production"]}
    on_toggle={true}
  />
  ```

  ### Real-Time Usage ⚡ NEW
  ```elixir
  <FlyMapEx.render
    marker_groups={@groups}
    theme={:responsive}
    real_time={true}
    channel="map:room_123"
    update_throttle={50}
  />
  ```

  ### Direct Component Usage
  ```elixir
  <FlyMapEx.Components.WorldMap.render
    marker_groups={processed_groups}
    colours={theme_colours}
    show_regions={false}
  />
  ```
