# Plan: Convert StageTemplate to Complete `<FlyMapEx.render />` Invocations with Compile-Time Validation

## Overview

Refactor the StageTemplate system to use complete, validated HEEx template strings instead of fragmented marker_groups lists. This prioritizes clean design over backward compatibility.

## Current Architecture Analysis

**StageTemplate System:**
- Currently uses `marker_groups` lists passed to `<FlyMapEx.render marker_groups={@marker_groups} />`
- Examples defined in content modules like `BasicUsage` with `example.marker_groups`
- Code generation happens at runtime via `DemoWeb.Helpers.CodeGenerator.generate_heex_template/4`

**MapBuilder Patterns Available:**
- Real-time validation system with `parse_and_validate_code/2`
- Compile-time AST parsing with `Code.eval_string/1`
- Comprehensive validation for region codes, coordinates, and structure
- Integration with existing `FlyMapEx.FlyRegions.valid?/1`

## Proposed Clean Architecture

### 1. New Example Definition Format
Replace current fragmented approach with complete, validated HEEx template strings:

```elixir
# Clean design - complete examples as they'd actually be used
def get_content("fly_regions") do
  %{
    content: [...],
    example: """
    <FlyMapEx.render
      marker_groups={[
        %{nodes: ["fra", "sin"], label: "Production", style_key: :primary}
      ]}
      theme={:responsive}
      layout={:side_by_side}
    />
    """
  }
end
```

### 2. Compile-Time Validation System
Create `DemoWeb.Content.ValidatedExample` module with:
- Macro that validates HEEx templates at compile time
- Extracts and validates all assigns (not just marker_groups)
- Integrates with existing MapBuilder validation
- Fails fast during compilation if examples are invalid

### 3. Single-Source Template Renderer
Build `DemoWeb.Components.ValidatedTemplate` that:
- Takes validated HEEx string and renders both the component AND the code display
- Eliminates duplication between CodeGenerator and actual rendering
- Parses template to extract assigns for component rendering

### 4. Simplified StageTemplate
Drastically simplify `stage_template.ex`:
- Remove complex marker_groups handling
- Accept single `validated_template` string
- Use new renderer for both display and execution

## Implementation Steps

1. **Create validation macro** - Compile-time HEEx validation with full assign support
2. **Build unified renderer** - Single component handling both code display and map rendering
3. **Convert content modules** - Update all examples to new validated template format
4. **Simplify StageTemplate** - Remove old complexity, use new clean interface
5. **Remove legacy code** - Delete old CodeGenerator complexity once migration complete

## Design Benefits

- ✅ **Truth in One Place**: Template string IS the code that executes
- ✅ **Compile-Time Safety**: All examples validated during build
- ✅ **Complete Feature Coverage**: All FlyMapEx assigns supported in examples
- ✅ **Simplified Codebase**: Remove complex runtime code generation
- ✅ **Better Examples**: Show real-world usage patterns with all options
- ✅ **Type Safety**: Leverage existing MapBuilder validation for all assigns

## Files to Modify

### New Files
- `demo/lib/demo_web/content/validated_example.ex` - Compile-time validation macro
- `demo/lib/demo_web/components/validated_template.ex` - Unified renderer component

### Modified Files
- `demo/lib/demo_web/live/live_components/stage_template.ex` - Simplified interface
- `demo/lib/demo/content/pages/basic_usage.ex` - Convert to new format
- `demo/lib/demo/content/pages/marker_styling.ex` - Convert to new format
- `demo/lib/demo/content/pages/theming.ex` - Convert to new format

### Files to Remove (after migration)
- Complex parts of `demo/lib/demo_web/helpers/code_generator.ex`

## Success Criteria

1. All examples compile and validate at build time
2. Displayed code exactly matches executed components
3. All FlyMapEx assigns supported in examples
4. Codebase significantly simplified
5. No runtime code generation needed