---
title: API Reference
description: Complete API documentation for FlyMapEx components and functions
nav_order: 3
---

# API Reference

Complete reference for FlyMapEx components and configuration options.

## FlyMapEx.render/1

The main entry point for rendering world maps.

### Parameters

- `region_groups` (required) - List of region group maps
- `theme` (optional) - Theme atom (`:dashboard`, `:monitoring`, `:presentation`, etc.)
- `config` (optional) - Custom configuration map

### Region Group Format

```elixir
%{
  regions: ["sjc", "fra"],     # List of Fly.io region codes
  style_key: :primary,         # Style identifier
  label: "Production Servers"  # Display label for legend
}
```

## Available Style Keys

| Style Key | Description | Color | Animation |
|-----------|-------------|-------|-----------|
| `:primary` | Primary markers | Blue | Animated |
| `:active` | Active status | Yellow | Static |
| `:expected` | Expected deployment | Orange | Animated |
| `:acknowledged` | Acknowledged | Violet | Static |
| `:secondary` | Secondary markers | Green | Static |
| `:warning` | Warning status | Red | Animated |
| `:inactive` | Inactive markers | Gray | Static |

## Themes

| Theme | Description | Use Case |
|-------|-------------|----------|
| `:dashboard` | Compact, cool colors | Infrastructure dashboards |
| `:monitoring` | Standard size, default colors | Monitoring applications |
| `:presentation` | Large, warm colors | Presentations |
| `:minimal` | Clean grayscale | Minimal interfaces |
| `:dark` | Dark background | Dark mode applications |

## Supported Regions

FlyMapEx supports all Fly.io regions with accurate geographic coordinates. Unknown regions are placed off-screen but won't cause errors.