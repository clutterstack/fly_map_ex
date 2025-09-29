defmodule FlyMapEx.Shared do
  @moduledoc """
  Shared logic for FlyMapEx components.

  This module contains data processing functions and utilities that are shared
  between the interactive LiveComponent and static Component implementations.
  """

  alias FlyMapEx.{Style, Nodes}

  @doc """
  Normalizes marker groups with style and node processing.

  This function processes a list of marker groups, ensuring each has proper
  style definitions and normalized node data. It handles both explicit styles
  and automatic style cycling for groups without styles.

  ## Parameters

  - `marker_groups`: List of marker group maps

  ## Returns

  List of normalized marker groups with processed styles and nodes
  """
  def normalize_marker_groups(marker_groups) when is_list(marker_groups) do
    # First pass: normalize each group with initial labels
    initial_groups =
      marker_groups
      |> Enum.with_index()
      |> Enum.map(fn {group, index} -> normalize_marker_group(group, index) end)

    # Second pass: ensure unique group_labels for toggle functionality
    ensure_unique_group_labels(initial_groups)
  end

  @doc """
  Determines which groups should be initially visible based on the configuration.

  ## Parameters

  - `marker_groups`: List of normalized marker groups
  - `initially_visible`: Configuration for initial visibility
    - `:all` - All groups visible
    - `:none` - No groups visible
    - List of group labels - Only specified groups visible

  ## Returns

  List of group labels that should be initially visible
  """
  def determine_initial_selection(marker_groups, :all) do
    # Select all groups that have a group_label
    marker_groups
    |> Enum.filter(&Map.has_key?(&1, :group_label))
    |> Enum.map(& &1.group_label)
  end

  def determine_initial_selection(_marker_groups, :none), do: []

  def determine_initial_selection(_marker_groups, labels) when is_list(labels), do: labels

  @doc """
  Filters marker groups to only include those that are currently visible.

  ## Parameters

  - `marker_groups`: List of all marker groups
  - `selected_groups`: List of group labels that should be visible

  ## Returns

  List of marker groups that should be displayed
  """
  def filter_visible_groups(marker_groups, selected_groups) when is_list(selected_groups) do
    # Only show groups that are selected (have group_label in selected_groups)
    # If selected_groups is empty, no groups will be visible
    Enum.filter(marker_groups, fn group ->
      case Map.get(group, :group_label) do
        # Groups without group_label are always shown
        nil -> true
        group_label -> group_label in selected_groups
      end
    end)
  end

  def filter_visible_groups(marker_groups, _), do: marker_groups

  @doc """
  Returns the appropriate CSS class for the layout container.

  ## Parameters

  - `layout`: Layout mode (`:side_by_side` or other)

  ## Returns

  String with appropriate CSS classes
  """
  def layout_container_class(:side_by_side), do: "fly-map-layout-side-by-side"

  def layout_container_class(_), do: "fly-map-layout-stacked"

  @doc """
  Returns the appropriate CSS class for the map container.

  ## Parameters

  - `layout`: Layout mode (`:side_by_side` or other)

  ## Returns

  String with appropriate CSS classes
  """
  def map_container_class(_), do: "fly-map-map-container"

  @doc """
  Returns the appropriate CSS class for the legend container.

  ## Parameters

  - `layout`: Layout mode (`:side_by_side` or other)

  ## Returns

  String with appropriate CSS classes
  """
  def legend_container_class(_), do: "fly-map-legend-container"

  # Private functions

  defp normalize_marker_group(%{style: style} = group, _index) when not is_nil(style) do
    # Normalize the style and process nodes
    normalized_style = Style.normalize(style)
    group = Map.put(group, :style, normalized_style)

    # Add group_label from label if not already present (for toggle functionality)
    group = add_group_label_if_needed(group)

    if Map.has_key?(group, :nodes) do
      case Nodes.process_marker_group(group) do
        {:ok, processed_group} -> processed_group
        processed_group -> processed_group
      end
    else
      group
    end
  end

  defp normalize_marker_group(group, index) do
    # No style specified - automatically assign using Style.cycle/1
    cycled_style = Style.cycle(index)
    group = Map.put(group, :style, cycled_style)

    # Add group_label from label if not already present (for toggle functionality)
    group = add_group_label_if_needed(group)

    if Map.has_key?(group, :nodes) do
      case Nodes.process_marker_group(group) do
        {:ok, processed_group} -> processed_group
        processed_group -> processed_group
      end
    else
      group
    end
  end

  # Helper function to add group_label from label if not already present
  defp add_group_label_if_needed(group) do
    if Map.has_key?(group, :group_label) do
      group
    else
      case Map.get(group, :label) do
        nil ->
          # Generate default label if missing
          default_label = generate_default_label(group)
          sanitized_label = sanitize_group_label(default_label)

          group
          |> Map.put(:label, default_label)
          |> Map.put(:group_label, sanitized_label)

        label ->
          # Sanitize the label for use as a group_label in CSS selectors
          sanitized_label = sanitize_group_label(label)
          Map.put(group, :group_label, sanitized_label)
      end
    end
  end

  # Sanitize group_label for use in CSS selectors and DOM attributes
  defp sanitize_group_label(label) when is_binary(label) do
    label
    |> String.replace(~r/[^a-zA-Z0-9_-]/, "_")
    # Replace multiple underscores with single
    |> String.replace(~r/_{2,}/, "_")
    # Remove leading/trailing underscores
    |> String.trim("_")
  end

  defp sanitize_group_label(label), do: to_string(label)

  # Generate default label for groups without explicit labels
  defp generate_default_label(group) do
    cond do
      # If we have nodes, create label based on count
      Map.has_key?(group, :nodes) and not is_nil(Map.get(group, :nodes)) ->
        node_count = length(Map.get(group, :nodes, []))

        case node_count do
          0 -> "Empty Group"
          1 -> "Single Node"
          count -> "#{count} Nodes"
        end

      # If we have a style, use it to generate label
      Map.has_key?(group, :style) ->
        style_name =
          case Map.get(group, :style) do
            atom when is_atom(atom) ->
              atom |> to_string() |> String.replace("_", " ") |> String.capitalize()

            _ ->
              "Styled Group"
          end

        style_name

      # Fallback to generic label
      true ->
        "Marker Group"
    end
  end

  # Ensure all groups have unique group_labels for proper toggle functionality
  defp ensure_unique_group_labels(groups) do
    # Track used labels and their counts
    {final_groups, _label_counts} =
      Enum.reduce(groups, {[], %{}}, fn group, {acc_groups, label_counts} ->
        group_label = Map.get(group, :group_label)

        if group_label do
          # Check if this label has been used before
          count = Map.get(label_counts, group_label, 0)

          {unique_label, updated_counts} =
            if count == 0 do
              # First use of this label
              {group_label, Map.put(label_counts, group_label, 1)}
            else
              # Duplicate label - make it unique
              unique_label = "#{group_label} #{count + 1}"
              {unique_label, Map.put(label_counts, group_label, count + 1)}
            end

          updated_group = Map.put(group, :group_label, unique_label)
          {[updated_group | acc_groups], updated_counts}
        else
          # No group_label, keep as is
          {[group | acc_groups], label_counts}
        end
      end)

    # Return groups in original order
    Enum.reverse(final_groups)
  end
end
