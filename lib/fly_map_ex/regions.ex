defmodule FlyMapEx.Regions do
  @moduledoc """
  Fly.io region data and coordinate mapping utilities.

  Provides functions for converting Fly.io region codes to geographic coordinates
  and human-readable names for map display.
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
  Returns all available Fly.io region codes as strings.

  ## Examples

      iex> FlyMapEx.Regions.list()
      ["ams", "iad", "atl", ...]
  """
  def list do
    Map.keys(@regions) |> Enum.map(&Atom.to_string/1)
  end

  @doc """
  Returns all region data as a map of {region_code, {longitude, latitude}}.

  ## Examples

      iex> FlyMapEx.Regions.all()
      %{ams: {5, 52}, iad: {-77, 39}, ...}
  """
  def all do
    @regions
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
    try do
      region_atom = String.to_existing_atom(region)

      case @regions[region_atom] do
        {lat, long} -> {:ok, {lat, long}}
        nil -> handle_special_region_with_error(region)
      end
    rescue
      ArgumentError -> handle_special_region_with_error(region)
    end
  end

  def coordinates(_), do: {:error, :invalid_input}

  @deprecated "Use coordinates/1 instead for better error handling"
  @doc """
  Get coordinates for a region code (backward compatibility).

  Returns {longitude, latitude} tuple or handles special cases with fallback coordinates.
  **Deprecated**: Use coordinates/1 instead for better error handling.

  ## Examples

      iex> FlyMapEx.Regions.coordinates_legacy("sjc")
      {-122, 37}

      iex> FlyMapEx.Regions.coordinates_legacy("unknown")
      {-190, 0}   # Off-screen position
  """
  def coordinates_legacy(region) when is_binary(region) do
    try do
      region_atom = String.to_existing_atom(region)

      case @regions[region_atom] do
        {lat, long} -> {lat, long}
        nil -> handle_special_region(region)
      end
    rescue
      ArgumentError -> handle_special_region(region)
    end
  end

  def coordinates_legacy(_), do: handle_special_region("unknown")

  @doc """
  Get human-readable name for a region code with error handling.

  Returns {:ok, name} for valid regions or {:error, reason} for failures.

  ## Examples

      iex> FlyMapEx.Regions.name("sjc")
      {:ok, "San Jose"}

      iex> FlyMapEx.Regions.name("unknown")
      {:error, :unknown_region}

      iex> FlyMapEx.Regions.name(123)
      {:error, :invalid_input}
  """
  def name(region) when is_binary(region) do
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

  def name(_), do: {:error, :invalid_input}

  @deprecated "Use name/1 instead for better error handling"
  @doc """
  Get human-readable name for a region code (backward compatibility).

  Returns string name or nil for unknown regions.
  **Deprecated**: Use name/1 instead for better error handling.

  ## Examples

      iex> FlyMapEx.Regions.name_legacy("sjc")
      "San Jose"

      iex> FlyMapEx.Regions.name_legacy("unknown")
      nil
  """
  def name_legacy(region) when is_binary(region) do
    try do
      region_atom = String.to_existing_atom(region)
      @region_names[region_atom]
    rescue
      ArgumentError -> nil
    end
  end

  def name_legacy(_), do: nil

  @doc """
  Get formatted display name for a list of regions.

  ## Examples

      iex> FlyMapEx.Regions.display_name(["sjc"])
      "San Jose"

      iex> FlyMapEx.Regions.display_name([])
      "your computer"

      iex> FlyMapEx.Regions.display_name(["sjc", "fra"])
      "sjc, fra"
  """
  def display_name([region]) when is_binary(region) do
    case name_legacy(region) do
      nil -> region
      human_name -> human_name
    end
  end

  def display_name([]) do
    "your computer"
  end

  def display_name(regions) when is_list(regions) do
    Enum.join(regions, ", ")
  end

  def display_name(_), do: "unknown"

  @doc """
  Validate if a region code is a known Fly.io region.

  ## Examples

      iex> FlyMapEx.Regions.valid?("sjc")
      true

      iex> FlyMapEx.Regions.valid?("invalid")
      false
  """
  def valid?(region) when is_binary(region) do
    region in list()
  end

  def valid?(_), do: false

  # Private functions

  # Seattle coordinates for development
  defp handle_special_region("dev"), do: {-122, 47}
  # Off-screen position for unknown regions
  defp handle_special_region("unknown"), do: {-190, 0}
  # Default off-screen for any other case
  defp handle_special_region(_), do: {-190, 0}

  # Error-handling version of special region handling
  defp handle_special_region_with_error("dev"), do: {:ok, {-122, 47}}
  defp handle_special_region_with_error(_), do: {:error, :unknown_region}
end
