# Behavioural Specification Template

This document defines the process for creating comprehensive behavioural specifications for software projects. The specification serves as both documentation and the basis for systematic test generation.

## Document Structure

### 1. Header and Purpose
- Clear title identifying the project
- Brief description of document purpose
- Explicit statement linking documentation to test generation

### 2. App States Section
For each state in the application:
- **State name**: Clear, descriptive identifier
- **Display**: What the user sees (UI elements, layout, content)
- **Available Actions**: What the user can do in this state
- **Constraints**: Rules, validation, limits that apply

### 3. Input Handling Section
Organized by input type:

#### Keyboard Input
- Subsection for each state
- Format: `Key combination`: Description → State transition (if any)
- Include platform-specific variations (Ctrl/Cmd)
- Group related keys logically

#### Mouse Input
- Subsection for each UI context (text areas, lists, buttons)
- Format: `Mouse action`: Description → Result
- Include drag, click, scroll behaviors

#### Special Input Types
- Clipboard operations (copy/paste text and media)
- File system operations
- Network operations

### 4. UI Display Rules Section
- **Layout Structure**: How screen space is divided
- **Content Rendering**: How data is presented
- **Visual Feedback**: How user actions are indicated

### 5. Error Conditions Section
- **Invalid Input**: How bad input is handled
- **System Errors**: How external failures are managed
- **Recovery Behaviour**: How the system returns to safe states

### 6. State Transitions Section
- **Valid Transitions**: Allowed state changes with format
- **Invalid Transitions**: Explicitly forbidden transitions

## Content Guidelines

### Precision Requirements
- Use exact key names (KeyCode::Enter, not "return key")
- Specify modifier keys explicitly (Ctrl+S, Cmd+S)
- Include platform variations where relevant
- State parameter details (CreateEntry(thread_id))

### Completeness Requirements
- Every state must have input handling defined
- Every user action must have documented result
- Every error condition must have recovery path
- Every transition must be explicitly listed

### Format Standards
- Use markdown for structure
- Code blocks for transition diagrams
- Bullet points for action lists
- Consistent terminology throughout

## Generation Process

### Phase 1: Discovery (Research)
1. **Code Exploration**
   - Read main application modules
   - Identify state enum/types
   - Map input handler functions
   - Find UI rendering logic

2. **Input Mapping**
   - Search for KeyCode patterns
   - Search for MouseEvent patterns
   - Identify clipboard operations
   - Find special input handlers

3. **State Analysis**
   - List all application states
   - Identify state parameters
   - Map state-specific UI elements
   - Document state-specific constraints

### Phase 2: Documentation (Specification)
1. **Structure Creation**
   - Create document with template sections
   - Define all states with descriptions
   - Map input handling per state
   - Document UI display rules

2. **Accuracy Verification**
   - Cross-reference with actual code
   - Test key combinations against implementation
   - Verify state transitions
   - Validate error handling paths

3. **Completeness Check**
   - Ensure all states covered
   - Verify all inputs documented
   - Check error conditions
   - Validate transition completeness

### Phase 3: Test Generation (Implementation)
1. **Test Categories**
   - **State Tests**: Verify UI rendering matches spec
   - **Input Tests**: Verify each input mapping works
   - **Transition Tests**: Verify state changes occur correctly
   - **Error Tests**: Verify error conditions handled per spec

2. **Test Organization**
   - `tests/behaviour/` - Generated from spec
   - `tests/ui/` - Visual/layout verification
   - `tests/input/` - Input handling verification
   - `tests/integration/` - End-to-end workflows

3. **Test Extraction**
   - Each documented behaviour becomes a test case
   - State constraints become validation tests
   - Error conditions become error handling tests
   - Transitions become state change tests

## Usage Instructions

### For New Projects
1. Run Phase 1 discovery process
2. Create behavioural specification document
3. Review specification against code
4. Generate tests from specification

### For Existing Projects
1. Audit current test coverage
2. Create specification for untested behaviours
3. Generate missing tests
4. Integrate with existing test suite

### For Updates
1. Update specification when behaviour changes
2. Regenerate affected tests
3. Ensure specification stays synchronized with code

## Quality Criteria

### Specification Quality
- **Accuracy**: Matches actual implementation
- **Completeness**: Covers all user-facing behaviour
- **Clarity**: Unambiguous action descriptions
- **Consistency**: Uniform terminology and format

### Test Coverage Quality
- **Systematic**: Every documented behaviour tested
- **Maintainable**: Tests update with specification
- **Reliable**: Tests accurately reflect requirements
- **Comprehensive**: Edge cases and error conditions covered

## Example Command
```
"Create a behavioural specification for [project]. Use the discovery process to map all states, input handling, and transitions. Generate a specification document following the template structure, then create a test generation plan."
```
>  For future projects, you can simply say:
>  "Create a behavioural specification for [project name] using the template. Follow the discovery process to map all
 > states and input handling."

This process ensures documentation and tests remain synchronized while providing comprehensive coverage of user-facing behaviour.