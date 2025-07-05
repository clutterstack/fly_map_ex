defmodule DemoWeb.MapDemoLive do
  @moduledoc """
  Interactive code builder for FlyMapEx components.

  Allows users to build marker groups through a live code editor with:
  - Real-time validation for region codes and syntax
  - Autocomplete hints for regions and styles
  - Live preview of the generated HEEx code
  - Copy-to-clipboard functionality
  """

  use Phoenix.LiveView

  import DemoWeb.Components.DemoNavigation

  def mount(_params, _session, socket) do
    # Default example marker groups to start with
    default_code = """
    [
      %{
        nodes: ["sjc", "fra"],
        label: "Production Servers"
      },
      %{
        nodes: ["ams", "lhr"],
        label: "Staging Servers"
      },
      %{
        nodes: ["ord", "dfw"],
        label: "Development Servers"
      }
    ]
    """

    socket =
      socket
      |> assign(:code_input, String.trim(default_code))
      |> assign(:marker_groups, [])
      |> assign(:validation_errors, [])
      |> assign(:generated_heex, "")
      |> parse_and_validate_code(default_code)

    {:ok, socket}
  end

  def handle_event("update_code", %{"code" => code}, socket) do
    socket = parse_and_validate_code(socket, code)
    {:noreply, socket}
  end

  def handle_event("copy_heex", _params, socket) do
    # JavaScript will handle the actual clipboard copy
    {:noreply, socket}
  end

  defp parse_and_validate_code(socket, code) do
    socket =
      socket
      |> assign(:code_input, code)
      |> assign(:validation_errors, [])

    try do
      # Parse the code as Elixir AST
      {marker_groups, _binding} = Code.eval_string(code)

      # Validate the structure
      errors = validate_marker_groups(marker_groups)

      if errors == [] do
        # Add group_label field to each marker group for toggle functionality
        marker_groups_with_labels = add_group_labels(marker_groups)
        heex_code = generate_heex_code(marker_groups)

        socket
        |> assign(:marker_groups, marker_groups_with_labels)
        |> assign(:generated_heex, heex_code)
      else
        socket
        |> assign(:validation_errors, errors)
        |> assign(:marker_groups, [])
        |> assign(:generated_heex, "")
      end
    rescue
      e ->
        socket
        |> assign(:validation_errors, ["Syntax error: #{Exception.message(e)}"])
        |> assign(:marker_groups, [])
        |> assign(:generated_heex, "")
    end
  end

  defp validate_marker_groups(marker_groups) when is_list(marker_groups) do
    marker_groups
    |> Enum.with_index()
    |> Enum.flat_map(fn {group, index} -> validate_group(group, index) end)
  end

  defp validate_marker_groups(_), do: ["Must be a list of marker groups"]

  defp validate_group(group, index) when is_map(group) do
    errors = []

    # Check required fields
    errors =
      if Map.has_key?(group, :nodes),
        do: errors,
        else: ["Group #{index + 1}: Missing 'nodes' field" | errors]

    # Style field is now optional - will auto-cycle if not provided

    errors =
      if Map.has_key?(group, :label),
        do: errors,
        else: ["Group #{index + 1}: Missing 'label' field" | errors]

    # Validate nodes if present
    if Map.has_key?(group, :nodes) do
      case group.nodes do
        nodes when is_list(nodes) ->
          validate_nodes(nodes, index) ++ errors

        _ ->
          ["Group #{index + 1}: 'nodes' must be a list" | errors]
      end
    else
      errors
    end
  end

  defp validate_group(_, index), do: ["Group #{index + 1}: Must be a map"]

  defp validate_nodes(nodes, group_index) do
    nodes
    |> Enum.with_index()
    |> Enum.flat_map(fn {node, node_index} -> validate_node(node, group_index, node_index) end)
  end

  defp validate_node(node, group_index, node_index) when is_binary(node) do
    # Check if it's a valid Fly.io region
    if FlyMapEx.Regions.valid?(node) do
      []
    else
      ["Group #{group_index + 1}, Node #{node_index + 1}: '#{node}' is not a valid Fly.io region"]
    end
  end

  defp validate_node(node, group_index, node_index) when is_map(node) do
    # Custom coordinate node - validate it has label and coordinates
    errors = []

    errors =
      if Map.has_key?(node, :label),
        do: errors,
        else: [
          "Group #{group_index + 1}, Node #{node_index + 1}: Custom node missing 'label'" | errors
        ]

    errors =
      if Map.has_key?(node, :coordinates),
        do: errors,
        else: [
          "Group #{group_index + 1}, Node #{node_index + 1}: Custom node missing 'coordinates'"
          | errors
        ]

    if Map.has_key?(node, :coordinates) do
      case node.coordinates do
        {lat, lng} when is_number(lat) and is_number(lng) ->
          if lat >= -90 and lat <= 90 and lng >= -180 and lng <= 180 do
            errors
          else
            [
              "Group #{group_index + 1}, Node #{node_index + 1}: Invalid coordinates - lat must be -90 to 90, lng -180 to 180"
              | errors
            ]
          end

        _ ->
          [
            "Group #{group_index + 1}, Node #{node_index + 1}: Coordinates must be {latitude, longitude} tuple"
            | errors
          ]
      end
    else
      errors
    end
  end

  defp validate_node(_, group_index, node_index) do
    [
      "Group #{group_index + 1}, Node #{node_index + 1}: Must be a region string or coordinate map"
    ]
  end

  defp add_group_labels(marker_groups) do
    Enum.map(marker_groups, fn group ->
      Map.put(group, :group_label, group.label)
    end)
  end

  defp generate_heex_code(marker_groups) do
    marker_groups_code = inspect(marker_groups, pretty: true, width: 60)

    """
    <FlyMapEx.render
      marker_groups={#{marker_groups_code}}
      class="my-map"
    />
    """
  end

  def render(assigns) do
    ~H"""
    <.demo_navigation current_page={:map_demo} />
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold text-base-content">FlyMapEx Interactive Code Builder</h1>
      </div>

      <p class="text-lg mb-6 text-base-content/80">
        Build marker groups for FlyMapEx with real-time validation and live preview.
      </p>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Code Input Section -->
        <div class="space-y-4">
          <div class="bg-base-100 rounded-lg shadow-lg p-6">
            <h2 class="text-xl font-semibold mb-4 text-base-content">Marker Groups Code</h2>

            <form phx-change="update_code">
              <textarea
                name="code"
                class="textarea textarea-bordered w-full h-96 font-mono text-sm"
                placeholder="Enter your marker groups..."
                phx-debounce="300"
              >{@code_input}</textarea>
            </form>

    <!-- Validation Errors -->
            <%= if @validation_errors != [] do %>
              <div class="mt-4 bg-error/10 border border-error/20 rounded-lg p-4">
                <h3 class="text-error font-semibold mb-2">Validation Errors:</h3>
                <ul class="list-disc list-inside space-y-1">
                  <%= for error <- @validation_errors do %>
                    <li class="text-error/80 text-sm">{error}</li>
                  <% end %>
                </ul>
              </div>
            <% end %>

    <!-- Hints Section -->
            <div class="mt-4 bg-info/10 border border-info/20 rounded-lg p-4">
              <h3 class="text-info font-semibold mb-2">Quick Reference:</h3>
              <div class="text-sm text-info/80 space-y-1">
                <p>
                  <strong>Styles (optional):</strong>
                  operational(), warning(), danger(), primary(), cycle(0)
                </p>
                <p><strong>Auto-cycling:</strong> Groups without styles get distinct colours automatically</p>
                <p><strong>Sample Regions:</strong> "sjc", "fra", "ams", "lhr", "ord", "dfw"</p>
                <p><strong>Custom Coordinates:</strong> Use maps with label and coordinates fields</p>
              </div>
            </div>
          </div>
        </div>

    <!-- Preview Section -->
        <div class="space-y-4">
          <!-- Live Map Preview -->
          <div class="bg-base-100 rounded-lg shadow-lg p-6">
            <h2 class="text-xl font-semibold mb-4 text-base-content">Live Preview</h2>

            <%= if @marker_groups != [] do %>
              <FlyMapEx.render
                marker_groups={@marker_groups}
                class="demo-map"
              />
            <% else %>
              <div class="flex items-center justify-center h-64 bg-base-200/50 rounded-lg border-2 border-dashed border-base-300">
                <p class="text-base-content/60">Map preview will appear here once code is valid</p>
              </div>
            <% end %>
          </div>

    <!-- Generated HEEx Code -->
          <div class="bg-base-100 rounded-lg shadow-lg p-6">
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-xl font-semibold text-base-content">Generated HEEx Code</h2>
              <%= if @generated_heex != "" do %>
                <button
                  class="btn btn-sm btn-primary"
                  phx-click="copy_heex"
                  onclick="navigator.clipboard.writeText(this.nextElementSibling.textContent)"
                >
                  Copy Code
                </button>
                <div class="hidden">{@generated_heex}</div>
              <% end %>
            </div>

            <%= if @generated_heex != "" do %>
              <pre class="bg-base-200 p-4 rounded-lg overflow-x-auto text-sm"><code>{@generated_heex}</code></pre>
            <% else %>
              <div class="bg-base-200/50 p-4 rounded-lg border-2 border-dashed border-base-300">
                <p class="text-base-content/60 text-center">Generated HEEx code will appear here</p>
              </div>
            <% end %>
          </div>
        </div>
      </div>

    <!-- Documentation Section -->
      <div class="mt-8 bg-base-100 rounded-lg shadow-lg p-6">
        <h2 class="text-xl font-semibold mb-4 text-base-content">How to Use</h2>
        <div class="prose prose-sm max-w-none">
          <ol class="list-decimal list-inside space-y-2 text-base-content/80">
            <li>Edit the marker groups code in the left panel</li>
            <li>See validation errors and hints below the code editor</li>
            <li>Watch the live map preview update automatically</li>
            <li>Copy the generated HEEx code to use in your project</li>
          </ol>

          <h3 class="text-lg font-semibold mt-6 mb-3 text-base-content">Marker Group Structure</h3>
          <div class="bg-base-200 p-4 rounded-lg text-sm">
            <p>Each marker group is a map with nodes, style, and label fields.</p>
            <p>Nodes can be region codes or coordinate maps.</p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
