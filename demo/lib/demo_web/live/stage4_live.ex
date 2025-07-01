defmodule DemoWeb.Stage4Live do
  use DemoWeb, :live_view

  alias DemoWeb.Layouts
  import DemoWeb.Components.DemoNavigation

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:current_demo, "color_cycling")
      |> assign(:custom_colour, "#3b82f6")
      |> assign(:custom_size, 8)
      |> assign(:custom_animated, true)
      |> assign(:custom_animation, "pulse")
      |> assign(:custom_gradient, false)
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
      |> assign(:custom_size, String.to_integer(Map.get(params, "size", "8")))
      |> assign(:custom_animated, Map.get(params, "animated") == "true")
      |> assign(:custom_animation, Map.get(params, "animation", "pulse"))
      |> assign(:custom_gradient, Map.get(params, "gradient") == "true")
      |> update_marker_groups()

    {:noreply, socket}
  end

  defp update_marker_groups(socket) do
    marker_groups =
      case socket.assigns.current_demo do
        "color_cycling" -> color_cycling_groups()
        "brand_integration" -> brand_integration_groups()
        "animation_showcase" -> animation_showcase_groups()
        "custom_builder" -> custom_builder_groups(socket.assigns)
        _ -> color_cycling_groups()
      end

    assign(socket, :marker_groups, marker_groups)
  end

  defp color_cycling_groups do
    [
      %{nodes: ["sjc"], style: FlyMapEx.Style.cycle(0), label: "App Server 1"},
      %{nodes: ["fra"], style: FlyMapEx.Style.cycle(1), label: "App Server 2"},
      %{nodes: ["ams"], style: FlyMapEx.Style.cycle(2), label: "Database Cluster"},
      %{nodes: ["lhr"], style: FlyMapEx.Style.cycle(3), label: "Cache Layer"},
      %{nodes: ["ord"], style: FlyMapEx.Style.cycle(4), label: "Background Jobs"},
      %{nodes: ["nrt"], style: FlyMapEx.Style.cycle(5), label: "Analytics Engine"},
      %{nodes: ["syd"], style: FlyMapEx.Style.cycle(6), label: "File Storage"},
      %{nodes: ["sin"], style: FlyMapEx.Style.cycle(7), label: "Message Queue"}
    ]
  end

  defp brand_integration_groups do
    [
      %{
        nodes: ["sjc", "fra"],
        style: FlyMapEx.Style.custom("var(--primary)", size: 10, animated: true),
        label: "Primary Brand Colour"
      },
      %{
        nodes: ["ams", "lhr"],
        style: FlyMapEx.Style.custom("var(--accent)", size: 8, gradient: true),
        label: "Accent with Gradient"
      },
      %{
        nodes: ["ord"],
        style: FlyMapEx.Style.custom("#1f2937", size: 12, animated: true, animation: :bounce),
        label: "Custom Corporate Gray"
      },
      %{
        nodes: ["nrt", "syd"],
        style: FlyMapEx.Style.custom("#059669", size: 6, gradient: true),
        label: "Brand Green"
      }
    ]
  end

  defp animation_showcase_groups do
    [
      %{
        nodes: ["sjc"],
        style: FlyMapEx.Style.custom("#ef4444", size: 10, animated: true, animation: :pulse),
        label: "Pulse Animation"
      },
      %{
        nodes: ["fra"],
        style: FlyMapEx.Style.custom("#f59e0b", size: 10, animated: true, animation: :bounce),
        label: "Bounce Animation"
      },
      %{
        nodes: ["ams"],
        style: FlyMapEx.Style.custom("#3b82f6", size: 10, animated: true, animation: :fade),
        label: "Fade Animation"
      },
      %{
        nodes: ["lhr"],
        style: FlyMapEx.Style.custom("#10b981", size: 10, animated: false),
        label: "No Animation (Static)"
      }
    ]
  end

  defp custom_builder_groups(assigns) do
    style =
      FlyMapEx.Style.custom(
        assigns.custom_colour,
        size: assigns.custom_size,
        animated: assigns.custom_animated,
        animation: String.to_atom(assigns.custom_animation),
        gradient: assigns.custom_gradient
      )

    [
      %{
        nodes: ["sjc", "fra", "ams"],
        style: style,
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
    assigns =
      assign(assigns, :code_examples, %{
        "color_cycling" => """
        # Perfect for multiple apps without semantic meaning
        marker_groups = [
          %{nodes: ["sjc"], style: FlyMapEx.Style.cycle(0), label: "App Server 1"},
          %{nodes: ["fra"], style: FlyMapEx.Style.cycle(1), label: "App Server 2"},
          %{nodes: ["ams"], style: FlyMapEx.Style.cycle(2), label: "Database Cluster"},
          # ... continues with cycle(3), cycle(4), etc.
        ]
        """,
        "brand_integration" => """
        # CSS variables adapt to your theme
        marker_groups = [
          %{
            nodes: ["sjc", "fra"],
            style: FlyMapEx.Style.custom("var(--primary)", size: 10, animated: true),
            label: "Primary Brand Colour"
          },
          %{
            nodes: ["ams", "lhr"],
            style: FlyMapEx.Style.custom("var(--accent)", gradient: true),
            label: "Accent with Gradient"
          },
          %{
            nodes: ["ord"],
            style: FlyMapEx.Style.custom("#1f2937", size: 12, animation: :bounce),
            label: "Custom Corporate Color"
          }
        ]
        """,
        "animation_showcase" => """
        # Different animations for different purposes
        marker_groups = [
          %{
            nodes: ["sjc"],
            style: FlyMapEx.Style.custom("#ef4444", animation: :pulse),
            label: "Pulse - Health Status"
          },
          %{
            nodes: ["fra"],
            style: FlyMapEx.Style.custom("#f59e0b", animation: :bounce),
            label: "Bounce - Critical Alerts"
          },
          %{
            nodes: ["ams"],
            style: FlyMapEx.Style.custom("#3b82f6", animation: :fade),
            label: "Fade - Background Process"
          }
        ]
        """,
        "custom_builder" => """
        # Live preview of your custom style
        style = FlyMapEx.Style.custom(
          "#{assigns.custom_colour}",
          size: #{assigns.custom_size},
          animated: #{assigns.custom_animated},
          animation: :#{assigns.custom_animation},
          gradient: #{assigns.custom_gradient}
        )

        marker_groups = [
          %{nodes: ["sjc", "fra", "ams"], style: style, label: "Custom Style"}
        ]
        """
      })

    ~H"""
    <.demo_navigation current_page={:stage4} />
    <div class="container mx-auto p-8">
      <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-3xl font-bold text-gray-800">Stage 4: Custom Styling</h1>
          <Layouts.theme_toggle />
        </div>
        <p class="text-gray-600 mb-6">
          Advanced styling capabilities: color cycling, brand integration, animations, and custom style building.
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
              if(@current_demo == "brand_integration", do: "btn-primary", else: "btn-outline")
            ]}
            phx-click="demo_change"
            phx-value-demo="brand_integration"
          >
            Brand Integration
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

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Map Display -->
        <div class="space-y-4">
          <h2 class="text-xl font-semibold text-gray-700">
            <%= case @current_demo do %>
              <% "color_cycling" -> %>
                Multiple Apps with Color Cycling
              <% "brand_integration" -> %>
                Brand Color Integration
              <% "animation_showcase" -> %>
                Animation Types Comparison
              <% "custom_builder" -> %>
                Interactive Style Builder
            <% end %>
          </h2>

          <FlyMapEx.render
            marker_groups={@marker_groups}
            background={FlyMapEx.Theme.responsive_background()}
          />

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
                        phx-change="update_custom"
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
                    <select name="size" class="select select-bordered w-full">
                      <%= for size <- [4, 6, 8, 10, 12, 16, 20] do %>
                        <option value={size} selected={@custom_size == size}>{size}px</option>
                      <% end %>
                    </select>
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Animation</label>
                    <select
                      name="animation"
                      class="select select-bordered w-full"
                    >
                      <%= for anim <- ["pulse", "bounce", "fade"] do %>
                        <option value={anim} selected={@custom_animation == anim}>
                          {String.capitalize(anim)}
                        </option>
                      <% end %>
                    </select>
                  </div>
                </div>

                <div class="space-y-2">
                  <label class="flex items-center space-x-2">
                    <input
                      type="checkbox"
                      name="animated"
                      value="true"
                      checked={@custom_animated}
                      class="checkbox"
                    />
                    <span class="text-sm text-gray-700">Animated</span>
                  </label>

                  <label class="flex items-center space-x-2">
                    <input
                      type="checkbox"
                      name="gradient"
                      value="true"
                      checked={@custom_gradient}
                      class="checkbox"
                    />
                    <span class="text-sm text-gray-700">Gradient</span>
                  </label>
            </div>
              </form>
            </div>
          <% end %>
        </div>

    <!-- Code Example and Info -->
        <div class="space-y-4">
          <h2 class="text-xl font-semibold text-gray-700">Code Example</h2>
          <div class="bg-gray-50 rounded-lg p-4">
            <pre class="text-sm text-gray-800 overflow-x-auto"><code><%= @code_examples[@current_demo] %></code></pre>
          </div>

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
            <% "brand_integration" -> %>
              <div class="bg-purple-50 border border-purple-200 rounded-lg p-4">
                <h3 class="font-semibold text-purple-800 mb-2">Brand Integration</h3>
                <ul class="text-purple-700 text-sm space-y-1">
                  <li>• <strong>CSS Variables:</strong> Use "var(--primary)" for theme adaptation</li>
                  <li>• <strong>Custom Hex:</strong> Corporate colours like "#1f2937"</li>
                  <li>• <strong>Gradient Effects:</strong> Add depth with radial gradients</li>
                  <li>• <strong>Size Variations:</strong> Create visual hierarchy</li>
                  <li>• <strong>Theme Responsive:</strong> Colours adapt to light/dark themes</li>
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
                    <div class="w-3 h-3 rounded-full animate-bounce bg-amber-500"></div>
                    <span class="text-green-700">
                      <strong>:bounce</strong> - Complex bounce (critical alerts)
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
                <ul class="text-orange-700 text-sm space-y-1">
                  <li>• <strong>Live Preview:</strong> See changes immediately</li>
                  <li>• <strong>Full Control:</strong> Colour, size, animation, gradient</li>
                  <li>• <strong>Code Generation:</strong> Copy the exact Style.custom() call</li>
                  <li>• <strong>Visual Editor:</strong> No need to remember parameters</li>
                  <li>• <strong>Experimentation:</strong> Test ideas before implementation</li>
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
        </div>
      </div>

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
    </style>
    """
  end
end
