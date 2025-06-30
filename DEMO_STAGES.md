# FlyMapEx Demo Stages

This document outlines a comprehensive demonstration of FlyMapEx library capabilities, progressing from basic usage to advanced features.

## Stage 1: Basic Map Display

**Goal**: Show minimal setup and basic functionality

**Features to demonstrate**:
- Single region group with default styling
- Basic Fly.io region codes ("sjc", "fra", "ams", "lhr")
- Default theme and minimal configuration
- Simple marker placement

**Example code**:
```elixir
marker_groups = [
  %{
    nodes: ["sjc", "fra", "ams"],
    style: FlyMapEx.Style.primary(),
    label: "My Servers"
  }
]
```

## Stage 2: Multiple Groups & Styling

**Goal**: Demonstrate semantic styling and multiple marker groups

**Features to demonstrate**:
- Multiple marker groups with different purposes
- Semantic styles: `operational()`, `warning()`, `danger()`, `inactive()`
- How colour consistency works when groups are toggled
- Different marker sizes and animations

**Example code**:
```elixir
marker_groups = [
  %{
    nodes: ["sjc", "fra"],
    style: FlyMapEx.Style.operational(),
    label: "Production Servers"
  },
  %{
    nodes: ["ams", "lhr"],
    style: FlyMapEx.Style.warning(),
    label: "Maintenance Mode"
  },
  %{
    nodes: ["ord"],
    style: FlyMapEx.Style.danger(),
    label: "Failed Nodes"
  }
]
```

## Stage 3: Themes & Backgrounds

**Goal**: Show visual customization through themes

**Features to demonstrate**:
- Different background themes: `:light`, `:dark`, `:minimal`, `:cool`, `:warm`
- Responsive background with DaisyUI integration
- High contrast accessibility theme (`:high_contrast`)
- How themes affect overall map appearance

**Example themes to show**:
```elixir
# Dark theme
<FlyMapEx.render marker_groups={groups} theme={:dark} />

# Responsive with DaisyUI
<FlyMapEx.render 
  marker_groups={groups} 
  background={FlyMapEx.Theme.responsive_background()} 
/>
```

## Stage 4: Custom Styling

**Goal**: Advanced styling capabilities and customization

**Features to demonstrate**:
- Non-semantic colour cycling with `cycle(index)`
- Custom styles with `custom()` function
- Animation options: `:pulse`, `:bounce`, `:fade`
- Gradient fills and size variations
- CSS variable integration

**Example code**:
```elixir
marker_groups = [
  %{
    nodes: ["sjc"],
    style: FlyMapEx.Style.cycle(0),
    label: "App 1"
  },
  %{
    nodes: ["fra"],
    style: FlyMapEx.Style.custom("#3b82f6", size: 10, animated: true, animation: :bounce),
    label: "Custom Style"
  },
  %{
    nodes: ["ams"],
    style: FlyMapEx.Style.custom("var(--primary)", gradient: true),
    label: "CSS Variable"
  }
]
```

## Stage 5: Interactive Features

**Goal**: Show dynamic and interactive capabilities

**Features to demonstrate**:
- Legend component with group toggling functionality
- Real-time map updates
- Group visibility controls
- Click handlers and state management

**Features to highlight**:
- How groups maintain consistent colours when toggled
- Legend component integration
- LiveView state management for interactivity

## Stage 6: Advanced Data Integration

**Goal**: Real-world data integration scenarios

**Features to demonstrate**:
- Custom coordinate nodes (non-Fly regions)
- Dynamic data from Fly.io DNS TXT records
- Machine discovery integration using `dig` commands
- Parsing machine data into marker groups

**Example custom nodes**:
```elixir
marker_groups = [
  %{
    nodes: [
      "sjc",  # Standard Fly region
      %{label: "Custom Location", coordinates: {37.7749, -122.4194}}  # Custom coordinates
    ],
    style: FlyMapEx.Style.operational(),
    label: "Mixed Locations"
  }
]
```

**Machine discovery example**:
```bash
dig +short txt vms.my-app-name.internal
# Returns: "683d314fdd4d68 yyz,568323e9b54dd8 lhr"
```

## Stage 7: Real-world Examples

**Goal**: Practical application scenarios

**Use cases to demonstrate**:
- Production monitoring dashboard
- Multi-app deployment visualization
- Live machine status tracking
- Health monitoring with automatic style updates
- Geographic distribution analysis

**Integration patterns**:
- Phoenix LiveView for real-time updates
- GenServer for background data fetching
- Periodic updates from Fly.io APIs

## Stage 8: Code Builder Tool

**Goal**: Show the interactive development experience

**Features to demonstrate**:
- Interactive code generation in `MapDemoLive`
- Real-time validation with error messages
- Autocomplete hints for regions and styles
- Copy-to-clipboard functionality
- Live preview updates as code changes

**Educational aspects**:
- Show validation errors for invalid regions
- Demonstrate syntax highlighting
- Quick reference for available styles and regions
- Generated HEEx code preview

## Demo Flow Recommendations

1. **Start Simple**: Begin with Stage 1 to establish baseline understanding
2. **Build Incrementally**: Each stage should build on previous concepts
3. **Show Interactivity**: Emphasize the LiveView integration throughout
4. **Real Data**: Use actual Fly.io regions and realistic scenarios
5. **End with Builder**: Stage 8 allows audience to experiment hands-on

## Technical Notes

- Each stage should be implemented as a separate LiveView page or component
- Use the existing demo application structure
- Leverage the Tidewave MCP server for live development
- Include code examples that can be copied directly
- Show both the code and resulting visual output for each stage

## Audience Considerations

- **Developers**: Focus on code examples and integration patterns
- **Designers**: Emphasize theming and visual customization
- **DevOps**: Highlight monitoring and deployment visualization use cases
- **General**: Keep explanations clear and build complexity gradually