# FlyMapEx HexDocs Documentation Enhancements

This document outlines comprehensive additions to the FlyMapEx library documentation based on advanced content found in the demo application's Stage LiveViews.

## Overview

The demo application contains substantial advanced documentation and real-world examples that should be incorporated into the main library documentation for HexDocs. This content includes production integration patterns, advanced configuration, real-world scenarios, and best practices.

## Main Module Documentation Additions

### FlyMapEx Module Enhancements

#### Production Integration Section

Add a new section to the main `FlyMapEx` module documentation:

```elixir
## Production Integration

### Data Loading Strategies

For production applications, implement efficient data loading and caching:

    # Dynamic loading with caching
    defmodule MyAppWeb.DashboardLive do
      def mount(_params, _session, socket) do
        marker_groups = MyApp.Infrastructure.get_current_status()
        {:ok, assign(socket, marker_groups: marker_groups)}
      end

      def handle_info({:status_update, new_groups}, socket) do
        {:noreply, assign(socket, marker_groups: new_groups)}
      end
    end

### Real-Time Updates

Integrate with Phoenix PubSub for live data synchronization:

    # Subscribe to infrastructure updates
    def mount(_params, _session, socket) do
      Phoenix.PubSub.subscribe(MyApp.PubSub, "infrastructure:status")
      # ... rest of mount logic
    end

### Error Handling and Graceful Degradation

Implement robust error handling for production reliability:

    def normalize_with_fallback(marker_groups) do
      marker_groups
      |> Enum.map(&safe_normalize_group/1)
      |> Enum.reject(&is_nil/1)
    end

    defp safe_normalize_group(group) do
      case FlyMapEx.Nodes.process_marker_group(group) do
        {:ok, processed} -> processed
        {:error, _reason} ->
          Logger.warning("Failed to process marker group: #{inspect(group)}")
          nil
      end
    end

### Template Design Patterns

Create reusable templates for common configurations:

    defmodule MyApp.MapTemplates do
      def monitoring_template(regions, options \\ []) do
        theme = Keyword.get(options, :theme, :dashboard)
        [
          %{nodes: regions.production, style: :operational, label: "Production"},
          %{nodes: regions.staging, style: :warning, label: "Staging"}
        ]
      end

      def deployment_template(deployment_status) do
        [
          %{nodes: deployment_status.completed, style: :operational, label: "Deployed"},
          %{nodes: deployment_status.in_progress, style: %{colour: "#f59e0b", animation: :pulse}, label: "Deploying"},
          %{nodes: deployment_status.pending, style: :inactive, label: "Pending"}
        ]
      end
    end
```

#### Real-World Examples Section

Add comprehensive scenario examples:

```elixir
## Real-World Examples

### Monitoring Dashboard

Create a monitoring dashboard with operational status indicators:

    marker_groups = [
      %{
        nodes: ["sjc", "fra", "ams", "lhr"],
        style: :operational,
        label: "Production Servers"
      },
      %{
        nodes: ["syd", "nrt"],
        style: :warning,
        label: "Maintenance Windows"
      }
    ]

### Deployment Visualization

Track application rollouts across regions:

    marker_groups = [
      %{
        nodes: ["sjc", "fra"],
        style: :operational,
        label: "Deployed v2.1.0"
      },
      %{
        nodes: ["ams", "lhr"],
        style: %{colour: "#3b82f6", animation: :pulse},
        label: "Deploying v2.1.0"
      },
      %{
        nodes: ["syd", "nrt", "dfw"],
        style: :inactive,
        label: "Pending Deployment"
      }
    ]

### Status Board Configuration

Comprehensive status overview for incident response:

    marker_groups = [
      %{
        nodes: ["sjc", "fra", "ams"],
        style: :operational,
        label: "Healthy Services"
      },
      %{
        nodes: ["lhr"],
        style: :danger,
        label: "Critical Issues"
      },
      %{
        nodes: ["syd"],
        style: :warning,
        label: "Degraded Performance"
      },
      %{
        nodes: ["nrt"],
        style: FlyMapEx.Style.named_colours(:cyan),
        label: "Acknowledged Issues"
      }
    ]
```

## Style Module Documentation Additions

### FlyMapEx.Style Module Enhancements

#### Complete Parameter Reference

Add comprehensive parameter documentation:

```elixir
## Complete Style Parameters Reference

### Direct Style Maps (Primary Interface)

The preferred method for custom styling:

    %{
      colour: "#8b5cf6",    # Hex codes, named colours (:blue), CSS variables (var(--primary))
      size: 8,             # Marker radius in pixels (default: 4)
      animation: :pulse,   # :none, :pulse, :fade (default: :none)
      glow: true           # Boolean for enhanced visibility (default: false)
    }

### Available Parameters

* **colour/color** - Marker colour specification:
  * Hex codes: `"#3b82f6"`, `"#10b981"`
  * Named colours: `:blue`, `:green`, `:red`, `:purple`
  * CSS variables: `"var(--primary)"`, `"var(--success)"`

* **size** - Marker radius in pixels:
  * Range: 1-20 pixels recommended
  * Default: 4 pixels
  * Large sizes (10+) for emphasis

* **animation** - Marker animation type:
  * `:none` - Static markers (default)
  * `:pulse` - Rhythmic size pulsing
  * `:fade` - Opacity pulsing

* **glow** - Enhanced visibility effect:
  * `true` - Adds radial gradient glow
  * `false` - Standard solid markers (default)

### Style Function Reference

    # Automatic colour cycling
    FlyMapEx.Style.cycle(0)     # Blue markers
    FlyMapEx.Style.cycle(1)     # Green markers
    FlyMapEx.Style.cycle(2)     # Red markers
    # Cycles through 12 predefined colours

    # Named colour access
    FlyMapEx.Style.named_colours(:blue)
    FlyMapEx.Style.named_colours(:green, size: 8, animation: :pulse)

    # Semantic presets
    :operational   # Running services - green
    :warning      # Needs attention - amber
    :danger       # Critical issues - red with pulse animation
    :inactive     # Not running - gray

### Production Configuration Patterns

Configure default styles in your application:

    # config/config.exs
    config :fly_map_ex,
      default_presets: %{
        operational: %{colour: "#10b981", size: 6},
        warning: %{colour: "#f59e0b", size: 6},
        danger: %{colour: "#ef4444", size: 6, animation: :pulse},
        inactive: %{colour: "#6b7280", size: 4}
      },
      style_presets: %{
        brand_primary: %{colour: "#your-brand-color", size: 8, animation: :pulse, glow: true},
        monitoring_alert: %{colour: "#ff6b6b", size: 10, glow: true}
      }

### Mixed Styling Approaches

Combine different styling methods for complex scenarios:

    marker_groups = [
      # Semantic styling for core functionality
      %{nodes: ["sjc", "fra"], style: :operational, label: "Production"},

      # Custom styling for special cases
      %{nodes: ["ams"], style: %{colour: "#8b5cf6", size: 10, glow: true}, label: "Special Alert"},

      # Named colours for organization
      %{nodes: ["lhr"], style: FlyMapEx.Style.named_colours(:purple), label: "Team Purple"},

      # Automatic cycling for dynamic groups
      %{nodes: ["syd"], style: FlyMapEx.Style.cycle(0), label: "Auto Group 1"}
    ]
```

## Theme Module Documentation Additions

### FlyMapEx.Theme Module Enhancements

#### CSS Framework Integration

Add comprehensive integration examples:

```elixir
## CSS Framework Integration

### DaisyUI Integration

The `:responsive` theme automatically adapts to DaisyUI theme changes:

    # Automatically switches with DaisyUI light/dark themes
    <FlyMapEx.render marker_groups={@groups} theme={:responsive} />

### Tailwind CSS Custom Properties

Create themes using Tailwind colour variables:

    custom_theme = %{
      land: "rgb(var(--color-slate-100))",
      ocean: "rgb(var(--color-slate-200))",
      border: "rgb(var(--color-slate-400))",
      neutral_marker: "rgb(var(--color-slate-500))",
      neutral_text: "rgb(var(--color-slate-700))"
    }

### Dynamic Theme Switching

Implement real-time theme changes:

    # LiveView theme switching
    def handle_event("theme_change", %{"theme" => theme}, socket) do
      socket = assign(socket, :current_theme, String.to_atom(theme))
      {:noreply, push_event(socket, "theme-changed", %{theme: theme})}
    end

    # JavaScript for CSS custom property updates
    window.addEventListener("phx:theme-changed", (e) => {
      document.documentElement.setAttribute("data-theme", e.detail.theme);
    });

### Environment-Specific Theming

Configure themes per environment:

    # config/dev.exs
    config :fly_map_ex, :default_theme, :light

    # config/prod.exs
    config :fly_map_ex, :default_theme, :responsive

    # config/test.exs
    config :fly_map_ex, :default_theme, :high_contrast

### Performance Optimization

Optimize theme rendering for production:

    # Precompile theme colours
    defmodule MyApp.ThemeCache do
      @compiled_themes %{
        corporate: FlyMapEx.Theme.map_theme(:corporate),
        dashboard: FlyMapEx.Theme.map_theme(:dashboard)
      }

      def get_theme(theme_name), do: @compiled_themes[theme_name]
    end
```

## Configuration Module Documentation Additions

### FlyMapEx.Config Module Enhancements

#### Complete Configuration Reference

Add comprehensive configuration documentation:

```elixir
## Complete Configuration Reference

### Core Settings

    config :fly_map_ex,
      # Default marker properties
      marker_opacity: 1.0,
      default_marker_radius: 8,
      region_marker_radius: 2,

      # Animation settings
      animation_duration: "2s",
      animation_opacity_range: {0.3, 1.0},
      svg_pulse_size_delta: 2,

      # Display defaults
      show_regions: true,
      layout_mode: :stacked,
      legend_container_multiplier: 2.0,

      # Theme configuration
      default_theme: :light

### Theme Configuration

    config :fly_map_ex,
      default_theme: :responsive,
      custom_themes: %{
        corporate: %{
          land: "#f8fafc",
          ocean: "#e2e8f0",
          border: "#475569",
          neutral_marker: "#64748b",
          neutral_text: "#334155"
        },
        brand: %{
          land: "#fef3c7",
          ocean: "#fed7aa",
          border: "#d97706",
          neutral_marker: "#92400e",
          neutral_text: "#451a03"
        }
      }

### Style Configuration

    config :fly_map_ex,
      default_presets: %{
        operational: %{colour: "#10b981", size: 6},
        warning: %{colour: "#f59e0b", size: 6},
        danger: %{colour: "#ef4444", size: 6, animation: :pulse},
        inactive: %{colour: "#6b7280", size: 4}
      },
      style_presets: %{
        brand_primary: %{colour: "#your-brand", size: 8, animation: :pulse},
        monitoring_alert: %{colour: "#ff6b6b", size: 10, glow: true}
      }

### Regional Configuration

    config :fly_map_ex, :custom_regions, %{
      "dev" => %{name: "Development", coordinates: {47.6062, -122.3321}},
      "laptop-chris" => %{name: "Chris's Laptop", coordinates: {49.2827, -123.1207}},
      "office-nyc" => %{name: "NYC Office", coordinates: {40.7128, -74.0060}}
    }

### Resolution Priority

Configuration resolution follows this priority order:

1. **Inline props** - Direct component attributes
2. **Custom themes/presets** - Application-specific configurations
3. **Application defaults** - Config-level defaults
4. **Library defaults** - Built-in fallbacks

### Environment Patterns

    # Development - Maximum visibility for debugging
    config :fly_map_ex,
      default_theme: :light,
      marker_opacity: 1.0,
      show_regions: true

    # Production - Performance and adaptability
    config :fly_map_ex,
      default_theme: :responsive,
      marker_opacity: 0.8,
      show_regions: false

    # Testing - Accessibility and consistency
    config :fly_map_ex,
      default_theme: :high_contrast,
      marker_opacity: 1.0,
      animation_duration: "0s"  # Disable animations for testing
```

## New Documentation Guides

### Getting Started Guide

```markdown
# Getting Started with FlyMapEx

## Basic Setup

Add FlyMapEx to your Phoenix LiveView application:

    # In your LiveView template
    <FlyMapEx.render marker_groups={@marker_groups} />

## Fundamental Concepts

### Marker Groups

The core data structure for organizing nodes:

    marker_groups = [
      %{
        nodes: ["sjc", "fra"],      # Where to place markers
        style: :operational,        # How markers appear
        label: "Production Servers" # What to call the group
      }
    ]

### Node Formats

Multiple ways to specify node locations:

    nodes: ["sjc", "fra"]                    # Fly.io region codes
    nodes: [{40.7, -74.0}, {51.5, -0.1}]    # Coordinate tuples
    nodes: [%{label: "NYC", region: "lhr"}] # Custom labels
    nodes: [%{label: "Custom", coordinates: {52.0, 13.0}}] # Full custom

### Basic Styling

    # Automatic colours (simplest)
    %{nodes: ["sjc"], label: "Group 1"}

    # Semantic presets (recommended)
    %{nodes: ["sjc"], style: :operational, label: "Production"}

    # Custom styling (most flexible)
    %{nodes: ["sjc"], style: %{colour: "#3b82f6", size: 8}, label: "Custom"}

## First Map

Create your first interactive map:

    defmodule MyAppWeb.MapLive do
      use MyAppWeb, :live_view

      def mount(_params, _session, socket) do
        marker_groups = [
          %{
            nodes: ["sjc", "fra", "lhr"],
            style: :operational,
            label: "Production Servers"
          },
          %{
            nodes: ["ams", "syd"],
            style: :warning,
            label: "Maintenance Mode"
          }
        ]

        {:ok, assign(socket, marker_groups: marker_groups)}
      end

      def render(assigns) do
        ~H"""
        <div class="container mx-auto p-4">
          <h1 class="text-2xl mb-4">Infrastructure Map</h1>
          <FlyMapEx.render
            marker_groups={@marker_groups}
            theme={:dashboard}
            show_regions={true}
          />
        </div>
        """
      end
    end
```

### Styling Guide

```markdown
# Comprehensive Styling Guide

## Style Philosophy

FlyMapEx uses a layered approach to styling:

1. **Automatic** - Default colours for quick prototyping
2. **Semantic** - Meaningful presets for common states
3. **Custom** - Full control for unique requirements

## Semantic Styling (Recommended)

Use semantic presets to convey meaning:

    :operational  # Green - systems running normally
    :warning     # Amber - requires attention
    :danger      # Red with pulse - critical issues
    :inactive    # Gray - not currently active

### When to Use Semantic Styles

- Monitoring dashboards
- Status indicators
- Health checks
- Incident response tools

## Custom Styling

For unique requirements, use direct style maps:

    %{
      colour: "#8b5cf6",    # Brand colours, hex codes
      size: 10,            # Emphasis through size
      animation: :pulse,   # Draw attention
      glow: true           # Enhanced visibility
    }

### Style Parameters Deep Dive

**Colour Options:**
- Hex codes: `"#3b82f6"`, `"#ef4444"`
- Named colours: `:blue`, `:red`, `:green`
- CSS variables: `"var(--primary)"`, `"oklch(0.7 0.15 200)"`

**Size Guidelines:**
- Small (2-4px): Subtle indicators
- Medium (6-8px): Standard markers
- Large (10-12px): Important alerts
- Extra large (14+px): Critical emphasis

**Animation Usage:**
- `:none` - Static, stable states
- `:pulse` - Attention-seeking, alerts
- `:fade` - Gentle breathing effect

**Glow Effects:**
- Use sparingly for critical items
- Effective for dark themes
- Can impact performance with many markers

## Advanced Styling Patterns

### Conditional Styling

    def get_style_for_status(status) do
      case status do
        :healthy -> :operational
        :degraded -> :warning
        :down -> :danger
        :maintenance -> %{colour: "#8b5cf6", animation: :fade}
        _ -> :inactive
      end
    end

### Dynamic Style Generation

    def generate_team_styles(teams) do
      teams
      |> Enum.with_index()
      |> Enum.map(fn {team, index} ->
        %{
          nodes: team.regions,
          style: FlyMapEx.Style.cycle(index),
          label: team.name
        }
      end)
    end

### Performance Optimization

- Prefer semantic presets over custom maps when possible
- Avoid excessive glow effects (limit to 3-5 per map)
- Use CSS variables for theme-aware colours
- Cache complex style calculations
```

### Production Guide

```markdown
# Production Deployment Guide

## Performance Optimization

### Efficient Data Loading

Implement smart loading strategies:

    defmodule MyApp.MapData do
      @cache_ttl :timer.minutes(5)

      def get_marker_groups do
        ConCache.get_or_store(:map_cache, :marker_groups, fn ->
          %ConCache.Item{
            value: build_marker_groups(),
            ttl: @cache_ttl
          }
        end)
      end

      defp build_marker_groups do
        # Expensive data fetching and processing
        MyApp.Infrastructure.get_all_regions()
        |> process_regions()
        |> normalize_marker_groups()
      end
    end

### Error Handling

Implement robust error handling:

    def safe_render_map(marker_groups) do
      case validate_marker_groups(marker_groups) do
        {:ok, validated} ->
          FlyMapEx.render(marker_groups: validated)

        {:error, reasons} ->
          Logger.warning("Map rendering failed: #{inspect(reasons)}")
          render_fallback_map()
      end
    end

### Real-Time Updates

Integrate with Phoenix PubSub:

    defmodule MyAppWeb.DashboardLive do
      def mount(_params, _session, socket) do
        if connected?(socket) do
          Phoenix.PubSub.subscribe(MyApp.PubSub, "infrastructure:updates")
        end

        {:ok, load_initial_data(socket)}
      end

      def handle_info({:region_update, region, status}, socket) do
        updated_groups = update_region_status(socket.assigns.marker_groups, region, status)
        {:noreply, assign(socket, marker_groups: updated_groups)}
      end
    end

## Scalability Considerations

### Large Data Sets

For applications with many regions:

    # Implement pagination or filtering
    def get_visible_marker_groups(filters \\ %{}) do
      all_groups = get_all_marker_groups()

      all_groups
      |> filter_by_criteria(filters)
      |> limit_groups(50) # Prevent UI overload
    end

### Memory Management

    # Use GenServer for state management
    defmodule MyApp.MapState do
      use GenServer

      def get_current_state do
        GenServer.call(__MODULE__, :get_state)
      end

      def update_region(region, status) do
        GenServer.cast(__MODULE__, {:update_region, region, status})
      end
    end

## Security Considerations

### Input Validation

Always validate marker group data:

    def validate_marker_group(group) do
      with {:ok, nodes} <- validate_nodes(group.nodes),
           {:ok, style} <- validate_style(group.style),
           {:ok, label} <- validate_label(group.label) do
        {:ok, %{nodes: nodes, style: style, label: label}}
      end
    end

### Rate Limiting

Implement rate limiting for real-time updates:

    defmodule MyApp.UpdateThrottle do
      use GenServer

      @update_interval 1000 # 1 second minimum between updates

      def throttled_update(data) do
        GenServer.cast(__MODULE__, {:throttled_update, data})
      end
    end

## Monitoring and Observability

### Performance Metrics

Track map performance:

    defmodule MyApp.MapTelemetry do
      def track_render_time(fun) do
        start_time = System.monotonic_time()
        result = fun.()
        end_time = System.monotonic_time()

        duration = System.convert_time_unit(end_time - start_time, :native, :millisecond)
        :telemetry.execute([:map, :render], %{duration: duration})

        result
      end
    end

### Error Tracking

Implement comprehensive error tracking:

    def handle_map_error(error, context) do
      Sentry.capture_exception(error,
        extra: %{
          map_context: context,
          marker_groups_count: length(context.marker_groups)
        }
      )
    end
```

## Implementation Checklist

### Pre-Production

- [ ] Configure appropriate themes for your brand
- [ ] Set up custom regions if needed
- [ ] Implement error handling and fallbacks
- [ ] Add performance monitoring
- [ ] Test with realistic data volumes
- [ ] Validate accessibility compliance

### Production Deployment

- [ ] Configure caching strategies
- [ ] Set up real-time update mechanisms
- [ ] Implement rate limiting
- [ ] Add security validation
- [ ] Monitor performance metrics
- [ ] Plan for scaling scenarios

### Post-Deployment

- [ ] Monitor error rates and performance
- [ ] Collect user feedback on map usability
- [ ] Track loading times and responsiveness
- [ ] Plan for feature enhancements
- [ ] Maintain documentation and examples

## Best Practices Summary

1. **Start Simple** - Begin with semantic styles and basic configurations
2. **Validate Early** - Implement robust input validation and error handling
3. **Cache Wisely** - Cache expensive computations but keep data fresh
4. **Monitor Performance** - Track render times and user interactions
5. **Plan for Scale** - Design for growth in data volume and user base
6. **Document Everything** - Maintain clear documentation for your team
7. **Test Thoroughly** - Include accessibility and performance testing
8. **Iterate Based on Feedback** - Continuously improve based on user needs