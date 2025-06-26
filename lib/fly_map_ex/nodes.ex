defmodule FlyMapEx.Nodes do
  @moduledoc """
  Utilities for working with generic nodes that have coordinates and labels.
  
  This module provides functions for coordinate transformation, node validation,
  and backward compatibility with Fly.io region codes.
  """

  alias FlyMapEx.Regions

  @doc """
  Transform a list of node groups to include processed coordinates.
  
  Node groups can contain either:
  - Fly.io region codes (strings like "sjc", "fra") - for backward compatibility
  - Node maps with coordinates (%{label: "Server 1", coordinates: {40.7128, -74.0060}})
  
  ## Examples
  
      # Mixed usage - region codes and coordinate nodes
      node_groups = [
        %{
          nodes: ["sjc", "fra"],  # Fly.io regions
          style_key: :primary,
          label: "Legacy Regions"
        },
        %{
          nodes: [
            %{label: "Custom Server", coordinates: {40.7128, -74.0060}},
            %{label: "Another Server", coordinates: {51.5074, -0.1278}}
          ],
          style_key: :secondary,
          label: "Custom Nodes"
        }
      ]
      
      processed = FlyMapEx.Nodes.process_node_groups(node_groups)
  """
  def process_node_groups(node_groups) when is_list(node_groups) do
    Enum.map(node_groups, &process_node_group/1)
  end

  @doc """
  Process a single node group to normalize nodes to coordinate format.
  """
  def process_node_group(%{nodes: nodes} = group) when is_list(nodes) do
    processed_nodes = Enum.map(nodes, &normalize_node/1)
    Map.put(group, :nodes, processed_nodes)
  end

  def process_node_group(group), do: group

  @doc """
  Normalize a node to the standard format with label and coordinates.
  
  ## Examples
  
      # Fly.io region code
      iex> FlyMapEx.Nodes.normalize_node("sjc")
      %{label: "San Jose, California (US)", coordinates: {37.3382, -121.8863}}
      
      # Already normalized node
      iex> FlyMapEx.Nodes.normalize_node(%{label: "Custom", coordinates: {40.0, -74.0}})
      %{label: "Custom", coordinates: {40.0, -74.0}}
  """
  def normalize_node(node) when is_binary(node) do
    # Assume it's a Fly.io region code for backward compatibility
    case Regions.coordinates(node) do
      {lat, lng} ->
        %{
          label: Regions.name(node) || node,
          coordinates: {lat, lng}
        }
      _ ->
        # Unknown region, place off-screen
        %{
          label: node,
          coordinates: {0, -190}  # Off-screen coordinates
        }
    end
  end

  def normalize_node(%{label: label, coordinates: {lat, lng}} = node) 
      when is_binary(label) and is_number(lat) and is_number(lng) do
    # Already in correct format
    node
  end

  def normalize_node(%{coordinates: {lat, lng}} = node) 
      when is_number(lat) and is_number(lng) do
    # Has coordinates but no label
    Map.put(node, :label, "Node at #{lat}, #{lng}")
  end

  def normalize_node(invalid) do
    raise ArgumentError, """
    Invalid node format: #{inspect(invalid)}
    
    Expected either:
    - A Fly.io region code string (e.g., "sjc")
    - A node map with label and coordinates (e.g., %{label: "Server", coordinates: {40.0, -74.0}})
    """
  end

  @doc """
  Extract coordinates from a list of normalized nodes.
  
  ## Examples
  
      nodes = [
        %{label: "Server 1", coordinates: {40.7128, -74.0060}},
        %{label: "Server 2", coordinates: {51.5074, -0.1278}}
      ]
      
      iex> FlyMapEx.Nodes.extract_coordinates(nodes)
      [{40.7128, -74.0060}, {51.5074, -0.1278}]
  """
  def extract_coordinates(nodes) when is_list(nodes) do
    Enum.map(nodes, fn %{coordinates: coords} -> coords end)
  end

  @doc """
  Transform WGS84 coordinates to SVG coordinates.
  
  Takes latitude/longitude coordinates and converts them to SVG pixel coordinates
  based on the provided bounding box.
  
  ## Examples
  
      iex> FlyMapEx.Nodes.wgs84_to_svg({40.7128, -74.0060}, {0, 0, 800, 400})
      {186.64, 151.49}
  """
  def wgs84_to_svg({lat, lng}, {x_min, y_min, x_max, y_max}) do
    svg_width = x_max - x_min
    svg_height = y_max - y_min

    bounds = %{min_lng: -180, max_lng: 180, min_lat: -90, max_lat: 90}

    # Calculate percentage position along each axis
    x_percent = (lng - bounds.min_lng) / (bounds.max_lng - bounds.min_lng)
    # Note the inversion for y-axis since SVG's y increases downward
    y_percent = 1 - (lat - bounds.min_lat) / (bounds.max_lat - bounds.min_lat)

    # Convert to pixel positions
    x = x_percent * svg_width + x_min
    y = y_percent * svg_height + y_min

    {x, y}
  end

  @doc """
  Transform a list of coordinates to SVG coordinates.
  
  ## Examples
  
      coordinates = [{40.7128, -74.0060}, {51.5074, -0.1278}]
      bbox = {0, 0, 800, 400}
      
      iex> FlyMapEx.Nodes.coordinates_to_svg(coordinates, bbox)
      [{186.64, 151.49}, {400.0, 124.44}]
  """
  def coordinates_to_svg(coordinates, bbox) when is_list(coordinates) do
    Enum.map(coordinates, &wgs84_to_svg(&1, bbox))
  end

  @doc """
  Validate node coordinates are within valid ranges.
  
  ## Examples
  
      iex> FlyMapEx.Nodes.validate_coordinates({40.7128, -74.0060})
      :ok
      
      iex> FlyMapEx.Nodes.validate_coordinates({91.0, 0.0})
      {:error, "Latitude must be between -90 and 90"}
  """
  def validate_coordinates({lat, lng}) when is_number(lat) and is_number(lng) do
    cond do
      lat < -90 or lat > 90 ->
        {:error, "Latitude must be between -90 and 90"}
      lng < -180 or lng > 180 ->
        {:error, "Longitude must be between -180 and 180"}
      true ->
        :ok
    end
  end

  def validate_coordinates(_), do: {:error, "Coordinates must be a {latitude, longitude} tuple"}

  @doc """
  Count total nodes across all node groups.
  
  ## Examples
  
      node_groups = [
        %{nodes: [%{label: "A", coordinates: {0, 0}}, %{label: "B", coordinates: {1, 1}}]},
        %{nodes: [%{label: "C", coordinates: {2, 2}}]}
      ]
      
      iex> FlyMapEx.Nodes.total_node_count(node_groups)
      3
  """
  def total_node_count(node_groups) when is_list(node_groups) do
    node_groups
    |> Enum.map(fn group -> length(Map.get(group, :nodes, [])) end)
    |> Enum.sum()
  end
end