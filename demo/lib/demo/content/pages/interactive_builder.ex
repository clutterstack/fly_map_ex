defmodule DemoWeb.Content.InteractiveBuilder do
  @moduledoc """
  A content page to be rendered from PageLive within the StageTemplate live_component.
  """

  alias DemoWeb.Helpers.ContentHelpers

  @doc """
  Gives the PageLive LiveView the title and description to populate slots in Layouts.app/1,
  and the live_component to use as a template for rendering the content in this module.
  """

  def doc_metadata do
    %{
      title: "Interactive Builder",
      description: "Apply your knowledge to build real-world map configurations with guided scenarios, freeform building, and code export.",
      template: "StageTemplate"
    }
  end

  def tabs do
    [
      %{key: "guided",
        label: "Guided Scenarios"
      },
      %{
        key: "custom",
        label: "Custom"
      },
      %{
        key: "freeform",
        label: "Freeform Builder"
      },
      %{
        key: "export",
        label: "Export & Integration"
      }
    ]
  end

  @doc """
   All the content for each tab:
  * `content`: Info to go into the info panel
  * `example`: A description for the code panel label, an optional code comment,
    and the assigns to pass to the FlyMapEx.node_map component.
  """

  def get_content("guided") do
    %{
      content:
        [
          ContentHelpers.content_section(
            "Guided Scenarios",
            "Learn by building real-world map configurations with step-by-step guidance. Each scenario demonstrates common patterns and best practices."
          ),
          ContentHelpers.info_box(
            :primary,
            "Monitoring Dashboard",
            [
              "Track service health across multiple regions with status indicators.",
              ContentHelpers.titled_list([
                "Production servers marked as operational",
                "Maintenance windows highlighted with warnings",
                "Clear legend for status interpretation"
              ])
            ]
            |> Enum.join()
          ),
          ContentHelpers.info_box(
            :success,
            "Deployment Map",
            [
              "Visualize application rollouts and deployment status across regions.",
              ContentHelpers.titled_list([
                "Active deployments with animated markers",
                "Completed deployments in stable states",
                "Pending regions awaiting deployment"
              ])
            ]
            |> Enum.join()
          ),
          ContentHelpers.info_box(
            :secondary,
            "Status Board",
            [
              "Create a comprehensive status overview for incident response and monitoring.",
              ContentHelpers.titled_list([
                "Critical issues highlighted with danger styling",
                "Healthy services marked as operational",
                "Maintenance and acknowledged states"
              ])
            ]
            |> Enum.join()
          ),
          ContentHelpers.pro_tip(
            "Each scenario builds on concepts from previous stages, combining marker groups, styling, and theming into practical applications.",
            type: :best_practice
          )
        ]
        |> Enum.join(),
      example: %{
        marker_groups: [
          %{
            nodes: ["sjc", "fra", "ams", "lhr"],
            style: :operational,
            label: "Production Servers"
          },
          %{
            nodes: ["syd", "nrt"],
            style: :warning,
            label: "Maintenance Windows"
          }
        ],
        description: "Real-world monitoring dashboard with operational status indicators",
        code_comment:
          "# Monitoring Dashboard Example\n# This demonstrates a practical monitoring scenario with production servers\n# and maintenance windows, using operational and warning styles for clear status visualization."
      }
    }
  end

  def get_content("custom") do
    %{
      content:
        [
          ContentHelpers.content_section(
            "Direct Style Maps",
            ~s"""
            Define fully custom marker styles using direct style maps - the primary interface for custom styling.
            """
          ),
          ContentHelpers.code_snippet(~s"""
          %{
            nodes: ["sjc", "fra"],
            style: %{
              colour: "#10b981",    # hex, named colour, or CSS variable
              size: 8,             # radius in pixels
              animation: :pulse,   # :none, :pulse, :fade
              glow: true           # boolean for glow effect
            },
            label: "Custom Group"
          }
          """),
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
        |> Enum.join(),
      example: %{
        marker_groups: [
          %{
            nodes: ["sjc", "fra"],
            style: %{
              # hex, named colour, or CSS variable
              colour: "#8b5cf6",
              # radius in pixels
              size: 8,
              # :none, :pulse, :fade
              animation: :pulse,
              # boolean for glow effect
              glow: true
            },
            label: "Custom Group"
          }
        ],
        description: "Direct style maps with full control over appearance",
        code_comment: "Direct style maps are the primary interface for custom styling"
      }
    }
  end

  def get_content("freeform") do
    %{
      content:
        [
          ContentHelpers.content_section(
            "Freeform Builder",
            "Build custom map configurations from scratch with full creative control. Perfect for unique requirements and experimental designs."
          ),
          ContentHelpers.info_box(
            :primary,
            "Interactive Region Selection",
            [
              "Click regions on the map to build your marker groups dynamically.",
              ContentHelpers.titled_list([
                "Visual region picker with live preview",
                "Drag and drop group organization",
                "Real-time code generation"
              ]),
              ~s(<div class="mt-2 text-xs text-primary/70"><em>Coming in Phase 2: Enhanced Interactivity</em></div>)
            ]
            |> Enum.join()
          ),
          ContentHelpers.info_box(
            :success,
            "Custom Group Builder",
            [
              "Create marker groups with custom styling and labels.",
              ContentHelpers.titled_list([
                "Add/remove regions with search and autocomplete",
                "Live style customization with sliders and pickers",
                "Group management with reordering and duplication"
              ]),
              ~s(<div class="mt-2 text-xs text-success/70"><em>Coming in Phase 2: Enhanced Interactivity</em></div>)
            ]
            |> Enum.join()
          ),
          ContentHelpers.info_box(
            :secondary,
            "Live Preview Canvas",
            [
              "See your changes instantly as you build.",
              ContentHelpers.titled_list([
                "Real-time map updates during editing",
                "Side-by-side comparison views",
                "Undo/redo functionality"
              ]),
              ~s(<div class="mt-2 text-xs text-secondary/70"><em>Coming in Phase 2: Enhanced Interactivity</em></div>)
            ]
            |> Enum.join()
          ),
          ContentHelpers.pro_tip(
            "Use the guided scenarios to explore different configurations. Full freeform building tools will be added in Phase 2 with interactive controls and live editing.",
            type: :warning
          )
        ]
        |> Enum.join(),
      example: %{
        marker_groups: [],
        description: "Interactive builder for custom map configurations",
        code_comment:
          "# Freeform Builder\n# This provides a blank canvas for creating custom marker group configurations.\n# Use this to experiment with different regional deployments and styling approaches."
      }
    }
  end

  def get_content("export") do
    %{
      content:
        [
          ContentHelpers.content_section(
            "Export & Integration",
            "Generate production-ready code in multiple formats for seamless integration into your Phoenix LiveView applications."
          ),
          ContentHelpers.info_box(
            :primary,
            "Export Formats",
            [
              "Choose the format that best fits your integration needs:",
              ContentHelpers.titled_list([
                "HEEx: Direct template integration",
                "Elixir: Reusable function modules",
                "JSON: Configuration-driven approach"
              ])
            ]
            |> Enum.join()
          ),
          ContentHelpers.ul_with_bold(
            "Integration Patterns",
            [
              {"Direct Embed", "Copy HEEx template into your LiveView"},
              {"Function Component", "Create reusable components"},
              {"Configuration Module", "Centralize map configurations"},
              {"Dynamic Loading", "Load configurations from database"}
            ]
          ),
          ContentHelpers.ul_with_bold(
            "Production Considerations",
            [
              {"Performance", "Optimize for rendering speed"},
              {"Maintainability", "Structure for easy updates"},
              {"Scalability", "Handle growing data sets"},
              {"Accessibility", "Ensure inclusive design"}
            ]
          ),
          ContentHelpers.info_box(
            :warning,
            "Copy to Clipboard",
            [
              "Generated code is ready for immediate use:",
              ~s(<div class="mt-2 text-xs text-warning/70"><em>Coming in Phase 2: One-click clipboard integration</em></div>)
            ]
            |> Enum.join()
          ),
          ContentHelpers.pro_tip(
            "Start with HEEx templates for quick prototyping, then extract to Elixir modules for production applications with multiple maps.",
            type: :best_practice
          )
        ]
        |> Enum.join(),
      example: %{
        marker_groups: [
          %{
            nodes: ["sjc", "fra", "ams", "lhr"],
            style: :operational,
            label: "Production Servers"
          },
          %{
            nodes: ["syd", "nrt"],
            style: :warning,
            label: "Maintenance Windows"
          }
        ],
        description: "Code generation and production integration examples",
        code_comment:
          "# Export & Integration Example\n# This shows how to structure marker groups for easy code generation\n# and integration into production Phoenix LiveView applications."
      }
    }
  end
end