defmodule DemoWeb.Stage2Live do
  use DemoWeb, :live_view

  alias DemoWeb.Layouts
  import DemoWeb.Components.MapWithCodeComponent
  import DemoWeb.Components.DemoNavigation
  import DemoWeb.Components.InteractiveControls
  import DemoWeb.Components.ProgressiveDisclosure

  def mount(_params, _session, socket) do
    # Define the progressive examples according to the plan
    examples = %{
      automatic: [
        %{
          nodes: ["sjc", "fra"],
          style: FlyMapEx.Style.cycle(0),
          label: "Production Servers"
        },
        %{
          nodes: ["ams", "lhr"],
          style: FlyMapEx.Style.cycle(1),
          label: "Staging Environment"
        },
        %{
          nodes: ["ord"],
          style: FlyMapEx.Style.cycle(2),
          label: "Development"
        },
        %{
          nodes: ["nrt", "syd"],
          style: FlyMapEx.Style.cycle(3),
          label: "Testing"
        }
      ],
      semantic: [
        %{
          nodes: ["sjc", "fra"],
          style: FlyMapEx.Style.operational(),
          label: "Production Servers"
        },
        %{
          nodes: ["ams", "lhr"],
          style: FlyMapEx.Style.warning(),
          label: "Maintenance Mode"
        },
        %{
          nodes: ["ord"],
          style: FlyMapEx.Style.danger(),
          label: "Failed Nodes"
        },
        %{
          nodes: ["nrt", "syd"],
          style: FlyMapEx.Style.inactive(),
          label: "Offline Nodes"
        }
      ],
      custom: [
        %{
          nodes: ["sjc", "fra"],
          style: FlyMapEx.Style.custom("#10b981", size: 8, animation: :pulse, glow: true),
          label: "High-Performance Servers"
        },
        %{
          nodes: ["ams", "lhr"],
          style: FlyMapEx.Style.custom("#f59e0b", size: 6, animation: :fade, glow: false),
          label: "Standard Servers"
        },
        %{
          nodes: ["ord"],
          style: FlyMapEx.Style.custom("#ef4444", size: 10, animation: :pulse, glow: true),
          label: "Critical Alerts"
        },
        %{
          nodes: ["nrt"],
          style: FlyMapEx.Style.custom("#6b7280", size: 4, animation: :none, glow: false),
          label: "Maintenance"
        }
      ],
      mixed: [
        %{
          nodes: ["sjc", "fra"],
          style: FlyMapEx.Style.operational(),
          label: "Production (Semantic)"
        },
        %{
          nodes: ["ams", "lhr"],
          style: FlyMapEx.Style.cycle(1),
          label: "Staging (Auto-Cycle)"
        },
        %{
          nodes: ["ord"],
          style: FlyMapEx.Style.custom("#9333ea", size: 8, animation: :pulse, glow: true),
          label: "Special Deploy (Custom)"
        },
        %{
          nodes: ["nrt", "syd"],
          style: :inactive,
          label: "Offline (Atom)"
        }
      ]
    }

    # Tab content for the new tabbed interface
    tabs = [
      %{
        key: "automatic",
        label: "Automatic",
        content: get_automatic_content()
      },
      %{
        key: "semantic",
        label: "Semantic",
        content: get_semantic_content()
      },
      %{
        key: "custom",
        label: "Custom",
        content: get_custom_content()
      },
      %{
        key: "mixed",
        label: "Mixed",
        content: get_mixed_content()
      }
    ]

    # Custom parameters for the custom example
    custom_params = %{
      size: 6,
      animation: :none,
      glow: false,
      color: "#3b82f6"
    }

    {:ok, assign(socket,
      examples: examples,
      tabs: tabs,
      current_example: "automatic",
      custom_params: custom_params
    )}
  end

  def handle_event("switch_example", %{"option" => option}, socket) do
    {:noreply, assign(socket, current_example: option)}
  end

  def handle_event("update_param", %{"param" => param, "value" => value}, socket) do
    updated_params = case param do
      "size" -> Map.put(socket.assigns.custom_params, :size, String.to_integer(value))
      "animation" -> Map.put(socket.assigns.custom_params, :animation, String.to_atom(value))
      "glow" -> Map.put(socket.assigns.custom_params, :glow, value == "true")
      "color" -> Map.put(socket.assigns.custom_params, :color, value)
      _ -> socket.assigns.custom_params
    end

    {:noreply, assign(socket, custom_params: updated_params)}
  end

  def handle_event("apply_preset", %{"preset" => preset}, socket) do
    updated_example = case preset do
      "operational" -> "semantic"
      "warning" -> "semantic"
      "danger" -> "semantic"
      "inactive" -> "semantic"
      _ -> socket.assigns.current_example
    end

    {:noreply, assign(socket, current_example: updated_example)}
  end

  defp current_marker_groups(assigns) do
    Map.get(assigns.examples, String.to_atom(assigns.current_example), [])
  end

  def render(assigns) do
    ~H"""
    <.demo_navigation current_page={:stage2} />
    <div class="container mx-auto p-8">
      <!-- Stage Title & Progress -->
      <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-3xl font-bold text-gray-800">Stage 2: Styling Markers</h1>
          <Layouts.theme_toggle />
        </div>
        <p class="text-gray-600 mb-6">
          Master visual customization and semantic meaning through FlyMapEx's comprehensive styling system.
        </p>
      </div>

      <!-- Full Width Map (Above the Fold) -->
      <div class="mb-8 p-6 bg-gray-50 rounded-lg">
        <FlyMapEx.render
          marker_groups={current_marker_groups(assigns)}
          theme={:responsive}
          layout={:side_by_side}
        />
      </div>

      <!-- Side-by-Side: Tabbed Info Panel & Code Examples -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
        <!-- Tabbed Info Panel -->
        <div>
          <.tabbed_info_panel
            tabs={@tabs}
            current={@current_example}
            event="switch_example"
          />
        </div>

        <!-- Code Examples Panel -->
        <div>
          <div class="bg-white border border-gray-200 rounded-lg overflow-hidden">
            <div class="bg-gray-50 px-4 py-3 border-b border-gray-200">
              <h3 class="font-semibold text-gray-800">Code Example</h3>
            </div>
            <div class="p-4">
              <pre class="text-sm text-gray-800 overflow-x-auto bg-gray-50 p-3 rounded"><code><%= get_focused_code(@current_example, current_marker_groups(assigns)) %></code></pre>
            </div>

            <!-- Quick Stats -->
            <div class="bg-blue-50 border-t border-gray-200 px-4 py-3">
              <div class="text-sm text-blue-700">
                <strong>Current Configuration:</strong> <%= get_current_description(@current_example) %> •
                <%= length(current_marker_groups(assigns)) %> groups •
                <%= count_total_nodes(current_marker_groups(assigns)) %> nodes
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Progressive Disclosure for Advanced Topics -->
      <.learn_more_section
        topics={get_advanced_topics()}
      />

      <!-- Navigation -->
      <div class="mt-8 flex justify-between">
        <.link navigate={~p"/stage1"} class="inline-block bg-gray-600 text-white px-6 py-2 rounded-lg hover:bg-gray-700 transition-colors">
          ← Stage 1: Defining Marker Groups
        </.link>
        <.link navigate={~p"/stage3"} class="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors">
          Next: Stage 3 - Map Themes →
        </.link>
      </div>
    </div>
    """
  end

  # Helper functions for the template
  defp get_current_description(example) do
    case example do
      "automatic" -> "Automatic color cycling for multiple groups"
      "semantic" -> "Semantic presets for meaningful server states"
      "custom" -> "Custom parameters for size, animation, and glow"
      "mixed" -> "Mixed approaches combining different methods"
      _ -> "Unknown example"
    end
  end

  defp get_styling_method(example) do
    case example do
      "automatic" -> "FlyMapEx.Style.cycle/1"
      "semantic" -> "Semantic function calls"
      "custom" -> "FlyMapEx.Style.custom/2"
      "mixed" -> "Mixed function calls and atoms"
      _ -> "Unknown"
    end
  end

  defp count_total_nodes(marker_groups) do
    Enum.reduce(marker_groups, 0, fn group, acc ->
      nodes = group[:nodes] || []
      acc + length(nodes)
    end)
  end

  defp get_advanced_topics do
    [
      %{
        id: "style-functions",
        title: "Style Function Reference",
        content: ~s"""
        <div class="space-y-4">
          <p class="text-sm text-gray-700">
            FlyMapEx provides multiple approaches to styling markers:
          </p>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <h4 class="font-semibold text-gray-800 mb-2">Automatic Cycling</h4>
              <ul class="text-sm text-gray-600 space-y-1">
                <li>• <code class="bg-gray-100 px-1 rounded">FlyMapEx.Style.cycle(0)</code> - Blue</li>
                <li>• <code class="bg-gray-100 px-1 rounded">FlyMapEx.Style.cycle(1)</code> - Green</li>
                <li>• <code class="bg-gray-100 px-1 rounded">FlyMapEx.Style.cycle(2)</code> - Red</li>
                <li>• Cycles through 12 predefined colors</li>
              </ul>
            </div>
            <div>
              <h4 class="font-semibold text-gray-800 mb-2">Semantic Presets</h4>
              <ul class="text-sm text-gray-600 space-y-1">
                <li>• <code class="bg-gray-100 px-1 rounded">operational()</code> - Running services</li>
                <li>• <code class="bg-gray-100 px-1 rounded">warning()</code> - Needs attention</li>
                <li>• <code class="bg-gray-100 px-1 rounded">danger()</code> - Critical issues</li>
                <li>• <code class="bg-gray-100 px-1 rounded">inactive()</code> - Not running</li>
              </ul>
            </div>
          </div>
        </div>
        """
      },
      %{
        id: "custom-styling",
        title: "Custom Style Parameters",
        content: ~s"""
        <div class="space-y-4">
          <p class="text-sm text-gray-700">
            Build completely custom styles with <code class="bg-gray-100 px-1 rounded">FlyMapEx.Style.custom/2</code>:
          </p>
          <pre class="bg-gray-100 p-4 rounded-lg text-sm"><code>FlyMapEx.Style.custom("#3b82f6", [
  size: 10,        # radius in pixels
  animation: :pulse,   # :none, :pulse, :fade
  glow: true       # enable glow effect
])</code></pre>
          <div class="mt-4">
            <h4 class="font-semibold text-gray-800 mb-2">Available Parameters</h4>
            <div class="space-y-2 text-sm">
              <div>
                <strong>size:</strong> Marker radius in pixels (default: 6)
              </div>
              <div>
                <strong>animation:</strong> :none, :pulse, :fade (default: :none)
              </div>
              <div>
                <strong>glow:</strong> Boolean for glow effect (default: false)
              </div>
            </div>
          </div>
        </div>
        """
      },
      %{
        id: "style-performance",
        title: "Performance & Best Practices",
        content: ~s"""
        <div class="space-y-4">
          <div>
            <h4 class="font-semibold text-gray-800 mb-2">Performance Considerations</h4>
            <ul class="text-sm text-gray-600 space-y-1">
              <li>• Animated markers use CSS animations for smooth performance</li>
              <li>• Glow effects add minimal overhead with box-shadow</li>
              <li>• Use semantic presets for consistent styling across your app</li>
              <li>• Custom colors are validated at compile time</li>
            </ul>
          </div>
          <div>
            <h4 class="font-semibold text-gray-800 mb-2">Styling Strategies</h4>
            <ul class="text-sm text-gray-600 space-y-1">
              <li>• <strong>Automatic:</strong> Use cycle() for consistent multi-group colors</li>
              <li>• <strong>Semantic:</strong> Use presets for meaningful status indicators</li>
              <li>• <strong>Custom:</strong> Use custom() for brand-specific styling</li>
              <li>• <strong>Mixed:</strong> Combine approaches for complex scenarios</li>
            </ul>
          </div>
        </div>
        """
      },
      %{
        id: "production-config",
        title: "Production Configuration",
        content: ~s"""
        <div class="space-y-4">
          <p class="text-sm text-gray-700">
            Configure default styling in your application:
          </p>
          <pre class="bg-gray-100 p-4 rounded-lg text-sm"><code># config/config.exs
config :fly_map_ex,
  default_style: :operational,
  custom_presets: %{
    brand_primary: FlyMapEx.Style.custom("#your-brand-color", [
      size: 8,
      animation: :pulse,
      glow: true
    ])
  }</code></pre>
          <div class="mt-4">
            <h4 class="font-semibold text-gray-800 mb-2">Style Normalization</h4>
            <p class="text-sm text-gray-600">
              FlyMapEx automatically normalizes various style formats:
            </p>
            <ul class="text-sm text-gray-600 space-y-1 mt-2">
              <li>• Atoms (`:operational`) → style maps</li>
              <li>• Function calls (`operational()`) → style maps</li>
              <li>• Keyword lists → normalized style maps</li>
              <li>• Custom maps → validated and normalized</li>
            </ul>
          </div>
        </div>
        """
      }
    ]
  end

  # Tab content creation functions
  defp get_automatic_content do
    ~s"""
    <div class="space-y-4">
      <div>
        <h4 class="font-semibold text-gray-800 mb-2">Automatic Color Cycling</h4>
        <p class="text-sm text-gray-600 mb-3">
          The <code class="bg-gray-100 px-1 rounded">FlyMapEx.Style.cycle/1</code> function automatically assigns consistent colors to multiple groups without manual specification.
        </p>
      </div>

      <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h5 class="font-medium text-blue-800 mb-2">Color Progression</h5>
        <div class="grid grid-cols-2 gap-2 text-sm">
          <div class="flex items-center space-x-2">
            <div class="w-4 h-4 rounded-full bg-blue-600"></div>
            <span class="text-blue-700">cycle(0) - Blue</span>
          </div>
          <div class="flex items-center space-x-2">
            <div class="w-4 h-4 rounded-full bg-green-600"></div>
            <span class="text-blue-700">cycle(1) - Green</span>
          </div>
          <div class="flex items-center space-x-2">
            <div class="w-4 h-4 rounded-full bg-red-600"></div>
            <span class="text-blue-700">cycle(2) - Red</span>
          </div>
          <div class="flex items-center space-x-2">
            <div class="w-4 h-4 rounded-full bg-purple-600"></div>
            <span class="text-blue-700">cycle(3) - Purple</span>
          </div>
        </div>
      </div>

      <div>
        <h5 class="font-medium text-gray-800 mb-2">When to Use</h5>
        <ul class="text-sm text-gray-600 space-y-1">
          <li>• Multiple groups with equal importance</li>
          <li>• Need consistent visual hierarchy</li>
          <li>• Want to avoid color conflicts</li>
          <li>• Building dashboard-style displays</li>
        </ul>
      </div>

      <div class="bg-gray-50 border border-gray-200 rounded-lg p-3">
        <p class="text-xs text-gray-600">
          <strong>Pro Tip:</strong> cycle() automatically wraps after 12 colors, ensuring visual consistency across any number of groups.
        </p>
      </div>
    </div>
    """
  end

  defp get_semantic_content do
    ~s"""
    <div class="space-y-4">
      <div>
        <h4 class="font-semibold text-gray-800 mb-2">Semantic Styling</h4>
        <p class="text-sm text-gray-600 mb-3">
          Use meaningful preset functions that convey status and state at a glance.
        </p>
      </div>

      <div class="space-y-3">
        <div class="flex items-start space-x-3 p-3 bg-green-50 border border-green-200 rounded-lg">
          <div class="w-4 h-4 rounded-full bg-green-600 mt-0.5"></div>
          <div>
            <h5 class="font-medium text-green-800">operational()</h5>
            <p class="text-sm text-green-700">Healthy, running services. Green, static markers.</p>
          </div>
        </div>

        <div class="flex items-start space-x-3 p-3 bg-amber-50 border border-amber-200 rounded-lg">
          <div class="w-4 h-4 rounded-full bg-amber-500 mt-0.5"></div>
          <div>
            <h5 class="font-medium text-amber-800">warning()</h5>
            <p class="text-sm text-amber-700">Needs attention. Amber, static markers.</p>
          </div>
        </div>

        <div class="flex items-start space-x-3 p-3 bg-red-50 border border-red-200 rounded-lg">
          <div class="w-4 h-4 rounded-full bg-red-600 animate-pulse mt-0.5"></div>
          <div>
            <h5 class="font-medium text-red-800">danger()</h5>
            <p class="text-sm text-red-700">Critical issues. Red, pulsing animation for attention.</p>
          </div>
        </div>

        <div class="flex items-start space-x-3 p-3 bg-gray-50 border border-gray-200 rounded-lg">
          <div class="w-4 h-4 rounded-full bg-gray-500 mt-0.5"></div>
          <div>
            <h5 class="font-medium text-gray-800">inactive()</h5>
            <p class="text-sm text-gray-700">Not running or offline. Gray, static markers.</p>
          </div>
        </div>
      </div>

      <div class="bg-blue-50 border border-blue-200 rounded-lg p-3">
        <p class="text-xs text-blue-700">
          <strong>Best Practice:</strong> Use semantic styles for monitoring dashboards and status displays where color meaning is crucial.
        </p>
      </div>
    </div>
    """
  end

  defp get_custom_content do
    ~s"""
    <div class="space-y-4">
      <div>
        <h4 class="font-semibold text-gray-800 mb-2">Custom Parameters</h4>
        <p class="text-sm text-gray-600 mb-3">
          Build completely custom styles with <code class="bg-gray-100 px-1 rounded">FlyMapEx.Style.custom/2</code> for brand-specific or unique requirements.
        </p>
      </div>

      <div class="space-y-3">
        <div class="border border-gray-200 rounded-lg p-3">
          <h5 class="font-medium text-gray-800 mb-2">Size Parameter</h5>
          <div class="flex items-center space-x-3">
            <div class="w-2 h-2 rounded-full bg-blue-600"></div>
            <span class="text-sm">size: 4</span>
            <div class="w-3 h-3 rounded-full bg-blue-600"></div>
            <span class="text-sm">size: 6 (default)</span>
            <div class="w-4 h-4 rounded-full bg-blue-600"></div>
            <span class="text-sm">size: 8</span>
            <div class="w-5 h-5 rounded-full bg-blue-600"></div>
            <span class="text-sm">size: 10</span>
          </div>
        </div>

        <div class="border border-gray-200 rounded-lg p-3">
          <h5 class="font-medium text-gray-800 mb-2">Animation Options</h5>
          <div class="space-y-2 text-sm">
            <div class="flex items-center space-x-2">
              <div class="w-3 h-3 rounded-full bg-gray-600"></div>
              <span>:none - Static markers</span>
            </div>
            <div class="flex items-center space-x-2">
              <div class="w-3 h-3 rounded-full bg-blue-600 animate-pulse"></div>
              <span>:pulse - Radius grows/shrinks</span>
            </div>
            <div class="flex items-center space-x-2">
              <div class="w-3 h-3 rounded-full bg-green-600" style="animation: fade 2s infinite;"></div>
              <span>:fade - Opacity changes</span>
            </div>
          </div>
        </div>

        <div class="border border-gray-200 rounded-lg p-3">
          <h5 class="font-medium text-gray-800 mb-2">Glow Effect</h5>
          <div class="flex items-center space-x-4">
            <div class="text-center">
              <div class="w-4 h-4 rounded-full bg-purple-600 mx-auto mb-1"></div>
              <span class="text-xs">glow: false</span>
            </div>
            <div class="text-center">
              <div class="w-4 h-4 rounded-full bg-purple-600 mx-auto mb-1" style="box-shadow: 0 0 8px #9333ea;"></div>
              <span class="text-xs">glow: true</span>
            </div>
          </div>
        </div>
      </div>

      <div class="bg-purple-50 border border-purple-200 rounded-lg p-3">
        <p class="text-xs text-purple-700">
          <strong>Use Case:</strong> Perfect for brand-specific styling, special alerts, or when you need precise control over appearance.
        </p>
      </div>
    </div>
    """
  end

  defp get_mixed_content do
    ~s"""
    <div class="space-y-4">
      <div>
        <h4 class="font-semibold text-gray-800 mb-2">Mixed Approaches</h4>
        <p class="text-sm text-gray-600 mb-3">
          Combine different styling methods in one configuration for complex real-world scenarios.
        </p>
      </div>

      <div class="space-y-3">
        <div class="bg-green-50 border border-green-200 rounded-lg p-3">
          <div class="flex items-center space-x-2 mb-2">
            <div class="w-3 h-3 rounded-full bg-green-600"></div>
            <h5 class="font-medium text-green-800">Semantic Functions</h5>
          </div>
          <p class="text-sm text-green-700">Use operational(), warning(), etc. for critical status indicators.</p>
        </div>

        <div class="bg-blue-50 border border-blue-200 rounded-lg p-3">
          <div class="flex items-center space-x-2 mb-2">
            <div class="w-3 h-3 rounded-full bg-blue-600"></div>
            <h5 class="font-medium text-blue-800">Auto-Cycling</h5>
          </div>
          <p class="text-sm text-blue-700">Use cycle() for equal-importance groupings.</p>
        </div>

        <div class="bg-purple-50 border border-purple-200 rounded-lg p-3">
          <div class="flex items-center space-x-2 mb-2">
            <div class="w-4 h-4 rounded-full bg-purple-600 animate-pulse" style="box-shadow: 0 0 6px #9333ea;"></div>
            <h5 class="font-medium text-purple-800">Custom Styling</h5>
          </div>
          <p class="text-sm text-purple-700">Use custom() for special cases requiring unique appearance.</p>
        </div>

        <div class="bg-gray-50 border border-gray-200 rounded-lg p-3">
          <div class="flex items-center space-x-2 mb-2">
            <div class="w-3 h-3 rounded-full bg-gray-600"></div>
            <h5 class="font-medium text-gray-800">Atom Shortcuts</h5>
          </div>
          <p class="text-sm text-gray-700">Use :inactive, :operational atoms for convenience.</p>
        </div>
      </div>

      <div>
        <h5 class="font-medium text-gray-800 mb-2">Common Patterns</h5>
        <ul class="text-sm text-gray-600 space-y-1">
          <li>• <strong>Primary systems:</strong> Semantic styles for critical monitoring</li>
          <li>• <strong>Secondary groups:</strong> Auto-cycling for organization</li>
          <li>• <strong>Special alerts:</strong> Custom styles for unique cases</li>
          <li>• <strong>Utility groups:</strong> Atom shortcuts for simple cases</li>
        </ul>
      </div>

      <div class="bg-amber-50 border border-amber-200 rounded-lg p-3">
        <p class="text-xs text-amber-700">
          <strong>Production Tip:</strong> Start with semantic styles for core functionality, then add cycling and custom styles as needed.
        </p>
      </div>
    </div>
    """
  end

  # Generate focused code examples for each tab
  defp get_focused_code(example, marker_groups) do
    case example do
      "automatic" ->
        ~s"""
marker_groups = [
  %{
    nodes: ["sjc", "fra"],
    style: FlyMapEx.Style.cycle(0),
    label: "Production Servers"
  },
  %{
    nodes: ["ams", "lhr"],
    style: FlyMapEx.Style.cycle(1),
    label: "Staging Environment"
  }
]
        """

      "semantic" ->
        ~s"""
marker_groups = [
  %{
    nodes: ["sjc", "fra"],
    style: FlyMapEx.Style.operational(),
    label: "Production Servers"
  },
  %{
    nodes: ["ams", "lhr"],
    style: FlyMapEx.Style.warning(),
    label: "Maintenance Mode"
  },
  %{
    nodes: ["ord"],
    style: FlyMapEx.Style.danger(),
    label: "Failed Nodes"
  }
]
        """

      "custom" ->
        ~s"""
marker_groups = [
  %{
    nodes: ["sjc", "fra"],
    style: FlyMapEx.Style.custom("#10b981", [
      size: 8,
      animation: :pulse,
      glow: true
    ]),
    label: "High-Performance Servers"
  }
]
        """

      "mixed" ->
        ~s"""
marker_groups = [
  %{
    nodes: ["sjc", "fra"],
    style: FlyMapEx.Style.operational(),  # Semantic
    label: "Production (Semantic)"
  },
  %{
    nodes: ["ams", "lhr"],
    style: FlyMapEx.Style.cycle(1),      # Auto-cycle
    label: "Staging (Auto-Cycle)"
  },
  %{
    nodes: ["ord"],
    style: FlyMapEx.Style.custom("#9333ea", [
      size: 8, animation: :pulse, glow: true
    ]),                                   # Custom
    label: "Special Deploy (Custom)"
  },
  %{
    nodes: ["nrt", "syd"],
    style: :inactive,                    # Atom shorthand
    label: "Offline (Atom)"
  }
]
        """

      _ ->
        {_map_attrs, code_string} = DemoWeb.Components.MapWithCodeComponent.build_map_and_code(%{
          marker_groups: marker_groups,
          theme: :responsive
        })
        code_string
    end
  end
end
