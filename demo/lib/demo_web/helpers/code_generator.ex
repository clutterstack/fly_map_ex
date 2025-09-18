defmodule DemoWeb.Helpers.CodeGenerator do
  @moduledoc """
  Shared code generation utilities for all LiveViews that need to display
  FlyMapEx code examples alongside rendered maps.

  Ensures perfect coupling between displayed code and executed code by using
  a single source of truth approach.
  """

  @doc """
  Generate HEEx template code for a given marker_groups configuration.

  Returns the complete <FlyMapEx.node_map> call as a string that can be:
  1. Displayed in code panels
  2. Evaluated to get marker_groups data for rendering

  ## Options

  * `:theme` - Theme atom to include (default: :responsive)
  * `:layout` - Layout atom to include (default: :side_by_side)
  * `:context` - Context string for comment (default: "Configuration")
  * `:format` - Output format :heex, :elixir, or :json (default: :heex)
  * `:code_comment` - Additional comment to include in generated code (default: nil)
  """
  def generate_flymap_code(marker_groups, opts \\ []) do
    theme = Keyword.get(opts, :theme, :responsive)
    layout = Keyword.get(opts, :layout, :side_by_side)
    format = Keyword.get(opts, :format, :heex)
    code_comment = Keyword.get(opts, :code_comment, nil)

    case format do
      :heex -> generate_heex_template(marker_groups, theme, layout, code_comment)
      :elixir -> generate_elixir_module(marker_groups, theme, layout, code_comment)
      :json -> generate_json_config(marker_groups, theme, layout, code_comment)
      _ -> generate_heex_template(marker_groups, theme, layout, code_comment)
    end
  end

  @doc """
  Generate just the marker_groups data structure as a code string.

  This can be evaluated to get the actual marker_groups list.
  """
  def generate_marker_groups_code(marker_groups) do
    # Use the existing MapWithCodeComponent logic which handles __source__ correctly
    {_map_attrs, full_code} =
      DemoWeb.Components.MapWithCodeComponent.build_map_and_code(%{
        marker_groups: marker_groups,
        theme: nil
      })

    # Handle case where marker_groups is nil (no variable declaration)
    if full_code == "<FlyMapEx.node_map />" do
      # Return empty list for display purposes
      "[]"
    else
      # Extract just the marker_groups part
      [marker_groups_line | _rest] = String.split(full_code, "\n\n")

      marker_groups_line
      |> String.trim_leading("marker_groups = ")
    end
  end

  @doc """
  Evaluate a marker_groups code string to get the actual data structure.
  """
  def evaluate_marker_groups_code(code_string) do
    try do
      {result, _} = Code.eval_string(String.trim(code_string))
      result
    rescue
      _ -> []
    end
  end


  def generate_heex_template(marker_groups, theme, layout, code_comment) do
    marker_groups_code = generate_marker_groups_code(marker_groups)
    guide_comment = ""
    # Add additional code comment if provided
    comment =
      if code_comment do
        commentify(code_comment)
      else
        guide_comment
      end

    # Build attribute lines conditionally
    attr_lines = []

    # Only include marker_groups if not nil and not empty
    attr_lines =
      if marker_groups != nil and marker_groups != [] do
        attr_lines ++ ["  marker_groups={#{marker_groups_code}}"]
      else
        attr_lines
      end

    # Only include theme if it's not the default or empty
    attr_lines =
      if theme && theme != :responsive && theme != "" do
        attr_lines ++ ["  theme={:#{theme}}"]
      else
        attr_lines
      end

    # Only include layout if it's not the default or empty
    attr_lines =
      if layout && layout != :side_by_side && layout != "" do
        attr_lines ++ ["  layout={:#{layout}}"]
      else
        attr_lines
      end

    # Create minimal render call if no attributes
    render_call =
      if attr_lines == [] do
        "<FlyMapEx.node_map />"
      else
        "<FlyMapEx.node_map\n#{Enum.join(attr_lines, "\n")}\n/>"
      end

    # usage_note = "# Add this to your LiveView template\n# Remember to import FlyMapEx in your view module"

    "#{comment}\n\n#{render_call}"
  end

  defp generate_elixir_module(marker_groups, theme, layout, context, code_comment \\ nil) do
    marker_groups_code = generate_marker_groups_code(marker_groups)
    context_lower = String.downcase(context)

    # Build attribute lines conditionally
    attr_lines = ["      marker_groups={#{context_lower}_map_groups()}"]

    # Only include theme if it's not the default or empty
    attr_lines =
      if theme && theme != :responsive && theme != "" do
        attr_lines ++ ["      theme={:#{theme}}"]
      else
        attr_lines
      end

    # Only include layout if it's not the default or empty
    attr_lines =
      if layout && layout != :side_by_side && layout != "" do
        attr_lines ++ ["      layout={:#{layout}}"]
      else
        attr_lines
      end

    # Build module comment with optional code comment
    module_comment =
      if code_comment do
        "# #{String.capitalize(context)} Map Module\n# #{code_comment}"
      else
        "# #{String.capitalize(context)} Map Module"
      end

    lines = [
      module_comment,
      "defmodule YourApp.MapConfigs do",
      "  @moduledoc \"Centralized map configurations for #{context} displays\"",
      "",
      "  def #{context_lower}_map_groups do",
      "    #{marker_groups_code}",
      "  end",
      "",
      "  def render_#{context_lower}_map(assigns) do",
      "    ~H\"\"\"",
      "    <FlyMapEx.node_map",
      "#{Enum.join(attr_lines, "\n")}",
      "    />",
      "    \"\"\"",
      "  end",
      "end",
      "",
      "# Usage in your LiveView:",
      "# import YourApp.MapConfigs",
      "# <.render_#{context_lower}_map />"
    ]

    Enum.join(lines, "\n")
  end

  defp generate_json_config(marker_groups, theme, layout, context, code_comment \\ nil) do
    # Convert marker_groups to JSON representation
    json_groups =
      try do
        marker_groups
        |> Enum.map(fn group ->
          nodes_json = group.nodes |> Enum.map(&"\"#{&1}\"") |> Enum.join(", ")
          style_name = get_style_name(group.style)

          "    {\n      \"nodes\": [#{nodes_json}],\n      \"style\": \"#{style_name}\",\n      \"label\": \"#{group.label}\"\n    }"
        end)
        |> Enum.join(",\n")
      rescue
        _ -> "    // Error parsing groups"
      end

    # Build JSON with optional code comment
    json_comment =
      if code_comment do
        "  \"comment\": \"#{code_comment}\","
      else
        ""
      end

    lines = [
      "{",
      "  \"name\": \"#{String.capitalize(context)} Map Configuration\",",
      json_comment,
      "  \"theme\": \"#{theme}\",",
      "  \"layout\": \"#{layout}\",",
      "  \"marker_groups\": [",
      json_groups,
      "  ]",
      "}",
      "",
      "# Use with a JSON loader function:",
      "# def load_config(config_name) do",
      "#   config = Jason.decode!(File.read!(\"configs/\" <> config_name <> \".json\"))",
      "#   # Transform JSON to Elixir structures",
      "# end"
    ]

    lines
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n")
  end

  # Helper to extract style name from style map
  defp get_style_name(style) do
    case style do
      %{__source__: {name, _, _}} -> Atom.to_string(name)
      _ -> "operational"
    end
  end

  # Helper to prepend `# ` to each line in the given string.
  defp commentify(string) when is_binary(string) do
    string
    |> String.split("\n", trim: false)
    |> Enum.map(&("# " <> &1))
    |> Enum.join("\n")
  end
end
