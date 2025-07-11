defmodule FlyMapEx.Adapters do
  @moduledoc """
  Data transformation utilities for common patterns when working with Fly.io deployments.

  Provides helpers for extracting region data from various data sources and formats
  commonly used in Elixir applications.
  """

  alias FlyMapEx.Regions

  @doc """
  Extract regions from a list of node IDs or hostnames.

  Useful when you have a list of Fly.io machine IDs or hostnames that include
  region codes in their names.

  ## Examples

      iex> FlyMapEx.Adapters.from_node_ids(["machine-1-sjc", "machine-2-fra"])
      ["sjc", "fra"]

      iex> FlyMapEx.Adapters.from_node_ids(["app-name-sjc-1234", "app-name-fra-5678"])
      ["sjc", "fra"]
  """
  def from_node_ids(node_ids) when is_list(node_ids) do
    node_ids
    |> Enum.map(&extract_region_from_node_id/1)
    |> Enum.reject(&(&1 in ["unknown", "", nil]))
    |> Enum.uniq()
  end

  def from_node_ids(_), do: []

  @doc """
  Extract regions from Fly.io machine data structures.

  Expects a list of maps with region information, commonly returned from
  Fly.io API calls or machine listings.

  ## Examples

      iex> machines = [%{"region" => "sjc"}, %{"region" => "fra"}]
      iex> FlyMapEx.Adapters.from_machines(machines)
      ["sjc", "fra"]

      iex> machines = [%{region: "sjc"}, %{region: "fra"}]
      iex> FlyMapEx.Adapters.from_machines(machines, :region)
      ["sjc", "fra"]
  """
  def from_machines(machines, region_key \\ "region")

  def from_machines(machines, region_key) when is_list(machines) do
    machines
    |> Enum.map(&get_region_from_map(&1, region_key))
    |> Enum.reject(&(&1 in ["unknown", "", nil]))
    |> Enum.uniq()
  end

  def from_machines(_, _), do: []

  @doc """
  Extract regions from a list of acknowledgment or response data.

  Useful for tracking which regions have responded to requests or acknowledged
  messages in distributed systems.

  ## Examples

      iex> acks = [%{node_id: "machine-sjc-1", status: :ok}, %{node_id: "machine-fra-2", status: :ok}]
      iex> FlyMapEx.Adapters.from_acknowledgments(acks, :node_id)
      ["sjc", "fra"]
  """
  def from_acknowledgments(acks, node_id_key \\ :node_id)

  def from_acknowledgments(acks, node_id_key) when is_list(acks) do
    acks
    |> Enum.map(&get_region_from_map(&1, node_id_key))
    |> Enum.map(&extract_region_from_node_id/1)
    |> Enum.reject(&(&1 in ["unknown", "", nil]))
    |> Enum.uniq()
  end

  def from_acknowledgments(_, _), do: []

  @doc """
  Create region lists for common deployment patterns.

  Returns a map with different region categories for typical multi-region
  deployment scenarios.

  ## Examples

      iex> deployment = %{
      ...>   local_region: "sjc",
      ...>   all_regions: ["sjc", "fra", "ams"],
      ...>   healthy_regions: ["sjc", "fra"]
      ...> }
      iex> FlyMapEx.Adapters.deployment_regions(deployment)
      %{
        our_regions: ["sjc"],
        active_regions: ["fra"],
        expected_regions: ["fra", "ams"],
        ack_regions: []
      }
  """
  def deployment_regions(deployment) when is_map(deployment) do
    local_region = Map.get(deployment, :local_region)
    all_regions = Map.get(deployment, :all_regions, [])
    healthy_regions = Map.get(deployment, :healthy_regions, [])
    acknowledged_regions = Map.get(deployment, :acknowledged_regions, [])

    # Our regions - just the local region
    our_regions = if local_region, do: [local_region], else: []

    # Active regions - healthy regions excluding our region
    active_regions = Enum.reject(healthy_regions, &(&1 == local_region))

    # Expected regions - all regions excluding our region
    expected_regions = Enum.reject(all_regions, &(&1 == local_region))

    # Acknowledged regions - regions that have acknowledged, excluding our region
    ack_regions = Enum.reject(acknowledged_regions, &(&1 == local_region))

    %{
      our_regions: our_regions,
      active_regions: active_regions,
      expected_regions: expected_regions,
      ack_regions: ack_regions
    }
  end

  def deployment_regions(_), do: %{our_regions: [], active_regions: [], expected_regions: [], ack_regions: []}

  @doc """
  Convert deployment data to region groups format.

  Creates a list of region groups suitable for the new FlyMapEx API.

  ## Examples

      iex> deployment = %{
      ...>   local_region: "sjc",
      ...>   all_regions: ["sjc", "fra", "ams"],
      ...>   healthy_regions: ["sjc", "fra"],
      ...>   acknowledged_regions: ["sjc"]
      ...> }
      iex> FlyMapEx.Adapters.to_region_groups(deployment)
      [
        %{regions: ["sjc"], style_key: :primary, label: "Our Node"},
        %{regions: ["fra"], style_key: :active, label: "Active Regions"},
        %{regions: ["fra", "ams"], style_key: :expected, label: "Expected Regions"},
        %{regions: ["sjc"], style_key: :acknowledged, label: "Acknowledged"}
      ]
  """
  def to_region_groups(deployment) when is_map(deployment) do
    regions_data = deployment_regions(deployment)
    
    [
      %{regions: regions_data.our_regions, style_key: :primary, label: "Our Node"},
      %{regions: regions_data.active_regions, style_key: :active, label: "Active Regions"},
      %{regions: regions_data.expected_regions, style_key: :expected, label: "Expected Regions"},
      %{regions: regions_data.ack_regions, style_key: :acknowledged, label: "Acknowledged"}
    ]
    |> Enum.reject(fn group -> Enum.empty?(group.regions) end)
  end

  def to_region_groups(_), do: []

  @doc """
  Create custom region groups from a specification.

  Allows full customization of region groups with custom style keys and labels.

  ## Examples

      iex> groups_spec = [
      ...>   {["sjc"], :primary, "Primary Deployment"},
      ...>   {["fra", "ams"], :secondary, "Secondary Regions"},
      ...>   {["lhr"], :monitoring, "Monitoring Node"}
      ...> ]
      iex> FlyMapEx.Adapters.create_region_groups(groups_spec)
      [
        %{regions: ["sjc"], style_key: :primary, label: "Primary Deployment"},
        %{regions: ["fra", "ams"], style_key: :secondary, label: "Secondary Regions"},
        %{regions: ["lhr"], style_key: :monitoring, label: "Monitoring Node"}
      ]
  """
  def create_region_groups(groups_spec) when is_list(groups_spec) do
    Enum.map(groups_spec, fn
      {regions, style_key, label} when is_list(regions) ->
        %{regions: regions, style_key: style_key, label: label}
      
      {regions, style_key} when is_list(regions) ->
        %{regions: regions, style_key: style_key}
        
      %{} = group -> group
      
      _ -> %{regions: [], style_key: :unknown, label: "Unknown"}
    end)
    |> Enum.reject(fn group -> Enum.empty?(Map.get(group, :regions, [])) end)
  end

  def create_region_groups(_), do: []

  @doc """
  Filter regions to only include valid Fly.io regions.

  ## Examples

      iex> FlyMapEx.Adapters.filter_valid_regions(["sjc", "invalid", "fra", "unknown"])
      ["sjc", "fra"]
  """
  def filter_valid_regions(regions) when is_list(regions) do
    Enum.filter(regions, &Regions.valid?/1)
  end

  def filter_valid_regions(_), do: []

  @doc """
  Convert development regions to production equivalents.

  Useful for applications that use generic region names in development
  but need to map to specific Fly.io regions.

  ## Examples

      iex> FlyMapEx.Adapters.normalize_regions(["dev", "local", "test"])
      ["sjc", "sjc", "sjc"]  # All map to San Jose by default

      iex> FlyMapEx.Adapters.normalize_regions(["dev"], %{"dev" => "fra"})
      ["fra"]
  """
  def normalize_regions(regions, mapping \\ %{})

  def normalize_regions(regions, mapping) when is_list(regions) do
    default_mapping = %{
      "dev" => "sjc",
      "local" => "sjc",
      "test" => "sjc",
      "development" => "sjc",
      "localhost" => "sjc"
    }

    full_mapping = Map.merge(default_mapping, mapping)

    regions
    |> Enum.map(&(Map.get(full_mapping, &1, &1)))
    |> filter_valid_regions()
  end

  def normalize_regions(_, _), do: []

  # Private helper functions

  defp extract_region_from_node_id(node_id) when is_binary(node_id) do
    # Common patterns for Fly.io machine IDs and hostnames
    cond do
      # Pattern: machine-1-sjc, app-sjc-1234, etc.
      String.contains?(node_id, "-") ->
        node_id
        |> String.split("-")
        |> Enum.find(&Regions.valid?/1)
        |> case do
          nil -> "unknown"
          region -> region
        end

      # Pattern: sjc1, fra2, etc. (region + number)
      String.length(node_id) > 3 ->
        potential_region = String.slice(node_id, 0, 3)
        if Regions.valid?(potential_region), do: potential_region, else: "unknown"

      # Direct region code
      Regions.valid?(node_id) -> node_id

      # Unknown pattern
      true -> "unknown"
    end
  end

  defp extract_region_from_node_id(_), do: "unknown"

  defp get_region_from_map(map, key) when is_map(map) do
    # Try both string and atom keys
    Map.get(map, key) || Map.get(map, to_string(key)) || "unknown"
  end

  defp get_region_from_map(_, _), do: "unknown"
end
