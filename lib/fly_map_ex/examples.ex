defmodule FlyMapEx.Examples do
  @moduledoc """
  File-based example loading for FlyMapEx with compile-time validation.

  This module provides functions to load HEEx template examples from the
  `documentation/examples/` directory and validate them at compile time,
  ensuring that displayed code examples exactly match what gets executed.

  ## Usage

  ```elixir
  # Load and validate an example file
  example = FlyMapEx.Examples.validated_example_file("basic_usage/add_markers")

  # Use in content modules
  def get_content("add_markers") do
    %{
      content: [...],
      example: FlyMapEx.Examples.validated_example_file("basic_usage/add_markers")
    }
  end
  ```

  ## Directory Structure

  Examples are organized in subdirectories under `documentation/examples/`:

  ```
  documentation/examples/
  ├── basic_usage/
  │   ├── add_markers.heex
  │   ├── fly_regions.heex
  │   └── custom_regions.heex
  ├── marker_styling/
  │   ├── automatic.heex
  │   ├── semantic.heex
  │   └── custom.heex
  └── theming/
      ├── presets.heex
      └── custom.heex
  ```

  All example files are loaded and validated at compile time.
  """

  @doc """
  Loads and validates a HEEx template file at compile time.

  The function reads the template file, validates all assigns against FlyMapEx
  requirements, and returns a structured representation for both rendering and
  code display.

  Returns a map containing:
  - `:template` - The original template string for code display
  - `:assigns` - Parsed and validated assigns for component rendering
  - `:description` - Generated description based on content

  Compilation fails if:
  - File does not exist
  - Template syntax is invalid
  - Region codes are invalid
  - Coordinate formats are incorrect
  - Required fields are missing
  """
  defmacro validated_example_file(path) do
    # Look for examples directory in current directory first, then parent directory
    # This handles both library root and demo app compilation contexts
    cwd = File.cwd!()

    potential_paths = [
      Path.join([cwd, "documentation", "examples", "#{path}.heex"]),
      Path.join([cwd, "..", "documentation", "examples", "#{path}.heex"])
    ]

    full_path = Enum.find(potential_paths, &File.exists?/1)

    unless full_path do
      raise CompileError, description: "Example file not found. Tried: #{inspect(potential_paths)}"
    end

    heex_string = File.read!(full_path)

    # Parse and validate the template using embedded validation logic
    parsed_assigns = parse_template(heex_string)
    validate_assigns!(parsed_assigns)

    # Return quoted expression for the validated example
    quote do
      %{
        template: unquote(heex_string),
        assigns: unquote(Macro.escape(parsed_assigns)),
        description: unquote(generate_description(parsed_assigns))
      }
    end
  end

  @doc """
  Lists all available example files in the documentation/examples directory.

  Returns a list of example paths relative to the examples directory,
  without the .heex extension.
  """
  def list_examples do
    cwd = File.cwd!()

    potential_dirs = [
      Path.join([cwd, "documentation", "examples"]),
      Path.join([cwd, "..", "documentation", "examples"])
    ]

    examples_dir = Enum.find(potential_dirs, &File.exists?/1)

    if examples_dir do
      examples_dir
      |> File.ls!()
      |> Enum.flat_map(fn subdir ->
        subdir_path = Path.join(examples_dir, subdir)

        if File.dir?(subdir_path) do
          subdir_path
          |> File.ls!()
          |> Enum.filter(&String.ends_with?(&1, ".heex"))
          |> Enum.map(fn file ->
            "#{subdir}/#{Path.rootname(file)}"
          end)
        else
          []
        end
      end)
      |> Enum.sort()
    else
      []
    end
  end

  @doc """
  Reads an example file without validation for use in ExDoc.

  This function is intended for use in module documentation where you need
  the raw template content without compile-time validation.
  """
  def read_example_file(path) do
    cwd = File.cwd!()

    potential_paths = [
      Path.join([cwd, "documentation", "examples", "#{path}.heex"]),
      Path.join([cwd, "..", "documentation", "examples", "#{path}.heex"])
    ]

    full_path = Enum.find(potential_paths, &File.exists?/1)

    if full_path do
      {:ok, File.read!(full_path)}
    else
      {:error, "Example file not found: #{path}.heex"}
    end
  end

  # Helper function to generate descriptions
  defp generate_description(assigns) do
    marker_groups = assigns[:marker_groups] || []
    group_count = length(marker_groups)

    node_count =
      marker_groups
      |> Enum.flat_map(fn group -> group[:nodes] || [] end)
      |> length()

    theme = format_theme_for_description(assigns[:theme] || :responsive)
    layout = assigns[:layout] || :side_by_side

    "Map with #{group_count} group(s), #{node_count} node(s), #{theme} theme, #{layout} layout"
  end

  defp format_theme_for_description(theme) when is_atom(theme), do: theme
  defp format_theme_for_description(theme) when is_map(theme), do: "custom"

  # Template parsing and validation logic (copied from DemoWeb.Content.ValidatedExample)

  def parse_template(template_string) do
    try do
      case parse_template_ast(template_string) do
        {:ok, assigns} -> assigns
        {:error, reason} -> raise CompileError, description: reason
      end
    rescue
      e ->
        raise CompileError, description: "Failed to parse template: #{Exception.message(e)}"
    end
  end

  defp parse_template_ast(template_string) do
    cleaned_template = String.trim(template_string)

    case Regex.run(~r/<FlyMapEx\.render\s*(.*?)\s*\/>/s, cleaned_template) do
      [_, attrs_content] ->
        parse_heex_attributes(attrs_content)

      _ ->
        if String.match?(cleaned_template, ~r/<FlyMapEx\.render\s*\/>/) do
          {:ok, %{}}
        else
          {:error, "Invalid FlyMapEx.render template format"}
        end
    end
  end

  defp parse_heex_attributes(attrs_content) when attrs_content == "" do
    {:ok, %{}}
  end

  defp parse_heex_attributes(attrs_content) do
    attrs_content
    |> String.trim()
    |> parse_individual_attributes()
  end

  defp parse_individual_attributes(attrs_string) do
    attr_names =
      Regex.scan(~r/(\w+)\s*=/, attrs_string)
      |> Enum.map(fn [_, name] -> name end)

    assigns =
      attr_names
      |> Enum.reduce(%{}, fn attr_name, acc ->
        case extract_attribute_value(attrs_string, attr_name) do
          {:ok, value} -> Map.put(acc, String.to_atom(attr_name), value)
          {:error, _} -> acc
        end
      end)

    {:ok, assigns}
  end

  defp extract_attribute_value(attrs_string, attr_name) do
    pattern = ~r/#{Regex.escape(attr_name)}\s*=\s*\{/

    case Regex.run(pattern, attrs_string, return: :index) do
      [{start, length}] ->
        start_pos = start + length - 1

        case extract_balanced_braces(attrs_string, start_pos) do
          {:ok, content} -> evaluate_elixir_expression(content)
          error -> error
        end

      _ ->
        {:error, "Attribute not found"}
    end
  end

  defp extract_balanced_braces(string, start_pos) do
    if String.at(string, start_pos) == "{" do
      extract_balanced_content(string, start_pos + 1, 1, "")
    else
      {:error, "Expected opening brace"}
    end
  end

  defp extract_balanced_content(string, pos, depth, acc) do
    if pos < String.length(string) do
      char = String.at(string, pos)

      case {char, depth} do
        {"}", 1} ->
          {:ok, acc}

        {"}", depth} when depth > 1 ->
          extract_balanced_content(string, pos + 1, depth - 1, acc <> char)

        {"{", depth} ->
          extract_balanced_content(string, pos + 1, depth + 1, acc <> char)

        {char, _} ->
          extract_balanced_content(string, pos + 1, depth, acc <> char)
      end
    else
      {:error, "Unmatched braces"}
    end
  end

  defp evaluate_elixir_expression(expr_string) do
    try do
      {result, _} = Code.eval_string(String.trim(expr_string))
      {:ok, result}
    rescue
      e ->
        {:error, "Invalid Elixir expression: #{Exception.message(e)}"}
    end
  end

  def validate_assigns!(assigns) do
    # Validate marker_groups if present
    if marker_groups = assigns[:marker_groups] do
      validate_marker_groups!(marker_groups)
    end

    # Validate theme if present
    if theme = assigns[:theme] do
      validate_theme!(theme)
    end

    # Validate layout if present
    if layout = assigns[:layout] do
      validate_layout!(layout)
    end

    assigns
  end

  defp validate_marker_groups!(marker_groups) when is_list(marker_groups) do
    marker_groups
    |> Enum.with_index()
    |> Enum.each(fn {group, index} -> validate_group!(group, index) end)
  end

  defp validate_marker_groups!(_) do
    raise CompileError, description: "marker_groups must be a list"
  end

  defp validate_group!(group, index) when is_map(group) do
    nodes = group[:nodes] || group["nodes"]

    unless nodes do
      raise CompileError, description: "Group #{index + 1}: Missing 'nodes' field"
    end

    validate_nodes!(nodes, index)
  end

  defp validate_group!(_, index) do
    raise CompileError, description: "Group #{index + 1}: Must be a map"
  end

  defp validate_nodes!(nodes, group_index) when is_list(nodes) do
    nodes
    |> Enum.with_index()
    |> Enum.each(fn {node, node_index} -> validate_node!(node, group_index, node_index) end)
  end

  defp validate_nodes!(_, group_index) do
    raise CompileError, description: "Group #{group_index + 1}: 'nodes' must be a list"
  end

  defp validate_node!(node, group_index, node_index) when is_binary(node) do
    unless FlyMapEx.FlyRegions.valid?(node) do
      raise CompileError,
        description:
          "Group #{group_index + 1}, Node #{node_index + 1}: '#{node}' is not a valid Fly.io region"
    end
  end

  defp validate_node!(node, group_index, node_index) when is_tuple(node) do
    validate_coordinates!(node, group_index, node_index)
  end

  defp validate_node!(node, group_index, node_index) when is_map(node) do
    unless node[:label] || node["label"] do
      raise CompileError,
        description: "Group #{group_index + 1}, Node #{node_index + 1}: Custom node missing 'label'"
    end

    coordinates = node[:coordinates] || node["coordinates"]

    unless coordinates do
      raise CompileError,
        description:
          "Group #{group_index + 1}, Node #{node_index + 1}: Custom node missing 'coordinates'"
    end

    validate_coordinates!(coordinates, group_index, node_index)
  end

  defp validate_node!(_, group_index, node_index) do
    raise CompileError,
      description:
        "Group #{group_index + 1}, Node #{node_index + 1}: Must be a region string, coordinate tuple, or coordinate map"
  end

  defp validate_coordinates!({lat, lng}, group_index, node_index)
       when is_number(lat) and is_number(lng) do
    unless lat >= -90 and lat <= 90 and lng >= -180 and lng <= 180 do
      raise CompileError,
        description:
          "Group #{group_index + 1}, Node #{node_index + 1}: Invalid coordinates - lat must be -90 to 90, lng -180 to 180"
    end
  end

  defp validate_coordinates!(_, group_index, node_index) do
    raise CompileError,
      description:
        "Group #{group_index + 1}, Node #{node_index + 1}: Coordinates must be {latitude, longitude} tuple"
  end

  defp validate_theme!(theme) when is_atom(theme) do
    valid_themes = [:light, :dark, :minimal, :cool, :warm, :high_contrast, :responsive]

    unless theme in valid_themes do
      raise CompileError,
        description: "Invalid theme: #{theme}. Valid themes: #{inspect(valid_themes)}"
    end
  end

  defp validate_theme!(theme) when is_map(theme) do
    required_keys = [:land, :ocean, :border, :neutral_marker, :neutral_text]
    missing_keys = required_keys -- Map.keys(theme)

    unless missing_keys == [] do
      raise CompileError,
        description: "Custom theme missing keys: #{inspect(missing_keys)}"
    end
  end

  defp validate_theme!(theme) do
    raise CompileError,
      description: "Theme must be an atom or map, got: #{inspect(theme)}"
  end

  defp validate_layout!(layout) when is_atom(layout) do
    valid_layouts = [:side_by_side, :stacked, :map_only, :legend_only]

    unless layout in valid_layouts do
      raise CompileError,
        description: "Invalid layout: #{layout}. Valid layouts: #{inspect(valid_layouts)}"
    end
  end

  defp validate_layout!(layout) do
    raise CompileError,
      description: "Layout must be an atom, got: #{inspect(layout)}"
  end
end
