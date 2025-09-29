defmodule FlyMapEx.Content.ValidatedExample do
  @moduledoc """
  Compile-time validation and parsing for FlyMapEx HEEx template examples.

  This module provides macros and functions to validate complete `<FlyMapEx.render />`
  templates at compile time, ensuring that displayed code examples exactly match
  what gets executed.

  ## Usage

  ```elixir
  defmodule MyContent do
    import DemoWeb.Content.ValidatedExample

    def get_content("example") do
      %{
        content: [...],
        example: validated_template(\"\"\"
          <FlyMapEx.render
            marker_groups={[
              %{nodes: ["fra", "sin"], label: "Production"}
            ]}
            theme={:dark}
          />
        \"\"\")
      }
    end
  end
  ```
  """

  @doc """
  Validates a HEEx template string at compile time and returns a structured
  representation for both rendering and code display.

  The macro parses the template, validates all assigns against FlyMapEx
  requirements, and returns a map containing:
  - `:template` - The original template string for code display
  - `:assigns` - Parsed and validated assigns for component rendering
  - `:description` - Generated description based on content

  Compilation fails if:
  - Template syntax is invalid
  - Region codes are invalid
  - Coordinate formats are incorrect
  - Required fields are missing
  """
  defmacro validated_template(heex_string, opts_ast \\ []) do
    {opts, _binding} = Code.eval_quoted(opts_ast, [], __CALLER__)

    # Parse the HEEx template at compile time
    parsed_assigns = parse_template(heex_string)

    # Validate the parsed assigns
    validate_assigns!(parsed_assigns, opts)

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
  Parses a HEEx template string to extract FlyMapEx.render assigns.

  Returns a map containing all assigns found in the template.
  """
  def parse_template(template_string) do
    # Use a more robust approach - evaluate the template as quoted code
    try do
      # Extract just the attributes from the template by parsing as AST
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
    # Convert the HEEx template to a quoted expression we can analyze
    # This handles multi-line attributes and comments properly
    cleaned_template = String.trim(template_string)

    # Check for invalid # comments in HEEx templates
    if String.contains?(cleaned_template, "#") do
      # Check if # appears in a position that would be a comment
      lines = String.split(cleaned_template, "\n")

      Enum.each(lines, fn line ->
        # Check for lines that start with # (comment pattern)
        if Regex.match?(~r/^\s*#/, line) do
          {:error, "Invalid HEEx syntax: Use <%!-- comment --%> instead of # for comments"}
          |> then(fn {_status, msg} ->
            raise CompileError, description: msg
          end)
        end

        # Check for inline # comments that are not inside strings
        # Look for # that appears after whitespace and is not inside quotes
        if Regex.match?(~r/\s#(?![^"]*"[^"]*$)(?![^']*'[^']*$)/, line) do
          # Additional check: make sure it's not inside a string literal or map
          # Simple heuristic: if there's an uneven number of quotes before the #, it's likely inside a string
          parts_before_hash = String.split(line, "#") |> List.first()
          quote_count = String.graphemes(parts_before_hash) |> Enum.count(&(&1 == "\""))

          # If quote count is even, we're likely not inside a string
          if rem(quote_count, 2) == 0 do
            {:error, "Invalid HEEx syntax: Use <%!-- comment --%> instead of # for comments"}
            |> then(fn {_status, msg} ->
              raise CompileError, description: msg
            end)
          end
        end
      end)
    end

    # Extract the component call using regex that handles multiline
    case Regex.run(~r/<FlyMapEx\.render\s*(.*?)\s*\/>/s, cleaned_template) do
      [_, attrs_content] ->
        parse_heex_attributes(attrs_content)

      _ ->
        # Try to handle the case where there are no attributes
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
    # Parse HEEx-style attributes using a more robust approach
    # Split by attribute patterns and parse each one individually
    attrs_content
    |> String.trim()
    |> parse_individual_attributes()
  end

  defp parse_individual_attributes(attrs_string) do
    # Find attribute names and their positions
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
    # Find the attribute assignment
    pattern = ~r/#{Regex.escape(attr_name)}\s*=\s*\{/

    case Regex.run(pattern, attrs_string, return: :index) do
      [{start, length}] ->
        # Find the start position of the opening brace
        start_pos = start + length - 1

        # Extract the balanced braces content
        case extract_balanced_braces(attrs_string, start_pos) do
          {:ok, content} -> evaluate_elixir_expression(content)
          error -> error
        end

      _ ->
        {:error, "Attribute not found"}
    end
  end

  defp extract_balanced_braces(string, start_pos) do
    # Extract content between balanced braces starting at start_pos
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
          # Found closing brace, we're done
          {:ok, acc}

        {"}", depth} when depth > 1 ->
          # Nested closing brace
          extract_balanced_content(string, pos + 1, depth - 1, acc <> char)

        {"{", depth} ->
          # Opening brace
          extract_balanced_content(string, pos + 1, depth + 1, acc <> char)

        {char, _} ->
          # Regular character
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

  defp validate_assigns!(assigns, opts) do
    # Validate marker_groups if present
    if marker_groups = assigns[:marker_groups] do
      validate_marker_groups!(marker_groups, opts)
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

  defp validate_marker_groups!(marker_groups, opts) when is_list(marker_groups) do
    marker_groups
    |> Enum.with_index()
    |> Enum.each(fn {group, index} -> validate_group!(group, index, opts) end)
  end

  defp validate_marker_groups!(_, _opts) do
    raise CompileError, description: "marker_groups must be a list"
  end

  defp validate_group!(group, index, opts) when is_map(group) do
    # Validate nodes field (required)
    nodes = group[:nodes] || group["nodes"]

    unless nodes do
      raise CompileError, description: "Group #{index + 1}: Missing 'nodes' field"
    end

    validate_nodes!(nodes, index, opts)
  end

  defp validate_group!(_, index, _opts) do
    raise CompileError, description: "Group #{index + 1}: Must be a map"
  end

  defp validate_nodes!(nodes, group_index, opts) when is_list(nodes) do
    nodes
    |> Enum.with_index()
    |> Enum.each(fn {node, node_index} -> validate_node!(node, group_index, node_index, opts) end)
  end

  defp validate_nodes!(_, group_index, _opts) do
    raise CompileError, description: "Group #{group_index + 1}: 'nodes' must be a list"
  end

  defp validate_node!(node, group_index, node_index, opts) when is_binary(node) do
    # Check if it's a valid Fly.io region or known custom region
    unless valid_region?(node, opts) do
      raise CompileError,
        description:
          "Group #{group_index + 1}, Node #{node_index + 1}: '#{node}' is not a valid Fly.io region or known custom region"
    end
  end

  defp validate_node!(node, group_index, node_index, _opts) when is_tuple(node) do
    # Direct coordinate tuple - validate format
    validate_coordinates!(node, group_index, node_index)
  end

  defp validate_node!(node, group_index, node_index, opts) when is_map(node) do
    # Custom coordinate node - validate it has label and coordinates
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

  defp validate_node!(_, group_index, node_index, _opts) do
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

  # Check if a region is valid - either a Fly.io region or a known custom region
  defp valid_region?(region, opts) when is_binary(region) do
    allowed_regions =
      opts
      |> Keyword.get(:allow_regions, [])
      |> Enum.map(&to_string/1)

    region in allowed_regions or FlyMapEx.FlyRegions.valid?(region)
  end

  defp valid_region?(_, _opts), do: false

  defp validate_theme!(theme) when is_atom(theme) do
    valid_themes = [:light, :dark, :minimal, :cool, :warm, :high_contrast, :responsive]

    unless theme in valid_themes do
      raise CompileError,
        description: "Invalid theme: #{theme}. Valid themes: #{inspect(valid_themes)}"
    end
  end

  defp validate_theme!(theme) when is_map(theme) do
    # Custom theme map - validate it has required keys
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
end
