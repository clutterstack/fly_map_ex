# FlyMapEx Demo Application Behavioral Specification

This document defines the comprehensive behavioral specification for the FlyMapEx Phoenix LiveView demo application and library. The specification serves as both documentation and the basis for systematic test generation covering all user-facing behaviors.

## Document Purpose

This specification documents all observable behaviors of the FlyMapEx demo application, including:
- User interactions and system responses
- State transitions between application pages and modes
- Error conditions and recovery mechanisms
- Visual feedback patterns and UI rules

This specification will be used to generate comprehensive test suites ensuring all documented behaviors work correctly.

## App States Section

### 1. MapDemoLive (Interactive Code Builder)
**Route**: `/` and `/demo`
**Display**: 
- Full-width map preview with live code editor
- Real-time validation feedback
- Generated HEEx template with copy functionality
- Responsive layout adapts from sidebar to topbar on mobile

**Available Actions**:
- Edit Elixir code in real-time with immediate validation
- Copy generated HEEx template to clipboard
- View syntax and validation errors with contextual hints

**Constraints**:
- Code must be valid Elixir syntax
- Marker groups must have `nodes` and `label` fields
- Fly.io region codes must be valid (validated against FlyMapEx.Regions)
- Custom coordinates must be within valid ranges (-90 to 90 lat, -180 to 180 lng)

### 2. Stage1Live (Placing Markers)
**Route**: `/stage1`
**Display**:
- Educational stage with 4 example tabs: blank_map, by_coords, fly_regions, multiple_nodes
- Split layout: map preview and informational content panels
- Navigation between examples via tabs

**Available Actions**:
- Switch between example tabs
- Navigate to previous (Home) or next (Stage2) stages
- View generated code for each example

**Constraints**:
- Tab selection persists within stage
- Each example has predefined marker group configurations

### 3. Stage2Live (Marker Styles)
**Route**: `/stage2`
**Display**:
- 5 example tabs: automatic, named_colours, semantic, custom, mixed
- Interactive custom styling controls for the custom example
- Advanced topics with expandable sections

**Available Actions**:
- Switch between style examples
- Modify custom style parameters (size, animation, glow, colour)
- Apply semantic style presets
- View style function documentation

**Constraints**:
- Custom parameters validate input types (integer for size, atom for animation, boolean for glow)
- Colour values must be valid hex format (#rrggbb)
- Parameter changes apply immediately to map preview

### 4. Stage3Live (Map Themes)
**Route**: `/stage3`
**Display**:
- 4 example tabs: presets, responsive, custom, configuration
- Theme-aware examples with per-example theme overrides
- Theme configuration documentation

**Available Actions**:
- Switch between theme examples
- View different theme presets and their effects
- Learn about responsive theming patterns

**Constraints**:
- Each example can override the stage theme
- Theme changes affect visual presentation immediately

### 5. Stage4Live (Interactive Builder)
**Route**: `/stage4`
**Display**:
- 3 example tabs: guided, freeform, export
- Scenario-based guided examples (monitoring, deployment, status)
- Export format selection (HEEx, Elixir, JSON)

**Available Actions**:
- Switch between guided scenarios
- Change export format for generated code
- View production-ready code examples

**Constraints**:
- Scenario switching evaluates code dynamically
- Format changes update export display but don't affect map
- Code generation must match displayed map configuration

### 6. MachineMapLive (Real-time Machine Discovery)
**Route**: `/map`
**Display**:
- Real-time visualization of actual Fly.io machines
- App selection interface with multi-select capability
- Machine details grouped by region
- Loading states and automatic refresh

**Available Actions**:
- Discover available Fly.io applications
- Select/deselect applications for display
- Refresh machine data manually
- Toggle app selection interface visibility

**Constraints**:
- DNS discovery may fail (network dependent)
- Cached data used for instant filtering
- Empty states displayed when no machines found

## Input Handling Section

### Mouse Input

#### Navigation Links
- **Sidebar Navigation** (Desktop):
  - Click: `phx-click` with `navigate` attribute → Route transition
  - Hover: Visual feedback with colour transition
  - Active state: `bg-primary/10 text-primary border-r-2 border-primary`

- **Topbar Navigation** (Mobile):
  - Click: Same navigation behavior as sidebar
  - Mobile menu toggle: `@click="open = !open"` (Alpine.js)

#### Button Interactions
- **Tab Switching**:
  - Click: `phx-click="switch_example"` with `phx-value-option={tab.key}`
  - Result: Updates `current_example` assign → Map re-renders
  - Visual feedback: Active tab styling

- **Theme Toggle**:
  - Click: `JS.dispatch("phx:set-theme", detail: %{theme: "system|light|dark"})`
  - Result: Application-wide theme change with localStorage persistence
  - Visual feedback: Active theme button styling

- **Copy to Clipboard**:
  - Click: JavaScript `navigator.clipboard.writeText()`
  - Result: HEEx code copied to clipboard
  - Visual feedback: Flash message confirmation

#### Stage-Specific Controls
- **Stage2Live Parameter Updates**:
  - Input change: `phx-change="update_param"`
  - Result: Custom style parameters updated → Map preview updated
  - Validation: Type conversion and range checking

- **Stage4Live Scenario Switching**:
  - Click: `phx-click="switch_scenario"` with `phx-value-option={scenario}`
  - Result: Dynamic code evaluation → Marker groups updated
  - Effect: Map and code display synchronized

### Form Input

#### Code Editor (MapDemoLive)
- **Text Input**:
  - Event: `phx-change="update_code"` with 300ms debounce
  - Validation: Real-time Elixir syntax and structure validation
  - Result: Marker groups updated or validation errors displayed

#### Parameter Controls (Stage2Live)
- **Range Inputs**: Size parameter (1-20)
- **Select Inputs**: Animation type (:none, :pulse, :fade)
- **Checkbox Inputs**: Glow effect (boolean)
- **Color Inputs**: Hex colour validation

### Keyboard Input

#### Accessibility
- **Tab Navigation**: Logical focus order through interactive elements
- **Enter/Space**: Activate buttons and links
- **Escape**: Close mobile menu (Alpine.js)

## UI Display Rules Section

### Layout Structure

#### Desktop Layout (lg+)
- **Sidebar**: Fixed 256px width (`w-64`) navigation
- **Main Content**: Fluid width with responsive map display
- **Split Panels**: CSS Grid (`grid-cols-1 lg:grid-cols-2`) for content

#### Mobile Layout
- **Topbar**: Collapsible navigation with hamburger menu
- **Stacked Content**: Single column layout with full-width map
- **Overlay Menu**: Slide-in navigation for mobile

### Content Rendering

#### Map Visualization
- **Container**: `bg-base-200 rounded-lg p-6` with responsive scaling
- **SVG Rendering**: Coordinate transformation from WGS84 to SVG space
- **Legend**: Toggleable with consistent colour indicators
- **Markers**: Style-dependent rendering (static/animated, coloured, sized)

#### Code Display
- **Syntax Highlighting**: `<pre><code>` blocks with `bg-base-200 p-3 rounded`
- **Live Generation**: Real-time code generation matching displayed configuration
- **Export Formats**: HEEx, Elixir, JSON with format-specific syntax

### Visual Feedback

#### Button States
- **Active**: `bg-primary text-primary-content shadow-md`
- **Inactive**: `bg-base-200 text-base-content border-2 border-base-300`
- **Hover**: `hover:bg-primary/80` with `transition-colors duration-200`
- **Focus**: `focus:ring-2 focus:ring-primary focus:ring-offset-2`

#### Theme System
- **DaisyUI Integration**: Semantic colour tokens (`primary`, `secondary`, `success`, etc.)
- **Light/Dark**: Automatic contrast adjustment via CSS custom properties
- **Theme Switching**: Client-side theme management with localStorage persistence

## Error Conditions Section

### Invalid Input

#### Code Validation Errors (MapDemoLive)
- **Syntax Errors**: `Code.eval_string/1` compilation failures
- **Display**: Red-themed error section with specific error messages
- **Recovery**: Clear marker groups until valid code provided

#### Parameter Validation Errors (Stage2Live)
- **Type Errors**: Invalid integer, atom, or boolean conversion
- **Range Errors**: Size parameters outside 1-20 range
- **Format Errors**: Invalid hex colour format
- **Recovery**: Fallback to previous valid values

#### Region Validation Errors
- **Invalid Regions**: Non-existent Fly.io region codes
- **Display**: Specific error messages with region and group context
- **Recovery**: Skip invalid regions, continue processing valid ones

### System Errors

#### Network Failures (MachineMapLive)
- **DNS Discovery Failures**: Handle lookup failures gracefully
- **Error Types**: `:no_machines_found`, `:discovery_failed`
- **Display**: Empty states with retry options
- **Recovery**: Use cached data when available

#### LiveView Connection Errors
- **Client Disconnection**: Show error overlay with `phx-disconnected`
- **Server Disconnection**: Separate error state for server connectivity
- **Recovery**: Auto-hide errors on `phx-connected` reconnection

### Recovery Behaviour

#### State Preservation
- **Valid Previous State**: Maintain valid configuration during error conditions
- **Graceful Degradation**: Continue functioning with reduced features
- **User Feedback**: Clear error messages with recovery instructions

#### Auto-retry Patterns
- **Periodic Refresh**: Built-in refresh for machine discovery
- **Cached Fallbacks**: Use cached data when fresh queries fail
- **Progressive Loading**: Separate loading states for different operations

## State Transitions Section

### Valid Transitions

#### Route-Based Navigation
```
Home (MapDemoLive) ↔ Stage1Live ↔ Stage2Live ↔ Stage3Live ↔ Stage4Live
                   ↕
                MachineMapLive
```

#### In-Stage Transitions
- **Tab Switching**: `switch_example` event → Update `current_example` assign
- **Parameter Updates**: Stage-specific events → Update custom parameters
- **Theme Changes**: Global theme events → Update visual presentation

#### Stage-Specific Transitions
- **Stage2Live**: `update_param` → Custom style parameters
- **Stage2Live**: `apply_preset` → Semantic style examples  
- **Stage4Live**: `switch_scenario` → Guided scenario examples
- **Stage4Live**: `switch_format` → Export format selection

### Invalid Transitions

#### Forbidden Operations
- **Direct URL to Examples**: No deep linking to specific tabs
- **Cross-Stage Example Sharing**: Examples don't persist across stages
- **Backward Time Travel**: No browser history integration for example states

#### State Constraints
- **Example Isolation**: Tab selections isolated per stage
- **Parameter Scope**: Custom parameters limited to specific stages
- **Theme Persistence**: Only global theme persists across navigation

### Transition Validation
- **Route Validation**: All routes must exist in router configuration
- **Example Validation**: All example keys must exist in stage configuration
- **Parameter Validation**: All parameter updates must pass type checking

## Usage Instructions

### For Test Generation
1. Each documented behavior becomes a test case
2. State constraints become validation tests  
3. Error conditions become error handling tests
4. Transitions become state change tests

### For Verification
1. State Tests: Verify UI rendering matches specification
2. Input Tests: Verify each input mapping works correctly
3. Transition Tests: Verify state changes occur as documented
4. Error Tests: Verify error conditions handled per specification

### Test Organization
- `tests/behaviour/` - Generated from this specification
- `tests/integration/` - End-to-end workflow tests
- `tests/components/` - Component-specific behavior tests
- `tests/liveview/` - LiveView state and event tests

## Quality Criteria

### Specification Quality
- **Accuracy**: Matches actual implementation behavior
- **Completeness**: Covers all user-facing functionality
- **Clarity**: Unambiguous action descriptions and results
- **Consistency**: Uniform terminology and format throughout

### Test Coverage Quality  
- **Systematic**: Every documented behavior has corresponding tests
- **Maintainable**: Tests update automatically with specification changes
- **Reliable**: Tests accurately reflect documented requirements
- **Comprehensive**: Edge cases and error conditions fully covered

This specification ensures complete documentation of the FlyMapEx ecosystem's user-facing behaviors and provides the foundation for comprehensive automated testing.