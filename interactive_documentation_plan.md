# FlyMapEx Interactive Documentation Design Plan

## Overview

This document outlines the educational design for transforming the FlyMapEx demo app into comprehensive interactive documentation. The goal is to create a cohesive, progressive learning experience that teaches users how to effectively use the FlyMapEx library.

## Educational Philosophy

- **Progressive Complexity**: Each stage builds on previous concepts while remaining independently consumable
- **Learning by Doing**: Interactive examples with immediate visual feedback
- **Consistent Patterns**: Uniform layout and interaction patterns across all stages
- **Above the Fold**: Key concepts and primary examples visible without scrolling
- **Contextual Depth**: Advanced topics available via expandable sections or modals

## Overall Structure: 4 Core Learning Stages

### Stage 1: Defining Marker Groups

#### Implementation progress 
[x] Phase 1: Foundation
[-] Phase 2: Enhanced Interactivity (started)
[ ] Phase 3: Advanced Features (later)
[ ] Phase 4: Polish and Integration (later)

**Learning Objective**: Understand the fundamental data structure and syntax options

**Key Concepts**:
- Basic marker group structure
- Fly region shorthand vs. custom coordinates
- Single vs. multiple markers
- Multiple groups organization

### Stage 2: Styling Markers
#### Implementation progress 
[ ] Phase 1: Foundation
[ ] Phase 2: Enhanced Interactivity
[ ] Phase 3: Advanced Features (later)
[ ] Phase 4: Polish and Integration (later)

**Learning Objective**: Master visual customization and semantic meaning

**Key Concepts**:
- Automatic style cycling
- Semantic style presets
- Custom style parameters
- Configuration-based style presets

### Stage 3: Map Themes
#### Implementation progress 
[ ] Phase 1: Foundation
[ ] Phase 2: Enhanced Interactivity
[ ] Phase 3: Advanced Features (later)
[ ] Phase 4: Polish and Integration (later)

**Learning Objective**: Control overall visual presentation and branding

**Key Concepts**:
- Predefined theme presets
- Responsive theming
- Custom theme creation
- Configuration vs. inline theming

### Stage 4: Interactive Builder/Playground

#### Implementation progress 
[ ] Phase 1: Foundation
[ ] Phase 2: Enhanced Interactivity
[ ] Phase 3: Advanced Features (later)
[ ] Phase 4: Polish and Integration (later)

**Learning Objective**: Apply knowledge to real-world scenarios

**Key Concepts**:
- Guided scenario building
- Freeform experimentation
- Code export and integration

## Within-Stage Progressions

### Stage 1: Defining Marker Groups
**Progression: Simple → Multiple → Mixed**

1. **Single Node with Coordinates**
   - Show basic `%{coordinates: {lat, lng}, label: "Name"}` syntax
   - Explain coordinate system (WGS84)
   - Interactive example with SF coordinates

2. **Fly Region Shorthand**
   - Same location using `"sjc"` region code
   - Explain region code convenience
   - Show region lookup and validation
 

3. **Multiple Nodes in Group**
   - Single group with `["sjc", "fra", "ams", "lhr"]`
   - Demonstrate label and style consistency
   - Interactive toggle to add/remove regions

4. **Multiple Groups**
   - Two groups with different purposes
   - Example: "Production" vs "Staging" servers
   - Show legend generation and group management

**Interactive Elements**:
- Buttons: "Single Node (coordinates)", "Single Node (Fly region)", "Multiple Nodes (one group)", "Multiple groups"
- **Later** Add/remove region buttons
- **Later** Group management controls

### Stage 2: Styling Markers

More implementation in ./stage2_implementation.md

**Progression: Automatic → Semantic → Custom**

1. **Automatic Styling**
   - Multiple groups with default cycle colours
   - Explain colour consistency and cycling
   - Show `FlyMapEx.Style.cycle/1` function

2. **Semantic Presets**
   - Same data with meaningful styles
   - `operational()`, `warning()`, `danger()`, `inactive()`
   - Explain semantic meaning and visual conventions

3. **Custom Parameters**
   - Modify size, animation, glow on presets
   - Show parameter combinations
   - Interactive sliders for live adjustment

4. **Custom Styles**
   - Build completely custom styles
   - Colour picker integration
   - Animation and effect controls

5. **Config Presets**
   - Save custom styles as reusable presets
   - Show config.exs integration
   - Demonstrate preset usage

**Interactive Elements**:
- Style preset buttons (operational, warning, danger, etc.)
- Parameter sliders (size, opacity, animation speed)
- Colour picker for custom styles
- Animation toggles (none, pulse, spin, bounce)
- Glow/gradient checkboxes
- Save/load preset controls

### Stage 3: Map Themes
**Progression: Presets → Responsive → Custom**

1. **Theme Presets**
   - Buttons for dashboard, monitoring, presentation, minimal, dark
   - Same content with different visual presentations
   - Explain theme use cases and contexts

2. **Responsive Theme**
   - Show how responsive theme adapts
   - Different breakpoints and contexts
   - Automatic colour and sizing adjustments

3. **Custom Theme Creation**
   - Interactive theme builder
   - Colour pickers for land, ocean, borders
   - Typography and spacing controls
   - Real-time preview

4. **Configuration Approaches**
   - config.exs vs inline theme specification
   - Theme precedence and override rules
   - Production deployment considerations

**Interactive Elements**:
- Theme preset buttons
- Responsive preview simulator
- Custom theme builder with colour pickers
- Typography controls
- Save/export theme functionality

### Stage 4: Interactive Builder/Playground
**Progression: Guided → Freeform → Export**

1. **Guided Scenarios**
   - Pre-built examples: "Monitoring Dashboard", "Deployment Map", "Status Board"
   - Step-by-step construction with explanations
   - Best practice demonstrations

2. **Freeform Building**
   - Empty canvas with full customization
   - Drag-and-drop region selection
   - Live code generation and preview

3. **Export and Integration**
   - Generate production-ready code
   - Multiple export formats (HEEx, Elixir module, JSON config)
   - Integration examples and documentation

**Interactive Elements**:
- Scenario selection buttons
- Region selection map interface
- Group management tools
- Style and theme builders
- Code export with format selection
- Copy-to-clipboard functionality

## Technical Implementation Notes

### Existing Components to Leverage

1. **DemoNavigation** (`demo_navigation.ex`)
   - Consistent navigation pattern across stages
   - Mobile-responsive design
   - Clear progression indicators

2. **MapWithCodeComponent** (`map_with_code_component.ex`)
   - Side-by-side map and code display
   - Automatic code generation from configurations
   - Sophisticated style formatting

3. **Existing Stage Pattern**
   - LiveView structure for interactivity
   - Consistent mount/handle_event patterns
   - Responsive layout grid

### New Components Needed

1. **InteractiveControls**
   - Reusable preset buttons
   - Parameter sliders and controls
   - Toggle switches for feature comparison

2. **ThemeBuilder**
   - Colour picker integration
   - Real-time theme preview
   - Theme export functionality

3. **StyleBuilder**
   - Style parameter controls
   - Animation preview
   - Custom style creation

4. **RegionSelector**
   - Interactive region selection
   - Visual region map
   - Search and filter capabilities

5. **CodeExporter**
   - Multiple format support
   - Formatted code generation
   - Copy-to-clipboard integration

### Data Structures

```elixir
# Example configurations for each stage
stage_configs = %{
  stage1: %{
    examples: [
      %{
        name: "single_node",
        marker_groups: [...],
        description: "Basic single node example"
      }
    ]
  },
  stage2: %{
    style_presets: [...],
    custom_options: [...],
    examples: [...]
  },
  stage3: %{
    theme_presets: [...],
    custom_themes: [...],
    examples: [...]
  },
  stage4: %{
    scenarios: [...],
    templates: [...]
  }
}
```

## Layout Patterns

### Consistent Page Structure

```
┌─────────────────────────────────────────────────────┐
│ Navigation Bar                                      │
├─────────────────────────────────────────────────────┤
│ Stage Title & Progress                              │
├─────────────────────────────────────────────────────┤
│ Key Concept Explanation (Above the Fold)           │
├─────────────────────────────────────────────────────┤
│ Interactive Controls & Presets                     │
├─────────────────────────────────────────────────────┤
│ ┌─────────────────────┬─────────────────────────┐   │
│ │ Live Map Preview    │ Generated Code          │   │
│ │                     │                         │   │
│ │                     │                         │   │
│ └─────────────────────┴─────────────────────────┘   │
├─────────────────────────────────────────────────────┤
│ Expandable Advanced Topics                          │
├─────────────────────────────────────────────────────┤
│ Previous/Next Navigation                            │
└─────────────────────────────────────────────────────┘
```

### Responsive Considerations

- Mobile: Stack map and code vertically
- Tablet: Stack map and code vertically
- Desktop: Maintain side-by-side with adjusted proportions

## Implementation Priorities

### Phase 1: Foundation
1. Update existing stages to follow consistent pattern
2. Create reusable interactive control components
3. Implement progressive disclosure for advanced topics

### Phase 2: Enhanced Interactivity
1. Add preset buttons and live controls to each stage
2. Implement theme and style builders
3. Add export functionality

### Phase 3: Advanced Features
1. Complete interactive builder/playground
2. Add guided scenarios and templates
3. Implement sharing and collaboration features

### Phase 4: Polish and Integration
1. Performance optimization
2. Accessibility improvements
3. Documentation and deployment

## Key Design Decisions

1. **Consistency Over Novelty**: Use established patterns from existing stages
2. **Progressive Enhancement**: Start with basic functionality, add advanced features
3. **Educational First**: Prioritize learning objectives over feature completeness
4. **Real-World Application**: Always show how concepts apply to production use

## Success Metrics

- **User Comprehension**: Can users build their own maps after completing stages?
- **Adoption**: Do users integrate FlyMapEx into their own projects?
- **Progression**: Do users complete multiple stages in sequence?
- **Engagement**: How long do users spend in each stage?

## Next Steps

This plan provides the foundation for implementing the interactive documentation. Choose any stage or component to begin detailed implementation planning and development.

Priority areas for next conversations:
1. **Stage 1 Enhancement** - Add progressive controls and preset buttons
2. **Style Builder Component** - Create interactive style customization
3. **Theme Builder Component** - Build comprehensive theme editor
4. **Interactive Builder** - Develop the freeform playground experience