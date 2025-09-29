# Basic Usage

Place node markers using coordinates or Fly.io region codes.

## Add Markers to the Map
`<FlyMapEx.render />` renders just an SVG map in the default layout and colour theme.

To place nodes on the map, supply the `:marker_groups` assign; a list of maps that must contain at least a `:nodes` field indicating where to put the markers on the map.

Use latitude and longitude, Fly.io region (airport) codes, or custom-configured named locations for map positions.

Here's an example with two node groups: one with a node in San Francisco and one somewhere in the North Sea, using `{lat, long}` notation; and one with a node in Frankfurt and a node in Singapore, using Fly.io region (airport) codes.

```heex
<FlyMapEx.render
    marker_groups={[
      %{nodes: [{37.8, -122.4}, {56, 3.6}]},
      %{nodes: ["fra", "sin"]}
    ]}
  />
```
### Tips
- Coordinate tuples use standard WGS84 format: `{latitude, longitude}` where negative values mean western or southern hemispheres.
### Related
- [Map Themes](theming.md)
- [WGS84 Coordinate System](https://en.wikipedia.org/wiki/World_Geodetic_System)
- [Custom Regions](#custom_regions)
- [Fly.io Regions](https://fly.io/docs/reference/regions/)
## Configure custom regions
Define custom regions in your app config for mixed Fly.io + local deployments. Perfect for showing development environments, office locations, or hybrid cloud setups.

Custom regions are treated like Fly.io regions once configured, allowing seamless mixing of official regions with your own custom locations.

```heex
<FlyMapEx.render
    marker_groups={[
      %{nodes: [{37.8, -122.4}, {56, 3.6}]},
      %{nodes: ["fra", "sin"]},
      %{nodes: ["laptop"]}
    ]}
  />
```
### Configuration Example
```elixir
# config/config.exs

config :fly_map_ex, :custom_regions,
  %{
    "dev" => %{name: "Development", coordinates: {47.6062, -122.3321}},
    "laptop" =>
      %{
        name: "Laptop",
        # Iqaluit, approximately
        coordinates: {63.7, -68.5}
      }
  }
```
### Tips
- Custom regions are treated like Fly.io regions once configured
- Use descriptive names that clearly identify the location purpose
- Coordinate format is the same as for direct coordinate tuples
### Related
- [Marker Styling](marker_styling.md)
- [Configuration Reference](theming.md#configuration)