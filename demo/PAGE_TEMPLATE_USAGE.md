# Page Template Usage Guide

This guide shows how to use the `DemoWeb.Components.PageTemplate` component to create consistent non-live pages in the demo application.

## Basic useage

The page template provides a consistent layout with navigation, theming, and responsive design for static content pages.

### 1. Create a Controller Action

```elixir
defmodule DemoWeb.PageController do
  use DemoWeb, :controller

  def about(conn, _params) do
    # Pass any data your page needs
    render(conn, :about, title: "About FlyMapEx")
  end
end
```

### 2. Create the Template

Create a new `.html.heex` file in `lib/demo_web/controllers/page_html/`:

```heex
<!-- lib/demo_web/controllers/page_html/about.html.heex -->
<.page_template current_page={:about} flash={@flash}>
  <:title>About FlyMapEx</:title>
  <:description>
    Learn more about the FlyMapEx library and its capabilities for
    displaying interactive world maps with Fly.io region markers.
  </:description>
  <:content>
    <div class="space-y-6">
      <div class="bg-base-200 rounded-lg p-6">
        <h3 class="text-lg font-semibold mb-4">Our Mission</h3>
        <p class="text-base-content/70">
          To provide developers with powerful, easy-to-use components for
          visualizing global infrastructure and deployments.
        </p>
      </div>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="bg-primary/10 border border-primary/20 rounded-lg p-4">
          <h4 class="font-medium text-primary mb-2">Open Source</h4>
          <p class="text-sm text-primary/80">
            FlyMapEx is open source and available on GitHub.
          </p>
        </div>
        <div class="bg-success/10 border border-success/20 rounded-lg p-4">
          <h4 class="font-medium text-success mb-2">Community Driven</h4>
          <p class="text-sm text-success/80">
            Built with feedback and contributions from the community.
          </p>
        </div>
      </div>
    </div>
  </:content>
</.page_template>
```

### 3. Add Route

Add the route to your router:

```elixir
# lib/demo_web/router.ex
scope "/", DemoWeb do
  pipe_through :browser
  
  get "/about", PageController, :about
end
```

### 4. Update Navigation

Add your new page to the navigation in `lib/demo_web/components/navigation.ex`:

```elixir
defp nav_items do
  [
    {"/", "Home", :map_demo},
    {"/about", "About", :about},  # Add your new page here
    {"/stage1", "Placing Markers", :stage1},
    # ... other pages
  ]
end
```

## Advanced Usage

### With Sidebar Content

You can add additional content to the sidebar using the `:sidebar_extra` slot:

```heex
<.page_template current_page={:docs} flash={@flash}>
  <:title>Documentation</:title>
  <:description>Complete API reference and usage guides.</:description>
  <:sidebar_extra>
    <div class="p-4">
      <h3 class="font-semibold mb-2 text-base-content">Quick Links</h3>
      <ul class="space-y-1 text-sm">
        <li><a href="#api" class="text-primary hover:underline">API Reference</a></li>
        <li><a href="#examples" class="text-primary hover:underline">Examples</a></li>
        <li><a href="#themes" class="text-primary hover:underline">Themes</a></li>
      </ul>
    </div>
  </:sidebar_extra>
  <:content>
    <!-- Your documentation content -->
  </:content>
</.page_template>
```

### With Dynamic Content

You can pass content from your controller and render it dynamically:

```elixir
# Controller
def docs(conn, _params) do
  content = File.read!("priv/static/docs/getting_started.md")
  render(conn, :docs, content: content)
end
```

```heex
<!-- Template -->
<.page_template current_page={:docs} flash={@flash}>
  <:title>Documentation</:title>
  <:description>Getting started with FlyMapEx</:description>
  <:content>
    <DemoWeb.Helpers.ContentHelpers.convert_markdown markdown={@content} />
  </:content>
</.page_template>
```

### Custom Styling

Add custom CSS classes to the main content area:

```heex
<.page_template current_page={:special} flash={@flash} class="max-w-4xl mx-auto">
  <:title>Special Page</:title>
  <:content>
    <!-- Content will be constrained to max-width with centered alignment -->
  </:content>
</.page_template>
```

## Available Semantic Colours

The demo app uses DaisyUI semantic colours for consistency across light/dark themes:

- `text-primary`, `bg-primary/10`, `border-primary/20` - Primary brand colour
- `text-success`, `bg-success/10`, `border-success/20` - Success states
- `text-warning`, `bg-warning/10`, `border-warning/20` - Warning states
- `text-error`, `bg-error/10`, `border-error/20` - Error states
- `text-secondary`, `bg-secondary/10`, `border-secondary/20` - Secondary colour
- `text-base-content`, `bg-base-100`, `border-base-300` - Base content colours

## Best Practices

1. **Use semantic colours** instead of hardcoded Tailwind colours for proper theme support
2. **Include meaningful descriptions** to help users understand page purpose
3. **Structure content** with proper headings and sections for accessibility
4. **Test responsive design** to ensure content works on mobile and desktop
5. **Keep navigation current_page keys consistent** between templates and navigation component
6. **Use the `:sidebar_extra` slot** for contextual navigation or related links

## Component Structure

The page template automatically includes:

- ✅ Flash message display
- ✅ Responsive navigation (topbar on mobile, sidebar on desktop)
- ✅ Consistent layout and spacing
- ✅ DaisyUI theme support (light/dark mode)
- ✅ Mobile-friendly hamburger menu
- ✅ Semantic HTML structure for accessibility

You only need to focus on your content while the template handles all the layout concerns.