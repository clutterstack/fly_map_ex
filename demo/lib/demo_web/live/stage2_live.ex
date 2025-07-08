defmodule DemoWeb.Stage2Live do
  @moduledoc """
  Stage 2: Styling Markers

  This stage demonstrates the comprehensive styling system for FlyMapEx markers,
  including automatic cycling, semantic presets, custom parameters, and mixed approaches.
  """

  use DemoWeb.Live.StageBase

  alias DemoWeb.Helpers.{ContentHelpers, StageConfig}

  # Required StageBase callbacks

  def stage_title, do: "Stage 2: Styling Markers"

  def stage_description do
    "Master visual customization and semantic meaning through FlyMapEx's comprehensive styling system."
  end

  def stage_examples do
    %{
      automatic: %{
        marker_groups: [
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
        description: "Automatic colour cycling for multiple groups",
        code_comment: "FlyMapEx.Style.cycle/1 automatically assigns different colours to each group"
      },
      semantic: %{
        marker_groups: [
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
        description: "Semantic styling with meaningful colours",
        code_comment: "Use semantic styles to convey status and meaning through colour"
      },
      custom: %{
        marker_groups: [
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
        description: "Custom styling with full control over appearance",
        code_comment: "FlyMapEx.Style.custom/2 allows complete customization of colour, size, animation, and effects"
      },
      mixed: %{
        marker_groups: [
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
        ],
        description: "Mixed styling approaches in one map",
        code_comment: "You can mix semantic, automatic, custom, and atom styles in the same map"
      }
    }
  end

  def stage_tabs do
    [
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
  end

  def stage_navigation, do: StageConfig.stage_navigation(:stage2)

  def get_current_description(example) do
    case example do
      "automatic" -> "Automatic color cycling for multiple groups"
      "semantic" -> "Semantic presets for meaningful server states"
      "custom" -> "Custom parameters for size, animation, and glow"
      "mixed" -> "Mixed approaches combining different methods"
      _ -> "Unknown example"
    end
  end

  def get_advanced_topics do
    [
      %{
        id: "style-functions",
        title: "Style Function Reference",
        content: get_style_functions_content()
      },
      %{
        id: "custom-styling",
        title: "Custom Style Parameters",
        content: get_custom_styling_content()
      },
      %{
        id: "style-performance",
        title: "Performance & Best Practices",
        content: get_style_performance_content()
      },
      %{
        id: "production-config",
        title: "Production Configuration",
        content: get_production_config_content()
      }
    ]
  end

  def default_example, do: "automatic"

  def stage_theme, do: :dashboard

  def stage_layout, do: :side_by_side

  # Optional StageBase callbacks

  def handle_stage_event("update_param", %{"param" => param, "value" => value}, socket) do
    updated_params = case param do
      "size" -> Map.put(socket.assigns.custom_params, :size, String.to_integer(value))
      "animation" -> Map.put(socket.assigns.custom_params, :animation, String.to_atom(value))
      "glow" -> Map.put(socket.assigns.custom_params, :glow, value == "true")
      "color" -> Map.put(socket.assigns.custom_params, :color, value)
      _ -> socket.assigns.custom_params
    end

    {:noreply, assign(socket, custom_params: updated_params)}
  end

  def handle_stage_event("apply_preset", %{"preset" => preset}, socket) do
    updated_example = case preset do
      "operational" -> "semantic"
      "warning" -> "semantic"
      "danger" -> "semantic"
      "inactive" -> "semantic"
      _ -> socket.assigns.current_example
    end

    {:noreply, assign(socket, current_example: updated_example)}
  end

  def handle_stage_event(_event, _params, socket) do
    {:noreply, socket}
  end

  # Content generation functions using ContentHelpers

  # Advanced topics content

  defp get_style_functions_content do
    [
      ContentHelpers.content_section(
        "Style Function Reference",
        "FlyMapEx provides multiple approaches to styling markers:"
      ),
      ~s"""
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <h4 class="font-semibold text-base-content mb-2">Automatic Cycling</h4>
          #{ContentHelpers.titled_list([
            "#{ContentHelpers.code_snippet("FlyMapEx.Style.cycle(0)", inline: true)} - Blue",
            "#{ContentHelpers.code_snippet("FlyMapEx.Style.cycle(1)", inline: true)} - Green",
            "#{ContentHelpers.code_snippet("FlyMapEx.Style.cycle(2)", inline: true)} - Red",
            "Cycles through 12 predefined colors"
          ])}
        </div>
        <div>
          <h4 class="font-semibold text-base-content mb-2">Semantic Presets</h4>
          #{ContentHelpers.titled_list([
            "#{ContentHelpers.code_snippet("operational()", inline: true)} - Running services",
            "#{ContentHelpers.code_snippet("warning()", inline: true)} - Needs attention",
            "#{ContentHelpers.code_snippet("danger()", inline: true)} - Critical issues",
            "#{ContentHelpers.code_snippet("inactive()", inline: true)} - Not running"
          ])}
        </div>
      </div>
      """,
      "</div>"
    ]
    |> Enum.join()
  end

  defp get_custom_styling_content do
    [
      ContentHelpers.content_section(
        "Custom Style Parameters",
        "Build completely custom styles with #{ContentHelpers.code_snippet("FlyMapEx.Style.custom/2", inline: true)}:"
      ),
      ContentHelpers.code_snippet(
        "FlyMapEx.Style.custom(\"#3b82f6\", [\n  size: 10,        # radius in pixels\n  animation: :pulse,   # :none, :pulse, :fade\n  glow: true       # enable glow effect\n])"
      ),
      ContentHelpers.ul_with_bold(
        "Available Parameters",
        [
          {"size", "Marker radius in pixels (default: 6)"},
          {"animation", ":none, :pulse, :fade (default: :none)"},
          {"glow", "Boolean for glow effect (default: false)"}
        ]
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  defp get_style_performance_content do
    [
      ContentHelpers.content_section(
        "Performance & Best Practices",
        "Optimize your styling approach for production deployments."
      ),
      ContentHelpers.ul_with_bold(
        "Performance Considerations",
        [
          {"Animated markers", "use CSS animations for smooth performance"},
          {"Glow effects", "add minimal overhead with box-shadow"},
          {"Semantic presets", "for consistent styling across your app"},
          {"Custom colors", "are validated at compile time"}
        ]
      ),
      ContentHelpers.ul_with_bold(
        "Styling Strategies",
        [
          {"Automatic", "Use cycle() for consistent multi-group colors"},
          {"Semantic", "Use presets for meaningful status indicators"},
          {"Custom", "Use custom() for brand-specific styling"},
          {"Mixed", "Combine approaches for complex scenarios"}
        ]
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  defp get_production_config_content do
    [
      ContentHelpers.content_section(
        "Production Configuration",
        "Configure default styling in your application:"
      ),
      ContentHelpers.code_snippet(
        "# config/config.exs\nconfig :fly_map_ex,\n  default_style: :operational,\n  custom_presets: %{\n    brand_primary: FlyMapEx.Style.custom(\"#your-brand-color\", [\n      size: 8,\n      animation: :pulse,\n      glow: true\n    ])\n  }"
      ),
      ContentHelpers.ul_with_bold(
        "Style Normalization",
        [
          {"Atoms (`:operational`)", "→ style maps"},
          {"Function calls (`operational()`)", "→ style maps"},
          {"Keyword lists", "→ normalized style maps"},
          {"Custom maps", "→ validated and normalized"}
        ],
        class: "mt-4"
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  # Tab content creation functions using ContentHelpers

  defp get_automatic_content do
    [
      ContentHelpers.content_section(
        "Automatic Color Cycling",
        "The #{ContentHelpers.code_snippet("FlyMapEx.Style.cycle/1", inline: true)} function automatically assigns consistent colors to multiple groups without manual specification."
      ),
      ContentHelpers.info_box(
        :primary,
        "Color Progression",
        ContentHelpers.color_grid([
          {"bg-primary", "cycle(0) - Blue"},
          {"bg-success", "cycle(1) - Green"},
          {"bg-error", "cycle(2) - Red"},
          {"bg-secondary", "cycle(3) - Purple"}
        ], cols: 2)
      ),
      ContentHelpers.ul_with_bold(
        "When to Use",
        [
          {"Multiple groups", "with equal importance"},
          {"Consistent visual hierarchy", "is needed"},
          {"Avoid color conflicts", "automatically"},
          {"Dashboard-style displays", "are being built"}
        ]
      ),
      ContentHelpers.pro_tip(
        "cycle() automatically wraps after 12 colors, ensuring visual consistency across any number of groups."
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  defp get_semantic_content do
    [
      ContentHelpers.content_section(
        "Semantic Styling",
        "Use meaningful preset functions that convey status and state at a glance."
      ),
      ContentHelpers.status_steps([
        {:operational, "operational()", "Healthy, running services. Green, static markers.", "bg-success"},
        {:warning, "warning()", "Needs attention. Amber, static markers.", "bg-warning"},
        {:danger, "danger()", "Critical issues. Red, pulsing animation for attention.", "bg-error"},
        {:inactive, "inactive()", "Not running or offline. Gray, static markers.", "bg-base-content"}
      ]),
      ContentHelpers.pro_tip(
        "Use semantic styles for monitoring dashboards and status displays where color meaning is crucial.",
        type: :best_practice
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  defp get_custom_content do
    [
      ContentHelpers.content_section(
        "Custom Parameters",
        "Build completely custom styles with #{ContentHelpers.code_snippet("FlyMapEx.Style.custom/2", inline: true)} for brand-specific or unique requirements."
      ),
      ContentHelpers.info_box(
        :secondary,
        "Size Parameter",
        ContentHelpers.color_grid([
          {"bg-primary", "size: 4 (small)"},
          {"bg-primary", "size: 6 (default)"},
          {"bg-primary", "size: 8 (large)"},
          {"bg-primary", "size: 10 (extra large)"}
        ], cols: 2)
      ),
      ContentHelpers.ul_with_bold(
        "Animation Options",
        [
          {":none", "Static markers"},
          {":pulse", "Radius grows/shrinks"},
          {":fade", "Opacity changes"}
        ]
      ),
      ContentHelpers.ul_with_bold(
        "Glow Effect",
        [
          {"glow: false", "Standard markers"},
          {"glow: true", "Enhanced visibility with shadow"}
        ]
      ),
      ContentHelpers.pro_tip(
        "Perfect for brand-specific styling, special alerts, or when you need precise control over appearance.",
        type: :production
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  defp get_mixed_content do
    [
      ContentHelpers.content_section(
        "Mixed Approaches",
        "Combine different styling methods in one configuration for complex real-world scenarios."
      ),
      ContentHelpers.status_steps([
        {:semantic, "Semantic Functions", "Use operational(), warning(), etc. for critical status indicators.", "bg-success"},
        {:cycling, "Auto-Cycling", "Use cycle() for equal-importance groupings.", "bg-primary"},
        {:custom, "Custom Styling", "Use custom() for special cases requiring unique appearance.", "bg-secondary"},
        {:atoms, "Atom Shortcuts", "Use :inactive, :operational atoms for convenience.", "bg-base-content"}
      ]),
      ContentHelpers.ul_with_bold(
        "Common Patterns",
        [
          {"Primary systems", "Semantic styles for critical monitoring"},
          {"Secondary groups", "Auto-cycling for organization"},
          {"Special alerts", "Custom styles for unique cases"},
          {"Utility groups", "Atom shortcuts for simple cases"}
        ]
      ),
      ContentHelpers.pro_tip(
        "Start with semantic styles for core functionality, then add cycling and custom styles as needed.",
        type: :production
      ),
      "</div>"
    ]
    |> Enum.join()
  end

end
