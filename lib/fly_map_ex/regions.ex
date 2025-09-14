defmodule FlyMapEx.Regions do
  @moduledoc """
  Fly.io region data and coordinate mapping utilities.

  Provides functions for converting Fly.io region codes to geographic coordinates
  and human-readable names for map display.

  ## Custom Regions

  You can define custom regions in your application configuration:

      config :fly_map_ex, :custom_regions, %{
        "dev" => %{name: "Development", coordinates: {47.6062, -122.3321}},
        "laptop-chris" => %{name: "Chris's Laptop", coordinates: {49.2827, -123.1207}},
        "office-nyc" => %{name: "NYC Office", coordinates: {40.7128, -74.0060}}
      }

  Custom regions will be merged with built-in Fly.io regions, with custom regions
  taking precedence if there are naming conflicts.
  """

  @regions %{
    ams: {52, 5},
    iad: {39, -77},
    atl: {34, -84},
    bog: {5, -74},
    bos: {42, -71},
    otp: {45, 26},
    ord: {42, -88},
    dfw: {33, -97},
    den: {40, -105},
    eze: {-35, -59},
    fra: {50, 9},
    gdl: {21, -103},
    hkg: {22, 114},
    jnb: {-26, 28},
    lhr: {51, 0},
    lax: {34, -118},
    mad: {40, -4},
    mia: {26, -80},
    yul: {45, -74},
    bom: {19, 73},
    cdg: {49, 3},
    phx: {33, -112},
    qro: {21, -100},
    gig: {-23, -43},
    sjc: {37, -122},
    scl: {-33, -71},
    gru: {-23, -46},
    sea: {47, -122},
    ewr: {41, -74},
    sin: {1, 104},
    arn: {60, 18},
    syd: {-34, 151},
    nrt: {36, 140},
    yyz: {44, -80},
    waw: {52, 21}
  }

  @region_names %{
    ams: "Amsterdam",
    iad: "Ashburn",
    atl: "Atlanta",
    bog: "Bogotá",
    bos: "Boston",
    otp: "Bucharest",
    ord: "Chicago",
    dfw: "Dallas",
    den: "Denver",
    eze: "Ezeiza",
    fra: "Frankfurt",
    gdl: "Guadalajara",
    hkg: "Hong Kong",
    jnb: "Johannesburg",
    lhr: "London",
    lax: "Los Angeles",
    mad: "Madrid",
    mia: "Miami",
    yul: "Montreal",
    bom: "Mumbai",
    cdg: "Paris",
    phx: "Phoenix",
    qro: "Querétaro",
    gig: "Rio de Janeiro",
    sjc: "San Jose",
    scl: "Santiago",
    gru: "Sao Paulo",
    sea: "Seattle",
    ewr: "Secaucus",
    sin: "Singapore",
    arn: "Stockholm",
    syd: "Sydney",
    nrt: "Tokyo",
    yyz: "Toronto",
    waw: "Warsaw"
  }

  @doc """
  Returns all available region codes as strings, including custom regions.

  ## Examples

      iex> FlyMapEx.Regions.list()
      ["ams", "iad", "atl", "dev", "laptop-chris", ...]
  """
  def list do
    built_in = Map.keys(@regions) |> Enum.map(&Atom.to_string/1)
    custom = Map.keys(get_custom_regions())
    Enum.uniq(built_in ++ custom)
  end

  @doc """
  Returns all region data as a map of {region_code, {longitude, latitude}}.
  Includes both built-in Fly.io regions and custom regions from configuration.

  ## Examples

      iex> FlyMapEx.Regions.all()
      %{ams: {5, 52}, iad: {-77, 39}, "dev" => {47.6062, -122.3321}, ...}
  """
  def all do
    custom_regions =
      get_custom_regions()
      |> Enum.map(fn {key, %{coordinates: coords}} -> {key, coords} end)
      |> Map.new()

    built_in_as_strings =
      @regions
      |> Enum.map(fn {key, coords} -> {Atom.to_string(key), coords} end)
      |> Map.new()

    Map.merge(built_in_as_strings, custom_regions)
  end

  @doc """
  Get coordinates for a region code with error handling.

  Returns {:ok, {longitude, latitude}} for valid regions or {:error, reason} for failures.

  ## Examples

      iex> FlyMapEx.Regions.coordinates("sjc")
      {:ok, {-122, 37}}

      iex> FlyMapEx.Regions.coordinates("dev")
      {:ok, {-122, 47}}  # Seattle for development

      iex> FlyMapEx.Regions.coordinates("unknown")
      {:error, :unknown_region}

      iex> FlyMapEx.Regions.coordinates(123)
      {:error, :invalid_input}
  """
  def coordinates(region) when is_binary(region) do
    # First check custom regions
    case get_custom_regions()[region] do
      %{coordinates: {lat, long}} ->
        {:ok, {lat, long}}

      nil ->
        # Then check built-in Fly.io regions
        try do
          region_atom = String.to_existing_atom(region)

          case @regions[region_atom] do
            {lat, long} -> {:ok, {lat, long}}
            nil -> {:error, :unknown_region}
          end
        rescue
          ArgumentError -> {:error, :unknown_region}
        end
    end
  end

  def coordinates(_), do: {:error, :invalid_input}

  def name(region) when is_binary(region) do
    # First check custom regions
    case get_custom_regions()[region] do
      %{name: name} ->
        {:ok, name}

      nil ->
        # Then check built-in Fly.io regions
        try do
          region_atom = String.to_existing_atom(region)

          case @region_names[region_atom] do
            nil -> {:error, :unknown_region}
            name -> {:ok, name}
          end
        rescue
          ArgumentError -> {:error, :unknown_region}
        end
    end
  end

  def name(_), do: {:error, :invalid_input}

  @doc """
  Validate if a region code is a known Fly.io region.

  ## Examples

      iex> FlyMapEx.Regions.valid?("sjc")
      true

      iex> FlyMapEx.Regions.valid?("invalid")
      false
  """
  def valid?(region) when is_binary(region) do
    # Check custom regions first
    Map.has_key?(get_custom_regions(), region) or
      # Then check built-in regions
      region in (Map.keys(@regions) |> Enum.map(&Atom.to_string/1))
  end

  def valid?(_), do: false

  # Private functions

  # Get custom regions from application configuration
  defp get_custom_regions do
    Application.get_env(:fly_map_ex, :custom_regions, %{})
  end
end
