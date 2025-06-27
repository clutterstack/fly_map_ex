defmodule DemoWeb.MachineMapLive do
  @moduledoc """
  LiveView component that displays a real-time world map of Fly.io machines.

  Periodically discovers machines using DNS and displays them on a FlyMapEx world map.
  """

  use Phoenix.LiveView

  alias Demo.MachineDiscovery

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:available_apps, [])
      |> assign(:selected_apps, [])
      |> assign(:app_machines, %{})
      |> assign(:marker_groups, [])
      |> assign(:all_machines, [])
      |> assign(:last_updated, nil)
      |> assign(:error, nil)
      |> assign(:apps_loading, false)
      |> assign(:machines_loading, false)
      |> assign(:apps_error, nil)
      |> assign(:show_app_selection, true)

    # Try to get a default app from config/env
    default_app = get_app_name()

    socket = if default_app do
      assign(socket, :selected_apps, [default_app])
    else
      socket
    end

    {:ok, socket}
  end

  def handle_event("discover_apps", _params, socket) do
    socket = assign(socket, :apps_loading, true)

    case MachineDiscovery.discover_apps() do
      {:ok, apps} ->
        socket =
          socket
          |> assign(:available_apps, apps)
          |> assign(:apps_loading, false)
          |> assign(:apps_error, nil)

        {:noreply, socket}

      {:error, reason} ->
        error_message = case reason do
          :no_apps_found -> "No apps found in _apps.internal DNS record"
          :discovery_failed -> "Failed to query _apps.internal DNS"
          other -> "App discovery error: #{inspect(other)}"
        end

        socket =
          socket
          |> assign(:apps_loading, false)
          |> assign(:apps_error, error_message)

        {:noreply, socket}
    end
  end

  def handle_event("toggle_app", %{"app" => app_name}, socket) do
    selected_apps = socket.assigns.selected_apps

    new_selected_apps = if app_name in selected_apps do
      List.delete(selected_apps, app_name)
    else
      [app_name | selected_apps]
    end

    socket = assign(socket, :selected_apps, new_selected_apps)
    {:noreply, socket}
  end

  def handle_event("select_all_apps", _params, socket) do
    available_apps = socket.assigns.available_apps
    socket = assign(socket, :selected_apps, available_apps)
    {:noreply, socket}
  end

  def handle_event("deselect_all_apps", _params, socket) do
    socket = assign(socket, :selected_apps, [])
    {:noreply, socket}
  end

  def handle_event("toggle_app_selection", _params, socket) do
    socket = assign(socket, :show_app_selection, !socket.assigns.show_app_selection)
    {:noreply, socket}
  end

  def handle_event("refresh_machines", _params, socket) do
    selected_apps = socket.assigns.selected_apps

    if selected_apps == [] do
      {:noreply, socket}
    else
      socket = assign(socket, :machines_loading, true)

      app_machines = MachineDiscovery.discover_all_apps(selected_apps)
      marker_groups = MachineDiscovery.from_app_machines(app_machines)

      all_machines =
        app_machines
        |> Enum.flat_map(fn {app_name, result} ->
          case result do
            {:ok, machines} -> Enum.map(machines, fn {machine_id, region} -> {machine_id, region, app_name} end)
            {:error, _} -> []
          end
        end)

      socket =
        socket
        |> assign(:app_machines, app_machines)
        |> assign(:marker_groups, marker_groups)
        |> assign(:all_machines, all_machines)
        |> assign(:machines_loading, false)
        |> assign(:last_updated, DateTime.utc_now())
        |> assign(:error, nil)

      {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-6">Fly.io Multi-App Machine Map</h1>

      <!-- App Discovery Section -->
      <div class="bg-white rounded-lg shadow-lg mb-6">
        <div class="flex items-center justify-between p-6 pb-4">
          <h2 class="text-xl font-semibold">App Selection</h2>
          <button
            phx-click="toggle_app_selection"
            class="text-sm bg-gray-100 hover:bg-gray-200 text-gray-700 px-3 py-1 rounded-lg transition-colors flex items-center gap-2"
          >
            <%= if @show_app_selection do %>
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7"/>
              </svg>
              Hide
            <% else %>
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
              </svg>
              Show
            <% end %>
          </button>
        </div>

        <div class={"#{if @show_app_selection, do: "p-6 pt-0", else: "hidden"}"}>

          <div class="flex gap-4 mb-4">
            <button
              phx-click="discover_apps"
              class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg disabled:opacity-50"
              disabled={@apps_loading}
            >
              <%= if @apps_loading do %>
                <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white inline" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Discovering...
              <% else %>
                Select Apps
              <% end %>
            </button>

            <button
              phx-click="refresh_machines"
              class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg disabled:opacity-50"
              disabled={@machines_loading || @selected_apps == []}
            >
              <%= if @machines_loading do %>
                <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white inline" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Refreshing...
              <% else %>
                Update Map
              <% end %>
            </button>
          </div>

          <%= if @apps_error do %>
            <div class="bg-red-50 border border-red-200 rounded-lg p-4 mb-4">
              <h3 class="text-red-800 font-semibold">App Discovery Error</h3>
              <p class="text-red-700 text-sm mt-1"><%= @apps_error %></p>
            </div>
          <% end %>

          <%= if @available_apps != [] do %>
            <div class="mb-4">
              <div class="flex items-center justify-between mb-3">
                <h3 class="text-lg font-medium">Available Apps</h3>
                <div class="flex gap-2">
                  <button
                    phx-click="select_all_apps"
                    class="text-sm bg-gray-100 hover:bg-gray-200 text-gray-700 px-3 py-1 rounded-lg transition-colors"
                    disabled={length(@available_apps) == length(@selected_apps)}
                  >
                    Select All
                  </button>
                  <button
                    phx-click="deselect_all_apps"
                    class="text-sm bg-gray-100 hover:bg-gray-200 text-gray-700 px-3 py-1 rounded-lg transition-colors"
                    disabled={@selected_apps == []}
                  >
                    Deselect All
                  </button>
                </div>
              </div>
              <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
                <%= for app <- @available_apps do %>
                  <label class="flex items-center space-x-2 p-2 border rounded-lg hover:bg-gray-50 cursor-pointer">
                    <input
                      type="checkbox"
                      phx-click="toggle_app"
                      phx-value-app={app}
                      checked={app in @selected_apps}
                      class="rounded border-gray-300"
                    />
                    <span class="text-sm font-mono"><%= app %></span>
                  </label>
                <% end %>
              </div>
            </div>
          <% end %>

          <%= if @selected_apps != [] do %>
            <div class="mb-4 p-3 bg-blue-50 rounded-lg">
              <div class="flex items-center justify-between">
                <div>
                  <span class="text-sm font-medium text-blue-800">Selected Apps (<%= length(@selected_apps) %>):</span>
                  <div class="flex flex-wrap gap-2 mt-2">
                    <%= for app <- @selected_apps do %>
                      <span class="bg-blue-100 text-blue-800 px-2 py-1 rounded text-sm font-mono">
                        <%= app %>
                      </span>
                    <% end %>
                  </div>
                </div>
                <%= if @last_updated do %>
                  <div class="text-xs text-blue-600">
                    Updated: <%= Calendar.strftime(@last_updated, "%H:%M:%S") %>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>

        </div>
      </div>

      <!-- World Map -->
      <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
        <FlyMapEx.render
          marker_groups={@marker_groups}
          class="machine-map"
        />
      </div>

      <!-- Machine Details -->
      <%= if @all_machines != [] do %>
        <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
          <h2 class="text-xl font-semibold mb-4">Machine Details</h2>

          <!-- Summary Stats -->
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
            <div class="bg-blue-50 p-4 rounded-lg">
              <h3 class="text-blue-800 font-semibold">Total Machines</h3>
              <p class="text-2xl font-bold text-blue-900"><%= length(@all_machines) %></p>
            </div>
            <div class="bg-green-50 p-4 rounded-lg">
              <h3 class="text-green-800 font-semibold">Active Apps</h3>
              <p class="text-2xl font-bold text-green-900"><%= length(@selected_apps) %></p>
            </div>
            <div class="bg-purple-50 p-4 rounded-lg">
              <h3 class="text-purple-800 font-semibold">Regions</h3>
              <p class="text-2xl font-bold text-purple-900">
                <%= @all_machines |> Enum.map(fn {_, region, _} -> region end) |> Enum.uniq() |> length() %>
              </p>
            </div>
          </div>

          <!-- Machines by App -->
          <div class="space-y-4">
            <h3 class="text-lg font-medium">Machines by App</h3>
            <%= for group <- @marker_groups do %>
              <div class="border rounded-lg p-4">
                <div class="flex items-center mb-2">
                  <span
                    class="inline-block w-3 h-3 rounded-full mr-2"
                    style={"background-color: #{get_style_color(group.style_key)};"}
                  ></span>
                  <h4 class="font-semibold"><%= group.label %></h4>
                </div>
                <div class="text-sm text-gray-600">
                  <p>Regions: <%= Enum.join(group.regions, ", ") %></p>
                  <div class="mt-2">
                    <p class="font-medium">Machines:</p>
                    <div class="ml-4 space-y-1">
                      <%= for {machine_id, region, app} <- @all_machines, app == group.app_name do %>
                        <div class="font-mono text-xs">
                          <span class="text-gray-500"><%= String.slice(machine_id, 0, 8) %>...</span>
                          <span class="text-blue-600 ml-2"><%= region %></span>
                        </div>
                      <% end %>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>
          </div>

          <!-- Machines by Region -->
          <div class="mt-6">
            <h3 class="text-lg font-medium mb-4">Machines by Region</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <%= for {region, machines} <- @all_machines |> Enum.group_by(fn {_, region, _} -> region end) do %>
                <div class="border rounded-lg p-4">
                  <h4 class="font-semibold text-blue-800"><%= region %></h4>
                  <p class="text-sm text-gray-600 mb-2"><%= length(machines) %> machines</p>
                  <div class="space-y-1">
                    <%= for {machine_id, _, app} <- machines do %>
                      <div class="text-xs">
                        <span class="font-mono text-gray-500"><%= String.slice(machine_id, 0, 8) %>...</span>
                        <span class="text-purple-600 ml-2">(<%= app %>)</span>
                      </div>
                    <% end %>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      <% end %>

      <div class="mt-8 text-xs text-gray-500">
        <p>This demo queries Fly.io internal DNS for app discovery and machine information.</p>
        <p>Make sure you're running on Fly.io's private network (WireGuard) for DNS queries to work.</p>
      </div>
    </div>
    """
  end

  # Private functions

  defp get_app_name do
    # Try to get app name from config first, then environment
    Application.get_env(:demo, :fly_app_name) ||
      System.get_env("FLY_APP_NAME")
  end

  defp get_style_color(style_key) do
    style_colours = %{
      primary: "#77b5fe",
      active: "#ffdc66",
      secondary: "#28a745",
      warning: "#dc3545",
      expected: "#ff8c42",
      acknowledged: "#9d4edd",
      inactive: "#6c757d"
    }

    Map.get(style_colours, style_key, "#888888")
  end

  # A group has to be a map?

  defp fly_region_group do
    for {region_atom, coords} <- Regions.all() #  %{ams: {5, 52}, iad: {-77, 39}, ...}
      region_string = Atom.to_string(region_atom)
      svg_coords = wgs84_to_svg(coords, @bbox)
      {region_string, svg_coords}
    end

    %{style:}
  end

end
