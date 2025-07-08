defmodule DemoWeb.Stage3Live do
  @moduledoc """
  Stage 3: Map Themes

  This stage demonstrates FlyMapEx's comprehensive theming system,
  including predefined presets, responsive theming, custom themes, and configuration patterns.
  """

  use DemoWeb.Live.StageBase

  alias DemoWeb.Helpers.{ContentHelpers, StageConfig}

  # Required StageBase callbacks

  def stage_title, do: "Stage 3: Map Themes"

  def stage_description do
    "Control overall visual presentation and branding with FlyMapEx's comprehensive theming system."
  end

  def stage_examples do
    %{
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
  end

  def stage_tabs do
    [
      %{
        key: "presets",
        label: "Theme Presets",
        content: get_presets_content()
      },
      %{
        key: "responsive",
        label: "Responsive",
        content: get_responsive_content()
      },
      %{
        key: "custom",
        label: "Custom",
        content: get_custom_content()
      },
      %{
        key: "configuration",
        label: "Configuration",
        content: get_configuration_content()
      }
    ]
  end

  def stage_navigation, do: StageConfig.stage_navigation(:stage3)

  def get_current_description(example) do
    case example do
      "presets" -> "Predefined themes for common use cases"
      "responsive" -> "Adaptive theming that responds to context"
      "custom" -> "Custom theme creation with full control"
      "configuration" -> "Theme configuration and deployment patterns"
      _ -> "Unknown theme approach"
    end
  end

  def get_advanced_topics do
    [
      %{
        id: "theme-performance",
        title: "Theme Performance Optimization",
        content: get_theme_performance_content()
      },
      %{
        id: "theme-libraries",
        title: "Creating Theme Libraries",
        content: get_theme_libraries_content()
      },
      %{
        id: "dynamic-switching",
        title: "Dynamic Theme Switching",
        content: get_dynamic_switching_content()
      }
    ]
  end

  def default_example, do: "presets"

  # See also helper get_example_theme() for per-tab theme control
  def stage_theme, do: :minimal

  def stage_layout, do: :stacked

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
      ),
      "</div>"
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
      ),
      "</div>"
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
          {"Context Switching", "Automatically adapt themes based on time, location, or user context"},
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
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  # Tab content creation functions using ContentHelpers

  defp get_presets_content do
    [
      ContentHelpers.content_section(
        "Predefined Theme Presets",
        "Ready-to-use themes optimized for common use cases. Quick to implement and consistently styled."
      ),
      ContentHelpers.status_steps([
        {:dashboard, ":dashboard", "Compact design for control panels and admin interfaces.", "bg-primary"},
        {:monitoring, ":monitoring", "Standard size with clear visibility for status dashboards.", "bg-success"},
        {:presentation, ":presentation", "Large markers with warm colours for demos and presentations.", "bg-secondary"},
        {:minimal, "Also available", ":minimal • :dark • :light • :high_contrast", "bg-base-content"}
      ]),
      ContentHelpers.pro_tip(
        "Use preset themes when you need consistent styling or want to match common interface patterns.",
        type: :best_practice
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  defp get_responsive_content do
    [
      ContentHelpers.content_section(
        "Responsive Theme",
        "Automatically adapts to your site's design system using CSS custom properties. Perfect for seamless integration."
      ),
      ContentHelpers.info_box(
        :primary,
        "CSS Custom Properties",
        [
          "Reads your site's CSS variables:",
          ContentHelpers.titled_list([
            "--color-background → land areas",
            "--color-border → country borders",
            "--color-muted → ocean areas"
          ], type: :arrows)
        ] |> Enum.join()
      ),
      ContentHelpers.info_box(
        :success,
        "Context Awareness",
        "Automatically adapts to light/dark mode and high contrast settings."
      ),
      ContentHelpers.code_snippet(
        ":root {\n  --color-background: #f8fafc;\n  --color-border: #e2e8f0;\n  --color-muted: #cbd5e1;\n}"
      ),
      ContentHelpers.pro_tip(
        "Use as your default theme for maintenance-free branding consistency.",
        type: :best_practice
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  defp get_custom_content do
    [
      ContentHelpers.content_section(
        "Custom Theme Creation",
        "Create completely custom themes with full control over colours. Perfect for branded experiences."
      ),
      ContentHelpers.info_box(
        :primary,
        "Theme Properties",
        ContentHelpers.titled_list([
          "land_color → Countries and land masses",
          "ocean_color → Water areas",
          "border_color → Country borders",
          "background_color → Container background"
        ], type: :arrows)
      ),
      ContentHelpers.info_box(
        :success,
        "Colour Formats",
        "Supports hex, RGB, HSL, CSS variables, and named colours."
      ),
      ContentHelpers.info_box(
        :warning,
        "Accessibility",
        "Ensure 4.5:1 contrast ratio and don't rely solely on colour for information."
      ),
      ContentHelpers.pro_tip(
        "Use custom themes when you need precise visual control or brand-specific experiences.",
        type: :production
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  defp get_configuration_content do
    [
      ContentHelpers.content_section(
        "Theme Configuration",
        "Configure themes at the application level for consistent theming across your entire app."
      ),
      ContentHelpers.info_box(
        :primary,
        "Application Config",
        ContentHelpers.code_snippet(
          "# config/config.exs\nconfig :fly_map_ex,\n  default_theme: :responsive"
        )
      ),
      ContentHelpers.ul_with_bold(
        "Environment-Specific Themes",
        [
          {"Development", ":light - Bright debugging"},
          {"Production", ":responsive - Adaptive"},
          {"Testing", ":high_contrast - Maximum visibility"}
        ]
      ),
      ContentHelpers.ul_with_bold(
        "Precedence Order",
        [
          {"1. Inline theme prop", "Highest priority"},
          {"2. Component default", "Component-level setting"},
          {"3. Application config", "App-wide configuration"},
          {"4. Library default", "Fallback theme"}
        ]
      ),
      ContentHelpers.pro_tip(
        "Use config-based themes for centralized management and consistency across your application.",
        type: :best_practice
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  # Override context name for better code generation
  def get_context_name(example) do
    case example do
      "presets" -> "presets"
      "responsive" -> "responsive"
      "custom" -> "custom"
      "configuration" -> "config"
      _ -> "theme"
    end
  end

  # Per-example theme implementation
  def get_example_theme(example) do
    case example do
      "presets" -> :dashboard
      "responsive" -> :responsive
      "custom" -> :minimal
      "configuration" -> :light
      _ -> nil  # Fall back to stage theme
    end
  end
end
