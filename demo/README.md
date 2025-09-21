# FlyMapEx Demo App

This Phoenix LiveView application demonstrates real-time machine discovery and visualization using FlyMapEx.

## Features

- **Real-time Machine Discovery**: Uses Fly.io's internal DNS to discover running machines every 30 seconds
- **Interactive World Map**: Shows machines as markers on a world map with marker grouping
- **Live Updates**: Automatically updates the map when machines are added/removed
- **Error Handling**: Gracefully handles DNS lookup failures and missing apps
- **SEO Metadata System**: Standardized SEO metadata with data locality and type safety
- **DaisyUI Theming**: Responsive light/dark theme support throughout the application

## Running the Demo

```bash
# Install dependencies
mix deps.get

# Start the Phoenix server
mix phx.server
```

Visit http://localhost:4000 and click "View Machine Map Demo".

## How It Works

### DNS Machine Discovery

The demo queries Fly.io's internal DNS for TXT records:

```bash
# Example DNS query (inside Fly.io network)
dig +short txt vms.my-app-name.internal
# Returns: "683d314fdd4d68 yyz,568323e9b54dd8 lhr"
```

### LiveView Integration

```elixir
# lib/demo_web/live/machine_map_live.ex
def mount(_params, _session, socket) do
  # Start periodic discovery
  {:ok, _pid} = MachineDiscovery.start_periodic_discovery(app_name, self(), 30_000)
  {:ok, socket}
end

def handle_info({:machines_updated, {:ok, machines}}, socket) do
  # Convert machines to marker groups for FlyMapEx
  marker_groups = FlyMapEx.Adapters.from_machine_tuples(machines, "Running Machines", :primary)
  socket = assign(socket, marker_groups: marker_groups)
  {:noreply, socket}
end
```

### FlyMapEx Usage

```heex
<FlyMapEx.render
  marker_groups={@marker_groups}
  class="machine-map"
/>
```

## Configuration

The demo automatically detects the app name from the `FLY_APP_NAME` environment variable when running on Fly.io, or falls back to "my-app-name" for local development.

## Requirements

- **On Fly.io**: Must be running inside Fly.io's private network (WireGuard) to access internal DNS
- **Locally**: Works for demonstration purposes but will show "No machines found" without access to Fly.io DNS

## Deployment

To deploy this demo on Fly.io:

```bash
fly launch
fly deploy
```

The demo will automatically discover machines in your Fly.io app when running on the platform.

## Architecture

### SEO Metadata System

The demo implements a comprehensive SEO metadata system designed for maintainability and type safety:

#### LiveView Metadata Pattern

Each LiveView module includes a standardized `get_metadata/0` function:

```elixir
def get_metadata do
  %{
    title: page_title(),
    description: "Page description for search engines",
    keywords: "relevant, search, keywords"
  }
end
```

#### Implementation Details

1. **Data Locality**: Metadata lives with the content it describes
2. **Type Safety**: Compile-time validation ensures metadata consistency
3. **Standardization**: Consistent pattern across all LiveView modules
4. **Root Layout Integration**: Metadata automatically rendered as `<meta>` tags

#### Technical Flow

1. LiveView `mount/3` calls `get_metadata/0` and assigns to socket
2. Root layout conditionally renders SEO meta tags from socket assigns
3. Static pages use RouteRegistry metadata via PageController
4. Page titles handled by Phoenix LiveView's built-in `@page_title` mechanism

This approach ensures proper SEO meta tags are present on initial page load for search engine indexing while maintaining the benefits of LiveView's real-time updates.