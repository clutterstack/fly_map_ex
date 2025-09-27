# Basic Usage

Place node markers using coordinates or Fly.io region codes.

## Table of Contents

- [Add Markers to the Map](#add-markers-to-the-map)
- [Fly.io Region Codes](#flyio-region-codes)
- [Custom Regions for Mixed Deployments](#custom-regions-for-mixed-deployments)

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
- [Map Themes](theming.md)
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
## Custom Regions for Mixed Deployments
Define custom regions in your app config for mixed Fly.io + local deployments. Perfect for showing development environments, office locations, or hybrid cloud setups.

Custom regions are treated like Fly.io regions once configured, allowing seamless mixing of official regions with your own custom locations.

```heex
<FlyMapEx.render
    marker_groups={[
      %{
        nodes: [{47.6062, -122.3321}, {63.7, -68.5}],
        label: "Development Environments"
      },
      %{
        nodes: ["fra", "sin", "lhr"],
        label: "Production Regions"
      }
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