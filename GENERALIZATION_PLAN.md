# FlyMapEx Generalization Plan

## Overview

This document outlines the plan to generalize the FlyMapEx library to work with any lat/long coordinates while maintaining full backward compatibility with Fly.io regions.

## What's Already Done ✅

- **Legend component** now conditionally shows Fly.io regions based on `show_regions` attribute
- **Main entry point** passes `show_regions` through to legend component  
- **Demo app** uses `show_regions={false}` to hide unnecessary background regions
- **Node processing** already handles both formats via `FlyMapEx.Nodes.normalize_node/1`
- **Legend display logic** updated to handle generic marker groups alongside app-based groups
- **Style access** made safe with fallbacks for normalized style maps
- **Custom coordinates working** - verified with demo app showing NYC Server and floating server

## Remaining Work

### 1. ~~Update Legend Node Display Logic~~ ✅ COMPLETED
**File**: `lib/fly_map_ex/components/legend_component.ex`
**Status**: DONE - Legend now shows generic marker groups when no app data provided, and safely accesses normalized style properties

### 2. Rename WorldMap Functions for Genericity (Optional)
**File**: `lib/fly_map_ex/components/world_map.ex`
**Priority**: Medium

**Issue**: Functions named `fly_region_markers` and `fly_region_hover_text` sound Fly-specific

**Solution**: Rename to:
- `fly_region_markers` → `background_location_markers`
- `fly_region_hover_text` → `background_location_hover_text`
- Update all references

### 3. Update Documentation
**Files**: `lib/fly_map_ex.ex`, function docs throughout
**Priority**: Low

**Solution**:
- Update main module `@moduledoc` to emphasize generic coordinate support
- Add examples showing custom coordinates alongside Fly regions
- Update function docs to mention both node formats

### 4. Test Generalization
**Priority**: Medium
**Status**: IN PROGRESS

**Verification**: Library works correctly with:
- ✅ Pure custom coordinate nodes: Confirmed working with NYC Server + floating server demo
- ⏳ Mixed usage: some Fly regions, some custom coordinates (needs testing)
- ✅ Pure Fly region usage: Existing demo app unchanged behavior

## Node Format Support

The library should support both formats seamlessly:

### Fly.io Region Code (Existing)
```elixir
%{
  nodes: ["sjc", "fra", "lhr"],
  style: FlyMapEx.Style.primary(),
  label: "Production Servers"
}
```

### Custom Coordinates (New)
```elixir
%{
  nodes: [
    %{label: "NYC Data Center", coordinates: {40.7128, -74.0060}},
    %{label: "London Office", coordinates: {51.5074, -0.1278}}
  ],
  style: FlyMapEx.Style.primary(),
  label: "Our Locations"
}
```

### Mixed Usage (New)
```elixir
%{
  nodes: [
    "sjc",  # Fly region
    %{label: "Custom Server", coordinates: {40.7128, -74.0060}}
  ],
  style: FlyMapEx.Style.primary(),
  label: "Mixed Deployment"
}
```

## Current Status

**CORE FUNCTIONALITY WORKING**: The library now successfully supports custom coordinates alongside Fly regions. The main blockers have been resolved:

1. **Legend displays custom coordinates properly** - Shows marker group labels and node information
2. **Coordinate plotting works correctly** - Custom lat/long coordinates appear in correct map positions  
3. **Backward compatibility maintained** - Existing Fly region usage unchanged

**Ready for production use** with custom coordinates. Remaining tasks are cosmetic improvements and documentation updates.

## Key Insight
The coordinate resolution was never the problem - `FlyMapEx.Nodes.normalize_node/1` already handles both formats perfectly. The main issue was legend display logic being too tightly coupled to Fly app discovery.

## Backward Compatibility Guarantee
- All existing code using Fly regions will work unchanged
- Same visual output for Fly region usage
- API remains the same, only internal logic enhanced