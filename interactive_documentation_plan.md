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
[x] Phase 1: Foundation ✅ COMPLETED - Tabbed Interface
[ ] Phase 2: Enhanced Interactivity (ready to start)
[ ] Phase 3: Advanced Features (later)
[ ] Phase 4: Polish and Integration (later)

**Learning Objective**: Master visual customization and semantic meaning

**Key Concepts**:
- Automatic style cycling with `FlyMapEx.Style.cycle/1`
- Semantic style presets (operational, warning, danger, inactive)
- Custom style parameters (size, animation, glow)
- Mixed styling approaches for real-world scenarios

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

**✅ COMPLETED: Tabbed Interface Implementation**

**Current Implementation Status**:
- ✅ Tabbed info panel with rich, focused content for each styling approach
- ✅ Full-width map above the fold for immediate visual impact
- ✅ Side-by-side tabbed info panel and focused code examples
- ✅ Four comprehensive tabs: Automatic → Semantic → Custom → Mixed
- ✅ Tab-specific code examples that are concise and relevant
- ✅ Visual styling guides with live CSS demonstrations

**Progression: Automatic → Semantic → Custom → Mixed** ✅ IMPLEMENTED

1. **Automatic Styling** ✅ COMPLETED
   - Deep dive into `FlyMapEx.Style.cycle/1` functionality
   - Color progression guide showing all 12 cycle colors
   - When to use automatic styling (equal importance groups)
   - Pro tips about color wrapping and consistency

2. **Semantic Presets** ✅ COMPLETED
   - Comprehensive coverage of operational(), warning(), danger(), inactive()
   - Visual examples with colored panels showing each preset
   - Best practices for monitoring dashboards and status displays
   - Animation logic explanation for critical states

3. **Custom Parameters** ✅ COMPLETED
   - Interactive parameter guide for size, animation, glow
   - Visual size progression (4px → 6px → 8px → 10px)
   - Animation type demonstrations (none, pulse, fade)
   - Glow effect visual comparison

4. **Mixed Approaches** ✅ COMPLETED
   - Real-world scenarios combining different methods
   - Production patterns and strategies
   - Common use cases with examples
   - Migration guidance from simple to complex styling

**Interactive Elements Implemented**:
- ✅ Tabbed navigation for switching styling approaches
- ✅ Full-width map updates when switching tabs
- ✅ Focused code examples per tab
- ✅ Quick configuration stats panel
- ✅ Rich visual styling guides within each tab

**Phase 2 Opportunities (Enhanced Interactivity)**:
- [ ] Live parameter adjustment sliders within Custom tab
- [ ] Color picker integration for real-time custom styling
- [ ] Animation preview controls
- [ ] Save/load custom style configurations
- [ ] Interactive style comparison tool

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

1. **InteractiveControls** ✅ ENHANCED
   - ✅ Reusable preset buttons
   - ✅ Tabbed info panel component
   - [ ] Parameter sliders and controls (ready for Phase 2)
   - [ ] Toggle switches for feature comparison

2. **ThemeBuilder**
   - [ ] Colour picker integration
   - [ ] Real-time theme preview
   - [ ] Theme export functionality

3. **StyleBuilder**
   - [ ] Style parameter controls (enhanced version of current custom tab)
   - [ ] Animation preview
   - [ ] Custom style creation with live preview

4. **RegionSelector**
   - [ ] Interactive region selection
   - [ ] Visual region map
   - [ ] Search and filter capabilities

5. **CodeExporter**
   - [ ] Multiple format support
   - [ ] Formatted code generation
   - [ ] Copy-to-clipboard integration

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

**Original Layout Pattern:**
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

**✅ NEW: Stage 2 Tabbed Layout Pattern (Implemented):**
```
┌─────────────────────────────────────────────────────┐
│ Navigation Bar                                      │
├─────────────────────────────────────────────────────┤
│ Stage Title & Brief Description                     │
├─────────────────────────────────────────────────────┤
│ FlyMapEx Component (Full Width, Above the Fold)    │
│ ┌─────────────────────────────────────────────────┐ │
│ │ Interactive World Map with Legend               │ │
│ └─────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────┤
│ ┌─────────────────────┬─────────────────────────┐   │
│ │ Tabbed Info Panel   │ Focused Code Examples   │   │
│ │ ┌─────────────────┐ │ ┌─────────────────────┐ │   │
│ │ │[Auto][Sem][Cus] │ │ │ # Tab-specific code │ │   │
│ │ │ │Mixed│         │ │ │                     │ │   │
│ │ │─────────────────│ │ │                     │ │   │
│ │ │ Rich topic-     │ │ │                     │ │   │
│ │ │ specific content│ │ │                     │ │   │
│ │ └─────────────────┘ │ └─────────────────────┘ │   │
│ └─────────────────────┴─────────────────────────┘   │
├─────────────────────────────────────────────────────┤
│ Expandable Advanced Topics                          │
├─────────────────────────────────────────────────────┤
│ Previous/Next Navigation                            │
└─────────────────────────────────────────────────────┘
```

**Benefits of New Tabbed Layout:**
- **Immediate Visual Impact**: Full map visible above the fold
- **Focused Learning**: Each tab deep-dives into one concept  
- **Shorter Code**: Tab-specific examples vs. full configs
- **Better Space Usage**: Info and code side-by-side
- **Progressive Disclosure**: Advanced topics still available

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
1. **Stage 1 Enhancement** - Add progressive controls and preset buttons (consider tabbed approach)
2. **Stage 2 Phase 2** - Add live parameter controls and real-time styling within existing tabs
3. **Stage 3 Foundation** - Apply tabbed interface pattern to theme exploration
4. **Style Builder Component** - Create enhanced interactive style customization
5. **Theme Builder Component** - Build comprehensive theme editor
6. **Interactive Builder** - Develop the freeform playground experience

## Key Learnings from Stage 2 Tabbed Interface

**Design Principles Validated:**
- **Coup d'Oeuil**: Full-width map above fold provides immediate visual comprehension
- **Focused Learning**: Tabbed content allows deep exploration without cognitive overload
- **Progressive Disclosure**: Advanced topics remain accessible but don't clutter main interface
- **Consistent Patterns**: Same event handling and component patterns work across stages

**Technical Patterns Established:**
- **`tabbed_info_panel/1` Component**: Reusable across stages with flexible content
- **Tab Content Functions**: Private functions generate rich HTML content per tab
- **Focused Code Generation**: Tab-specific code examples vs. comprehensive configs
- **State Management**: Clean tab switching with map updates

**Recommended for Other Stages:**
- Consider tabbed approach for Stage 1 (Single → Multiple → Mixed)
- Apply to Stage 3 for theme exploration (Presets → Responsive → Custom)
- Essential for Stage 4 builder (Guided → Freeform → Export)