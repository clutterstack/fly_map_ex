defmodule Demo.MachineDiscovery do
  @moduledoc """
  DNS-based machine discovery for Fly.io applications.

  Uses Erlang's built-in :inet_res module to query Fly.io internal DNS
  for TXT records containing machine IDs and their regions.
  """

  require Logger

  @doc """
  Discover machines in a Fly.io app using internal DNS.

  Queries the TXT record at `vms.{app_name}.internal` and parses the response
  to extract machine IDs and their regions.

  ## Examples

      iex> Demo.MachineDiscovery.discover_machines("my-app-name")
      {:ok, [{"683d314fdd4d68", "yyz"}, {"568323e9b54dd8", "lhr"}]}

      iex> Demo.MachineDiscovery.discover_machines("nonexistent-app")
      {:error, :no_machines_found}
  """
  def discover_machines(app_name) when is_binary(app_name) do
    dns_name = String.to_charlist("vms.#{app_name}.internal")

    case :inet_res.lookup(dns_name, :in, :txt) do
      [] ->
        Logger.debug("No TXT records found for #{app_name}")
        {:error, :no_machines_found}

      records when is_list(records) ->
        txt_content =
          records
          |> Enum.map(&parse_txt_record/1)
          |> Enum.join("")

        machines = FlyMapEx.Adapters.from_fly_dns_txt(txt_content)

        case machines do
          [] -> {:error, :no_machines_found}
          machines -> {:ok, machines}
        end

      {:error, reason} ->
        Logger.warning("DNS lookup failed for #{app_name}: #{inspect(reason)}")
        {:error, reason}
    end
  rescue
    error ->
      Logger.error("Machine discovery failed for #{app_name}: #{inspect(error)}")
      {:error, :discovery_failed}
  end

  @doc """
  Discover available Fly.io apps using internal DNS.

  Queries the TXT record at `_apps.internal` and parses the response
  to extract a comma-separated list of app names.

  ## Examples

      iex> Demo.MachineDiscovery.discover_apps()
      {:ok, ["my-app-name", "another-app", "third-app"]}

      iex> Demo.MachineDiscovery.discover_apps()
      {:error, :no_apps_found}
  """
  def discover_apps() do
    dns_name = ~c"_apps.internal"

    case :inet_res.lookup(dns_name, :in, :txt) do
      [] ->
        Logger.debug("No TXT records found for _apps.internal")
        {:error, :no_apps_found}

      records when is_list(records) ->
        txt_content =
          records
          |> Enum.map(&parse_txt_record/1)
          |> Enum.join("")

        apps = parse_apps_list(txt_content)

        case apps do
          [] -> {:error, :no_apps_found}
          apps -> {:ok, apps}
        end

      {:error, reason} ->
        Logger.warning("DNS lookup failed for _apps.internal: #{inspect(reason)}")
        {:error, reason}
    end
  rescue
    error ->
      Logger.error("App discovery failed: #{inspect(error)}")
      {:error, :discovery_failed}
  end

  @doc """
  Discover only apps that have active machines using _instances.internal DNS.

  Queries the TXT record at `_instances.internal` and extracts unique app names
  from the instance data. This ensures we only show apps with running machines.

  ## Examples

      iex> Demo.MachineDiscovery.discover_apps_with_machines()
      {:ok, ["c-corrodocs", "ccorrosion", "where"]}

      iex> Demo.MachineDiscovery.discover_apps_with_machines()
      {:error, :no_instances_found}
  """
  def discover_apps_with_machines() do
    dns_name = ~c"_instances.internal"

    case :inet_res.lookup(dns_name, :in, :txt) do
      [] ->
        Logger.debug("No TXT records found for _instances.internal")
        {:error, :no_instances_found}

      records when is_list(records) ->
        txt_content =
          records
          |> Enum.map(&parse_txt_record/1)
          |> Enum.join("")

        instances = FlyMapEx.Adapters.from_fly_instances_txt(txt_content)

        apps =
          instances
          |> Enum.map(fn {_instance_id, app_name, _region} -> app_name end)
          |> Enum.uniq()
          |> Enum.sort()

        case apps do
          [] -> {:error, :no_instances_found}
          apps -> {:ok, apps}
        end

      {:error, reason} ->
        Logger.warning("DNS lookup failed for _instances.internal: #{inspect(reason)}")
        {:error, reason}
    end
  rescue
    error ->
      Logger.error("App discovery with machines failed: #{inspect(error)}")
      {:error, :discovery_failed}
  end

  @doc """
  Discover machines for multiple apps simultaneously.

  Returns a map with app names as keys and machine discovery results as values.

  ## Examples

      iex> Demo.MachineDiscovery.discover_all_apps(["app1", "app2"])
      %{
        "app1" => {:ok, [{"683d314fdd4d68", "yyz"}]},
        "app2" => {:error, :no_machines_found}
      }
  """
  def discover_all_apps(app_names) when is_list(app_names) do
    app_names
    |> Task.async_stream(&{&1, discover_machines(&1)}, max_concurrency: 10)
    |> Enum.into(%{}, fn {:ok, {app_name, result}} -> {app_name, result} end)
  end

  def discover_all_apps(_), do: %{}

  @doc """
  Discover all apps and their machines in a single _instances.internal query.

  More efficient than the traditional two-step process of discovering apps
  then querying each one individually. Returns both the apps and their machine data.

  ## Examples

      iex> Demo.MachineDiscovery.discover_all_from_instances()
      %{
        "c-corrodocs" => {:ok, [{"3d8d9250a27de8", "yyz"}]},
        "ccorrosion" => {:ok, [{"5683d56ea79d28", "yyz"}, {"e286de5c69e986", "mia"}]}
      }
  """
  def discover_all_from_instances() do
    dns_name = ~c"_instances.internal"

    case :inet_res.lookup(dns_name, :in, :txt) do
      [] ->
        Logger.debug("No TXT records found for _instances.internal")
        %{}

      records when is_list(records) ->
        txt_content =
          records
          |> Enum.map(&parse_txt_record/1)
          |> Enum.join("")

        instances = FlyMapEx.Adapters.from_fly_instances_txt(txt_content)

        # Group instances by app name and convert to the expected format
        instances
        |> Enum.group_by(fn {_instance_id, app_name, _region} -> app_name end)
        |> Enum.into(%{}, fn {app_name, app_instances} ->
          # Convert to {machine_id, region} tuples for compatibility
          machines =
            app_instances
            |> Enum.map(fn {instance_id, _app_name, region} -> {instance_id, region} end)

          {app_name, {:ok, machines}}
        end)

      {:error, reason} ->
        Logger.warning("DNS lookup failed for _instances.internal: #{inspect(reason)}")
        %{}
    end
  rescue
    error ->
      Logger.error("Instance discovery failed: #{inspect(error)}")
      %{}
  end

  @doc """
  Convert app machines data to marker groups for FlyMapEx.

  Takes a map of app names to machine discovery results and converts them
  to FlyMapEx marker groups format with distinct cycling colors for each app.
  Uses FlyMapEx.Style.cycle/1 to automatically assign visually distinct colors.

  ## Examples

      iex> app_machines = %{
      ...>   "app1" => {:ok, [{"machine1", "yyz"}, {"machine2", "fra"}]},
      ...>   "app2" => {:ok, [{"machine3", "lhr"}]}
      ...> }
      iex> Demo.MachineDiscovery.from_app_machines(app_machines)
      [
        %{nodes: ["yyz", "fra"], style: FlyMapEx.Style.cycle(0), label: "app1 (2 machines)"},
        %{nodes: ["lhr"], style: FlyMapEx.Style.cycle(1), label: "app2 (1 machine)"}
      ]
  """
  def from_app_machines(app_machines) when is_map(app_machines) do
    app_machines
    |> Enum.filter(fn {_app, result} ->
      match?({:ok, [_ | _]}, result)
    end)
    |> Enum.map(fn {app_name, {:ok, machines}} ->
      nodes = machines |> Enum.map(fn {_id, region} -> region end) |> Enum.uniq()
      machine_count = length(machines)

      # Use highly distinct styles for maximum visual distinction
      # Get a stable style based on app name hash
      style_index = stable_style_index(app_name)
      base_style = Enum.at(distinct_app_styles(), style_index)

      # Optionally adjust size based on machine count for additional context
      adjusted_size =
        case machine_count do
          count when count >= 10 -> round(base_style.size * 1.3)
          count when count >= 5 -> round(base_style.size * 1.1)
          _ -> base_style.size
        end

      style = Map.put(base_style, :size, adjusted_size)

      label =
        case machine_count do
          1 -> "#{app_name} (1 machine)"
          n -> "#{app_name} (#{n} machines)"
        end

      %{
        nodes: nodes,
        style: style,
        label: label,
        group_label: app_name,
        machine_count: machine_count
      }
    end)
  end

  def from_app_machines(_), do: []

  # Private helper to generate a stable style index for an app name
  # Uses a simple hash to ensure the same app always gets the same style
  defp stable_style_index(app_name) do
    # Get the number of available distinct styles
    style_count = length(distinct_app_styles())

    # Create a simple hash of the app name
    hash =
      app_name
      |> String.to_charlist()
      |> Enum.reduce(0, fn char, acc -> acc + char end)

    # Map to style index
    rem(hash, style_count)
  end

  # Define highly distinct styles for different apps
  # Uses bright, visually distinct colors with consistent sizing for maximum clarity
  defp distinct_app_styles do
    base_radius = FlyMapEx.Config.marker_base_radius()
    # standard_size = round(1.3 * base_radius)

    [
      # Bright blue
      %{colour: "#2563eb", size: round(base_radius), animated: false, gradient: false},

      # Bright green
      %{colour: "#16e34a", size: round(1.1 * base_radius), animated: false, gradient: false},

      # Bright red
      %{colour: "#ec2626", size: round(1.2 * base_radius), animated: false, gradient: false},

      # Bright purple
      %{colour: "#b333ea", size: round(1.4 * base_radius), animated: false, gradient: false},

      # Bright orange
      %{colour: "#ea580c", size: round(1.6 * base_radius), animated: false, gradient: false},

      # Bright cyan
      %{colour: "#08b1b2", size: round(1.8 * base_radius), animated: false, gradient: false},

      # Bright yellow
      %{colour: "#cafa04", size: round(2 * base_radius), animated: false, gradient: false},

      # Bright pink
      %{colour: "#eb97a7", size: round(2.2 * base_radius), animated: false, gradient: false},

      # Bright teal
      %{colour: "#0d9488", size: round(2.4 * base_radius), animated: false, gradient: false},

      # Bright lime
      %{colour: "#65a30d", size: round(2.6 * base_radius), animated: false, gradient: false},

      # Bright amber
      %{colour: "#d97706", size: round(2.8 * base_radius), animated: false, gradient: false},

      # Bright indigo
      %{colour: "#4338ca", size: round(3 * base_radius), animated: false, gradient: false}
    ]
  end

  @doc """
  Discover machines periodically and send results to a process.

  Starts a task that queries DNS every `interval_ms` milliseconds and sends
  results to the given process as `{:machines_updated, result}` messages.

  ## Examples

      iex> Demo.MachineDiscovery.start_periodic_discovery("my-app", self(), 30_000)
      #PID<0.123.0>
  """
  def start_periodic_discovery(app_name, target_pid, interval_ms \\ 30_000) do
    Task.start(fn ->
      periodic_discovery_loop(app_name, target_pid, interval_ms)
    end)
  end

  # Private functions

  defp parse_txt_record(record) when is_list(record) do
    # TXT records come as a list of binaries, join them
    record |> Enum.join("")
  end

  defp parse_txt_record(record) when is_binary(record) do
    record
  end

  defp parse_txt_record(_), do: ""

  defp parse_apps_list(txt_content) when is_binary(txt_content) do
    txt_content
    |> String.trim()
    |> case do
      "" ->
        []

      content ->
        content
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))
    end
  end

  defp parse_apps_list(_), do: []

  defp periodic_discovery_loop(app_name, target_pid, interval_ms) do
    result = discover_machines(app_name)
    send(target_pid, {:machines_updated, result})

    Process.sleep(interval_ms)
    periodic_discovery_loop(app_name, target_pid, interval_ms)
  end
end
