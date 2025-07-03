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
  * `theme` - Theme atom (optional, conflicts with background)
  * `background` - Background configuration (optional, conflicts with theme)
  * `title` - Title for the map section (optional, alias for map_title)
  * `map_title` - Title for the map section (optional)
  * `code_title` - Title for the code section (optional, default: "Code Example")
  * `show_code` - Whether to show the code section (default: true)
  * `class` - Additional CSS classes for the container
  * `map_class` - Additional CSS classes for the map container
  * `code_class` - Additional CSS classes for the code container
  * `extra_content` - Optional slot for additional content in code section
  """
  attr :marker_groups, :list, required: true
  attr :theme, :atom, default: nil
  attr :background, :any, default: nil
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
          <h2 class="text-xl font-semibold text-gray-700"><%= @map_title || @title %></h2>
        <% end %>

        <div class="p-4 bg-gray-50 rounded-lg">
          <FlyMapEx.render {@map_attrs} />
        </div>
      </div>

      <!-- Code Display -->
      <%= if @show_code do %>
        <div class={["space-y-4", @code_class]}>
          <h2 class="text-xl font-semibold text-gray-700"><%= @code_title %></h2>
          <div class="bg-gray-50 rounded-lg p-4">
            <pre class="text-sm text-gray-800 overflow-x-auto"><code><%= @code_string %></code></pre>
          </div>

          <%= render_slot(@extra_content) %>
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
    background = Map.get(config, :background) || Map.get(config, "background")
    layout = Map.get(config, :map_layout)

    # Build map attributes
    map_attrs = %{marker_groups: marker_groups, layout: layout}

    map_attrs =
      cond do
        background != nil -> Map.put(map_attrs, :background, background)
        theme != nil -> Map.put(map_attrs, :theme, theme)
        true -> map_attrs
      end

    # Generate code string
    code_string = generate_code_string(marker_groups, theme, background)

    {map_attrs, code_string}
  end

  defp generate_code_string(marker_groups, theme, background) do
    # Generate the marker_groups code representation
    marker_groups_code = format_marker_groups_code(marker_groups)

    # Generate the component call
    component_attrs =
      cond do
        background != nil ->
          "\n  background={FlyMapEx.Theme.responsive_background()}"

        theme != nil ->
          "\n  theme={:#{theme}}"

        true ->
          ""
      end

    marker_groups_code <>
      "\n\n<FlyMapEx.render\n  marker_groups={marker_groups}" <> component_attrs <> "\n/>"
  end

  defp format_marker_groups_code(marker_groups) do
    # Format marker groups as readable Elixir code
    groups_lines =
      Enum.map(marker_groups, fn group ->
        style_str = format_style(group.style || group[:style])
        label_str = inspect(group.label || group[:label])

        cond do
          Map.has_key?(group, :nodes) or Map.has_key?(group, "nodes") ->
            nodes_str = format_nodes(group[:nodes] || Map.get(group, "nodes"))
            "    %{\n      nodes: " <>
              nodes_str <>
              ",\n      style: " <> style_str <> ",\n      label: " <> label_str <> "\n    }"

          Map.has_key?(group, :markers) or Map.has_key?(group, "markers") ->
            markers_str = format_markers(group[:markers] || Map.get(group, "markers"))
            "    %{\n      nodes: " <>
              markers_str <>
              ",\n      style: " <> style_str <> ",\n      label: " <> label_str <> "\n    }"

          true ->
            "    %{\n      style: " <> style_str <> ",\n      label: " <> label_str <> "\n    }"
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

        node when is_map(node) ->
          # Handle custom coordinate nodes
          label = inspect(node.label || node[:label])
          coords = format_coordinates(node.coordinates || node[:coordinates])
          "%{label: #{label}, coordinates: #{coords}}"
      end)

    "[" <> Enum.join(formatted_nodes, ", ") <> "]"
  end

  defp format_markers(markers) when is_list(markers) do
    formatted_markers =
      Enum.map(markers, fn marker ->
        label = inspect(marker.label || marker[:label])
        lat = marker.lat || marker[:lat]
        lng = marker.lng || marker[:lng]
        "\n      %{coordinates: {#{lat}, #{lng}}, label: #{label}}"
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

  defp format_style(style), do: inspect(style)

  defp format_flymap_style_from_source(style_map, {function_name, args, _opts}) do
    # Build the function call using source metadata
    function_call = "FlyMapEx.Style.#{function_name}"

    # Get the expected defaults for this function
    defaults = get_function_defaults(function_name)

    # Build list of parameters that differ from defaults
    additional_params =
      []
      |> maybe_add_param(:size, Map.get(style_map, :size), defaults.size)
      |> maybe_add_param(:animation, Map.get(style_map, :animation), defaults.animation)
      |> maybe_add_param(:glow, Map.get(style_map, :glow), defaults.glow)
      |> maybe_add_param(:gradient, Map.get(style_map, :gradient), defaults.gradient)

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
    case function_name do
      :operational -> %{size: 4, animation: :none, glow: false, gradient: false}
      :warning -> %{size: 4, animation: :none, glow: false, gradient: false}
      :danger -> %{size: 4, animation: :pulse, glow: true, gradient: false}
      :inactive -> %{size: 4, animation: :none, glow: false, gradient: false}
      :primary -> %{size: 4, animation: :none, glow: false, gradient: false}
      :secondary -> %{size: 4, animation: :none, glow: false, gradient: false}
      :info -> %{size: 4, animation: :none, glow: false, gradient: false}
      :cycle -> %{size: 4, animation: :none, glow: false, gradient: false}
      :custom -> %{size: 4, animation: :none, glow: false, gradient: false}
      _ -> %{size: 4, animation: :none, glow: false, gradient: false}
    end
  end

  defp format_flymap_style(style_map, colour) do
    # Determine the style function and its actual defaults based on the colour pattern
    {function_name, params, default_size, default_animation} =
      cond do
        is_integer(colour) and colour >= 0 and colour <= 11 ->
          {"FlyMapEx.Style.cycle", [Integer.to_string(colour)], 7, :none}

        colour in [:red, :orange, :green, :blue, :purple, :gray] ->
          function_name = "FlyMapEx.Style.#{colour}"
          {function_name, [], 6, :none}

        colour == "#10b981" ->
          {"FlyMapEx.Style.operational", [], 7, :pulse}

        colour == "#f59e0b" ->
          {"FlyMapEx.Style.warning", [], 8, :none}

        colour == "#ef4444" ->
          {"FlyMapEx.Style.danger", [], 9, :pulse}

        colour == "#6b7280" ->
          {"FlyMapEx.Style.inactive", [], 5, :none}

        colour == "#3b82f6" ->
          {"FlyMapEx.Style.primary", [], 7, :none}

        colour == "#14b8a6" ->
          {"FlyMapEx.Style.secondary", [], 6, :none}

        colour == "#0ea5e9" ->
          {"FlyMapEx.Style.info", [], 6, :none}

        true ->
          # Custom style
          {"FlyMapEx.Style.custom", [inspect(colour)], 6, :none}
      end

    # Build list of additional parameters (those that differ from actual defaults)
    additional_params =
      []
      |> maybe_add_param(:size, Map.get(style_map, :size), default_size)
      |> maybe_add_param(:animation, Map.get(style_map, :animation), default_animation)
      |> maybe_add_param(:glow, Map.get(style_map, :glow), false)
      |> maybe_add_param(:gradient, Map.get(style_map, :gradient), false)

    # Combine all parameters
    all_params = params ++ additional_params

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
end
