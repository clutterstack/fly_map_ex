defmodule FlyMapEx.Nodes do
  @moduledoc """
  Utilities for working with generic nodes that have coordinates and labels.

  This module provides functions for coordinate transformation, node validation,
  and backward compatibility with Fly.io region codes.
  """

  alias FlyMapEx.Regions


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
      {lat, long} ->
        %{
          label: Regions.name(node) || node,
          coordinates: {lat, long}
        }
      _ ->
        # Unknown region, place off-screen
        %{
          label: node,
          coordinates: {0, -190}  # Off-screen coordinates
        }
    end
  end

  def normalize_node(%{label: label, coordinates: {lat, long}} = node)
      when is_binary(label) and is_number(lat) and is_number(long) do
    # Already in correct format
    node
  end

  def normalize_node(%{coordinates: {lat, long}} = node)
      when is_number(lat) and is_number(long) do
    # Has coordinates but no label
    Map.put(node, :label, "Node at #{lat}, #{long}")
  end

  def normalize_node(invalid) do
    raise ArgumentError, """
    Invalid node format: #{inspect(invalid)}

    Expected either:
    - A Fly.io region code string (e.g., "sjc")
    - A node map with label and coordinates (e.g., %{label: "Server", coordinates: {40.0, -74.0}})
    """
  end




end
