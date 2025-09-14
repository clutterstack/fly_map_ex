defmodule FlyMapEx.Adapters do
  @moduledoc """
  Data transformation utilities for common patterns when working with Fly.io deployments.

  Provides helpers for extracting region data from various data sources and formats
  commonly used in Elixir applications.
  """

  alias FlyMapEx.Style

  @doc """
  Parse Fly.io DNS TXT record for machine discovery.

  Parses the format returned by Fly.io internal DNS TXT records which contain
  machine IDs and their regions in the format: "machineId region,machineId region"

  ## Examples

      iex> FlyMapEx.Adapters.from_fly_dns_txt("683d314fdd4d68 yyz,568323e9b54dd8 lhr")
      [{"683d314fdd4d68", "yyz"}, {"568323e9b54dd8", "lhr"}]

      iex> FlyMapEx.Adapters.from_fly_dns_txt("")
      []
  """
  def from_fly_dns_txt(txt_record) when is_binary(txt_record) do
    txt_record
    |> String.trim()
    |> case do
      "" ->
        []

      record ->
        record
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.map(&parse_machine_entry/1)
        |> Enum.reject(&is_nil/1)
    end
  end

  def from_fly_dns_txt(_), do: []

  @doc """
  Parse Fly.io _instances.internal DNS TXT record for instance discovery.

  Parses the format returned by `_instances.internal` which contains instance data
  in the format: "instance=id,app=name,ip=addr,region=reg;instance=id2,app=name2,..."

  ## Examples

      iex> txt = "instance=3d8d9250a27de8,app=c-corrodocs,ip=fdaa:0:3b99:a7b:1d3:cb60:76c3:2,region=yyz;instance=5683d56ea79d28,app=ccorrosion,ip=fdaa:0:3b99:a7b:1d3:ea9b:7cc0:2,region=yyz"
      iex> FlyMapEx.Adapters.from_fly_instances_txt(txt)
      [
        {"3d8d9250a27de8", "c-corrodocs", "yyz"},
        {"5683d56ea79d28", "ccorrosion", "yyz"}
      ]

      iex> FlyMapEx.Adapters.from_fly_instances_txt("")
      []
  """
  def from_fly_instances_txt(txt_record) when is_binary(txt_record) do
    txt_record
    |> String.trim()
    |> case do
      "" ->
        []

      record ->
        record
        |> String.split(";")
        |> Enum.map(&String.trim/1)
        |> Enum.map(&parse_instance_entry/1)
        |> Enum.reject(&is_nil/1)
    end
  end

  def from_fly_instances_txt(_), do: []

  @doc """
  Convert machine tuples to marker groups.

  Takes a list of {machine_id, region} tuples and converts them to FlyMapEx
  marker groups format, optionally grouping by region or keeping separate.

  ## Examples

      iex> machines = [{"683d314fdd4d68", "yyz"}, {"568323e9b54dd8", "lhr"}, {"123abc", "yyz"}]
      iex> FlyMapEx.Adapters.from_machine_tuples(machines, "Running Machines")
      [
        %{nodes: ["yyz"], style: FlyMapEx.Style.named_colours(:blue), label: "Running Machines (2)", machine_count: 2},
        %{nodes: ["lhr"], style: FlyMapEx.Style.named_colours(:blue), label: "Running Machines (1)", machine_count: 1}
      ]

      iex> FlyMapEx.Adapters.from_machine_tuples(machines, "Operational", :operational)
      [
        %{nodes: ["yyz"], style: FlyMapEx.Style.operational(), label: "Operational (2)", machine_count: 2},
        %{nodes: ["lhr"], style: FlyMapEx.Style.operational(), label: "Operational (1)", machine_count: 1}
      ]
  """
  def from_machine_tuples(machine_tuples, label, style_key \\ :operational)

  def from_machine_tuples(machine_tuples, label, style_key) when is_list(machine_tuples) do
    machine_tuples
    |> Enum.reject(fn {_id, region} -> region in ["", nil, "unknown"] end)
    |> Enum.group_by(fn {_id, region} -> region end)
    |> Enum.map(fn {region, machines} ->
      count = length(machines)
      label_with_count = "#{label} (#{count})"

      %{
        nodes: [region],
        style: Style.normalize(style_key),
        label: label_with_count,
        machine_count: count
      }
    end)
    |> Enum.reject(fn group -> Enum.empty?(group.nodes) end)
  end

  def from_machine_tuples(_, _label, _style_key), do: []

  # Note: Style normalization is now handled by FlyMapEx.Style.normalize/1

  # Private helper functions

  defp parse_machine_entry(entry) when is_binary(entry) do
    case String.split(entry, " ", parts: 2) do
      [machine_id, region] ->
        machine_id = String.trim(machine_id)
        region = String.trim(region)

        if machine_id != "" and region != "" do
          {machine_id, region}
        else
          nil
        end

      _ ->
        nil
    end
  end

  defp parse_machine_entry(_), do: nil

  defp parse_instance_entry(entry) when is_binary(entry) do
    # Parse format: "instance=id,app=name,ip=addr,region=reg"
    parts = String.split(entry, ",")

    case parts do
      [instance_part, app_part, _ip_part, region_part] ->
        with ["instance", instance_id] <- String.split(instance_part, "=", parts: 2),
             ["app", app_name] <- String.split(app_part, "=", parts: 2),
             ["region", region] <- String.split(region_part, "=", parts: 2) do
          instance_id = String.trim(instance_id)
          app_name = String.trim(app_name)
          region = String.trim(region)

          if instance_id != "" and app_name != "" and region != "" do
            {instance_id, app_name, region}
          else
            nil
          end
        else
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp parse_instance_entry(_), do: nil
end
