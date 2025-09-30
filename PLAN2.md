# Fix JSON Coordinate Encoding Issue

## Problem
Tuple coordinates `{lat, lng}` in marker nodes cause JSON encoding errors when using real-time channels, because tuples aren't valid JSON types.

## Root Cause
In `lib/fly_map_ex.ex:171`, the code attempts to JSON encode `@marker_groups` which contains nodes with coordinate tuples:

```elixir
"data-initial-state": JSON.encode!(%{
  marker_groups: @marker_groups,  # Contains {lat, lng} tuples
  theme: @map_theme,
  config: %{...}
})
```

When nodes have format `%{label: "NYC", coordinates: {40.7, -74.0}}`, Jason throws an error because tuples aren't valid JSON.

## Solution Strategy
Add coordinate conversion helper that transforms tuples to lists only at the JSON boundary, keeping internal tuple format unchanged for performance and Elixir idioms.

## Implementation Plan

### 1. Add Helper Function
**File**: `lib/fly_map_ex/shared.ex`

Add function to recursively convert coordinate tuples to lists:

```elixir
@doc """
Convert coordinate tuples to lists for JSON encoding.
Recursively processes marker groups and nodes, converting {lat, lng} → [lat, lng].
"""
def convert_coordinates_for_json(marker_groups) when is_list(marker_groups) do
  Enum.map(marker_groups, &convert_group_coordinates/1)
end

defp convert_group_coordinates(group) when is_map(group) do
  case Map.get(group, :nodes) do
    nodes when is_list(nodes) ->
      converted_nodes = Enum.map(nodes, &convert_node_coordinates/1)
      Map.put(group, :nodes, converted_nodes)
    _ ->
      group
  end
end

defp convert_node_coordinates(%{coordinates: {lat, lng}} = node)
     when is_number(lat) and is_number(lng) do
  Map.put(node, :coordinates, [lat, lng])
end

defp convert_node_coordinates(node), do: node
```

### 2. Update JSON Encoding
**File**: `lib/fly_map_ex.ex` (around line 171)

Replace direct encoding with converted coordinates:

```elixir
"data-initial-state": JSON.encode!(%{
  marker_groups: Shared.convert_coordinates_for_json(@marker_groups),
  theme: @map_theme,
  config: %{
    bbox: %{minX: 0, minY: 0, maxX: 800, maxY: 391},
    update_throttle: @update_throttle
  }
})
```

### 3. Verify JavaScript Compatibility
**File**: `priv/static/js/real_time_map_hook.js` and related

Check that JavaScript coordinate handling works with arrays instead of tuples:
- Coordinate destructuring: `const [lat, lng] = coordinates`
- SVG transformation functions
- Marker creation/update logic

### 4. Test Cases
Test with various node formats:
- Fly.io regions: `"sjc"` → gets normalized to tuple → converted to array
- Direct tuples: `{40.7, -74.0}` → converted to `[40.7, -74.0]`
- Map nodes: `%{label: "NYC", coordinates: {40.7, -74.0}}` → coordinates converted
- Mixed groups with different node types

## Benefits
- **Minimal Impact**: Only changes JSON serialization boundary
- **Performance**: Keeps efficient tuple format internally
- **Backward Compatible**: No changes to existing coordinate handling
- **JSON Native**: Arrays are valid JSON, eliminating encoding errors
- **Maintainable**: Clear separation between internal format and serialization

## Success Criteria
- ✅ Real-time maps work without JSON encoding errors
- ✅ All existing node formats continue working
- ✅ No performance degradation in normal usage
- ✅ JavaScript coordinate handling functions correctly
- ✅ Tests pass for various marker group configurations

## Files to Modify
1. `lib/fly_map_ex/shared.ex` - Add coordinate conversion helper
2. `lib/fly_map_ex.ex` - Use helper before JSON encoding
3. Potentially JavaScript files if coordinate handling needs updates

## Alternative Considered
Changing coordinate format throughout to `%{lat: 40.7, lng: -74.0}` was rejected due to:
- Memory overhead (more verbose than tuples)
- Breaking changes required across codebase
- Less idiomatic Elixir (tuples are natural for coordinate pairs)
- Performance impact for coordinate-heavy applications