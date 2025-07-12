---
title: Getting Started
description: Quick start guide for integrating FlyMapEx into your Phoenix application
nav_order: 2
---

# Getting Started with FlyMapEx

This guide will help you integrate FlyMapEx into your Phoenix LiveView application.

## Installation

Add FlyMapEx to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fly_map_ex, "~> 0.1.0"}
  ]
end
```

## Basic Usage

The simplest way to use FlyMapEx is with the main render function:

```elixir
defmodule MyApp.MapLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <div>
      <.live_component module={FlyMapEx} id="world-map" region_groups={@region_groups} />
    </div>
    """
  end

  def mount(_params, _session, socket) do
    region_groups = [
      %{regions: ["sjc", "fra"], style_key: :primary, label: "Production"},
      %{regions: ["ams", "lhr"], style_key: :active, label: "Staging"}
    ]
    
    {:ok, assign(socket, region_groups: region_groups)}
  end
end
```

## Configuration

You can customize the appearance using themes:

```elixir
<.live_component 
  module={FlyMapEx} 
  id="world-map" 
  region_groups={@region_groups}
  theme={:dashboard}
/>
```

## Next Steps

Explore our interactive demo to see all the features and configuration options available.