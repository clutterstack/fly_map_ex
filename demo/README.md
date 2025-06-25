# FlyMapEx Demo App

This Phoenix LiveView application demonstrates real-time machine discovery and visualization using FlyMapEx.

## Features

- **Real-time Machine Discovery**: Uses Fly.io's internal DNS to discover running machines every 30 seconds
- **Interactive World Map**: Shows machines as markers on a world map with region grouping
- **Live Updates**: Automatically updates the map when machines are added/removed
- **Error Handling**: Gracefully handles DNS lookup failures and missing apps

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
  # Convert machines to region groups for FlyMapEx
  region_groups = FlyMapEx.Adapters.from_machine_tuples(machines, "Running Machines", :primary)
  socket = assign(socket, region_groups: region_groups)
  {:noreply, socket}
end
```

### FlyMapEx Usage

```heex
<FlyMapEx.render
  region_groups={@region_groups}
  theme={:monitoring}
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