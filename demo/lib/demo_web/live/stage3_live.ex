defmodule DemoWeb.Stage3Live do
  use DemoWeb, :live_view

  import DemoWeb.Components.DemoNavigation
  import DemoWeb.Components.InteractiveControls
  import DemoWeb.Components.ProgressiveDisclosure
  import DemoWeb.Components.SidebarLayout
  import DemoWeb.Components.SidebarNavigation
  
  alias DemoWeb.Helpers.CodeGenerator

  def mount(_params, _session, socket) do
    # Define examples that showcase different theme characteristics
    examples = %{
      presets: [
        %{
          nodes: ["sjc", "fra", "ams"],
          style: FlyMapEx.Style.operational(),
          label: "Production Servers"
        },
        %{
          nodes: ["lhr", "syd"],
          style: FlyMapEx.Style.warning(),
          label: "Maintenance Mode"
        },
        %{
          nodes: ["ord", "nrt"],
          style: FlyMapEx.Style.danger(),
          label: "Failed Nodes"
        }
      ],
      responsive: [
        %{
          nodes: ["sjc", "fra", "ams", "lhr"],
          style: FlyMapEx.Style.operational(),
          label: "Global Infrastructure"
        },
        %{
          nodes: ["ord", "nrt"],
          style: FlyMapEx.Style.inactive(),
          label: "Standby Nodes"
        }
      ],
      custom: [
        %{
          nodes: ["sjc", "fra"],
          style: FlyMapEx.Style.custom("#10b981", size: 8, animation: :pulse, glow: true),
          label: "High-Performance Tier"
        },
        %{
          nodes: ["ams", "lhr"],
          style: FlyMapEx.Style.custom("#f59e0b", size: 6, animation: :fade, glow: false),
          label: "Standard Tier"
        },
        %{
          nodes: ["ord"],
          style: FlyMapEx.Style.custom("#ef4444", size: 10, animation: :pulse, glow: true),
          label: "Critical Alert"
        }
      ],
      configuration: [
        %{
          nodes: ["sjc", "fra", "ams"],
          style: FlyMapEx.Style.operational(),
          label: "Production Environment"
        },
        %{
          nodes: ["lhr", "syd"],
          style: FlyMapEx.Style.warning(),
          label: "Staging Environment"
        }
      ]
    }

    tabs = [
      %{key: "presets", label: "Theme Presets", content: get_tab_content("presets")},
      %{key: "responsive", label: "Responsive", content: get_tab_content("responsive")},
      %{key: "custom", label: "Custom", content: get_tab_content("custom")},
      %{key: "configuration", label: "Configuration", content: get_tab_content("configuration")}
    ]

    {:ok,
     assign(socket,
       examples: examples,
       current_theme: "presets",
       tabs: tabs
     )}
  end

  def handle_event("switch_example", %{"option" => theme}, socket) do
    {:noreply, assign(socket, current_theme: theme)}
  end


  def render(assigns) do
    ~H"""
    <.demo_navigation current_page={:stage3} />
        <.sidebar_layout>
      <:sidebar>
        <.sidebar_navigation current_page={:stage3} tabs={@tabs} current_tab={@current_theme} />
      </:sidebar>

      <:main>

    <div class="container mx-auto p-8">
      <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-3xl font-bold text-base-content">Stage 3: Map Themes</h1>
        </div>
        <p class="text-base-content/70 mb-6">
          Control overall visual presentation and branding with FlyMapEx's comprehensive theming system.
        </p>
      </div>

      <!-- Full Width Map (Above the Fold) -->
      <div class="mb-8 p-6 bg-base-200 rounded-lg">
        <FlyMapEx.render
          marker_groups={current_marker_groups(assigns)}
          theme={get_current_theme(@current_theme)}
          layout={:side_by_side}
        />
      </div>

      <!-- Side-by-Side: Tabbed Info Panel & Code Examples -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
        <!-- Tabbed Info Panel -->
        <div>
          <.tabbed_info_panel
            tabs={@tabs}
            current={@current_theme}
            event="switch_example"
            show_tabs={false}
          />
        </div>

        <!-- Code Examples Panel -->
        <div>
          <div class="bg-base-100 border border-base-300 rounded-lg overflow-hidden">
            <div class="bg-base-200 px-4 py-3 border-b border-base-300">
              <h3 class="font-semibold text-base-content">Code Example</h3>
            </div>
            <div class="p-4">
              <pre class="text-sm text-base-content overflow-x-auto bg-base-200 p-3 rounded"><code><%= get_focused_code(@current_theme, current_marker_groups(assigns)) %></code></pre>
            </div>

            <!-- Quick Stats -->
            <div class="bg-primary/10 border-t border-base-300 px-4 py-3">
              <div class="text-sm text-primary/80">
                <strong>Current Theme:</strong> <%= get_current_description(@current_theme) %> •
                Theme: <%= get_current_theme(@current_theme) %> •
                <%= length(current_marker_groups(assigns)) %> groups • <%= get_total_nodes(current_marker_groups(assigns)) %> nodes
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
        <.link navigate={~p"/stage2"} class="inline-block bg-neutral text-neutral-content px-6 py-2 rounded-lg hover:bg-neutral/80 transition-colors">
          ← Stage 2: Styling Markers
        </.link>
        <.link navigate={~p"/stage4"} class="inline-block bg-primary text-primary-content px-6 py-2 rounded-lg hover:bg-primary/80 transition-colors">
          Next: Stage 4 - Interactive Builder →
        </.link>
      </div>
    </div>
              </:main>
    </.sidebar_layout>

    """
  end

  # Helper functions for the new CodeGenerator pattern
  defp current_marker_groups(assigns) do
    Map.get(assigns.examples, String.to_atom(assigns.current_theme), [])
  end

  defp get_focused_code(theme_type, marker_groups) do
    # Use the shared CodeGenerator for consistent code generation
    CodeGenerator.generate_flymap_code(
      marker_groups,
      theme: get_current_theme(theme_type),
      layout: :side_by_side,
      context: get_current_description(theme_type)
    )
  end

  defp get_total_nodes(marker_groups) do
    marker_groups
    |> Enum.reduce(0, fn group, acc ->
      acc + length(group.nodes)
    end)
  end

  # Streamlined content generation functions
  defp get_tab_content("presets") do
    """
    <div class="space-y-4">
      <div>
        <h3 class="font-semibold text-base-content mb-3">Predefined Theme Presets</h3>
        <p class="text-base-content/70 text-sm mb-4">
          Ready-to-use themes optimized for common use cases. Quick to implement and consistently styled.
        </p>
      </div>

      <div class="space-y-3">
        <div class="bg-primary/10 border border-primary/20 rounded-lg p-3">
          <h4 class="font-medium text-primary mb-1">:dashboard</h4>
          <p class="text-sm text-primary">Compact design for control panels and admin interfaces.</p>
        </div>

        <div class="bg-success/10 border border-success/20 rounded-lg p-3">
          <h4 class="font-medium text-success mb-1">:monitoring</h4>
          <p class="text-sm text-success">Standard size with clear visibility for status dashboards.</p>
        </div>

        <div class="bg-secondary/10 border border-secondary/20 rounded-lg p-3">
          <h4 class="font-medium text-secondary mb-1">:presentation</h4>
          <p class="text-sm text-secondary">Large markers with warm colours for demos and presentations.</p>
        </div>

        <div class="bg-base-200 border border-base-300 rounded-lg p-3">
          <h4 class="font-medium text-base-content mb-1">Also available:</h4>
          <div class="text-sm text-base-content/80">
            <code>:minimal</code> • <code>:dark</code> • <code>:light</code> • <code>:high_contrast</code>
          </div>
        </div>
      </div>

      <div class="bg-success/10 border border-success/20 rounded-lg p-3">
        <p class="text-sm text-success/80">
          <strong>Use when:</strong> You need consistent styling or want to match common interface patterns.
        </p>
      </div>
    </div>
    """
  end

  defp get_tab_content("responsive") do
    """
    <div class="space-y-4">
      <div>
        <h3 class="font-semibold text-base-content mb-3">Responsive Theme</h3>
        <p class="text-base-content/70 text-sm mb-4">
          Automatically adapts to your site's design system using CSS custom properties. Perfect for seamless integration.
        </p>
      </div>

      <div class="space-y-3">
        <div class="bg-primary/10 border border-primary/20 rounded-lg p-3">
          <h4 class="font-medium text-primary mb-1">CSS Custom Properties</h4>
          <p class="text-sm text-primary mb-2">Reads your site's CSS variables:</p>
          <div class="text-xs text-primary/80 space-y-1">
            <div><code>--color-background</code> → land areas</div>
            <div><code>--color-border</code> → country borders</div>
            <div><code>--color-muted</code> → ocean areas</div>
          </div>
        </div>

        <div class="bg-success/10 border border-success/20 rounded-lg p-3">
          <h4 class="font-medium text-success mb-1">Context Awareness</h4>
          <p class="text-sm text-success">Automatically adapts to light/dark mode and high contrast settings.</p>
        </div>

        <div class="bg-warning/10 border border-warning/20 rounded-lg p-3">
          <h4 class="font-medium text-warning mb-1">Setup Example</h4>
          <pre class="text-xs text-warning/80 bg-warning/20 p-2 rounded mt-2"><code>:root {
            --color-background: #f8fafc;
            --color-border: #e2e8f0;
            --color-muted: #cbd5e1;
          }</code></pre>
        </div>
      </div>

      <div class="bg-success/10 border border-success/20 rounded-lg p-3">
        <p class="text-sm text-success/80">
          <strong>Best practice:</strong> Use as your default theme for maintenance-free branding consistency.
        </p>
      </div>
    </div>
    """
  end

  defp get_tab_content("custom") do
    """
    <div class="space-y-4">
      <div>
        <h3 class="font-semibold text-base-content mb-3">Custom Theme Creation</h3>
        <p class="text-base-content/70 text-sm mb-4">
          Create completely custom themes with full control over colours. Perfect for branded experiences.
        </p>
      </div>

      <div class="space-y-3">
        <div class="bg-primary/10 border border-primary/20 rounded-lg p-3">
          <h4 class="font-medium text-primary mb-1">Theme Properties</h4>
          <div class="text-sm text-primary space-y-1">
            <div><code>land_color</code> → Countries and land masses</div>
            <div><code>ocean_color</code> → Water areas</div>
            <div><code>border_color</code> → Country borders</div>
            <div><code>background_color</code> → Container background</div>
          </div>
        </div>

        <div class="bg-success/10 border border-success/20 rounded-lg p-3">
          <h4 class="font-medium text-success mb-1">Colour Formats</h4>
          <div class="text-sm text-success">
            Supports hex, RGB, HSL, CSS variables, and named colours.
          </div>
        </div>

        <div class="bg-warning/10 border border-warning/20 rounded-lg p-3">
          <h4 class="font-medium text-warning mb-1">Accessibility</h4>
          <p class="text-sm text-warning">Ensure 4.5:1 contrast ratio and don't rely solely on colour for information.</p>
        </div>
      </div>

      <div class="bg-success/10 border border-success/20 rounded-lg p-3">
        <p class="text-sm text-success/80">
          <strong>Use when:</strong> You need precise visual control or brand-specific experiences.
        </p>
      </div>
    </div>
    """
  end

  defp get_tab_content("configuration") do
    """
    <div class="space-y-4">
      <div>
        <h3 class="font-semibold text-base-content mb-3">Theme Configuration</h3>
        <p class="text-base-content/70 text-sm mb-4">
          Configure themes at the application level for consistent theming across your entire app.
        </p>
      </div>

      <div class="space-y-3">
        <div class="bg-primary/10 border border-primary/20 rounded-lg p-3">
          <h4 class="font-medium text-primary mb-1">Application Config</h4>
          <pre class="text-xs text-primary/80 bg-primary/20 p-2 rounded mt-2"><code># config/config.exs
          config :fly_map_ex,
            default_theme: :responsive</code></pre>
        </div>

        <div class="bg-success/10 border border-success/20 rounded-lg p-3">
          <h4 class="font-medium text-success mb-1">Environment-Specific</h4>
          <div class="text-sm text-success space-y-1">
            <div><strong>Dev:</strong> <code>:light</code> - Bright debugging</div>
            <div><strong>Prod:</strong> <code>:responsive</code> - Adaptive</div>
          </div>
        </div>

        <div class="bg-secondary/10 border border-secondary/20 rounded-lg p-3">
          <h4 class="font-medium text-secondary mb-1">Precedence Order</h4>
          <div class="text-sm text-secondary space-y-1">
            <div>1. Inline theme prop</div>
            <div>2. Component default</div>
            <div>3. Application config</div>
            <div>4. Library default</div>
          </div>
        </div>
      </div>

      <div class="bg-success/10 border border-success/20 rounded-lg p-3">
        <p class="text-sm text-success/80">
          <strong>Best practice:</strong> Use config-based themes for centralized management and consistency.
        </p>
      </div>
    </div>
    """
  end

  defp get_tab_content(_), do: "<div>Unknown tab content</div>"

  # Helper functions for the template
  defp get_current_description(theme) do
    case theme do
      "presets" -> "Predefined themes for common use cases"
      "responsive" -> "Adaptive theming that responds to context"
      "custom" -> "Custom theme creation with full control"
      "configuration" -> "Theme configuration and deployment patterns"
      _ -> "Unknown theme approach"
    end
  end

  defp get_current_theme(theme_type) do
    case theme_type do
      "presets" -> :dashboard
      "responsive" -> :responsive
      "custom" -> :minimal
      "configuration" -> :light
      _ -> :responsive
    end
  end


  defp get_advanced_topics do
    [
      %{
        id: "theme-performance",
        title: "Theme Performance Optimization",
        description: "Learn how to optimize theme rendering for large-scale applications",
        content: "<p class='text-sm text-base-content/80 mb-4'>Advanced caching strategies, CSS optimization, and bundle size management for theme systems.</p><ul class='text-sm text-base-content/80 space-y-2'><li>• <strong>CSS Caching:</strong> Implement smart caching strategies for theme assets</li><li>• <strong>Bundle Optimization:</strong> Minimize CSS payload with critical theme extraction</li><li>• <strong>Runtime Performance:</strong> Optimize theme switching with CSS custom properties</li></ul>"
      },
      %{
        id: "theme-libraries",
        title: "Creating Theme Libraries",
        description: "Build reusable theme collections for your organization",
        content: "<p class='text-sm text-base-content/80 mb-4'>Structured approaches to creating, sharing, and maintaining theme libraries across projects.</p><ul class='text-sm text-base-content/80 space-y-2'><li>• <strong>Theme Architecture:</strong> Design scalable theme systems with inheritance</li><li>• <strong>Version Management:</strong> Maintain backwards compatibility across theme updates</li><li>• <strong>Documentation:</strong> Create comprehensive theme guides and examples</li></ul>"
      },
      %{
        id: "dynamic-switching",
        title: "Dynamic Theme Switching",
        description: "Implement real-time theme changes based on user preferences",
        content: "<p class='text-sm text-base-content/80 mb-4'>LiveView patterns for dynamic theme updates without page reloads.</p><ul class='text-sm text-base-content/80 space-y-2'><li>• <strong>User Preferences:</strong> Store and persist theme choices</li><li>• <strong>Context Switching:</strong> Automatically adapt themes based on time, location, or user context</li><li>• <strong>Smooth Transitions:</strong> Implement animated theme changes with CSS transitions</li></ul>"
      }
    ]
  end

end
