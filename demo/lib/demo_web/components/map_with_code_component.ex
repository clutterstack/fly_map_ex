defmodule DemoWeb.Components.MapWithCodeComponent do
  @moduledoc """
  Reusable component that renders both a FlyMapEx map and its corresponding code.

  This ensures the displayed code always matches what's actually being rendered,
  making it perfect for documentation and demo purposes.
  """

  use Phoenix.Component

  @doc """
  Renders a map alongside its generated code.

  ## Attributes

  * `marker_groups` - List of marker groups to display
  * `theme` - Theme atom (optional)
  * `title` - Title for the map section (optional, alias for map_title)
  * `map_title` - Title for the map section (optional)
  * `code_title` - Title for the code section (optional, default: "Code Example")
  * `show_code` - Whether to show the code section (default: true)
  * `class` - Additional CSS classes for the container
  * `map_class` - Additional CSS classes for the map container
  * `code_class` - Additional CSS classes for the code container
  * `extra_content` - Optional slot for additional content in code section
  """
  attr :marker_groups, :list, default: nil
  attr :theme, :any, default: nil
  attr :title, :string, default: nil
  attr :map_title, :string, default: nil
  attr :code_title, :string, default: "Code Example"
  attr :show_code, :boolean, default: true
  attr :class, :string, default: ""
  attr :map_class, :string, default: ""
  attr :code_class, :string, default: ""
  attr :map_layout, :atom, default: nil

  slot :extra_content

  def map_with_code(assigns) do
    # Generate both the map attributes and code representation
    {map_attrs, code_string} = build_map_and_code(assigns)
    assigns = assign(assigns, map_attrs: map_attrs, code_string: code_string)

    ~H"""
    <div class={get_container_classes(assigns)}>
      <!-- Map Display -->
      <div class={["space-y-4", @map_class]}>
        <%= if @map_title || @title do %>
          <h2 class="text-xl font-semibold text-base-content/80">{@map_title || @title}</h2>
        <% end %>

        <div class="p-4 bg-base-200 rounded-lg">
          <FlyMapEx.render {@map_attrs} />
        </div>
      </div>
      
    <!-- Code Display -->
      <%= if @show_code do %>
        <div class={["space-y-4", @code_class]}>
          <h2 class="text-xl font-semibold text-base-content/80">{@code_title}</h2>
          <div class="bg-base-200 rounded-lg p-4">
            <pre class="text-sm text-base-content overflow-x-auto whitespace-pre-wrap break-words"><code><%= @code_string %></code></pre>
          </div>

          {render_slot(@extra_content)}
        </div>
      <% end %>
    </div>
    """
  end

  defp get_container_classes(assigns) do
    base_classes = ["gap-8", assigns.class]

    case assigns.map_layout do
      :side_by_side -> ["space-y-8"] ++ base_classes
      _ -> ["grid grid-cols-1 lg:grid-cols-2"] ++ base_classes
    end
  end

  @doc """
  Helper that can be used independently to get map attributes and code string.

  Returns `{map_attributes, code_string}` tuple.
  """
  def build_map_and_code(config) do
    marker_groups = Map.get(config, :marker_groups) || Map.get(config, "marker_groups")
    theme = Map.get(config, :theme) || Map.get(config, "theme")
    layout = Map.get(config, :map_layout)

    # Handle nil marker_groups differently from empty list
    # nil means no marker_groups attribute at all
    # [] means empty marker_groups attribute
    marker_groups =
      case marker_groups do
        # Keep nil to indicate no marker_groups attribute
        nil -> nil
        groups -> groups
      end

    # Build map attributes - only include marker_groups if not nil and not empty
    map_attrs = %{layout: layout}

    map_attrs =
      if marker_groups != nil and marker_groups != [] do
        Map.put(map_attrs, :marker_groups, marker_groups)
      else
        map_attrs
      end

    map_attrs =
      if theme != nil do
        Map.put(map_attrs, :theme, theme)
      else
        map_attrs
      end

    # Generate code string
    code_string = generate_code_string(marker_groups, theme)

    {map_attrs, code_string}
  end

  defp generate_code_string(marker_groups, theme) do
    # Generate the marker_groups code representation
    marker_groups_code = format_marker_groups_code(marker_groups)

    # Generate the component call
    component_attrs =
      if theme != nil do
        theme_str =
          if is_atom(theme),
            do: ":#{theme}",
            else: "FlyMapEx.Theme.custom_theme(#{inspect(theme)})"

        "\n  theme={#{theme_str}}"
      else
        ""
      end

    # Add marker_groups attribute only if not nil and not empty
    marker_groups_attr =
      if marker_groups != nil and marker_groups != [] do
        "\n  marker_groups={marker_groups}"
      else
        ""
      end

    # If we have no variable declaration and no attributes, show minimal version
    if marker_groups_code == "" and component_attrs == "" do
      "<FlyMapEx.render />"
    else
      marker_groups_code <>
        "\n\n<FlyMapEx.render" <> marker_groups_attr <> component_attrs <> "\n/>"
    end
  end

  defp format_marker_groups_code(marker_groups) when marker_groups in [nil, []] do
    # Return empty string for nil or empty marker groups
    ""
  end

  defp format_marker_groups_code(marker_groups) do
    # Format marker groups as readable Elixir code
    groups_lines =
      Enum.map(marker_groups, fn group ->
        style_str = format_style(Map.get(group, :style) || Map.get(group, "style"))
        label = Map.get(group, :label) || Map.get(group, "label")

        style_field = if style_str, do: ",\n      style: " <> style_str, else: ""
        label_field = if label, do: ",\n      label: " <> inspect(label), else: ""

        cond do
          Map.has_key?(group, :nodes) or Map.has_key?(group, "nodes") ->
            nodes_str = format_nodes(group[:nodes] || Map.get(group, "nodes"))

            "    %{\n      nodes: " <>
              nodes_str <>
              style_field <> label_field <> "\n    }"

          Map.has_key?(group, :markers) or Map.has_key?(group, "markers") ->
            markers_str = format_markers(group[:markers] || Map.get(group, "markers"))

            "    %{\n      nodes: " <>
              markers_str <>
              style_field <> label_field <> "\n    }"

          true ->
            if style_str || label do
              "    %{" <> style_field <> label_field <> "\n    }"
            else
              "    %{}\n    "
            end
        end
      end)

    groups_content = Enum.join(groups_lines, ",\n")

    "marker_groups = [\n" <> groups_content <> "\n]"
  end

  defp format_nodes(nodes) when is_list(nodes) do
    formatted_nodes =
      Enum.map(nodes, fn
        node when is_binary(node) ->
          inspect(node)

        {lat, lng} when is_number(lat) and is_number(lng) ->
          # Handle coordinate tuples
          "{#{lat}, #{lng}}"

        node when is_map(node) ->
          # Handle map-based nodes
          label = Map.get(node, :label) || Map.get(node, "label")
          region = Map.get(node, :region) || Map.get(node, "region")
          coords = format_coordinates(Map.get(node, :coordinates) || Map.get(node, "coordinates"))

          cond do
            label && region ->
              "%{label: #{inspect(label)}, region: #{inspect(region)}}"
            label && coords ->
              "%{label: #{inspect(label)}, coordinates: #{coords}}"
            coords ->
              "%{coordinates: #{coords}}"
            true ->
              inspect(node)
          end
      end)

    "[" <> Enum.join(formatted_nodes, ", ") <> "]"
  end

  defp format_markers(markers) when is_list(markers) do
    formatted_markers =
      Enum.map(markers, fn marker ->
        label = Map.get(marker, :label) || Map.get(marker, "label")
        lat = Map.get(marker, :lat) || Map.get(marker, "lat")
        lng = Map.get(marker, :lng) || Map.get(marker, "lng")

        if label do
          "\n      %{coordinates: {#{lat}, #{lng}}, label: #{inspect(label)}}"
        else
          "\n      %{coordinates: {#{lat}, #{lng}}}"
        end
      end)

    "[" <> Enum.join(formatted_markers, ",") <> "\n    ]"
  end

  defp format_coordinates({lat, lng}) when is_number(lat) and is_number(lng) do
    "{#{lat}, #{lng}}"
  end

  defp format_coordinates(coords), do: inspect(coords)

  defp format_style(style) when is_map(style) do
    # Check if this looks like a FlyMapEx.Style result
    case style do
      %{__source__: source_info} = style_map ->
        format_flymap_style_from_source(style_map, source_info)

      %{colour: colour, size: _size, animation: _animation} = style_map ->
        # Fallback for styles without source metadata (legacy)
        format_flymap_style(style_map, colour)

      _ ->
        inspect(style)
    end
  end

  defp format_style(nil), do: nil
  defp format_style(style), do: inspect(style)

  defp format_flymap_style_from_source(style_map, {function_name, args, _opts}) do
    # Build the function call using source metadata
    function_call = "FlyMapEx.Style.#{function_name}"

    # Get the expected defaults for this function
    defaults = get_function_defaults(function_name)

    # Build list of parameters that differ from defaults
    additional_params =
      []
      |> maybe_add_param(:size, Map.get(style_map, :size), Map.get(defaults, :size))
      |> maybe_add_param(
        :animation,
        Map.get(style_map, :animation),
        Map.get(defaults, :animation)
      )
      |> maybe_add_param(:glow, Map.get(style_map, :glow), Map.get(defaults, :glow))
      |> maybe_add_param(
        :gradient,
        Map.get(style_map, :gradient),
        Map.get(defaults, :gradient, false)
      )

    # Combine with original args
    all_params = args ++ additional_params

    # Format with multi-line if we have additional parameters
    if length(additional_params) > 0 do
      param_lines = Enum.map(all_params, fn param -> "        #{param}" end)
      function_call <> "(\n" <> Enum.join(param_lines, ",\n") <> "\n      )"
    else
      # Single line for simple cases
      if length(all_params) > 0 do
        formatted_args = Enum.map(args, &format_arg/1)
        function_call <> "(" <> Enum.join(formatted_args, ", ") <> ")"
      else
        function_call <> "()"
      end
    end
  end

  defp format_arg(arg) when is_binary(arg), do: inspect(arg)
  defp format_arg(arg) when is_integer(arg), do: Integer.to_string(arg)
  defp format_arg(arg), do: inspect(arg)

  defp get_function_defaults(function_name) do
    # Get defaults for preset styles
    case function_name do
      :operational -> %{colour: "#10b981", size: 4, animation: :none, glow: false}
      :warning -> %{colour: "#f59e0b", size: 4, animation: :none, glow: false}
      :danger -> %{colour: "#ef4444", size: 4, animation: :pulse, glow: false}
      :inactive -> %{colour: "#6b7280", size: 4, animation: :none, glow: false}
      :cycle -> FlyMapEx.Style.cycle(0)
      :custom -> %{size: 4, animation: :none, glow: false, gradient: false}
      _ -> %{size: 4, animation: :none, glow: false, gradient: false}
    end
  end

  defp format_flymap_style(style_map, colour) do
    # Determine the style function based on the colour pattern
    {function_name, params, defaults} =
      cond do
        is_integer(colour) and colour >= 0 and colour <= 11 ->
          {"FlyMapEx.Style.cycle", [Integer.to_string(colour)], FlyMapEx.Style.cycle(0)}

        colour in [:red, :orange, :green, :blue, :purple, :gray] ->
          function_name = "FlyMapEx.Style.#{colour}"
          {function_name, [], %{size: 4, animation: :none, glow: false, gradient: false}}

        colour == "#10b981" ->
          {":operational", [], %{colour: "#10b981", size: 4, animation: :none, glow: false}}

        colour == "#f59e0b" ->
          {":warning", [], %{colour: "#f59e0b", size: 4, animation: :none, glow: false}}

        colour == "#ef4444" ->
          {":danger", [], %{colour: "#ef4444", size: 4, animation: :pulse, glow: false}}

        colour == "#6b7280" ->
          {":inactive", [], %{colour: "#6b7280", size: 4, animation: :none, glow: false}}

        colour == "#3b82f6" ->
          {"FlyMapEx.Style.named_colours", [":blue"], FlyMapEx.Style.named_colours(:blue)}

        colour == "#14b8a6" ->
          {"FlyMapEx.Style.named_colours", [":teal"], FlyMapEx.Style.named_colours(:teal)}

        colour == "#0ea5e9" ->
          {"%{colour: \"#0ea5e9\"}", [], %{colour: "#0ea5e9", size: 4, animation: :none, glow: false}}

        true ->
          # Custom style - use direct style map format
          {nil, [], %{size: 4, animation: :none, glow: false, gradient: false}}
      end

    # Build list of additional parameters (those that differ from actual defaults)
    additional_params =
      []
      |> maybe_add_param(:size, Map.get(style_map, :size), Map.get(defaults, :size))
      |> maybe_add_param(
        :animation,
        Map.get(style_map, :animation),
        Map.get(defaults, :animation)
      )
      |> maybe_add_param(:glow, Map.get(style_map, :glow), Map.get(defaults, :glow, false))
      |> maybe_add_param(
        :gradient,
        Map.get(style_map, :gradient),
        Map.get(defaults, :gradient, false)
      )

    # Combine all parameters
    all_params = params ++ additional_params

    # Handle direct style map format (when function_name is nil)
    if function_name == nil do
      format_direct_style_map(style_map)
    else
      # Format with multi-line if we have additional parameters
      if length(additional_params) > 0 do
        param_lines = Enum.map(all_params, fn param -> "        #{param}" end)
        function_name <> "(\n" <> Enum.join(param_lines, ",\n") <> "\n      )"
      else
        # Single line for simple cases
        if length(all_params) > 0 do
          function_name <> "(" <> Enum.join(all_params, ", ") <> ")"
        else
          function_name <> "()"
        end
      end
    end
  end

  # Helper to conditionally add parameters that differ from defaults
  defp maybe_add_param(params, :size, value, default) when value != default do
    params ++ ["size: #{value}"]
  end

  defp maybe_add_param(params, :animation, value, default) when value != default do
    params ++ ["animation: :#{value}"]
  end

  defp maybe_add_param(params, :glow, true, false) do
    params ++ ["glow: true"]
  end

  defp maybe_add_param(params, :gradient, true, false) do
    params ++ ["gradient: true"]
  end

  defp maybe_add_param(params, _key, _value, _default), do: params

  # Format a style map as a direct style map (primary interface)
  defp format_direct_style_map(style_map) do
    # Build the style map representation
    style_fields = []

    # Add colour field
    colour = Map.get(style_map, :colour)
    style_fields = if colour, do: style_fields ++ ["colour: #{inspect(colour)}"], else: style_fields

    # Add size field if different from default
    size = Map.get(style_map, :size, 4)
    style_fields = if size != 4, do: style_fields ++ ["size: #{size}"], else: style_fields

    # Add animation field if different from default
    animation = Map.get(style_map, :animation, :none)
    style_fields = if animation != :none, do: style_fields ++ ["animation: :#{animation}"], else: style_fields

    # Add glow field if true
    glow = Map.get(style_map, :glow, false)
    style_fields = if glow, do: style_fields ++ ["glow: true"], else: style_fields

    # Format as multi-line style map
    if length(style_fields) > 1 do
      field_lines = Enum.map(style_fields, fn field -> "        #{field}" end)
      "%{\n" <> Enum.join(field_lines, ",\n") <> "\n      }"
    else
      # Single field - format inline
      "%{" <> Enum.join(style_fields, ", ") <> "}"
    end
  end
end
