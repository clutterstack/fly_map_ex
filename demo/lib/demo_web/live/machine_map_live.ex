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
      |> assign(:marker_groups, [fly_regions_group()])
      |> assign(:all_selected_machines, [])
      # Cache complete instance data for instant filtering
      |> assign(:all_instances_data, %{})
      |> assign(:last_updated, nil)
      |> assign(:error, nil)
      |> assign(:apps_loading, false)
      |> assign(:machines_loading, false)
      |> assign(:apps_error, nil)
      |> assign(:show_app_selection, true)

    # Try to get a default app from config/env
    default_app = get_app_name()

    socket =
      if default_app do
        assign(socket, :selected_apps, [default_app])
      else
        socket
      end

    # Start loading instance data immediately on mount
    send(self(), :load_instances)

    {:ok, socket}
  end

  def handle_event("discover_apps", _params, socket) do
    socket = discover_and_cache_instances(socket)
    {:noreply, socket}
  end

  def handle_event("toggle_app", %{"app" => app_name}, socket) do
    selected_apps = socket.assigns.selected_apps

    new_selected_apps =
      if app_name in selected_apps do
        List.delete(selected_apps, app_name)
      else
        [app_name | selected_apps]
      end

    socket =
      socket
      |> assign(:selected_apps, new_selected_apps)
      |> refresh_machines_for_selected_apps()

    {:noreply, socket}
  end

  def handle_event("select_all_apps", _params, socket) do
    available_apps = socket.assigns.available_apps

    socket =
      socket
      |> assign(:selected_apps, available_apps)
      |> refresh_machines_for_selected_apps()

    {:noreply, socket}
  end

  def handle_event("deselect_all_apps", _params, socket) do
    socket =
      socket
      |> assign(:selected_apps, [])
      |> refresh_machines_for_selected_apps()

    {:noreply, socket}
  end

  def handle_event("toggle_app_selection", _params, socket) do
    new_show_state = !socket.assigns.show_app_selection
    socket = assign(socket, :show_app_selection, new_show_state)
    {:noreply, socket}
  end

  def handle_info(:load_instances, socket) do
    socket =
      socket
      # Load and cache all instance data
      |> discover_and_cache_instances()
      # Apply to any pre-selected apps
      |> refresh_machines_for_selected_apps()

    {:noreply, socket}
  end

  def handle_event("refresh_machines", _params, socket) do
    socket =
      socket
      # Refresh cached data from DNS
      |> discover_and_cache_instances()
      # Filter for selected apps
      |> refresh_machines_for_selected_apps()

    {:noreply, socket}
  end

  # Private helper function to discover and cache all instance data
  defp discover_and_cache_instances(socket) do
    socket = assign(socket, :apps_loading, true)

    # Get all instance data in one DNS query and cache it
    all_instances_data = MachineDiscovery.discover_all_from_instances()

    if all_instances_data == %{} do
      socket
      |> assign(:apps_loading, false)
      |> assign(:apps_error, "No running machines found in _instances.internal DNS record")
    else
      # Extract app names from cached data
      available_apps =
        all_instances_data
        |> Map.keys()
        |> Enum.sort()

      socket
      |> assign(:all_instances_data, all_instances_data)
      |> assign(:available_apps, available_apps)
      |> assign(:apps_loading, false)
      |> assign(:apps_error, nil)
    end
  end

  # Private helper function to refresh machines for selected apps using cached data
  defp refresh_machines_for_selected_apps(socket) do
    selected_apps = socket.assigns.selected_apps
    all_instances_data = socket.assigns.all_instances_data

    if selected_apps == [] do
      # Clear the map if no apps are selected
      socket
      |> assign(:app_machines, %{})
      |> assign(:marker_groups, [])
      |> assign(:all_selected_machines, [])
      |> assign(:last_updated, DateTime.utc_now())
    else
      # Filter cached instance data for selected apps (no DNS query needed!)
      app_machines = Map.take(all_instances_data, selected_apps)
      marker_groups = MachineDiscovery.from_app_machines(app_machines)

      all_selected_machines =
        app_machines
        |> Enum.flat_map(fn {app_name, result} ->
          case result do
            {:ok, machines} ->
              Enum.map(machines, fn {machine_id, region} -> {machine_id, region, app_name} end)

            {:error, _} ->
              []
          end
        end)

      socket
      |> assign(:app_machines, app_machines)
      |> assign(:marker_groups, marker_groups)
      |> assign(:all_selected_machines, all_selected_machines)
      |> assign(:last_updated, DateTime.utc_now())
      |> assign(:error, nil)
    end
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-6">Fly.io Multi-App Machine Map</h1>

    <!-- Initial Loading State -->
      <%= if @apps_loading && @available_apps == [] do %>
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-6 mb-6">
          <div class="flex items-center gap-3">
            <svg
              class="animate-spin h-6 w-6 text-blue-600"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
              </circle>
              <path
                class="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              >
              </path>
            </svg>
            <div>
              <h3 class="text-blue-800 font-semibold">Loading Fly.io Applications</h3>
              <p class="text-blue-600 text-sm">Discovering running machines across all regions...</p>
            </div>
          </div>
        </div>
      <% end %>


    <!-- World Map -->
      <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
        <FlyMapEx.render marker_groups={@marker_groups} class="machine-map" />
      </div>

    <!-- Apps -->
      <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
        <h2 class="text-xl font-semibold mb-4">Apps with active Machines on this network</h2>

    <!-- Machines by App (all from DNS) -->
        <div class="space-y-4">
          <!--  for group <- @marker_groups do -->
          <%= for app <- @available_apps do %>
            <.app_card_content
              all_instances_data={@all_instances_data}
              marker_groups={@marker_groups}
              app_name={app}
              selected_apps={@selected_apps}
            />
          <% end %>
        </div>

    <!-- Machines by Region -->
        <div class="mt-6">
          <h3 class="text-lg font-medium mb-4">Machines by Region</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <%= for {region, machines} <- @all_selected_machines |> Enum.group_by(fn {_, region, _} -> region end) do %>
              <div class="border rounded-lg p-4">
                <h4 class="font-semibold text-blue-800">{region}</h4>
                <p class="text-sm text-gray-600 mb-2">{length(machines)} machines</p>
                <div class="space-y-1">
                  <%= for {machine_id, _, app} <- machines do %>
                    <div class="text-xs">
                      <span class="font-mono text-gray-500">{String.slice(machine_id, 0, 8)}...</span>
                      <span class="text-purple-600 ml-2">({app})</span>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>


      <!-- Machine Details -->
      <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
        <h2 class="text-xl font-semibold mb-4">Machine details</h2>

        <!-- Summary Stats -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <div class="bg-blue-50 p-4 rounded-lg">
            <h3 class="text-blue-800 font-semibold">Total Machines</h3>
            <p class="text-2xl font-bold text-blue-900">{length(@all_selected_machines)}</p>
          </div>
          <div class="bg-green-50 p-4 rounded-lg">
            <h3 class="text-green-800 font-semibold">Active Apps</h3>
            <p class="text-2xl font-bold text-green-900">{length(@selected_apps)}</p>
          </div>
          <div class="bg-purple-50 p-4 rounded-lg">
            <h3 class="text-purple-800 font-semibold">Regions</h3>
            <p class="text-2xl font-bold text-purple-900">
              {@all_selected_machines
              |> Enum.map(fn {_, region, _} -> region end)
              |> Enum.uniq()
              |> length()}
            </p>
          </div>
        </div>
      </div>

      <div class="mt-8 text-xs text-gray-500">
        <p>This demo queries Fly.io internal DNS for app discovery and machine information.</p>
        <p>
          Make sure you're running on Fly.io's private network (WireGuard) for DNS queries to work.
        </p>
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

  defp get_style_color(style) when is_map(style) do
    # Extract color from the new style format
    Map.get(style, :color, "#888888")
  end

  defp get_style_color(_), do: "#888888"

  # A group is a map
  #   %{nodes: ["sjc", "fra"], style: FlyMapEx.Style.primary(), label: "Active Regions"},

  defp fly_regions_group do
    %{
      nodes: FlyMapEx.Regions.list(),
      style: FlyMapEx.Style.info(size: 4, animated: false),
      label: "Fly.io regions"
    }
  end

  defp group_from_app_name(marker_groups, app_name) do
    Enum.find(marker_groups, fn group ->
      Map.get(group, :app_name) == app_name
    end)
  end

  defp colour_from_app_name(marker_groups, app_name) do
    group = group_from_app_name(marker_groups, app_name)

    case group do
      nil -> "#ffffffaa"
      _ -> get_style_color(group.style)
    end
  end

  defp regions_from_app_name(all_instances_data, app_name) do
    case Map.get(all_instances_data, app_name) do
      {:ok, instances} ->
        instances
        |> Enum.map(&elem(&1, 1))
        |> Enum.uniq()

      nil ->
        []
    end
  end

  defp machs_from_app_name(all_instances_data, app_name) do
    case Map.get(all_instances_data, app_name) do
      {:ok, instances} ->
        instances

      nil ->
        []
    end
  end

  def app_card_content(
        %{
          all_instances_data: all_instances_data,
          marker_groups: marker_groups,
          app_name: app_name,
          selected_apps: selected_apps
        } = assigns
      ) do
    region_string =
      regions_from_app_name(assigns.all_instances_data, app_name)
      |> Enum.map(fn region -> if is_binary(region), do: region, else: region.label end)
      |> Enum.join(", ")

     is_selected = app_name in selected_apps

      assigns =
        assigns
        |> assign(:region_string, region_string)
       |> assign(:is_selected, is_selected)

    ~H"""
    <div
        class={[
         "border rounded-lg p-3 cursor-pointer transition-all duration-200 hover:shadow-md",
          if(@is_selected, do: "border-blue-500 bg-blue-50 shadow-sm", else: "border-gray-200 hover:border-gray-300")
        ]}
        phx-click="toggle_app"
       phx-value-app={@app_name}
      >
      <div class="flex items-center justify-between">
        <div class="flex items-center">
          <span
              class={[
                "inline-block w-3 h-3 rounded-full mr-2",
                if(@is_selected, do: "ring-2 ring-blue-300", else: "")
              ]}
            style={"background-color: #{colour_from_app_name(@marker_groups, @app_name)};"}
          >
          </span>
          <h4 class={[
            "font-semibold",
            if(@is_selected, do: "text-blue-900", else: "text-gray-900")
          ]}>{@app_name}</h4>
        </div>
        <div class="flex items-center gap-2 text-xs text-gray-500">
          <span>{length(machs_from_app_name(@all_instances_data, @app_name))} machines</span>
          <span>•</span>
          <span>{@region_string}</span>
          <%= if @is_selected do %>
            <svg class="w-4 h-4 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
            </svg>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
