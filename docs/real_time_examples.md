# Real-Time Usage Examples ⚡

This document provides comprehensive examples of using FlyMapEx's real-time features for high-performance marker updates via Phoenix channels.

## Basic Setup

### 1. Application Configuration

Add channel infrastructure to your application:

```elixir
# lib/my_app_web/endpoint.ex
defmodule MyAppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :my_app

  # Add real-time socket
  socket "/socket", MyAppWeb.UserSocket,
    websocket: true,
    longpoll: false

  # ... existing configuration
end
```

### 2. User Socket

```elixir
# lib/my_app_web/channels/user_socket.ex
defmodule MyAppWeb.UserSocket do
  use Phoenix.Socket

  # Define map channels
  channel "map:*", MyAppWeb.MapChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    # Add authentication here if needed
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
```

### 3. Map Channel

```elixir
# lib/my_app_web/channels/map_channel.ex
defmodule MyAppWeb.MapChannel do
  use Phoenix.Channel
  require Logger

  @impl true
  def join("map:" <> room_id, _payload, socket) do
    Logger.info("Client joined map room: #{room_id}")
    {:ok, socket}
  end

  @impl true
  def handle_in("state_sync", %{"client_state" => client_state}, socket) do
    Logger.debug("State sync requested", client_state: client_state)

    # Compare with server state and respond accordingly
    {:reply, {:ok, %{status: "sync_acknowledged"}}, socket}
  end

  @impl true
  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{status: "pong"}}, socket}
  end

  # Broadcasting helper functions
  def broadcast_marker_state(channel_topic, state) do
    MyAppWeb.Endpoint.broadcast(channel_topic, "marker_state", state)
  end

  def broadcast_marker_update(channel_topic, update) do
    MyAppWeb.Endpoint.broadcast(channel_topic, "marker_update", update)
  end

  def broadcast_theme_change(channel_topic, theme_data) do
    MyAppWeb.Endpoint.broadcast(channel_topic, "theme_change", theme_data)
  end
end
```

### 4. JavaScript Setup

```javascript
// assets/js/app.js
import { RealTimeMapHook } from "./real_time_map_hook.js"

const liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: {
    RealTimeMap: RealTimeMapHook
  }
})
```

## Usage Examples

### Basic Real-Time Map

```elixir
# In your LiveView
defmodule MyAppWeb.DashboardLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    room_id = "dashboard_#{System.unique_integer([:positive])}"

    socket = socket
    |> assign(:room_id, room_id)
    |> assign(:marker_groups, initial_groups())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="dashboard">
      <h1>Real-Time Infrastructure Dashboard</h1>

      <FlyMapEx.render
        marker_groups={@marker_groups}
        theme={:dark}
        real_time={true}
        channel={"map:#{@room_id}"}
        update_throttle={100}
        class="dashboard-map"
      />
    </div>
    """
  end

  defp initial_groups do
    [
      %{
        nodes: ["sjc", "fra", "lhr"],
        style: :operational,
        label: "Production Servers"
      }
    ]
  end
end
```

### Real-Time Server Monitoring

```elixir
defmodule MyAppWeb.MonitoringLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    room_id = "monitoring_#{:rand.uniform(10000)}"

    # Start periodic updates
    :timer.send_interval(5000, self(), :update_servers)

    socket = socket
    |> assign(:room_id, room_id)
    |> assign(:servers, %{})

    {:ok, socket}
  end

  def handle_info(:update_servers, socket) do
    # Simulate server status updates
    updated_servers = fetch_server_status()

    # Broadcast to all connected clients
    marker_groups = servers_to_marker_groups(updated_servers)

    MyAppWeb.MapChannel.broadcast_marker_update(
      "map:#{socket.assigns.room_id}",
      %{
        group_id: "servers",
        markers: marker_groups
      }
    )

    {:noreply, assign(socket, :servers, updated_servers)}
  end

  def render(assigns) do
    ~H"""
    <div class="monitoring-dashboard">
      <div class="stats">
        <div class="stat">
          <div class="stat-title">Active Servers</div>
          <div class="stat-value text-primary"><%= map_size(@servers) %></div>
        </div>
      </div>

      <FlyMapEx.render
        marker_groups={servers_to_marker_groups(@servers)}
        theme={:responsive}
        real_time={true}
        channel={"map:#{@room_id}"}
        update_throttle={50}
        show_regions={true}
      />
    </div>
    """
  end

  defp fetch_server_status do
    # Simulate fetching server data
    %{
      "sjc-prod-1" => %{region: "sjc", status: :healthy, load: 0.3},
      "fra-prod-1" => %{region: "fra", status: :warning, load: 0.8},
      "lhr-prod-1" => %{region: "lhr", status: :healthy, load: 0.2}
    }
  end

  defp servers_to_marker_groups(servers) do
    servers
    |> Enum.group_by(fn {_id, server} -> server.status end)
    |> Enum.map(fn {status, server_list} ->
      nodes = Enum.map(server_list, fn {_id, server} -> server.region end)

      %{
        nodes: nodes,
        style: status_to_style(status),
        label: "#{String.capitalize(to_string(status))} (#{length(nodes)})"
      }
    end)
  end

  defp status_to_style(:healthy), do: :operational
  defp status_to_style(:warning), do: :warning
  defp status_to_style(:critical), do: :danger
  defp status_to_style(_), do: :inactive
end
```

### Multi-Room Chat with Geographic Presence

```elixir
defmodule MyAppWeb.ChatLive do
  use MyAppWeb, :live_view

  def mount(%{"room" => room_id}, _session, socket) do
    user_id = "user_#{:rand.uniform(1000)}"

    # Join presence tracking
    Phoenix.PubSub.subscribe(MyApp.PubSub, "chat:#{room_id}")
    Phoenix.PubSub.subscribe(MyApp.PubSub, "presence:#{room_id}")

    socket = socket
    |> assign(:room_id, room_id)
    |> assign(:user_id, user_id)
    |> assign(:user_locations, %{})
    |> assign(:messages, [])

    {:ok, socket}
  end

  def handle_event("set_location", %{"region" => region}, socket) do
    user_id = socket.assigns.user_id
    room_id = socket.assigns.room_id

    # Update user location
    Phoenix.PubSub.broadcast(
      MyApp.PubSub,
      "presence:#{room_id}",
      {:user_location_changed, user_id, region}
    )

    {:noreply, socket}
  end

  def handle_info({:user_location_changed, user_id, region}, socket) do
    updated_locations = Map.put(socket.assigns.user_locations, user_id, region)

    # Broadcast real-time location updates to map
    marker_groups = locations_to_marker_groups(updated_locations)

    MyAppWeb.MapChannel.broadcast_marker_state(
      "map:#{socket.assigns.room_id}",
      %{
        marker_groups: marker_groups,
        theme: %{},
        config: %{bbox: {0, 0, 800, 391}}
      }
    )

    {:noreply, assign(socket, :user_locations, updated_locations)}
  end

  def render(assigns) do
    ~H"""
    <div class="chat-app">
      <div class="chat-header">
        <h2>Room: <%= @room_id %></h2>
        <p>Users online: <%= map_size(@user_locations) %></p>
      </div>

      <div class="chat-layout">
        <div class="chat-messages">
          <!-- Chat messages here -->
        </div>

        <div class="presence-map">
          <h3>User Locations</h3>
          <FlyMapEx.render
            marker_groups={locations_to_marker_groups(@user_locations)}
            theme={:minimal}
            real_time={true}
            channel={"map:#{@room_id}"}
            update_throttle={200}
            interactive={false}
          />
        </div>
      </div>
    </div>
    """
  end

  defp locations_to_marker_groups(user_locations) do
    user_locations
    |> Enum.group_by(fn {_user, region} -> region end)
    |> Enum.map(fn {region, users} ->
      %{
        nodes: [region],
        style: :operational,
        label: "#{region} (#{length(users)} users)"
      }
    end)
  end
end
```

### Performance Monitoring with Custom Throttling

```elixir
defmodule MyAppWeb.PerformanceLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    room_id = "perf_#{System.system_time(:millisecond)}"

    # High-frequency updates for performance monitoring
    :timer.send_interval(1000, self(), :update_metrics)

    socket = socket
    |> assign(:room_id, room_id)
    |> assign(:metrics, %{})
    |> assign(:update_frequency, :high) # :high, :medium, :low

    {:ok, socket}
  end

  def handle_event("change_frequency", %{"frequency" => freq}, socket) do
    frequency = String.to_atom(freq)
    throttle = frequency_to_throttle(frequency)

    # Update throttling for real-time updates
    send_update_self(__MODULE__, id: "performance-map", update_throttle: throttle)

    {:noreply, assign(socket, :update_frequency, frequency)}
  end

  def handle_info(:update_metrics, socket) do
    new_metrics = collect_performance_metrics()

    # Only broadcast if there are significant changes
    if significant_change?(socket.assigns.metrics, new_metrics) do
      marker_groups = metrics_to_marker_groups(new_metrics)

      MyAppWeb.MapChannel.broadcast_marker_update(
        "map:#{socket.assigns.room_id}",
        %{
          group_id: "performance",
          markers: marker_groups
        }
      )
    end

    {:noreply, assign(socket, :metrics, new_metrics)}
  end

  def render(assigns) do
    ~H"""
    <div class="performance-dashboard">
      <div class="controls">
        <label>Update Frequency:</label>
        <select phx-change="change_frequency">
          <option value="high" selected={@update_frequency == :high}>High (25ms)</option>
          <option value="medium" selected={@update_frequency == :medium}>Medium (100ms)</option>
          <option value="low" selected={@update_frequency == :low}>Low (500ms)</option>
        </select>
      </div>

      <FlyMapEx.render
        id="performance-map"
        marker_groups={metrics_to_marker_groups(@metrics)}
        theme={:dark}
        real_time={true}
        channel={"map:#{@room_id}"}
        update_throttle={frequency_to_throttle(@update_frequency)}
      />
    </div>
    """
  end

  defp frequency_to_throttle(:high), do: 25
  defp frequency_to_throttle(:medium), do: 100
  defp frequency_to_throttle(:low), do: 500

  defp collect_performance_metrics do
    # Simulate collecting performance data
    %{
      "sjc" => %{cpu: :rand.uniform(100), response_time: :rand.uniform(200)},
      "fra" => %{cpu: :rand.uniform(100), response_time: :rand.uniform(200)},
      "lhr" => %{cpu: :rand.uniform(100), response_time: :rand.uniform(200)}
    }
  end

  defp significant_change?(old_metrics, new_metrics) do
    # Only update if CPU or response time changed significantly
    Enum.any?(new_metrics, fn {region, new_data} ->
      case old_metrics[region] do
        nil -> true
        old_data ->
          abs(new_data.cpu - old_data.cpu) > 10 or
          abs(new_data.response_time - old_data.response_time) > 50
      end
    end)
  end

  defp metrics_to_marker_groups(metrics) do
    # Convert performance metrics to visual marker groups
    metrics
    |> Enum.group_by(fn {_region, data} -> performance_status(data) end)
    |> Enum.map(fn {status, region_data} ->
      nodes = Enum.map(region_data, fn {region, _data} -> region end)

      %{
        nodes: nodes,
        style: status,
        label: "#{String.capitalize(to_string(status))} Performance"
      }
    end)
  end

  defp performance_status(%{cpu: cpu, response_time: rt}) when cpu < 50 and rt < 100, do: :operational
  defp performance_status(%{cpu: cpu, response_time: rt}) when cpu < 80 and rt < 200, do: :warning
  defp performance_status(_), do: :danger
end
```

## Broadcasting Patterns

### Complete State Updates

Use for initial loads or major state changes:

```elixir
def broadcast_complete_state(room_id, marker_groups, theme) do
  MyAppWeb.MapChannel.broadcast_marker_state("map:#{room_id}", %{
    marker_groups: marker_groups,
    theme: theme,
    config: %{
      bbox: {0, 0, 800, 391},
      timestamp: System.system_time(:millisecond)
    }
  })
end
```

### Incremental Updates

Use for frequent small changes:

```elixir
def broadcast_group_update(room_id, group_id, new_markers) do
  MyAppWeb.MapChannel.broadcast_marker_update("map:#{room_id}", %{
    group_id: group_id,
    markers: new_markers,
    timestamp: System.system_time(:millisecond)
  })
end
```

### Theme Changes

Use for dynamic theming:

```elixir
def broadcast_theme_update(room_id, new_theme) do
  MyAppWeb.MapChannel.broadcast_theme_change("map:#{room_id}", %{
    theme: new_theme,
    timestamp: System.system_time(:millisecond)
  })
end
```

## Performance Considerations

### Throttling Guidelines

- **High-frequency updates** (every second): Use 25-50ms throttle
- **Medium-frequency updates** (every 5-10 seconds): Use 100-200ms throttle
- **Low-frequency updates** (every 30+ seconds): Use 500ms+ throttle

### Bandwidth Optimization

1. **Use incremental updates** for small changes
2. **Batch related changes** before broadcasting
3. **Only broadcast significant changes** (implement change detection)
4. **Use appropriate throttling** based on update frequency

### Error Handling

The real-time system includes automatic:
- **Reconnection** with exponential backoff
- **State synchronization** on reconnect
- **Graceful fallback** to server rendering
- **Client-side validation** of incoming data

## Testing Real-Time Features

### Unit Testing Channels

```elixir
defmodule MyAppWeb.MapChannelTest do
  use MyAppWeb.ChannelCase

  test "joins map channel successfully" do
    {:ok, _, socket} = subscribe_and_join(socket(MyAppWeb.UserSocket), MyAppWeb.MapChannel, "map:test")
    assert socket
  end

  test "broadcasts marker updates" do
    {:ok, _, socket} = subscribe_and_join(socket(MyAppWeb.UserSocket), MyAppWeb.MapChannel, "map:test")

    broadcast_from!(socket, "marker_update", %{group_id: "test", markers: []})
    assert_broadcast "marker_update", %{group_id: "test"}
  end
end
```

### Integration Testing

```elixir
defmodule MyAppWeb.RealTimeMapTest do
  use MyAppWeb.ConnCase
  import Phoenix.LiveViewTest

  test "real-time map renders with channel configuration", %{conn: conn} do
    {:ok, view, html} = live(conn, "/dashboard")

    assert html =~ "phx-hook=\"RealTimeMap\""
    assert html =~ "data-channel=\"map:"
    assert html =~ "data-initial-state"
  end
end
```

This completes the comprehensive real-time usage examples. The system provides high-performance marker updates while maintaining backward compatibility and graceful fallback mechanisms.
