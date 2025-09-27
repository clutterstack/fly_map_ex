# Real-Time API Reference ⚡

Complete API documentation for FlyMapEx's real-time features including Phoenix channels, JavaScript hooks, and client-side utilities.

## Phoenix Channel API

### DemoWeb.MapChannel

Main Phoenix channel for real-time map communication.

#### Channel Join

```elixir
join("map:" <> room_id, payload, socket)
```

**Parameters:**
- `room_id` (string) - Unique identifier for the map room
- `payload` (map) - Optional join payload (currently unused)
- `socket` - Phoenix channel socket

**Returns:**
- `{:ok, socket}` on successful join
- `{:error, reason}` on join failure

**Example:**
```elixir
# Client joins channel
channel = socket.channel("map:dashboard_123", {})
channel.join()
  .receive("ok", resp => console.log("Joined successfully"))
  .receive("error", resp => console.log("Join failed"))
```

#### Inbound Messages

##### state_sync

Request client/server state synchronization.

```elixir
handle_in("state_sync", %{"client_state" => client_state}, socket)
```

**Parameters:**
- `client_state` (map) - Current client-side state for comparison

**Response:**
```elixir
{:reply, {:ok, %{status: status, diff: diff}}, socket}
```

**Status Values:**
- `"in_sync"` - Client and server states match
- `"state_updated"` - Server state newer, full update broadcasted
- `"sync_acknowledged"` - Sync request acknowledged

##### ping

Health check for connection monitoring.

```elixir
handle_in("ping", _payload, socket)
```

**Response:**
```elixir
{:reply, {:ok, %{status: "pong"}}, socket}
```

#### Outbound Messages

##### marker_state

Complete map state update (initial load or major changes).

**Payload:**
```elixir
%{
  marker_groups: [%{id: string, nodes: list, style: map, label: string}],
  theme: %{land: string, ocean: string, border: string, ...},
  config: %{bbox: tuple, update_throttle: integer}
}
```

##### marker_update

Incremental marker group update.

**Payload:**
```elixir
%{
  group_id: string,
  markers: [marker_data]
}
```

##### marker_add

Add new marker to existing group.

**Payload:**
```elixir
%{
  group_id: string,
  marker: marker_data
}
```

##### marker_remove

Remove marker from group.

**Payload:**
```elixir
%{
  group_id: string,
  marker_id: string
}
```

##### theme_change

Update map theme colors.

**Payload:**
```elixir
%{
  theme: %{land: string, ocean: string, border: string, ...}
}
```

##### group_toggle

Show/hide marker group.

**Payload:**
```elixir
%{
  group_id: string,
  visible: boolean
}
```

#### Broadcasting Functions

##### broadcast_marker_state/2

```elixir
DemoWeb.MapChannel.broadcast_marker_state(channel_topic, state)
```

Broadcast complete map state to all channel subscribers.

**Parameters:**
- `channel_topic` (string) - Channel topic (e.g., "map:room_123")
- `state` (map) - Complete state object with marker_groups, theme, config

##### broadcast_marker_update/2

```elixir
DemoWeb.MapChannel.broadcast_marker_update(channel_topic, update)
```

Broadcast incremental marker updates for efficiency.

**Parameters:**
- `channel_topic` (string) - Channel topic
- `update` (map) - Update object with group_id and markers

##### broadcast_theme_change/2

```elixir
DemoWeb.MapChannel.broadcast_theme_change(channel_topic, theme_data)
```

Broadcast theme color changes.

**Parameters:**
- `channel_topic` (string) - Channel topic
- `theme_data` (map) - Theme object with color definitions

##### broadcast_group_toggle/2

```elixir
DemoWeb.MapChannel.broadcast_group_toggle(channel_topic, toggle_data)
```

Broadcast marker group visibility changes.

**Parameters:**
- `channel_topic` (string) - Channel topic
- `toggle_data` (map) - Toggle object with group_id and visible boolean

## JavaScript Hook API

### RealTimeMapHook

Main LiveView hook for client-side map management.

#### Hook Lifecycle

##### mounted()

Called when hook element is mounted to DOM.

**Responsibilities:**
- Parse initial state from data attributes
- Validate real-time mode support
- Initialize Phoenix channel connection
- Render initial markers
- Set up error handling and reconnection logic

##### destroyed()

Called when hook element is removed from DOM.

**Responsibilities:**
- Leave Phoenix channel
- Clean up client-rendered markers
- Remove event listeners

#### Configuration Data Attributes

##### data-channel

**Type:** string
**Required:** Yes
**Example:** `"map:dashboard_123"`

Phoenix channel topic for real-time communication.

##### data-map-id

**Type:** string
**Required:** Yes
**Example:** `"fly-region-map-12345"`

HTML ID of target SVG map element.

##### data-initial-state

**Type:** JSON string
**Required:** Yes

Initial map state containing marker groups, theme, and configuration.

**Structure:**
```json
{
  "marker_groups": [
    {
      "id": "production",
      "nodes": ["sjc", "fra"],
      "style": {"colour": "#3b82f6", "size": 8},
      "label": "Production Servers"
    }
  ],
  "theme": {
    "land": "#f8fafc",
    "ocean": "#e2e8f0",
    "border": "#475569"
  },
  "config": {
    "bbox": [0, 0, 800, 391],
    "update_throttle": 100
  }
}
```

##### data-progressive-enhancement

**Type:** string
**Values:** `"true"` | `"false"`
**Default:** `"false"`

Enables progressive enhancement mode with graceful fallback.

#### Channel Event Handlers

##### handleMarkerState(payload)

Process complete state updates from server.

**Parameters:**
- `payload` (object) - Complete state object

**Actions:**
- Update client state
- Clear existing markers
- Render new markers from state
- Update theme if changed

##### handleMarkerUpdate(payload)

Process incremental marker updates.

**Parameters:**
- `payload` (object) - Update with group_id and markers

**Actions:**
- Find target marker group
- Update group markers in client state
- Re-render affected group markers

##### handleMarkerAdd(payload)

Process new marker additions.

**Parameters:**
- `payload` (object) - Addition with group_id and marker

**Actions:**
- Add marker to target group
- Create and render new marker element
- Update client state

##### handleMarkerRemove(payload)

Process marker removals.

**Parameters:**
- `payload` (object) - Removal with group_id and marker_id

**Actions:**
- Remove marker from DOM
- Update client state
- Clean up associated resources

##### handleThemeChange(payload)

Process theme color updates.

**Parameters:**
- `payload` (object) - Theme with color definitions

**Actions:**
- Update theme in client state
- Apply new colors to SVG elements
- Update CSS variables

##### handleGroupToggle(payload)

Process group visibility changes.

**Parameters:**
- `payload` (object) - Toggle with group_id and visible

**Actions:**
- Show/hide marker group via CSS
- Update client state

#### Error Handling & Recovery

##### isRealTimeModeSupported()

**Returns:** boolean

Validates browser and environment support for real-time features.

**Checks:**
- WebSocket availability
- Phoenix framework availability
- SVG manipulation support
- Socket initialization
- Required DOM elements

##### setupErrorHandling()

Configures error handling and recovery mechanisms.

**Features:**
- Connection state tracking
- Automatic reconnection with exponential backoff
- Maximum retry limits
- Graceful fallback triggers

##### attemptReconnect()

Handles automatic reconnection logic.

**Algorithm:**
1. Increment retry counter
2. Calculate exponential backoff delay (max 30 seconds)
3. Attempt channel rejoin
4. Reset counter on successful connection

##### fallbackToServerRendering()

Switches to server-side rendering mode.

**Actions:**
- Clear all client-rendered markers
- Mark fallback mode in DOM attributes
- Trigger LiveView update event
- Log fallback reason

#### State Management

##### validateServerState(state)

**Parameters:**
- `state` (object) - Server state object

**Returns:** boolean

Validates incoming server state structure and data.

**Validation Rules:**
- Required marker_groups array
- Valid group IDs and structures
- Valid marker coordinate data
- Proper theme object structure

##### validateMarkerData(marker)

**Parameters:**
- `marker` (string|array|object) - Marker coordinate data

**Returns:** boolean

Validates individual marker coordinate data.

**Supported Formats:**
- Region codes: `"sjc"`, `"fra"`
- Coordinate arrays: `[37.7749, -122.4194]`
- Coordinate objects: `{lat: 37.7749, lng: -122.4194}`

## JavaScript Utilities API

### map_coordinates.js

Client-side coordinate transformation utilities.

#### wgs84ToSvg(lat, lng, bbox)

**Parameters:**
- `lat` (number) - Latitude (-90 to 90)
- `lng` (number) - Longitude (-180 to 180)
- `bbox` (object) - Bounding box {minX, minY, maxX, maxY}

**Returns:** object - SVG coordinates {x, y}

Converts WGS84 geographic coordinates to SVG pixel coordinates.

**Example:**
```javascript
const coords = wgs84ToSvg(37.7749, -122.4194, {minX: 0, minY: 0, maxX: 800, maxY: 400});
// Returns: {x: 166.9, y: 131.1}
```

#### getRegionCoordinates(region)

**Parameters:**
- `region` (string) - Fly.io region code

**Returns:** object|null - Coordinates {lat, lng} or null if invalid

Gets geographic coordinates for Fly.io region codes.

#### regionToSvg(region, bbox)

**Parameters:**
- `region` (string) - Fly.io region code
- `bbox` (object) - Bounding box (optional, uses MAP_BBOX default)

**Returns:** object|null - SVG coordinates {x, y} or null if invalid

Convenience function combining region lookup and coordinate transformation.

#### markerToSvg(marker, bbox)

**Parameters:**
- `marker` (string|array|object) - Marker data in various formats
- `bbox` (object) - Bounding box (optional)

**Returns:** object|null - SVG coordinates {x, y} or null if invalid

Universal marker coordinate converter supporting multiple input formats.

### map_markers.js

Client-side marker rendering and manipulation.

#### createMarker(options)

**Parameters:**
- `options` (object) - Marker creation options

**Options:**
```javascript
{
  id: string,              // Unique marker ID
  style: {                 // Marker styling
    colour: string,        // Hex color
    size: number,          // Radius in pixels
    animation: string,     // 'none', 'pulse', 'fade'
    glow: boolean          // Enable glow effect
  },
  x: number,               // X coordinate
  y: number,               // Y coordinate
  dataAttrs: object        // Additional data attributes
}
```

**Returns:** SVGElement - Created marker group element

Creates new SVG marker with specified styling and position.

#### updateMarker(markerId, updates)

**Parameters:**
- `markerId` (string) - ID of marker to update
- `updates` (object) - Update object

**Updates:**
```javascript
{
  x: number,               // New X coordinate
  y: number,               // New Y coordinate
  style: {                 // Style updates
    colour: string,
    size: number,
    animation: string,
    glow: boolean
  }
}
```

**Returns:** boolean - True if marker found and updated

Updates existing marker position and styling.

#### removeMarker(markerId)

**Parameters:**
- `markerId` (string) - ID of marker to remove

**Returns:** boolean - True if marker found and removed

Removes marker from DOM and cleans up associated resources.

#### createMarkersFromGroups(markerGroups, bbox)

**Parameters:**
- `markerGroups` (array) - Array of marker group objects
- `bbox` (object) - Bounding box for coordinate transformation

**Returns:** array - Array of created marker elements

Batch creates markers from marker group data structure.

#### toggleMarkerGroup(groupLabel, visible)

**Parameters:**
- `groupLabel` (string) - Group label to toggle
- `visible` (boolean) - Whether group should be visible

Controls marker group visibility via CSS class manipulation.

## Configuration Constants

### MARKER_CONFIG

Default marker configuration values:

```javascript
{
  defaultRadius: 8,                    // Default marker size
  regionMarkerRadius: 4,               // Fly.io region marker size
  markerOpacity: 1.0,                  // Base marker opacity
  animationDuration: '2s',             // Animation duration
  pulseSizeDelta: 2,                   // Pulse animation size increase
  animationOpacityRange: [0.5, 1.0],   // Fade animation opacity range
  legendContainerMultiplier: 2.0       // Legend marker container scaling
}
```

### MAP_BBOX

Default map bounding box:

```javascript
{
  minX: 0,
  minY: 0,
  maxX: 800,
  maxY: 391
}
```

### FLY_REGIONS

Complete mapping of Fly.io region codes to coordinates:

```javascript
{
  'sjc': [37, -122],      // San Jose
  'fra': [50, 9],         // Frankfurt
  'lhr': [51, 0],         // London
  // ... all other regions
}
```

## Error Codes & Debugging

### Channel Errors

- **join_failed** - Channel join failed (authentication, room limits)
- **state_sync_failed** - State synchronization failed
- **invalid_payload** - Malformed message payload

### Hook Errors

- **support_detection_failed** - Real-time mode support check failed
- **channel_connection_failed** - Unable to establish channel connection
- **state_validation_failed** - Invalid server state received
- **marker_creation_failed** - SVG marker creation failed

### Recovery Actions

1. **Automatic reconnection** - Exponential backoff with max 5 attempts
2. **State resynchronization** - Full state refresh on reconnect
3. **Graceful fallback** - Switch to server rendering on persistent failures
4. **Error logging** - Comprehensive client-side error reporting

This API reference provides complete documentation for integrating and extending FlyMapEx's real-time features.