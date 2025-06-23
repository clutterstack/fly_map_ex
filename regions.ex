defmodule FlyMap.Regions do
  @moduledoc """
  Fly.io region data and coordinate mapping utilities.
  
  Provides functions for converting Fly.io region codes to geographic coordinates
  and human-readable names for map display.
  """
  
  @regions %{
    ams: {5, 52},
    iad: {-77, 39},
    atl: {-84, 34},
    bog: {-74, 5},
    bos: {-71, 42},
    otp: {26, 45},
    ord: {-88, 42},
    dfw: {-97, 33},
    den: {-105, 40},
    eze: {-59, -35},
    fra: {9, 50},
    gdl: {-103, 21},
    hkg: {114, 22},
    jnb: {28, -26},
    lhr: {0, 51},
    lax: {-118, 34},
    mad: {-4, 40},
    mia: {-80, 26},
    yul: {-74, 45},
    bom: {73, 19},
    cdg: {3, 49},
    phx: {-112, 33},
    qro: {-100, 21},
    gig: {-43, -23},
    sjc: {-122, 37},
    scl: {-71, -33},
    gru: {-46, -23},
    sea: {-122, 47},
    ewr: {-74, 41},
    sin: {104, 1},
    arn: {18, 60},
    syd: {151, -34},
    nrt: {140, 36},
    yyz: {-80, 44},
    waw: {21, 52}
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
  
      iex> FlyMap.Regions.list()
      ["ams", "iad", "atl", ...]
  """
  def list do
    Map.keys(@regions) |> Enum.map(&Atom.to_string/1)
  end
  
  @doc """
  Returns all region data as a map of {region_code, {longitude, latitude}}.
  
  ## Examples
  
      iex> FlyMap.Regions.all()
      %{ams: {5, 52}, iad: {-77, 39}, ...}
  """
  def all do
    @regions
  end
  
  @doc """
  Get coordinates for a region code.
  
  Returns {longitude, latitude} tuple or handles special cases.
  
  ## Examples
  
      iex> FlyMap.Regions.coordinates("sjc")
      {-122, 37}
      
      iex> FlyMap.Regions.coordinates("dev")
      {-122, 47}  # Seattle for development
      
      iex> FlyMap.Regions.coordinates("unknown")
      {-190, 0}   # Off-screen position
  """
  def coordinates(region) when is_binary(region) do
    try do
      region_atom = String.to_existing_atom(region)
      
      case @regions[region_atom] do
        {long, lat} -> {long, lat}
        nil -> handle_special_region(region)
      end
    rescue
      ArgumentError -> handle_special_region(region)
    end
  end
  
  def coordinates(_), do: handle_special_region("unknown")
  
  @doc """
  Get human-readable name for a region code.
  
  ## Examples
  
      iex> FlyMap.Regions.name("sjc")
      "San Jose"
      
      iex> FlyMap.Regions.name("unknown")
      nil
  """
  def name(region) when is_binary(region) do
    try do
      region_atom = String.to_existing_atom(region)
      @region_names[region_atom]
    rescue
      ArgumentError -> nil
    end
  end
  
  def name(_), do: nil
  
  @doc """
  Get formatted display name for a list of regions.
  
  ## Examples
  
      iex> FlyMap.Regions.display_name(["sjc"])
      "San Jose"
      
      iex> FlyMap.Regions.display_name([])
      "your computer"
      
      iex> FlyMap.Regions.display_name(["sjc", "fra"])
      "sjc, fra"
  """
  def display_name([region]) when is_binary(region) do
    case name(region) do
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
  
      iex> FlyMap.Regions.valid?("sjc")
      true
      
      iex> FlyMap.Regions.valid?("invalid")
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
end