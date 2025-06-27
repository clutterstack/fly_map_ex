defmodule FlyMapEx.Adapters do
  @moduledoc """
  Data transformation utilities for common patterns when working with Fly.io deployments.

  Provides helpers for extracting region data from various data sources and formats
  commonly used in Elixir applications.
  """









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
      "" -> []
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
  Convert machine tuples to marker groups.

  Takes a list of {machine_id, region} tuples and converts them to FlyMapEx
  marker groups format, optionally grouping by region or keeping separate.

  ## Examples

      iex> machines = [{"683d314fdd4d68", "yyz"}, {"568323e9b54dd8", "lhr"}, {"123abc", "yyz"}]
      iex> FlyMapEx.Adapters.from_machine_tuples(machines, "Running Machines")
      [
        %{nodes: ["yyz"], style: FlyMapEx.Style.primary(), label: "Running Machines (2)", machine_count: 2},
        %{nodes: ["lhr"], style: FlyMapEx.Style.primary(), label: "Running Machines (1)", machine_count: 1}
      ]

      iex> FlyMapEx.Adapters.from_machine_tuples(machines, "Active", :active)
      [
        %{nodes: ["yyz"], style: FlyMapEx.Style.active(), label: "Active (2)", machine_count: 2},
        %{nodes: ["lhr"], style: FlyMapEx.Style.active(), label: "Active (1)", machine_count: 1}
      ]
  """
  def from_machine_tuples(machine_tuples, label, style_key \\ :primary)

  def from_machine_tuples(machine_tuples, label, style_key) when is_list(machine_tuples) do
    machine_tuples
    |> Enum.reject(fn {_id, region} -> region in ["", nil, "unknown"] end)
    |> Enum.group_by(fn {_id, region} -> region end)
    |> Enum.map(fn {region, machines} ->
      count = length(machines)
      label_with_count = "#{label} (#{count})"

      %{
        nodes: [region],
        style: normalize_style(style_key),
        label: label_with_count,
        machine_count: count
      }
    end)
    |> Enum.reject(fn group -> Enum.empty?(group.nodes) end)
  end

  def from_machine_tuples(_, _label, _style_key), do: []

  # Helper function to normalize style keys to style maps
  defp normalize_style(style_key) when is_atom(style_key) do
    case style_key do
      :primary -> FlyMapEx.Style.primary()
      :active -> FlyMapEx.Style.active()
      :expected -> FlyMapEx.Style.warning()
      :acknowledged -> FlyMapEx.Style.success()
      :secondary -> FlyMapEx.Style.secondary()
      :warning -> FlyMapEx.Style.warning()
      :inactive -> FlyMapEx.Style.inactive()
      _ -> FlyMapEx.Style.info()
    end
  end

  defp normalize_style(style) when is_map(style), do: style
  defp normalize_style(_), do: FlyMapEx.Style.info()


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

      _ -> nil
    end
  end

  defp parse_machine_entry(_), do: nil

end
