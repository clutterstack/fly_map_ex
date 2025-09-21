# Navigation Title System (Refactored)

The demo app uses a centralized **`DemoWeb.RouteRegistry`** module as the single source of truth for all routes and metadata. The navigation component generates items dynamically from this registry, and **`DemoWeb.ContentMap`** extracts titles from the actual page modules.

## Architecture Overview

1. **`RouteRegistry`** - Central registry defining all routes with metadata
2. **`ContentMap`** - Title extraction service that delegates to RouteRegistry
3. **`Navigation`** - Component that generates navigation from RouteRegistry

## Three Types of Pages

**1. Content Pages** (Tutorial/Documentation)
- Modules like `DemoWeb.Content.NodePlacement`
- Registered in RouteRegistry with full module atoms
- Define titles via `doc_metadata/0` function returning `%{title: "Placing markers", ...}`
- ContentMap extracts titles dynamically: `apply(module, :doc_metadata, [])`

**2. LiveView Pages** (Interactive Components)
- Modules like `DemoWeb.MapDemoLive`
- Registered in RouteRegistry with full module atoms
- Define titles via `page_title/0` function: `def page_title, do: "Interactive Builder"`
- ContentMap calls: `apply(module, :page_title, [])`

**3. Static Pages** (Controller Routes)
- Handled by `PageController`
- Titles stored directly in RouteRegistry: `%{title: "FlyMapEx Demo Home", ...}`

## Route Registration

Routes are defined once in `RouteRegistry`:

```elixir
@routes [
  %{
    path: "/basic_use",
    key: "basic_use",
    type: :content,
    module: DemoWeb.Content.NodePlacement,
    nav_order: 3
  },
  %{
    path: "/demo",
    key: "demo",
    type: :liveview,
    module: DemoWeb.MapDemoLive,
    nav_order: 6
  }
]
```

## Title Resolution Flow

```elixir
# navigation.ex generates items:
RouteRegistry.navigation_routes()
|> Enum.map(fn route ->
  {route.path, DemoWeb.ContentMap.get_page_title(route.key), route.key}
end)

# ContentMap resolves titles by route type:
case RouteRegistry.get_route(page_id) do
  %{type: :content, module: module} ->
    apply(module, :doc_metadata, []).title
  %{type: :liveview, module: module} ->
    apply(module, :page_title, [])
  %{type: :static, title: title} ->
    title
end
```

## Benefits

- **Single source of truth**: All route metadata in RouteRegistry
- **No duplication**: Eliminates triple-definition across router.ex, content_map.ex, navigation.ex
- **Easy maintenance**: Add new pages by adding one entry to RouteRegistry
- **Automatic ordering**: `nav_order` field controls navigation sequence
- **Type safety**: Compile-time module references