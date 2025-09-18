defmodule DemoWeb.Stage3Live do
  @moduledoc """
  Stage 3: Map Themes

  This stage demonstrates FlyMapEx's comprehensive theming system,
  including predefined presets, responsive theming, custom themes, and configuration patterns.
  """

  use DemoWeb.Live.DocBase

  alias DemoWeb.Helpers.{ContentHelpers, StageConfig}

  # Required DocBase callbacks

  def doc_title, do: "Stage 3: Map Themes"

  def doc_description do
    "Control overall visual presentation and branding with FlyMapEx's comprehensive theming system."
  end

  def doc_component_type, do: :map

  def doc_examples do
    %{
      blank_map: %{
        marker_groups: [],
        description: "SVG world map foundation",
        code_comment:
          "The base SVG world map with country borders, land masses, and ocean areas. All themes control the colours of these geographic elements."
      },
      presets: %{
        marker_groups: [
          %{
            nodes: ["sjc", "fra", "ams"],
            style: %{colour: "#3b82f6", size: 8},
            label: "Production Servers"
          },
          %{
            nodes: ["lhr", "syd"],
            style: %{colour: "#f59e0b", size: 8},
            label: "Staging Environment"
          }
        ],
        description: "Built-in theme presets",
        code_comment:
          "FlyMapEx includes seven preset themes: :light, :dark, :minimal, :cool, :warm, :high_contrast, and :responsive. Each controls map background colours and neutral elements."
      },
      custom: %{
        marker_groups: [
          %{
            nodes: ["sjc", "fra"],
            style: %{colour: "#10b981", size: 8},
            label: "Primary Services"
          },
          %{
            nodes: ["ams", "lhr"],
            style: %{colour: "#f59e0b", size: 8},
            label: "Secondary Services"
          }
        ],
        description: "Custom theme creation methods",
        code_comment:
          "Two ways to create custom themes: inline theme maps or config-registered themes. Define land, ocean, border, neutral_marker, and neutral_text properties."
      },
      configuration: %{
        marker_groups: [
          %{
            nodes: ["sjc", "fra", "ams"],
            style: %{colour: "#3b82f6", size: 8},
            label: "Production Environment"
          }
        ],
        description: "Application-level theme configuration",
        code_comment:
          "Set default themes in config.exs for consistent theming across your app. Theme resolution: inline props → custom themes → app default → library default."
      }
    }
  end

  def doc_tabs do
    [
      %{
        key: "blank_map",
        label: "The Map",
        content: get_blank_map_content()
      },
      %{
        key: "presets",
        label: "Theme Presets",
        content: get_presets_content()
      },
      %{
        key: "custom",
        label: "Custom Themes",
        content: get_custom_content()
      },
      %{
        key: "configuration",
        label: "Configuration",
        content: get_configuration_content()
      }
    ]
  end

  def doc_navigation, do: StageConfig.stage_navigation(:stage3)

  # Default theme - overridden by get_example_theme() per example
  def doc_theme, do: :responsive

  def doc_layout, do: :stacked

  # Content generation functions using ContentHelpers

  # Advanced topics content

  defp get_theme_performance_content do
    [
      ContentHelpers.content_section(
        "Theme Performance Optimization",
        "Learn how to optimize theme rendering for large-scale applications."
      ),
      ContentHelpers.ul_with_bold(
        "Performance Considerations",
        [
          {"CSS Caching", "Implement smart caching strategies for theme assets"},
          {"Bundle Optimization", "Minimize CSS payload with critical theme extraction"},
          {"Runtime Performance", "Optimize theme switching with CSS custom properties"},
          {"Memory Management", "Efficient theme object reuse and cleanup"}
        ]
      ),
      ContentHelpers.pro_tip(
        "Use CSS custom properties for theme switching to avoid layout thrashing and enable smooth transitions.",
        type: :production
      )
    ]
    |> Enum.join()
  end

  defp get_theme_libraries_content do
    [
      ContentHelpers.content_section(
        "Creating Theme Libraries",
        "Build reusable theme collections for your organization."
      ),
      ContentHelpers.ul_with_bold(
        "Library Architecture",
        [
          {"Theme Inheritance", "Design scalable theme systems with base themes"},
          {"Version Management", "Maintain backwards compatibility across theme updates"},
          {"Documentation", "Create comprehensive theme guides and examples"},
          {"Testing", "Automated visual regression testing for themes"}
        ]
      ),
      ContentHelpers.code_snippet(
        "# Theme library structure\ndefmodule MyApp.Themes do\n  def corporate_light, do: FlyMapEx.Theme.light() |> override(primary: \"#your-brand\")\n  def corporate_dark, do: FlyMapEx.Theme.dark() |> override(primary: \"#your-brand\")\nend"
      ),
      ContentHelpers.pro_tip(
        "Create theme inheritance hierarchies to reduce duplication and maintain consistency across your organization.",
        type: :best_practice
      )
    ]
    |> Enum.join()
  end

  defp get_dynamic_switching_content do
    [
      ContentHelpers.content_section(
        "Dynamic Theme Switching",
        "Implement real-time theme changes based on user preferences."
      ),
      ContentHelpers.ul_with_bold(
        "Implementation Patterns",
        [
          {"User Preferences", "Store and persist theme choices in browser storage"},
          {"Context Switching",
           "Automatically adapt themes based on time, location, or user context"},
          {"Smooth Transitions", "Implement animated theme changes with CSS transitions"},
          {"System Integration", "Respect OS-level dark/light mode preferences"}
        ]
      ),
      ContentHelpers.code_snippet(
        "# LiveView theme switching\ndef handle_event(\"theme_change\", %{\"theme\" => theme}, socket) do\n  socket = assign(socket, :current_theme, String.to_atom(theme))\n  {:noreply, push_event(socket, \"theme-changed\", %{theme: theme})}\nend"
      ),
      ContentHelpers.pro_tip(
        "Use Phoenix LiveView's push_event to update CSS custom properties for instant theme changes without page reloads.",
        type: :production
      )
    ]
    |> Enum.join()
  end

  # Tab content creation functions using ContentHelpers
  defp get_blank_map_content do
    [
      ContentHelpers.content_section(
        "The SVG World Map",
        "FlyMapEx renders an SVG world map with country borders, land masses, and ocean areas. Themes control the colours of these geographic elements."
      ),
      ContentHelpers.ul_with_bold(
        "Map Elements",
        [
          {"Land", "Country and continental land masses"},
          {"Ocean", "Water bodies and sea areas"},
          {"Border", "Country boundaries and coastlines"},
          {"Neutral Markers", "Default region indicators"},
          {"Neutral Text", "Labels and region names"}
        ]
      )
    ]
    |> Enum.join()
  end

  defp get_presets_content do
    [
      ContentHelpers.content_section(
        "Built-in Theme Presets",
        "Seven ready-to-use themes that control map background colours, borders, and neutral elements."
      ),
      ContentHelpers.status_steps([
        {:light, ":light", "Clean, bright theme with gray land masses and dark borders",
         "bg-base-100"},
        {:dark, ":dark", "Dark background with subtle borders for dark mode interfaces",
         "bg-base-300"},
        {:minimal, ":minimal", "Transparent backgrounds with subtle borders for overlays",
         "bg-base-200"},
        {:cool, ":cool", "Blue-toned theme suitable for technical applications", "bg-info"},
        {:warm, ":warm", "Earth-toned theme with warm colours for friendly interfaces",
         "bg-warning"},
        {:high_contrast, ":high_contrast", "Maximum contrast theme for accessibility",
         "bg-base-content"},
        {:responsive, ":responsive", "CSS variable-based theme that adapts to system preferences",
         "bg-primary"}
      ]),
      """
      <div class="mt-4 p-4 bg-base-200 rounded-lg">
        <h4 class="font-semibold mb-2">Try Different Themes:</h4>
        <div class="flex flex-wrap gap-2">
          <button phx-click="switch_theme" phx-value-theme="light" class="btn btn-sm btn-outline">Light</button>
          <button phx-click="switch_theme" phx-value-theme="dark" class="btn btn-sm btn-outline">Dark</button>
          <button phx-click="switch_theme" phx-value-theme="minimal" class="btn btn-sm btn-outline">Minimal</button>
          <button phx-click="switch_theme" phx-value-theme="cool" class="btn btn-sm btn-outline">Cool</button>
          <button phx-click="switch_theme" phx-value-theme="warm" class="btn btn-sm btn-outline">Warm</button>
          <button phx-click="switch_theme" phx-value-theme="high_contrast" class="btn btn-sm btn-outline">High Contrast</button>
          <button phx-click="switch_theme" phx-value-theme="responsive" class="btn btn-sm btn-outline">Responsive</button>
        </div>
      </div>
      """
    ]
    |> Enum.join()
  end

  defp get_custom_content do
    [
      ContentHelpers.content_section(
        "Custom Theme Creation",
        "Two approaches for creating custom themes: inline theme maps or config-registered themes."
      ),
      ContentHelpers.info_box(
        :primary,
        "Theme Structure",
        ContentHelpers.titled_list(
          [
            "land → Countries and land masses",
            "ocean → Water bodies",
            "border → Country borders and coastlines",
            "neutral_marker → Default region markers",
            "neutral_text → Labels and region names"
          ],
          type: :arrows
        )
      ),
      ContentHelpers.code_snippet("""
      # Method 1: Inline custom theme
      <FlyMapEx.node_map
        marker_groups={@groups}
        theme=%{
          land: "#f8fafc",
          ocean: "#e2e8f0",
          border: "#475569",
          neutral_marker: "#64748b",
          neutral_text: "#334155"
        }
      />
      """),
      ContentHelpers.code_snippet("""
      # Method 2: Config-registered themes
      # config/config.exs
      config :fly_map_ex, :custom_themes,
        corporate: %{
          land: "#f8fafc",
          ocean: "#e2e8f0",
          border: "#475569",
          neutral_marker: "#64748b",
          neutral_text: "#334155"
        },
        sunset: %{
          land: "#fef3c7",
          ocean: "#fbbf24",
          border: "#d97706",
          neutral_marker: "#b45309",
          neutral_text: "#92400e"
        }

      # Usage
      <FlyMapEx.node_map theme={:corporate} />
      """)
    ]
    |> Enum.join()
  end

  defp get_configuration_content do
    [
      ContentHelpers.content_section(
        "Application-Level Theme Configuration",
        "Set default themes and create custom theme registries in your application config."
      ),
      ContentHelpers.code_snippet("""
      # config/config.exs
      config :fly_map_ex,
        default_theme: :responsive,
        custom_themes: %{
          corporate: %{
            land: "#f8fafc",
            ocean: "#e2e8f0",
            border: "#475569",
            neutral_marker: "#64748b",
            neutral_text: "#334155"
          },
          brand: %{
            land: "#fef3c7",
            ocean: "#fed7aa",
            border: "#d97706",
            neutral_marker: "#92400e",
            neutral_text: "#451a03"
          }
        }
      """),
      ContentHelpers.ul_with_bold(
        "Theme Resolution Priority",
        [
          {"1. Inline theme prop", "<FlyMapEx.node_map theme={:dark} />"},
          {"2. Custom themes", "config :fly_map_ex, :custom_themes"},
          {"3. Application default", "config :fly_map_ex, :default_theme"},
          {"4. Library default", ":light theme"}
        ]
      ),
      ContentHelpers.ul_with_bold(
        "Environment Patterns",
        [
          {"Development", ":light for debugging visibility"},
          {"Production", ":responsive for automatic adaptation"},
          {"Testing", ":high_contrast for accessibility testing"}
        ]
      )
    ]
    |> Enum.join()
  end

  # Per-example theme implementation
  def get_example_theme(example) do
    case example do
      "presets" -> :light
      "custom" -> :minimal
      "configuration" -> :warm
      # Fall back to stage theme
      _ -> nil
    end
  end
end
