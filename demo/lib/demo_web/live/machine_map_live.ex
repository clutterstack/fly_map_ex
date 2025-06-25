defmodule DemoWeb.MachineMapLive do
  @moduledoc """
  LiveView component that displays a real-time world map of Fly.io machines.

  Periodically discovers machines using DNS and displays them on a FlyMapEx world map.
  """

  use Phoenix.LiveView

  alias Demo.MachineDiscovery
  alias FlyMapEx.Adapters

  @refresh_interval_ms 30_000  # 30 seconds

  def mount(_params, _session, socket) do
    app_name = get_app_name()
    
    # Start periodic machine discovery
    {:ok, discovery_pid} = MachineDiscovery.start_periodic_discovery(
      app_name,
      self(),
      @refresh_interval_ms
    )

    # Initial discovery
    initial_result = MachineDiscovery.discover_machines(app_name)

    socket =
      socket
      |> assign(:app_name, app_name)
      |> assign(:discovery_pid, discovery_pid)
      |> assign(:last_updated, nil)
      |> assign(:error, nil)
      |> update_machines(initial_result)

    {:ok, socket}
  end

  def handle_info({:machines_updated, result}, socket) do
    socket = 
      socket
      |> update_machines(result)
      |> assign(:last_updated, DateTime.utc_now())

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-6">Fly.io Machine Map Demo</h1>
      
      <div class="mb-6">
        <p class="text-gray-600 mb-2">
          Monitoring app: <span class="font-mono font-semibold"><%= @app_name %></span>
        </p>
        
        <%= if @last_updated do %>
          <p class="text-sm text-gray-500">
            Last updated: <%= Calendar.strftime(@last_updated, "%H:%M:%S UTC") %>
          </p>
        <% end %>
      </div>

      <%= if @error do %>
        <div class="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
          <h3 class="text-red-800 font-semibold">Discovery Error</h3>
          <p class="text-red-700 text-sm mt-1"><%= @error %></p>
          <p class="text-red-600 text-xs mt-2">
            Make sure you're running this on Fly.io's private network and the app name is correct.
          </p>
        </div>
      <% end %>

      <%= if @machines && length(@machines) > 0 do %>
        <div class="bg-white rounded-lg shadow-lg p-6">
          <FlyMapEx.render
            region_groups={@region_groups}
            theme={:monitoring}
            class="machine-map"
          />
          
          <div class="mt-4 text-sm text-gray-600">
            <p>Total machines: <%= length(@machines) %></p>
            <p>Regions: <%= @machines |> Enum.map(fn {_, region} -> region end) |> Enum.uniq() |> Enum.join(", ") %></p>
          </div>
        </div>
      <% else %>
        <div class="bg-gray-50 border border-gray-200 rounded-lg p-8 text-center">
          <h3 class="text-gray-700 font-semibold mb-2">No Machines Found</h3>
          <p class="text-gray-600 text-sm">
            Waiting for machine discovery... This demo requires:
          </p>
          <ul class="text-gray-600 text-sm mt-2 text-left max-w-md mx-auto">
            <li>• Running on Fly.io's private network (WireGuard)</li>
            <li>• Valid app name with running machines</li>
            <li>• DNS TXT record at vms.<%= @app_name %>.internal</li>
          </ul>
        </div>
      <% end %>

      <div class="mt-8 text-xs text-gray-500">
        <p>This demo queries DNS every <%= div(@refresh_interval_ms, 1000) %> seconds for machine updates.</p>
        <p>In production, you might want to use Fly.io's API or other monitoring tools.</p>
      </div>
    </div>
    """
  end

  # Private functions

  defp get_app_name do
    # Try to get app name from config first, then environment
    Application.get_env(:demo, :fly_app_name) ||
      System.get_env("FLY_APP_NAME") ||
      raise "No Fly.io app name configured. Set :fly_app_name in config or FLY_APP_NAME environment variable."
  end

  defp update_machines(socket, {:ok, machines}) do
    region_groups = Adapters.from_machine_tuples(machines, "Running Machines", :primary)
    
    socket
    |> assign(:machines, machines)
    |> assign(:region_groups, region_groups)
    |> assign(:error, nil)
  end

  defp update_machines(socket, {:error, reason}) do
    error_message = case reason do
      :no_machines_found -> "No machines found for app '#{socket.assigns.app_name}'"
      :discovery_failed -> "DNS discovery failed"
      other -> "Discovery error: #{inspect(other)}"
    end

    socket
    |> assign(:machines, [])
    |> assign(:region_groups, [])
    |> assign(:error, error_message)
  end
end