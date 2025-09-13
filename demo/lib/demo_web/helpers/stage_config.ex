defmodule DemoWeb.Helpers.StageConfig do
  @moduledoc """
  Configuration helpers and validation for stage components.

  This module provides utilities for validating tab configurations,
  normalizing example data, and managing stage-specific settings.
  """

  @doc """
  Validates and normalizes tab configuration.
  """
  def validate_tabs(tabs) when is_list(tabs) do
    Enum.map(tabs, &validate_tab/1)
  end

  def validate_tabs(_), do: []

  @doc """
  Validates a single tab configuration.
  """
  def validate_tab(%{key: key, label: label, content: content} = tab)
      when is_binary(key) and is_binary(label) and is_binary(content) do
    tab
  end

  def validate_tab(tab) do
    %{
      key: Map.get(tab, :key, "unknown"),
      label: Map.get(tab, :label, "Unknown"),
      content: Map.get(tab, :content, "")
    }
  end

  @doc """
  Validates and normalizes example configuration.
  """
  def validate_examples(examples) when is_map(examples) do
    examples
    |> Enum.into(%{}, fn {key, value} ->
      {normalize_key(key), validate_example_value(value)}
    end)
  end

  def validate_examples(_), do: %{}

  @doc """
  Creates default tab configuration for common stage patterns.
  """
  def default_tabs(type) do
    case type do
      :basic ->
        [
          %{key: "intro", label: "Introduction", content: ""},
          %{key: "example", label: "Example", content: ""},
          %{key: "advanced", label: "Advanced", content: ""}
        ]

      :styling ->
        [
          %{key: "automatic", label: "Automatic", content: ""},
          %{key: "semantic", label: "Semantic", content: ""},
          %{key: "custom", label: "Custom", content: ""},
          %{key: "mixed", label: "Mixed", content: ""}
        ]

      :theming ->
        [
          %{key: "light", label: "Light Theme", content: ""},
          %{key: "dark", label: "Dark Theme", content: ""},
          %{key: "responsive", label: "Responsive", content: ""},
          %{key: "custom", label: "Custom Theme", content: ""}
        ]

      :layout ->
        [
          %{key: "side_by_side", label: "Side by Side", content: ""},
          %{key: "stacked", label: "Stacked", content: ""},
          %{key: "map_only", label: "Map Only", content: ""},
          %{key: "legend_only", label: "Legend Only", content: ""}
        ]

      _ ->
        default_tabs(:basic)
    end
  end

  @doc """
  Creates default navigation configuration for stages.
  """
  def stage_navigation(current_stage) do
    stages = [:stage1, :stage2, :stage3, :stage4]
    current_index = Enum.find_index(stages, &(&1 == current_stage))

    prev_stage =
      if current_index && current_index > 0 do
        Enum.at(stages, current_index - 1)
      else
        nil
      end

    next_stage =
      if current_index && current_index < length(stages) - 1 do
        Enum.at(stages, current_index + 1)
      else
        nil
      end

    %{prev: prev_stage, next: next_stage}
  end

  @doc """
  Validates marker group structure.
  """
  def validate_marker_group(%{nodes: nodes, label: label} = group)
      when is_list(nodes) and is_binary(label) do
    validated_nodes = Enum.filter(nodes, &valid_node?/1)
    Map.put(group, :nodes, validated_nodes)
  end

  def validate_marker_group(group) do
    %{
      nodes: [],
      label: Map.get(group, :label, "Unknown Group"),
      style: Map.get(group, :style, :operational)
    }
  end

  @doc """
  Validates marker groups list.
  """
  def validate_marker_groups(groups) when is_list(groups) do
    Enum.map(groups, &validate_marker_group/1)
  end

  def validate_marker_groups(_), do: []

  @doc """
  Merges multiple example configurations.
  """
  def merge_examples(example_configs) when is_list(example_configs) do
    Enum.reduce(example_configs, %{}, &Map.merge(&2, &1))
  end

  def merge_examples(_), do: %{}

  @doc """
  Gets the first available example key from a configuration.
  """
  def first_example_key(examples) when is_map(examples) do
    case Map.keys(examples) do
      [first | _] -> to_string(first)
      [] -> "unknown"
    end
  end

  def first_example_key(_), do: "unknown"

  @doc """
  Normalizes stage configuration for consistency.
  """
  def normalize_stage_config(config) do
    %{
      title: Map.get(config, :title, "Unknown Stage"),
      description: Map.get(config, :description, ""),
      examples: validate_examples(Map.get(config, :examples, %{})),
      tabs: validate_tabs(Map.get(config, :tabs, [])),
      navigation: Map.get(config, :navigation, %{prev: nil, next: nil}),
      default_example: Map.get(config, :default_example, "unknown")
    }
  end

  # Private helper functions

  defp normalize_key(key) when is_atom(key), do: key
  defp normalize_key(key) when is_binary(key), do: String.to_atom(key)
  defp normalize_key(_), do: :unknown

  defp validate_example_value(value) when is_list(value) do
    Enum.map(value, &validate_marker_group/1)
  end

  defp validate_example_value(value), do: [validate_marker_group(value)]

  defp valid_node?(node) when is_binary(node) do
    # Validate region code (3-letter string)
    String.length(node) == 3 and String.match?(node, ~r/^[a-z]{3}$/)
  end

  defp valid_node?({lat, lng}) when is_number(lat) and is_number(lng) do
    # Validate coordinate tuple ranges
    lat >= -90 and lat <= 90 and lng >= -180 and lng <= 180
  end

  defp valid_node?(%{region: region, label: label})
       when is_binary(region) and is_binary(label) do
    # Validate custom region label format
    String.length(region) == 3 and String.match?(region, ~r/^[a-z]{3}$/)
  end

  defp valid_node?(%{coordinates: {lat, lng}} = _node)
       when is_number(lat) and is_number(lng) do
    # Validate coordinate ranges in map format (legacy)
    lat >= -90 and lat <= 90 and lng >= -180 and lng <= 180
  end

  defp valid_node?(_), do: false
end
