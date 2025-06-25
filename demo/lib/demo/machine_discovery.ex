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

  defp periodic_discovery_loop(app_name, target_pid, interval_ms) do
    result = discover_machines(app_name)
    send(target_pid, {:machines_updated, result})
    
    Process.sleep(interval_ms)
    periodic_discovery_loop(app_name, target_pid, interval_ms)
  end
end