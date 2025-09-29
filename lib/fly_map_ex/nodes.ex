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

  ### Coordinate Tuples

      # Direct coordinate tuple (label will be generated)
      {40.7128, -74.0060}  # New York City
      {51.5074, -0.1278}   # London

  ### Custom Region Labels

      # Custom label for Fly.io region
      %{
        label: "My Production Server",
        region: "sjc"  # Uses San Jose coordinates
      }

  ### Custom Node Maps

      # Full node specification with coordinates
      %{
        label: "Custom Server",
        coordinates: {40.7128, -74.0060}  # New York City
      }

      # Coordinates only (label will be generated) - legacy format
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
          {40.0, -74.0},                           # Coordinate tuple
          %{label: "NYC Office", region: "lhr"},   # Custom label for region
          %{label: "Custom", coordinates: {52.0, 13.0}}  # Full custom node
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

      # Process coordinate tuple
      {:ok, node} = FlyMapEx.Nodes.normalize_node({52.5200, 13.4050})
      # => {:ok, %{label: "Node at 52.52, 13.405", coordinates: {52.5200, 13.4050}}}

      # Process custom region label
      {:ok, node} = FlyMapEx.Nodes.normalize_node(%{
        label: "Berlin Office",
        region: "fra"
      })
      # => {:ok, %{label: "Berlin Office", coordinates: {50.1109, 8.6821}}}

      # Process custom node with coordinates
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

      # Invalid region
      {:error, :unknown_region} = FlyMapEx.Nodes.normalize_node(%{
        label: "Custom", region: "invalid"
      })

  ## Coordinate System

  All coordinates use the WGS84 coordinate system:
  - **Latitude**: -90 to 90 degrees (South to North)
  - **Longitude**: -180 to 180 degrees (West to East)
  - **Format**: `{latitude, longitude}` tuple of numbers


  ## Error Types

  - `:unknown_region`: Fly.io region code not found
  - `:invalid_coordinates`: Malformed coordinate data
  - `:invalid_region`: Invalid region in region-based node map
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

  alias FlyMapEx.FlyRegions

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

  Supports four input formats:
  - Region string: `"sjc"` → auto-label from Regions
  - Coordinate tuple: `{lat, lng}` → auto-label from coordinates
  - Custom region label: `%{label: "Name", region: "sjc"}` → custom label with region lookup
  - Custom coordinates: `%{label: "Name", coordinates: {lat, lng}}` → full control

  ## Examples

      # Fly.io region code
      iex> FlyMapEx.Nodes.normalize_node("sjc")
      {:ok, %{label: "San Jose", coordinates: {37, -122}}}

      # Coordinate tuple
      iex> FlyMapEx.Nodes.normalize_node({40.0, -74.0})
      {:ok, %{label: "Node at 40.0, -74.0", coordinates: {40.0, -74.0}}}

      # Custom region label
      iex> FlyMapEx.Nodes.normalize_node(%{label: "Production", region: "sjc"})
      {:ok, %{label: "Production", coordinates: {37, -122}}}

      # Custom coordinates
      iex> FlyMapEx.Nodes.normalize_node(%{label: "Custom", coordinates: {40.0, -74.0}})
      {:ok, %{label: "Custom", coordinates: {40.0, -74.0}}}

      # Error cases
      iex> FlyMapEx.Nodes.normalize_node("invalid_region")
      {:error, :unknown_region}

      iex> FlyMapEx.Nodes.normalize_node(%{coordinates: "invalid"})
      {:error, :invalid_coordinates}
  """
  def normalize_node(node) when is_binary(node) do
    case FlyRegions.coordinates(node) do
      {:ok, {lat, long}} ->
        label =
          case FlyRegions.name(node) do
            {:ok, name} -> name
            {:error, _} -> node
          end

        {:ok, %{label: label, coordinates: {lat, long}}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def normalize_node({lat, long} = _node) when is_number(lat) and is_number(long) do
    {:ok, %{label: "(#{lat}, #{long})", coordinates: {lat, long}}}
  end

  def normalize_node(%{label: label, region: region})
      when is_binary(label) and is_binary(region) do
    case FlyRegions.coordinates(region) do
      {:ok, {lat, long}} ->
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
    {:ok, Map.put(node, :label, "(#{lat}, #{long})")}
  end

  def normalize_node(%{coordinates: _invalid}) do
    {:error, :invalid_coordinates}
  end

  def normalize_node(%{region: _invalid}) do
    {:error, :invalid_region}
  end

  def normalize_node(_invalid) do
    {:error, :invalid_format}
  end
end
