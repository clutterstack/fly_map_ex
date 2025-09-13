defmodule DemoWeb.Stage2Live do
  @moduledoc """
  Stage 2: Marker Styles

  This stage demonstrates the comprehensive styling system for FlyMapEx markers,
  including automatic cycling, semantic presets, custom parameters, and mixed approaches.
  """

  use DemoWeb.Live.StageBase

  alias DemoWeb.Helpers.{ContentHelpers, StageConfig}

  # Required StageBase callbacks

  def stage_title, do: "Stage 2: Marker Styles"

  def stage_description do
    "Master visual customization and semantic meaning through FlyMapEx's comprehensive styling system."
  end

  def stage_examples do
    %{
      automatic: %{
        marker_groups: [
          %{
            nodes: ["sjc", "fra"],
            label: "Production Servers"
          },
          %{
            nodes: ["ams", "lhr"],
            label: "Staging Environment"
          },
          %{
            nodes: ["ord"],
            label: "Development"
          },
          %{
            nodes: ["nrt", "syd"],
            label: "Testing"
          }
        ],
        description: "Automatic colours for multiple groups",
        code_comment: "FlyMapEx automatically assigns different colours to each group"
      },
      named_colours: %{
        marker_groups: [
          %{
            nodes: ["sjc", "fra"],
            style: FlyMapEx.Style.named_colours(:blue),
            label: ":blue markers"
          },
          %{
            nodes: ["ams", "lhr"],
            style: FlyMapEx.Style.named_colours(:green),
            label: ":green markers"
          },
          %{
            nodes: ["ord"],
            style: FlyMapEx.Style.named_colours(:red),
            label: ":red markers"
          },
          %{
            nodes: ["nrt", "syd"],
            style: FlyMapEx.Style.named_colours(:purple),
            label: ":purple markers"
          }
        ],
        description: "Named colours",
        code_comment: "FlyMapEx.Style.named_colours/1 provides access to predefined colors"
      },
      semantic: %{
        marker_groups: [
          %{
            nodes: ["sjc", "fra"],
            style: :operational,
            label: "Production Servers"
          },
          %{
            nodes: ["ams", "lhr"],
            style: :warning,
            label: "Maintenance Mode"
          },
          %{
            nodes: ["ord"],
            style: :danger,
            label: "Failed Nodes"
          },
          %{
            nodes: ["nrt", "syd"],
            style: :inactive,
            label: "Offline Nodes"
          }
        ],
        description: "Semantic styling with meaningful colours",
        code_comment: "Semantic presets resolve from configuration"
      },
      custom: %{
        marker_groups: [
           %{
              nodes: ["sjc", "fra"],
              style: %{
                colour: "#8b5cf6",    # hex, named colour, or CSS variable
                size: 8,             # radius in pixels
                animation: :pulse,   # :none, :pulse, :fade
                glow: true           # boolean for glow effect
              },
              label: "Custom Group"
            }

        ],
        description: "Direct style maps with full control over appearance",
        code_comment:
          "Direct style maps are the primary interface for custom styling"
      },
      mixed: %{
        marker_groups: [
          %{
            nodes: ["ams", "lhr"],
            style: :warning,
            label: "Maintenance Mode"
          },
          %{
            nodes: ["sjc", "fra"],
            style: %{
              colour: "#8b5cf6",    # hex, named colour, or CSS variable
              size: 8,             # radius in pixels
              animation: :pulse,   # :none, :pulse, :fade
              glow: true           # boolean for glow effect
          },
          label: "Custom Group"
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
        key: "named_colours",
        label: "Named colours",
        content: get_named_content()
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
    updated_params =
      case param do
        "size" -> Map.put(socket.assigns.custom_params, :size, String.to_integer(value))
        "animation" -> Map.put(socket.assigns.custom_params, :animation, String.to_atom(value))
        "glow" -> Map.put(socket.assigns.custom_params, :glow, value == "true")
        "color" -> Map.put(socket.assigns.custom_params, :color, value)
        _ -> socket.assigns.custom_params
      end

    {:noreply, assign(socket, custom_params: updated_params)}
  end

  def handle_stage_event("apply_preset", %{"preset" => preset}, socket) do
    updated_example =
      case preset do
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
          #{ContentHelpers.titled_list(["#{ContentHelpers.code_snippet("FlyMapEx.Style.cycle(0)", inline: true)} - Blue", "#{ContentHelpers.code_snippet("FlyMapEx.Style.cycle(1)", inline: true)} - Green", "#{ContentHelpers.code_snippet("FlyMapEx.Style.cycle(2)", inline: true)} - Red", "Cycles through 12 predefined colors"])}
        </div>
        <div>
          <h4 class="font-semibold text-base-content mb-2">Semantic Presets</h4>
          #{ContentHelpers.titled_list(["#{ContentHelpers.code_snippet("operational()", inline: true)} - Running services", "#{ContentHelpers.code_snippet("warning()", inline: true)} - Needs attention", "#{ContentHelpers.code_snippet("danger()", inline: true)} - Critical issues", "#{ContentHelpers.code_snippet("inactive()", inline: true)} - Not running"])}
        </div>
      </div>
      """
    ]
    |> Enum.join()
  end

  defp get_custom_styling_content do
    [
      ContentHelpers.content_section(
        "Custom Style Maps",
        "Create fully custom marker styles using direct style maps:"
      ),
      ContentHelpers.code_snippet(
        ~s"""
        %{
          nodes: ["sjc", "fra"],
          style: %{
            colour: "#3b82f6",   # or :color
            size: 10,            # radius in pixels
            animation: :pulse,   # :none, :pulse, :fade
            glow: true           # enable glow effect
          },
          label: "Custom Markers"
        }
        """
      ),
      ContentHelpers.ul_with_bold(
        "Available Parameters",
        [
          {"colour/color", "Hex codes, named colours (:blue), CSS variables"},
          {"size", "Marker radius in pixels (default: 4)"},
          {"animation", ":none, :pulse, :fade (default: :none)"},
          {"glow", "Boolean for glow effect (default: false)"}
        ]
      )
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
      )
    ]
    |> Enum.join()
  end

  # Tab content creation functions using ContentHelpers

  defp get_automatic_content do
    [
      ContentHelpers.content_section(
        "Automatic Colours",
        "If you don't specify a group's marker styles, a different colour is used for each group."
      )
    ]
    |> Enum.join()
  end

  defp get_named_content do
    [
      ContentHelpers.content_section(
        "Named colours",
        ~s"""
        Pick a colour by name using `FlyMapEx.Style.named_colours/1`.

        Available colours:


        """
      )
    ]
    |> Enum.join()
  end

  defp get_semantic_content do
    [
      ContentHelpers.content_section(
        "Semantic Styling",
        ~s"""
        Preset marker styles to convey status.

        Available semantic styles:

        """
      )
    ]
    |> Enum.join()
  end

  defp get_custom_content do
    [
      ContentHelpers.content_section(
        "Direct Style Maps",
        ~s"""
        Define fully custom marker styles using direct style maps - the primary interface for custom styling.
        """
      ),
      ContentHelpers.code_snippet(
        ~s"""
        %{
          nodes: ["sjc", "fra"],
          style: %{
            colour: "#8b5cf6",    # hex, named colour, or CSS variable
            size: 8,             # radius in pixels
            animation: :pulse,   # :none, :pulse, :fade
            glow: true           # boolean for glow effect
          },
          label: "Custom Group"
        }
        """
      ),
      ContentHelpers.ul_with_bold(
        "Style Parameters",
        [
          {"colour/color", "Hex codes, named colours (:blue), CSS variables (var(--primary))"},
          {"size", "Marker radius in pixels (default: 4)"},
          {"animation", ":none, :pulse, :fade (default: :none)"},
          {"glow", "Boolean for enhanced visibility (default: false)"}
        ]
      )
    ]
    |> Enum.join()
  end

  defp get_mixed_content do
    [
      ContentHelpers.content_section(
        "Mixed Approaches",
        "Combine different styling methods in one configuration for complex real-world scenarios."
      ),
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
      )
    ]
    |> Enum.join()
  end
end
