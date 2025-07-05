defmodule DemoWeb.MachineMapLive do
  @moduledoc """
  LiveView component that displays a real-time world map of Fly.io machines.

  Periodically discovers machines using DNS and displays them on a FlyMapEx world map.
  """

  use Phoenix.LiveView

  alias Demo.MachineDiscovery
  alias DemoWeb.Components.LoadingOverlay
  import DemoWeb.Components.DemoNavigation

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:available_apps, [])
      |> assign(:selected_apps, [])
      |> assign(:app_machines, %{})
      |> assign(:marker_groups, [])
      |> assign(:all_selected_machines, [])
      # Cache complete instance data for instant filtering
      |> assign(:all_instances_data, %{})
      |> assign(:last_updated, nil)
      |> assign(:error, nil)
      |> assign(:apps_loading, true)
      |> assign(:machines_loading, false)
      |> assign(:map_refreshing, false)
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

  def handle_event("refresh_machines", _params, socket) do
    socket =
      socket
      |> assign(:map_refreshing, true)
      # Refresh cached data from DNS
      |> discover_and_cache_instances()
      # Filter for selected apps
      |> refresh_machines_for_selected_apps()
      |> assign(:map_refreshing, false)

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
      |> assign(:selected_apps, available_apps)
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
    <.demo_navigation current_page={:machine_map} />
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold text-base-content">Fly.io Multi-App Machine Map</h1>
      </div>
      <h2 class="text-xl mb-4 text-base-content">Apps with active Machines on this network</h2>

    <!-- Initial Loading State -->
      <%= if @apps_loading && @available_apps == [] do %>
        <div class="bg-info/10 border border-info/20 rounded-lg p-6 mb-6">
          <div class="flex items-center gap-3">
            <svg
              class="animate-spin h-6 w-6 text-info"
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
              <h3 class="text-info font-semibold">Loading Fly.io Applications</h3>
              <p class="text-info/80 text-sm">Discovering running machines across all regions...</p>
            </div>
          </div>
        </div>
      <% end %>

    <!-- World Map -->
      <div class="bg-base-100 rounded-lg shadow-lg p-6 mb-6 relative">
        <FlyMapEx.render
          marker_groups={@marker_groups}
          class="machine-map"
          show_regions={false}
          layout={:side_by_side}
        />

        <LoadingOverlay.render
          show={@apps_loading || @map_refreshing}
          message={if @map_refreshing, do: "Refreshing Map Data", else: "Loading Map Data"}
        />
      </div>

    <!-- Machine Details -->
      <div class="bg-base-100 rounded-lg shadow-lg p-6 mb-6">
        <h2 class="text-xl font-semibold mb-4 text-base-content">Mapped Machines</h2>

    <!-- Summary Stats -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <div class="bg-info/10 p-4 rounded-lg">
            <h3 class="text-info font-semibold">Total Machines</h3>
            <p class="text-2xl font-bold text-info">{length(@all_selected_machines)}</p>
          </div>
          <div class="bg-success/10 p-4 rounded-lg">
            <h3 class="text-success font-semibold">Apps</h3>
            <p class="text-2xl font-bold text-success">{length(@selected_apps)}</p>
          </div>
          <div class="bg-secondary/10 p-4 rounded-lg">
            <h3 class="text-secondary font-semibold">Regions</h3>
            <p class="text-2xl font-bold text-secondary">
              {@all_selected_machines
              |> Enum.map(fn {_, region, _} -> region end)
              |> Enum.uniq()
              |> length()}
            </p>
          </div>
        </div>

    <!-- Machines by Region -->
        <div class="mt-6">
          <h3 class="text-lg font-medium mb-4 text-base-content">By region</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <%= for {region, machines} <- @all_selected_machines |> Enum.group_by(fn {_, region, _} -> region end) do %>
              <div class="border border-base-300 rounded-lg p-4 bg-base-200/30">
                <h4 class="font-semibold text-primary">{region}</h4>
                <p class="text-sm text-base-content/60 mb-2">{pluralize_machines(machines)}</p>
                <div class="space-y-1">
                  <%= for {machine_id, _, app} <- machines do %>
                    <div class="text-xs">
                      <span class="font-mono text-base-content/50">
                        {String.slice(machine_id, 0, 8)}...
                      </span>
                      <span class="text-secondary ml-2">({app})</span>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>

      <div class="mt-8 text-xs text-base-content/50">
        <p>This demo queries Fly.io internal DNS for app discovery and machine information.</p>
        <p>
          Make sure you're running on Fly.io's private network (WireGuard) for DNS queries to work.
        </p>
      </div>
    </div>
    """
  end

  # Helper functions

  @doc """
  Returns a properly pluralized string for machine counts.
  """
  def pluralize_machines(count) when is_integer(count) do
    case count do
      1 -> "1 machine"
      n -> "#{n} machines"
    end
  end

  def pluralize_machines(list) when is_list(list) do
    pluralize_machines(length(list))
  end

  # Private functions

  defp get_app_name do
    # Try to get app name from config first, then environment
    Application.get_env(:demo, :fly_app_name) ||
      System.get_env("FLY_APP_NAME")
  end

  # A group is a map
  #   %{nodes: ["sjc", "fra"], style: FlyMapEx.Style.primary(), label: "Active Regions"},
  #  We could define a function like the following and add it to the list in the marker_groups
  # assign in order to display the Fly.io deployment regions as active markers (the FlyMapEx lib
  # can display them out of the box, though)
  # defp fly_regions_group do
  #   %{
  #     nodes: FlyMapEx.Regions.list(),
  #     style: FlyMapEx.Style.info(size: 4, animated: false),
  #     label: "Fly.io regions"
  #   }
  # end
end
