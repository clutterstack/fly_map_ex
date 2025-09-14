# Documentation Architecture Evolution Plan

## Context

The FlyMapEx demo app originally used a behaviour-based pattern with `DemoWeb.Live.StageBase` and `DemoWeb.Components.StageLayout` to create consistent interactive documentation. This document tracks the evolution to a generic multi-library documentation system.

## ✅ Phase 1: Generic Tutorial System (COMPLETED)

### Implementation Summary

Successfully generalized the tutorial system from FlyMapEx-specific to multi-library support while preserving all existing functionality and UX patterns.

### Key Changes Made

#### 1. ✅ Abstract StageBase → DocBase Behaviour

**Before (FlyMapEx-specific):**
```elixir
@callback stage_title() :: String.t()
@callback stage_description() :: String.t()
@callback stage_examples() :: map()
@callback stage_tabs() :: list(map())
@callback stage_navigation() :: %{prev: atom() | nil, next: atom() | nil}
@callback get_advanced_topics() :: list(map())  # Removed in Phase 1
```

**After (Generic):**
```elixir
@callback doc_title() :: String.t()
@callback doc_description() :: String.t()
@callback doc_examples() :: map()           # Generic data structure
@callback doc_tabs() :: list(map())
@callback doc_navigation() :: %{prev: atom() | nil, next: atom() | nil}
@callback doc_component_type() :: atom()    # :map, :chart, :form, etc.
```

#### 2. ✅ Pluggable Code Generator System

**Implementation:** `DemoWeb.Helpers.DocCodeGeneratorRegistry`
- Registry-based system using `:persistent_term` for performance
- `DocCodeGeneratorRegistry.register(:map, &CodeGenerator.generate_flymap_code/2)`
- `DocCodeGeneratorRegistry.generate_code(component_type, examples, opts)`
- Auto-initialization in `Demo.Application.start/2`

#### 3. ✅ Dynamic Component Rendering

**Implementation:** `DemoWeb.Helpers.DocComponentRegistry`
- Dynamic component rendering based on `doc_component_type/0`
- `DocComponentRegistry.register(:map, &FlyMapEx.node_map/1)`
- Fallback display for unregistered component types
- Direct function invocation for optimal performance

#### 4. ✅ Updated Architecture

**Files Created:**
- `demo/lib/demo_web/live/doc_base.ex` - Generic behaviour module
- `demo/lib/demo_web/components/doc_layout.ex` - Generic layout component
- `demo/lib/demo_web/helpers/doc_code_generator_registry.ex` - Code generator registry
- `demo/lib/demo_web/helpers/doc_component_registry.ex` - Component registry

**Files Updated:**
- All `Stage*Live` modules converted to use `DocBase`
- `Demo.Application` - Added registry initialization
- Removed advanced topics content (moved to Phase 2)

### ✅ Verification Results

- ✅ All stages compile without errors
- ✅ All stages serve HTTP 200 responses
- ✅ FlyMapEx components render correctly via registry
- ✅ Code generation works through registry system
- ✅ Preserved all existing UX and functionality
- ✅ No breaking changes to user experience

### Benefits Achieved

1. **Multi-Library Ready** - Other interactive libraries can register components and generators
2. **Registry-Based Extensibility** - Easy to add new component types
3. **Clean Architecture** - Clear separation between content and presentation
4. **Backward Compatibility** - All existing FlyMapEx functionality preserved
5. **Performance** - Uses `:persistent_term` for fast registry lookups

## Phase 2: Add Reference System (PLANNED)

### Overview

Build comprehensive reference documentation system separate from tutorial flow, using the advanced topics content that was removed from Phase 1.

### Goals

1. **Dedicated Reference Pages** - Comprehensive documentation with proper navigation
2. **Content Separation** - Clear distinction between learning (tutorial) and lookup (reference)
3. **Cross-Linking** - Contextual "Learn more" links from tutorial to reference
4. **Multi-Library Support** - Reference system works for any component type

### Implementation Plan

#### 1. Create Reference Page Architecture

**Reference Behaviour (`DocReferenceBase`):**
```elixir
@callback reference_title() :: String.t()
@callback reference_description() :: String.t()
@callback reference_sections() :: list(map())
@callback reference_component_type() :: atom()
@callback reference_navigation() :: %{prev: atom() | nil, next: atom() | nil}
```

**Reference Layout Component:**
- Support different content formats (markdown, code examples, diagrams)
- Search functionality within reference sections
- Cross-linking to tutorial pages

#### 2. Content Migration from Phase 1

**FlyMapEx Advanced Topics (removed from stages):**
- **From Stage1:** "Understanding Coordinate Systems", "Marker Group Data Structure", "Production Usage Tips"
- **From Stage2:** "Style Function Reference", "Custom Style Parameters", "Production Configuration"
- **From Stage3:** "Theme Performance Optimization", "Creating Theme Libraries", "Dynamic Theme Switching"
- **From Stage4:** "Building Scenario Templates", "Production Integration Patterns", "Advanced Customization Techniques"

#### 3. Navigation System

**Unified Sidebar:**
```
Documentation
├── Tutorial
│   ├── Stage 1: Defining Marker Groups
│   ├── Stage 2: Marker Styles
│   ├── Stage 3: Map Themes
│   └── Stage 4: Interactive Builder
└── Reference
    ├── Coordinate Systems
    ├── Data Structures
    ├── Styling Reference
    ├── Theme Configuration
    └── Production Patterns
```

#### 4. Cross-Linking Strategy

- Add "Learn more" buttons in tutorial pages linking to relevant reference sections
- Include "Try it" buttons in reference pages linking back to relevant tutorial stages
- Breadcrumb navigation showing tutorial ↔ reference relationship

### Benefits

1. **Improved Information Architecture**: Clear separation between learning and reference
2. **Enhanced Discoverability**: Advanced topics no longer buried at bottom of pages
3. **Better Search**: Reference content optimized for lookup rather than sequential reading
4. **Scalable**: Easy to add reference content for new component types

### Current File Structure (After Phase 1)

```
demo/lib/demo_web/
├── live/
│   ├── doc_base.ex             # ✅ Generic behaviour module
│   ├── stage1_live.ex          # ✅ Updated to use DocBase
│   ├── stage2_live.ex          # ✅ Updated to use DocBase
│   ├── stage3_live.ex          # ✅ Updated to use DocBase
│   └── stage4_live.ex          # ✅ Updated to use DocBase
├── components/
│   ├── doc_layout.ex           # ✅ Generic layout component
│   └── ...
└── helpers/
    ├── doc_code_generator_registry.ex  # ✅ Code generator registry
    ├── doc_component_registry.ex       # ✅ Component registry
    └── stage_config.ex                 # Configuration utilities
```

### Next Steps for Phase 2

1. Create `DocReferenceBase` behaviour
2. Create `ReferenceLayout` component
3. Migrate advanced topics content to reference pages
4. Update navigation to include reference section
5. Add cross-linking between tutorial and reference
6. Implement search functionality for reference content

This approach maintains the successful tutorial patterns from Phase 1 while adding comprehensive reference documentation that scales across multiple component libraries.