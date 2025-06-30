defmodule FlyMapEx.Nodes do
  @moduledoc """
  Utilities for working with generic nodes that have coordinates and labels.

  This module provides functions for coordinate transformation, node validation,
  and backward compatibility with Fly.io region codes.
  """

  alias FlyMapEx.Regions

  @doc """
  Process a single marker group to normalize nodes to coordinate format.
  
  Returns {:ok, processed_group} or {:error, reason} if any nodes fail to normalize.
  """
  def process_marker_group(%{nodes: nodes} = group) when is_list(nodes) do
    nodes
    |> Enum.map(&normalize_node/1)
    |> collect_results()
    |> case do
      {:ok, processed_nodes} -> {:ok, Map.put(group, :nodes, processed_nodes)}
      {:error, _} = error -> error
    end
  end

  def process_marker_group(group), do: {:ok, group}

  @doc """
  Process a single marker group to normalize nodes (backward compatibility).
  
  Uses legacy error handling that falls back to off-screen coordinates for unknown regions.
  **Deprecated**: Use process_marker_group/1 instead for better error handling.
  """
  def process_marker_group_legacy(%{nodes: nodes} = group) when is_list(nodes) do
    processed_nodes = Enum.map(nodes, &normalize_node_legacy/1)
    Map.put(group, :nodes, processed_nodes)
  end

  def process_marker_group_legacy(group), do: group

  # Helper function to collect results
  defp collect_results(results) do
    {oks, errors} = Enum.split_with(results, &match?({:ok, _}, &1))
    
    case errors do
      [] -> {:ok, Enum.map(oks, fn {:ok, val} -> val end)}
      _ -> {:error, Enum.map(errors, fn {:error, reason} -> reason end)}
    end
  end

  @doc """
  Normalize a node to the standard format with label and coordinates.

  Returns {:ok, normalized_node} for valid input or {:error, reason} for failures.

  ## Examples

      # Fly.io region code
      iex> FlyMapEx.Nodes.normalize_node("sjc")
      {:ok, %{label: "San Jose", coordinates: {37, -122}}}

      # Already normalized node
      iex> FlyMapEx.Nodes.normalize_node(%{label: "Custom", coordinates: {40.0, -74.0}})
      {:ok, %{label: "Custom", coordinates: {40.0, -74.0}}}

      iex> FlyMapEx.Nodes.normalize_node("invalid_region")
      {:error, :unknown_region}

      iex> FlyMapEx.Nodes.normalize_node(%{coordinates: "invalid"})
      {:error, :invalid_coordinates}
  """
  def normalize_node(node) when is_binary(node) do
    case Regions.coordinates(node) do
      {:ok, {lat, long}} ->
        label = case Regions.name(node) do
          {:ok, name} -> name
          {:error, _} -> node
        end
        {:ok, %{label: label, coordinates: {lat, long}}}
      
      {:error, reason} -> {:error, reason}
    end
  end

  def normalize_node(%{label: label, coordinates: {lat, long}} = node)
      when is_binary(label) and is_number(lat) and is_number(long) do
    {:ok, node}
  end

  def normalize_node(%{coordinates: {lat, long}} = node)
      when is_number(lat) and is_number(long) do
    {:ok, Map.put(node, :label, "Node at #{lat}, #{long}")}
  end

  def normalize_node(%{coordinates: _invalid}) do
    {:error, :invalid_coordinates}
  end

  def normalize_node(_invalid) do
    {:error, :invalid_format}
  end

  @doc """
  Normalize a node to the standard format (backward compatibility).

  Returns normalized node map or raises ArgumentError for invalid input.
  **Deprecated**: Use normalize_node/1 instead for better error handling.

  ## Examples

      # Fly.io region code
      iex> FlyMapEx.Nodes.normalize_node_legacy("sjc")
      %{label: "San Jose", coordinates: {37, -122}}

      # Already normalized node
      iex> FlyMapEx.Nodes.normalize_node_legacy(%{label: "Custom", coordinates: {40.0, -74.0}})
      %{label: "Custom", coordinates: {40.0, -74.0}}
  """
  def normalize_node_legacy(node) when is_binary(node) do
    # Assume it's a Fly.io region code for backward compatibility
    case Regions.coordinates_legacy(node) do
      {lat, long} ->
        %{
          label: Regions.name_legacy(node) || node,
          coordinates: {lat, long}
        }

      _ ->
        # Unknown region, place off-screen
        %{
          label: node,
          # Off-screen coordinates
          coordinates: {0, -190}
        }
    end
  end

  def normalize_node_legacy(%{label: label, coordinates: {lat, long}} = node)
      when is_binary(label) and is_number(lat) and is_number(long) do
    # Already in correct format
    node
  end

  def normalize_node_legacy(%{coordinates: {lat, long}} = node)
      when is_number(lat) and is_number(long) do
    # Has coordinates but no label
    Map.put(node, :label, "Node at #{lat}, #{long}")
  end

  def normalize_node_legacy(invalid) do
    raise ArgumentError, """
    Invalid node format: #{inspect(invalid)}

    Expected either:
    - A Fly.io region code string (e.g., "sjc")
    - A node map with label and coordinates (e.g., %{label: "Server", coordinates: {40.0, -74.0}})
    """
  end
end
