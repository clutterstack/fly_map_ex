defmodule DemoWeb.Stage3Live do
  use DemoWeb, :live_view

  alias DemoWeb.Layouts
  import DemoWeb.Components.DemoNavigation
  import DemoWeb.Components.InteractiveControls
  import DemoWeb.Components.ProgressiveDisclosure

  def mount(_params, _session, socket) do
    marker_groups = [
      %{
        nodes: ["sjc", "fra", "ams"],
        style: FlyMapEx.Style.operational(),
        label: "Production Servers"
      },
      %{
        nodes: ["lhr", "syd"],
        style: FlyMapEx.Style.warning(),
        label: "Maintenance Mode"
      }
    ]

    tabs = [
      %{key: "presets", label: "Theme Presets", content: get_static_tab_content("presets")},
      %{key: "responsive", label: "Responsive", content: get_static_tab_content("responsive")},
      %{key: "custom", label: "Custom", content: get_static_tab_content("custom")},
      %{key: "configuration", label: "Configuration", content: get_static_tab_content("configuration")}
    ]

    {:ok,
     assign(socket,
       marker_groups: marker_groups,
       current_theme: "presets",
       tabs: tabs
     )}
  end

  def handle_event("switch_theme", %{"option" => theme}, socket) do
    {:noreply, assign(socket, current_theme: theme)}
  end


  def render(assigns) do
    ~H"""
    <.demo_navigation current_page={:stage3} />
    <div class="container mx-auto p-8">
      <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-3xl font-bold text-gray-800">Stage 3: Map Themes</h1>
          <Layouts.theme_toggle />
        </div>
        <p class="text-gray-600 mb-6">
          Control overall visual presentation and branding with FlyMapEx's comprehensive theming system.
        </p>
      </div>

      <!-- Full Width Map (Above the Fold) -->
      <div class="mb-8 p-6 bg-gray-50 rounded-lg">
        <FlyMapEx.render
          marker_groups={@marker_groups}
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
            event="switch_theme"
          />
        </div>

        <!-- Code Examples Panel -->
        <div>
          <div class="bg-white border border-gray-200 rounded-lg overflow-hidden">
            <div class="bg-gray-50 px-4 py-3 border-b border-gray-200">
              <h3 class="font-semibold text-gray-800">Code Example</h3>
            </div>
            <div class="p-4">
              <pre class="text-sm text-gray-800 overflow-x-auto bg-gray-50 p-3 rounded"><code><%= get_focused_code(@current_theme) %></code></pre>
            </div>

            <!-- Quick Stats -->
            <div class="bg-blue-50 border-t border-gray-200 px-4 py-3">
              <div class="text-sm text-blue-700">
                <strong>Current Theme:</strong> <%= get_current_description(@current_theme) %> •
                Theme: <%= get_current_theme(@current_theme) %> •
                2 groups • 5 nodes
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
        <.link navigate={~p"/stage2"} class="inline-block bg-gray-600 text-white px-6 py-2 rounded-lg hover:bg-gray-700 transition-colors">
          ← Stage 2: Styling Markers
        </.link>
        <.link navigate={~p"/stage4"} class="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors">
          Next: Stage 4 - Interactive Builder →
        </.link>
      </div>
    </div>
    """
  end

  # Static HTML content generation functions
  defp get_static_tab_content("presets") do
    """
    <div class="space-y-6">
      <div>
        <h3 class="font-semibold text-gray-800 mb-3">Predefined Theme Presets</h3>
        <p class="text-gray-600 text-sm mb-4">
          FlyMapEx provides carefully crafted theme presets optimized for common use cases.
          Each preset includes coordinated colours, typography, and spacing designed for specific interface contexts.
        </p>
      </div>

      <div class="space-y-4">
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <h4 class="font-medium text-blue-900 mb-2">:dashboard Theme</h4>
          <p class="text-sm text-blue-800 mb-2">Compact design with cool colours for control panels and admin interfaces.</p>
          <div class="flex gap-2 mb-2">
            <div class="w-4 h-4 bg-blue-100 border border-blue-300 rounded" title="Land Colour"></div>
            <div class="w-4 h-4 bg-blue-200 border border-blue-300 rounded" title="Ocean Colour"></div>
            <div class="w-4 h-4 bg-blue-600 border border-blue-300 rounded" title="Border Colour"></div>
          </div>
          <ul class="text-sm text-blue-700 space-y-1">
            <li>• Reduced visual weight for dense information displays</li>
            <li>• Cool colour palette reduces eye strain</li>
            <li>• Perfect for operational dashboards</li>
          </ul>
        </div>

        <div class="bg-green-50 border border-green-200 rounded-lg p-4">
          <h4 class="font-medium text-green-900 mb-2">:monitoring Theme</h4>
          <p class="text-sm text-green-800 mb-2">Standard size with clear visibility for status dashboards and real-time monitoring.</p>
          <div class="flex gap-2 mb-2">
            <div class="w-4 h-4 bg-green-100 border border-green-300 rounded" title="Land Colour"></div>
            <div class="w-4 h-4 bg-green-200 border border-green-300 rounded" title="Ocean Colour"></div>
            <div class="w-4 h-4 bg-green-600 border border-green-300 rounded" title="Border Colour"></div>
          </div>
          <ul class="text-sm text-green-700 space-y-1">
            <li>• Balanced sizing for extended viewing</li>
            <li>• High contrast for quick status recognition</li>
            <li>• Optimized for NOC and monitoring environments</li>
          </ul>
        </div>

        <div class="bg-purple-50 border border-purple-200 rounded-lg p-4">
          <h4 class="font-medium text-purple-900 mb-2">:presentation Theme</h4>
          <p class="text-sm text-purple-800 mb-2">Large markers with warm colours for demos, presentations, and public displays.</p>
          <div class="flex gap-2 mb-2">
            <div class="w-4 h-4 bg-orange-100 border border-orange-300 rounded" title="Land Colour"></div>
            <div class="w-4 h-4 bg-orange-200 border border-orange-300 rounded" title="Ocean Colour"></div>
            <div class="w-4 h-4 bg-orange-600 border border-orange-300 rounded" title="Border Colour"></div>
          </div>
          <ul class="text-sm text-purple-700 space-y-1">
            <li>• Larger markers for distance viewing</li>
            <li>• Warm colour palette for engagement</li>
            <li>• High visual impact for presentations</li>
          </ul>
        </div>

        <div class="bg-gray-50 border border-gray-200 rounded-lg p-4">
          <h4 class="font-medium text-gray-900 mb-2">Additional Presets</h4>
          <div class="grid grid-cols-2 gap-2 text-sm">
            <div class="flex items-center space-x-2">
              <code class="bg-white px-1 rounded text-xs">:minimal</code>
              <span class="text-gray-700">Clean grayscale</span>
            </div>
            <div class="flex items-center space-x-2">
              <code class="bg-white px-1 rounded text-xs">:dark</code>
              <span class="text-gray-700">Dark backgrounds</span>
            </div>
            <div class="flex items-center space-x-2">
              <code class="bg-white px-1 rounded text-xs">:light</code>
              <span class="text-gray-700">Light, airy design</span>
            </div>
            <div class="flex items-center space-x-2">
              <code class="bg-white px-1 rounded text-xs">:high_contrast</code>
              <span class="text-gray-700">Accessibility focused</span>
            </div>
          </div>
        </div>
      </div>

      <div class="bg-emerald-50 border border-emerald-200 rounded-lg p-4">
        <p class="text-sm text-emerald-700">
          <strong>Pro tip:</strong> Presets are perfect when you need consistent styling across multiple maps
          or want to quickly match common interface patterns. They're also great starting points for customization.
        </p>
      </div>
    </div>
    """
  end

  defp get_static_tab_content("responsive") do
    """
    <div class="space-y-6">
      <div>
        <h3 class="font-semibold text-gray-800 mb-3">Responsive Theme System</h3>
        <p class="text-gray-600 text-sm mb-4">
          The responsive theme automatically adapts to your site's design system using CSS custom properties.
          Perfect for component libraries and design systems that need consistent visual integration.
        </p>
      </div>

      <div class="space-y-4">
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <h4 class="font-medium text-blue-900 mb-2">Automatic CSS Property Detection</h4>
          <p class="text-sm text-blue-800 mb-2">Reads your site's CSS custom properties in order of precedence:</p>
          <ul class="text-sm text-blue-700 space-y-1">
            <li>• <code class="bg-blue-100 px-1 rounded">--color-background</code> for land areas</li>
            <li>• <code class="bg-blue-100 px-1 rounded">--color-border</code> for country borders</li>
            <li>• <code class="bg-blue-100 px-1 rounded">--color-muted</code> for ocean areas</li>
            <li>• <code class="bg-blue-100 px-1 rounded">--color-surface</code> for map container</li>
          </ul>
        </div>

        <div class="bg-green-50 border border-green-200 rounded-lg p-4">
          <h4 class="font-medium text-green-900 mb-2">Context Awareness</h4>
          <p class="text-sm text-green-800 mb-2">Automatically adjusts for different contexts:</p>
          <ul class="text-sm text-green-700 space-y-1">
            <li>• <strong>Light/Dark Mode:</strong> Adapts colours based on <code class="bg-green-100 px-1 rounded">prefers-color-scheme</code></li>
            <li>• <strong>High Contrast:</strong> Responds to <code class="bg-green-100 px-1 rounded">prefers-contrast</code> accessibility settings</li>
            <li>• <strong>Brand Variations:</strong> Follows your site's brand colour updates</li>
            <li>• <strong>Seasonal Themes:</strong> Automatically inherits promotional theme changes</li>
          </ul>
        </div>

        <div class="bg-purple-50 border border-purple-200 rounded-lg p-4">
          <h4 class="font-medium text-purple-900 mb-2">Design System Integration</h4>
          <p class="text-sm text-purple-800 mb-2">Works seamlessly with popular design systems:</p>
          <div class="grid grid-cols-2 gap-2 text-sm">
            <div class="flex items-center space-x-2">
              <span class="w-3 h-3 bg-purple-400 rounded-full"></span>
              <span class="text-purple-700">Tailwind CSS</span>
            </div>
            <div class="flex items-center space-x-2">
              <span class="w-3 h-3 bg-purple-400 rounded-full"></span>
              <span class="text-purple-700">Chakra UI</span>
            </div>
            <div class="flex items-center space-x-2">
              <span class="w-3 h-3 bg-purple-400 rounded-full"></span>
              <span class="text-purple-700">Material UI</span>
            </div>
            <div class="flex items-center space-x-2">
              <span class="w-3 h-3 bg-purple-400 rounded-full"></span>
              <span class="text-purple-700">Custom CSS</span>
            </div>
          </div>
        </div>

        <div class="bg-amber-50 border border-amber-200 rounded-lg p-4">
          <h4 class="font-medium text-amber-900 mb-2">Implementation Example</h4>
          <p class="text-sm text-amber-800 mb-2">Set up responsive theming in your CSS:</p>
          <pre class="text-xs text-amber-700 bg-amber-100 p-2 rounded"><code>:root {
  --color-background: #f8fafc;
  --color-border: #e2e8f0;
  --color-muted: #cbd5e1;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-background: #1e293b;
    --color-border: #475569;
    --color-muted: #334155;
  }
}</code></pre>
        </div>
      </div>

      <div class="bg-emerald-50 border border-emerald-200 rounded-lg p-4">
        <p class="text-sm text-emerald-700">
          <strong>Best practice:</strong> Use responsive theme as your default to ensure maps always match your site's visual identity.
          It's the most maintenance-free approach for consistent branding.
        </p>
      </div>
    </div>
    """
  end

  defp get_static_tab_content("custom") do
    ~s"""
    <div class="space-y-6">
      <div>
        <h3 class="font-semibold text-gray-800 mb-3">Custom Theme Creation</h3>
        <p class="text-gray-600 text-sm mb-4">
          Create completely custom themes with full control over colours, typography, and spacing.
          Perfect for branded experiences and unique design requirements.
        </p>
      </div>

      <div class="space-y-4">
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <h4 class="font-medium text-blue-900 mb-2">Theme Map Structure</h4>
          <p class="text-sm text-blue-800 mb-2">Define custom themes using a map with these properties:</p>
          <div class="space-y-2 text-sm">
            <div class="flex items-center space-x-2">
              <code class="bg-blue-100 px-1 rounded text-xs">land_color</code>
              <span class="text-blue-700">Background colour for countries and land masses</span>
            </div>
            <div class="flex items-center space-x-2">
              <code class="bg-blue-100 px-1 rounded text-xs">ocean_color</code>
              <span class="text-blue-700">Background colour for oceans and water</span>
            </div>
            <div class="flex items-center space-x-2">
              <code class="bg-blue-100 px-1 rounded text-xs">border_color</code>
              <span class="text-blue-700">Stroke colour for country borders</span>
            </div>
            <div class="flex items-center space-x-2">
              <code class="bg-blue-100 px-1 rounded text-xs">background_color</code>
              <span class="text-blue-700">Overall container background</span>
            </div>
          </div>
        </div>

        <div class="bg-green-50 border border-green-200 rounded-lg p-4">
          <h4 class="font-medium text-green-900 mb-2">Colour Format Support</h4>
          <p class="text-sm text-green-800 mb-2">Use any valid CSS colour format:</p>
          <ul class="text-sm text-green-700 space-y-1">
            <li>• <strong>Hex:</strong> <code class="bg-green-100 px-1 rounded">"#3b82f6"</code></li>
            <li>• <strong>RGB:</strong> <code class="bg-green-100 px-1 rounded">"rgb(59, 130, 246)"</code></li>
            <li>• <strong>HSL:</strong> <code class="bg-green-100 px-1 rounded">"hsl(217, 91%, 60%)"</code></li>
            <li>• <strong>CSS Variables:</strong> <code class="bg-green-100 px-1 rounded">"var(--primary-color)"</code></li>
            <li>• <strong>Named:</strong> <code class="bg-green-100 px-1 rounded">"steelblue"</code></li>
          </ul>
        </div>

        <div class="bg-purple-50 border border-purple-200 rounded-lg p-4">
          <h4 class="font-medium text-purple-900 mb-2">Brand Integration Examples</h4>
          <p class="text-sm text-purple-800 mb-2">Common branding patterns:</p>
          <div class="space-y-2 text-sm">
            <div class="p-2 bg-purple-100 rounded">
              <strong class="text-purple-900">Corporate:</strong> 
              <span class="text-purple-700">Subtle company colours, professional appearance</span>
            </div>
            <div class="p-2 bg-purple-100 rounded">
              <strong class="text-purple-900">Product:</strong> 
              <span class="text-purple-700">Match your product's colour scheme and personality</span>
            </div>
            <div class="p-2 bg-purple-100 rounded">
              <strong class="text-purple-900">White-label:</strong> 
              <span class="text-purple-700">Configurable themes for client customization</span>
            </div>
          </div>
        </div>

        <div class="bg-amber-50 border border-amber-200 rounded-lg p-4">
          <h4 class="font-medium text-amber-900 mb-2">Accessibility Considerations</h4>
          <p class="text-sm text-amber-800 mb-2">Ensure your custom themes meet accessibility standards:</p>
          <ul class="text-sm text-amber-700 space-y-1">
            <li>• <strong>Contrast Ratio:</strong> 4.5:1 minimum for text/background</li>
            <li>• <strong>Colour Blindness:</strong> Don't rely solely on colour for information</li>
            <li>• <strong>Focus Indicators:</strong> Ensure interactive elements are visible</li>
            <li>• <strong>Test Tools:</strong> Use browser dev tools to verify accessibility</li>
          </ul>
        </div>
      </div>

      <div class="bg-emerald-50 border border-emerald-200 rounded-lg p-4">
        <p class="text-sm text-emerald-700">
          <strong>Use case:</strong> Custom themes are ideal for white-label applications, brand-specific experiences, 
          or when you need precise visual control. They're perfect for embedding maps in existing designs.
        </p>
      </div>
    </div>
    """
  end

  defp get_static_tab_content("configuration") do
    ~s"""
    <div class="space-y-6">
      <div>
        <h3 class="font-semibold text-gray-800 mb-3">Theme Configuration Patterns</h3>
        <p class="text-gray-600 text-sm mb-4">
          Learn how to configure themes at the application level and understand
          theme precedence and override rules for production deployments.
        </p>
      </div>

      <div class="space-y-4">
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <h4 class="font-medium text-blue-900 mb-2">Application-Level Configuration</h4>
          <p class="text-sm text-blue-800 mb-2">Set default themes in your config.exs:</p>
          <pre class="text-xs text-blue-700 bg-blue-100 p-2 rounded"><code># config/config.exs
config :fly_map_ex,
  default_theme: :responsive,
  fallback_theme: :light</code></pre>
          <p class="text-sm text-blue-800 mt-2">Components automatically use the configured theme when no explicit theme is provided.</p>
        </div>

        <div class="bg-green-50 border border-green-200 rounded-lg p-4">
          <h4 class="font-medium text-green-900 mb-2">Environment-Specific Themes</h4>
          <p class="text-sm text-green-800 mb-2">Configure different themes per environment:</p>
          <div class="space-y-2 text-sm">
            <div class="p-2 bg-green-100 rounded">
              <strong class="text-green-900">Development:</strong> 
              <code class="bg-white px-1 rounded text-xs">:light</code>
              <span class="text-green-700">- Bright, easy debugging</span>
            </div>
            <div class="p-2 bg-green-100 rounded">
              <strong class="text-green-900">Staging:</strong> 
              <code class="bg-white px-1 rounded text-xs">:monitoring</code>
              <span class="text-green-700">- Production-like testing</span>
            </div>
            <div class="p-2 bg-green-100 rounded">
              <strong class="text-green-900">Production:</strong> 
              <code class="bg-white px-1 rounded text-xs">:responsive</code>
              <span class="text-green-700">- Adaptive to user preferences</span>
            </div>
          </div>
        </div>

        <div class="bg-purple-50 border border-purple-200 rounded-lg p-4">
          <h4 class="font-medium text-purple-900 mb-2">Theme Precedence Rules</h4>
          <p class="text-sm text-purple-800 mb-2">Themes are applied in this order (highest to lowest priority):</p>
          <ol class="text-sm text-purple-700 space-y-1">
            <li>1. <strong>Inline theme prop:</strong> <code class="bg-purple-100 px-1 rounded">theme={:custom}</code></li>
            <li>2. <strong>Component default:</strong> Set via component attributes</li>
            <li>3. <strong>Application config:</strong> From config.exs</li>
            <li>4. <strong>Library default:</strong> FlyMapEx's built-in theme</li>
          </ol>
        </div>

        <div class="bg-amber-50 border border-amber-200 rounded-lg p-4">
          <h4 class="font-medium text-amber-900 mb-2">Production Deployment Patterns</h4>
          <p class="text-sm text-amber-800 mb-2">Common deployment strategies:</p>
          <ul class="text-sm text-amber-700 space-y-1">
            <li>• <strong>Feature Flags:</strong> Toggle themes based on user segments</li>
            <li>• <strong>A/B Testing:</strong> Compare theme performance</li>
            <li>• <strong>White-labeling:</strong> Client-specific theme configuration</li>
            <li>• <strong>Runtime Updates:</strong> Change themes without deployment</li>
          </ul>
        </div>

        <div class="bg-gray-50 border border-gray-200 rounded-lg p-4">
          <h4 class="font-medium text-gray-900 mb-2">Advanced Configuration</h4>
          <p class="text-sm text-gray-800 mb-2">For complex applications:</p>
          <pre class="text-xs text-gray-700 bg-gray-100 p-2 rounded"><code># Dynamic theme resolution
def get_theme_for_user(user) do
  case user.preferences do
    %{theme: theme} when theme != nil -> theme
    %{dark_mode: true} -> :dark
    _ -> Application.get_env(:fly_map_ex, :default_theme)
  end
end</code></pre>
        </div>
      </div>

      <div class="bg-emerald-50 border border-emerald-200 rounded-lg p-4">
        <p class="text-sm text-emerald-700">
          <strong>Deployment tip:</strong> Use configuration-based themes for easier maintenance and consistent updates across your application.
          This approach enables centralized theme management and reduces code duplication.
        </p>
      </div>
    </div>
    """
  end

  defp get_static_tab_content(_), do: "<div>Unknown tab content</div>"

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

  defp get_focused_code(theme_type) do
    case theme_type do
      "presets" ->
        ~s[# Predefined theme presets - simple and effective
<FlyMapEx.render
  marker_groups={@marker_groups}
  theme={:dashboard}  # Compact for control panels
/>

# Available preset themes:
<FlyMapEx.render theme={:monitoring} />    # Standard visibility
<FlyMapEx.render theme={:presentation} />  # Large for demos
<FlyMapEx.render theme={:minimal} />       # Clean grayscale
<FlyMapEx.render theme={:dark} />          # Dark backgrounds
<FlyMapEx.render theme={:high_contrast} /> # Accessibility

# Perfect for quick deployment with proven designs]

      "responsive" ->
        ~s[# Responsive theme - adapts to your site automatically
<FlyMapEx.render
  marker_groups={@marker_groups}
  theme={:responsive}
/>

# Set up CSS custom properties in your stylesheet:
/* :root {
     --color-background: #f8fafc;  /* Land areas */
     --color-border: #e2e8f0;      /* Country borders */
     --color-muted: #cbd5e1;       /* Ocean areas */
   } */

# Automatically supports:
# - Light/dark mode switching via prefers-color-scheme
# - High contrast accessibility modes
# - Your existing design system colours]

      "custom" ->
        ~s[# Custom theme - complete visual control
<FlyMapEx.render
  marker_groups={@marker_groups}
  theme={%{
    land_color: "#f8fafc",      # Countries/continents
    ocean_color: "#e2e8f0",     # Water areas
    border_color: "#475569",    # Country borders
    background_color: "transparent"  # Container background
  }}
/>

# Support for all CSS colour formats:
theme={%{
  land_color: "hsl(210, 40%, 96%)",
  ocean_color: "var(--ocean-blue)",
  border_color: "#64748b"
}}

# Perfect for branded experiences and white-label apps]

      "configuration" ->
        ~s[# Configuration-based themes - centralized management
# In config/config.exs:
config :fly_map_ex, 
  default_theme: :responsive,
  fallback_theme: :light

# Components use configured theme automatically:
<FlyMapEx.render
  marker_groups={@marker_groups}
  # theme automatically applied from config
/>

# Override when needed:
<FlyMapEx.render
  marker_groups={@marker_groups}
  theme={:presentation}  # Overrides config default
/>

# Environment-specific configs in dev.exs, prod.exs, etc.]

      _ -> "# Unknown theme type"
    end
  end

  defp get_advanced_topics do
    [
      %{
        id: "theme-performance",
        title: "Theme Performance Optimization",
        description: "Learn how to optimize theme rendering for large-scale applications",
        content: "<p class='text-sm text-gray-700 mb-4'>Advanced caching strategies, CSS optimization, and bundle size management for theme systems.</p><ul class='text-sm text-gray-700 space-y-2'><li>• <strong>CSS Caching:</strong> Implement smart caching strategies for theme assets</li><li>• <strong>Bundle Optimization:</strong> Minimize CSS payload with critical theme extraction</li><li>• <strong>Runtime Performance:</strong> Optimize theme switching with CSS custom properties</li></ul>"
      },
      %{
        id: "theme-libraries",
        title: "Creating Theme Libraries",
        description: "Build reusable theme collections for your organization",
        content: "<p class='text-sm text-gray-700 mb-4'>Structured approaches to creating, sharing, and maintaining theme libraries across projects.</p><ul class='text-sm text-gray-700 space-y-2'><li>• <strong>Theme Architecture:</strong> Design scalable theme systems with inheritance</li><li>• <strong>Version Management:</strong> Maintain backwards compatibility across theme updates</li><li>• <strong>Documentation:</strong> Create comprehensive theme guides and examples</li></ul>"
      },
      %{
        id: "dynamic-switching",
        title: "Dynamic Theme Switching",
        description: "Implement real-time theme changes based on user preferences",
        content: "<p class='text-sm text-gray-700 mb-4'>LiveView patterns for dynamic theme updates without page reloads.</p><ul class='text-sm text-gray-700 space-y-2'><li>• <strong>User Preferences:</strong> Store and persist theme choices</li><li>• <strong>Context Switching:</strong> Automatically adapt themes based on time, location, or user context</li><li>• <strong>Smooth Transitions:</strong> Implement animated theme changes with CSS transitions</li></ul>"
      }
    ]
  end

end
