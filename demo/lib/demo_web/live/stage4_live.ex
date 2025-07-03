defmodule DemoWeb.Stage4Live do
  use DemoWeb, :live_view

  alias DemoWeb.Layouts
  import DemoWeb.Components.DemoNavigation
  import DemoWeb.Components.MapWithCodeComponent

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:current_demo, "color_cycling")
      |> assign(:custom_colour, "#3b82f6")
      |> assign(:custom_size, 8)
      |> assign(:custom_animation, "none")
      |> assign(:custom_glow, false)
      |> update_marker_groups()

    {:ok, socket}
  end

  def handle_event("demo_change", %{"demo" => demo}, socket) do
    socket =
      socket
      |> assign(:current_demo, demo)
      |> update_marker_groups()

    {:noreply, socket}
  end

  def handle_event("update_custom", params, socket) do
    socket =
      socket
      |> assign(:custom_colour, Map.get(params, "colour", socket.assigns.custom_colour))
      |> assign(:custom_size,
          case Map.get(params, "size") do
            nil -> socket.assigns.custom_size
            size_str -> String.to_integer(size_str)
          end)
      |> assign(:custom_animation, Map.get(params, "animation", socket.assigns.custom_animation))
      |> assign(:custom_glow, Map.get(params, "glow") == "true")
      |> update_marker_groups()

    {:noreply, socket}
  end

  defp update_marker_groups(socket) do
    marker_groups =
      case socket.assigns.current_demo do
        "color_cycling" -> color_cycling_groups()
        "animation_showcase" -> animation_showcase_groups()
        "custom_builder" -> custom_builder_groups(socket.assigns)
        _ -> color_cycling_groups()
      end

    assign(socket, :marker_groups, marker_groups)
  end

  defp color_cycling_groups do
    [
      %{nodes: ["sjc"], label: "App Server 1"},
      %{nodes: ["fra"], label: "App Server 2"},
      %{nodes: ["ams"], label: "Database Cluster"},
      %{nodes: ["lhr"], label: "Cache Layer"},
      %{nodes: ["ord"], label: "Background Jobs"},
      %{nodes: ["nrt"], label: "Analytics Engine"},
      %{nodes: ["syd"], label: "File Storage"},
      %{nodes: ["sin"], label: "Message Queue"}
    ]
  end

  defp animation_showcase_groups do
    [
      %{
        nodes: ["sjc"],
        style: FlyMapEx.Style.custom("#ef4444", size: 10, animation: :pulse),
        label: "Pulse Animation"
      },
      %{
        nodes: ["ams"],
        style: FlyMapEx.Style.custom("#3b82f6", size: 10, animation: :fade),
        label: "Fade Animation"
      },
      %{
        nodes: ["lhr"],
        style: FlyMapEx.Style.custom("#10b981", size: 10, animation: :none),
        label: "No Animation (Static)"
      }
    ]
  end

  defp custom_builder_groups(assigns) do
    custom_marker_style =
      FlyMapEx.Style.custom(
        assigns.custom_colour,
        size: assigns.custom_size,
        animation: String.to_atom(assigns.custom_animation),
        glow: assigns.custom_glow
      )

    [
      %{
        nodes: ["sjc", "fra", "ams"],
        style: custom_marker_style,
        label: "Custom Style Preview"
      }
    ]
  end

  defp text_color_for_background(hex_color) do
    if String.starts_with?(hex_color, "#") and String.length(hex_color) == 7 do
      r = Integer.parse(String.slice(hex_color, 1, 2), 16) |> elem(0)
      g = Integer.parse(String.slice(hex_color, 3, 2), 16) |> elem(0)
      b = Integer.parse(String.slice(hex_color, 5, 2), 16) |> elem(0)

      # Calculate relative luminance
      luminance = 0.299 * r + 0.587 * g + 0.114 * b

      if luminance > 128, do: "#000", else: "#fff"
    else
      "#000"
    end
  end

  def render(assigns) do

    ~H"""
    <.demo_navigation current_page={:stage4} />
    <div class="container mx-auto p-8">
      <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-3xl font-bold text-gray-800">Stage 4: Custom Styling</h1>
          <Layouts.theme_toggle />
        </div>
        <p class="text-gray-600 mb-6">
          Advanced styling capabilities: color cycling, animations, and custom style building.
        </p>
      </div>

    <!-- Demo Selector -->
      <div class="mb-6">
        <div class="flex flex-wrap gap-2">
          <button
            class={[
              "btn",
              if(@current_demo == "color_cycling", do: "btn-primary", else: "btn-outline")
            ]}
            phx-click="demo_change"
            phx-value-demo="color_cycling"
          >
            Color Cycling
          </button>
          <button
            class={[
              "btn",
              if(@current_demo == "animation_showcase", do: "btn-primary", else: "btn-outline")
            ]}
            phx-click="demo_change"
            phx-value-demo="animation_showcase"
          >
            Animation Showcase
          </button>
          <button
            class={[
              "btn",
              if(@current_demo == "custom_builder", do: "btn-primary", else: "btn-outline")
            ]}
            phx-click="demo_change"
            phx-value-demo="custom_builder"
          >
            Custom Style Builder
          </button>
        </div>
      </div>

      <.map_with_code
        marker_groups={@marker_groups}
          map_title={case @current_demo do
          "color_cycling" -> "Multiple Apps with Color Cycling"
          "animation_showcase" -> "Animation Types Comparison"
          "custom_builder" -> "Interactive Style Builder"
        end}
      >
        <:extra_content>
          <%= if @current_demo == "custom_builder" do %>
            <!-- Custom Style Builder Controls -->
            <div class="bg-gray-50 border border-gray-200 rounded-lg p-4 space-y-4">
              <h3 class="font-semibold text-gray-800">Style Builder</h3>

              <form phx-change="update_custom">
                <div class="grid grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Colour</label>
                    <div class="flex items-center gap-2">
                      <.input
                        type="color"
                        value={@custom_colour}
                        name="colour"
                        class="h-10 w-16 rounded border border-gray-300"
                        id="custom-colour-picker"
                      />
                      <div
                        class="h-10 w-20 rounded border border-gray-300 flex items-center justify-center text-xs font-mono"
                        style={"background-color: #{@custom_colour}; color: #{text_color_for_background(@custom_colour)}"}
                      >
                        {@custom_colour}
                      </div>
                    </div>
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Size</label>
                    <div class="flex items-center gap-3">
                      <input
                        type="range"
                        name="size"
                        min="2"
                        max="20"
                        step="2"
                        value={@custom_size}
                        class="flex-1 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer slider"
                      />
                      <span class="text-sm font-mono text-gray-600 min-w-[3rem]">{@custom_size}px</span>
                    </div>
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Animation</label>
                    <select
                      name="animation"
                      class="select select-bordered w-full"
                    >
                      <%= for anim <- ["pulse", "fade", "none"] do %>
                        <option value={anim} selected={@custom_animation == anim}>
                          {String.capitalize(anim)}
                        </option>
                      <% end %>
                    </select>
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Glow Effect</label>
                    <div class="flex items-center">
                      <input
                        type="checkbox"
                        name="glow"
                        value="true"
                        checked={@custom_glow}
                        class="checkbox checkbox-primary"
                      />
                      <span class="ml-2 text-sm text-gray-600">Enable glow effect</span>
                    </div>
                  </div>
                </div>
              </form>
            </div>
          <% end %>

          <!-- Context-specific info panels -->
          <%= case @current_demo do %>
            <% "color_cycling" -> %>
              <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <h3 class="font-semibold text-blue-800 mb-2">Color Cycling</h3>
                <ul class="text-blue-700 text-sm space-y-1">
                  <li>• <strong>cycle(index)</strong> automatically assigns distinct colours</li>
                  <li>• Perfect for multiple apps without semantic meaning</li>
                  <li>• 12 distinct colours available in the cycle</li>
                  <li>• Each group maintains consistent colour when toggled</li>
                  <li>• No need to manually pick colours for each group</li>
                </ul>
              </div>
            <% "animation_showcase" -> %>
              <div class="bg-green-50 border border-green-200 rounded-lg p-4">
                <h3 class="font-semibold text-green-800 mb-2">Animation Types</h3>
                <div class="space-y-2 text-sm">
                  <div class="flex items-center space-x-2">
                    <div class="w-3 h-3 rounded-full animate-pulse bg-red-500"></div>
                    <span class="text-green-700">
                      <strong>:pulse</strong> - Radius + opacity (health status)
                    </span>
                  </div>
                  <div class="flex items-center space-x-2">
                    <div class="w-3 h-3 rounded-full bg-blue-500" style="animation: fade 3s infinite;">
                    </div>
                    <span class="text-green-700">
                      <strong>:fade</strong> - Opacity only (background activity)
                    </span>
                  </div>
                  <div class="flex items-center space-x-2">
                    <div class="w-3 h-3 rounded-full bg-emerald-500"></div>
                    <span class="text-green-700">
                      <strong>static</strong> - No animation (stable state)
                    </span>
                  </div>
                </div>
              </div>
            <% "custom_builder" -> %>
              <div class="bg-orange-50 border border-orange-200 rounded-lg p-4">
                <h3 class="font-semibold text-orange-800 mb-2">Custom Style Builder</h3>
                <div class="mb-3 p-3 bg-white rounded border text-sm font-mono">
                  <div class="text-orange-600 mb-1"># Variable assignment</div>
                  <div>custom_marker_style = FlyMapEx.Style.custom(</div>
                  <div class="ml-4">"{@custom_colour}",</div>
                  <div class="ml-4">size: {@custom_size},</div>
                  <div class="ml-4">animation: :{@custom_animation},</div>
                  <div class="ml-4">glow: {@custom_glow}</div>
                  <div>)</div>
                  <div class="mt-2 text-orange-600"># Usage in marker groups</div>
                  <div>style: custom_marker_style</div>
                </div>
                <ul class="text-orange-700 text-sm space-y-1">
                  <li>• <strong>Live Preview:</strong> See changes immediately</li>
                  <li>• <strong>Variable Pattern:</strong> Store style in custom_marker_style</li>
                  <li>• <strong>Reusable:</strong> Assign once, use in multiple groups</li>
                  <li>• <strong>Visual Editor:</strong> No need to remember parameters</li>
                  <li>• <strong>Code Generation:</strong> Copy the exact implementation</li>
                </ul>
              </div>
          <% end %>

          <!-- Best Practices Panel -->
          <div class="bg-gray-50 border border-gray-200 rounded-lg p-4">
            <h3 class="font-semibold text-gray-800 mb-2">Best Practices</h3>
            <ul class="text-gray-700 text-sm space-y-1">
              <li>
                • <strong>Semantic First:</strong>
                Use operational(), warning(), danger() when data has meaning
              </li>
              <li>
                • <strong>Color Cycling:</strong>
                Use cycle() for multiple groups without semantic significance
              </li>
              <li>
                • <strong>Custom Styling:</strong>
                Use custom() for brand colours and specific requirements
              </li>
              <li>
                • <strong>Accessibility:</strong>
                Ensure sufficient contrast and don't rely only on colour
              </li>
              <li>
                • <strong>Performance:</strong>
                Limit animations to critical states that need attention
              </li>
            </ul>
          </div>
        </:extra_content>
      </.map_with_code>

    <!-- Navigation -->
      <div class="mt-8 flex justify-between">
        <.link navigate="/stage3" class="btn btn-outline">
          ← Stage 3: Themes & Backgrounds
        </.link>
        <.link navigate="/demo" class="btn btn-primary">
          Back to Demo Hub →
        </.link>
      </div>
    </div>

    <style>
      @keyframes fade {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.3; }
      }

      .slider::-webkit-slider-thumb {
        appearance: none;
        height: 20px;
        width: 20px;
        border-radius: 50%;
        background: #3b82f6;
        cursor: pointer;
        border: 2px solid #fff;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
      }

      .slider::-moz-range-thumb {
        height: 20px;
        width: 20px;
        border-radius: 50%;
        background: #3b82f6;
        cursor: pointer;
        border: 2px solid #fff;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
      }
    </style>
    """
  end
end
