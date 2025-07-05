defmodule FlyMapEx.Nodes do
  @moduledoc """
  Utilities for working with generic nodes that have coordinates and labels.

  This module provides functions for node normalization, coordinate transformation,
  and validation. It supports both Fly.io region codes and custom node definitions,
  ensuring consistent data structures throughout the FlyMapEx system.

  ## Features

  - **Node normalization**: Convert various input formats to standard node structure
  - **Fly.io integration**: Built-in support for Fly.io region codes
  - **Custom nodes**: Support for arbitrary geographic locations
  - **Error handling**: Comprehensive validation with clear error messages
  - **Backward compatibility**: Legacy functions for existing integrations
  - **Coordinate validation**: Ensures valid latitude/longitude values

  ## Node Structure

  All nodes are normalized to a consistent structure:

      %{
        label: "Display Name",           # Human-readable label
        coordinates: {latitude, longitude}  # WGS84 coordinates
      }

  ## Input Formats

  The module accepts various input formats and normalizes them:

  ### Fly.io Region Codes

      # Simple region code string
      "sjc"  # San Jose, California
      "fra"  # Frankfurt, Germany
      "lhr"  # London Heathrow, UK

  ### Custom Node Maps

      # Full node specification
      %{
        label: "Custom Server",
        coordinates: {40.7128, -74.0060}  # New York City
      }

      # Coordinates only (label will be generated)
      %{
        coordinates: {51.5074, -0.1278}  # London
      }

  ## Usage Examples

  ### Processing Marker Groups

      # Process a marker group with mixed node types
      marker_group = %{
        label: "Production Servers",
        nodes: [
          "sjc",                                    # Fly.io region
          "fra",                                    # Fly.io region
          %{label: "Custom", coordinates: {40.0, -74.0}}  # Custom node
        ]
      }

      case FlyMapEx.Nodes.process_marker_group(marker_group) do
        {:ok, processed_group} ->
          # All nodes normalized successfully
          render_map(processed_group)
        
        {:error, reasons} ->
          # Handle validation errors
          handle_errors(reasons)
      end

  ### Individual Node Processing

      # Process Fly.io region
      {:ok, node} = FlyMapEx.Nodes.normalize_node("sjc")
      # => {:ok, %{label: "San Jose", coordinates: {37.3382, -121.8863}}}

      # Process custom node
      {:ok, node} = FlyMapEx.Nodes.normalize_node(%{
        label: "Data Center",
        coordinates: {52.5200, 13.4050}
      })

  ### Error Handling

      # Invalid region code
      {:error, :unknown_region} = FlyMapEx.Nodes.normalize_node("invalid")

      # Invalid coordinates
      {:error, :invalid_coordinates} = FlyMapEx.Nodes.normalize_node(%{
        coordinates: "not a tuple"
      })

  ## Coordinate System

  All coordinates use the WGS84 coordinate system:
  - **Latitude**: -90 to 90 degrees (South to North)
  - **Longitude**: -180 to 180 degrees (West to East)
  - **Format**: `{latitude, longitude}` tuple of numbers

  ## Legacy Support

  The module provides legacy functions for backward compatibility:
  - `process_marker_group_legacy/1`: Uses fallback coordinates for unknown regions
  - `normalize_node_legacy/1`: Raises exceptions instead of returning error tuples

  These functions are deprecated and should be avoided in new code.

  ## Error Types

  - `:unknown_region`: Fly.io region code not found
  - `:invalid_coordinates`: Malformed coordinate data
  - `:invalid_format`: Input doesn't match any expected format

  ## Performance Considerations

  - Node normalization is performed once during marker group processing
  - Fly.io region lookups are cached for performance
  - Coordinate validation is minimal overhead
  - Legacy functions may have higher error handling costs

  ## Integration

  This module is primarily used by:
  - `FlyMapEx.Component` for marker group processing
  - `FlyMapEx.Components.WorldMap` for coordinate transformation
  - Custom components requiring node normalization
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

  @deprecated "Use process_marker_group/1 instead for better error handling"
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
        label =
          case Regions.name(node) do
            {:ok, name} -> name
            {:error, _} -> node
          end

        {:ok, %{label: label, coordinates: {lat, long}}}

      {:error, reason} ->
        {:error, reason}
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

  @deprecated "Use normalize_node/1 instead for better error handling"
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
    case Regions.coordinates(node) do
      {:ok, {lat, long}} ->
        label = case Regions.name(node) do
          {:ok, name} -> name
          {:error, _} -> node
        end
        %{
          label: label,
          coordinates: {lat, long}
        }
      {:error, _} ->
        # Unknown region, place off-screen
        %{
          label: node,
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
