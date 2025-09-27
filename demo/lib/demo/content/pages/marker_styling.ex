defmodule DemoWeb.Content.MarkerStyling do
  @moduledoc """
  A content page to be rendered from PageLive within the StageTemplate live_component.
  """

  import DemoWeb.Content.ValidatedExample
  alias DemoWeb.Helpers.ContentHelpers

  @doc """
  Gives the PageLive LiveView the title and description to populate slots in Layouts.app/1,
  and the live_component to use as a template for rendering the content in this module.
  """

  def doc_metadata do
    %{
      title: "Marker Styles",
      description: "Master visual customization and semantic meaning through FlyMapEx's comprehensive styling system.",
      template: "StageTemplate"
    }
  end

  def tabs do
    [
      %{key: "automatic",
        label: "Automatic"
      },
      %{
        key: "semantic",
        label: "Semantic"
      },
      %{
        key: "custom",
        label: "Custom"
      },
      %{
        key: "mixed",
        label: "Mixed"
      }
    ]
  end

  @doc """
   All the content for each tab:
  * `content`: Info to go into the info panel
  * `example`: A description for the code panel label, an optional code comment,
    and the assigns to pass to the FlyMapEx.render component.
  """

  def get_content("automatic") do
    %{
      content:
        [
          ContentHelpers.content_section(
            "Automatic Colours",
            "If you don't specify a group's marker styles, a different colour is used for each group."
          )
        ]
        |> Enum.join(),
      example: validated_template("""
        <FlyMapEx.render
          marker_groups={[
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
          ]}
        />
      """)
    }
  end

  def get_content("semantic") do
    %{
      content:
        [
          ContentHelpers.content_section(
            "Semantic Styling",
            ~s"""
            Preset marker styles to convey status.

            Available semantic styles:
            """
          )
        ]
        |> Enum.join(),
      example: validated_template("""
        <FlyMapEx.render
          marker_groups={[
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
          ]}
        />
      """)
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
              colour: "#8b5cf6",    # hex, named colour, or CSS variable
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
      example: validated_template("""
        <FlyMapEx.render
          marker_groups={[
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
          ]}
        />
      """)
    }
  end

  def get_content("mixed") do
    %{
      content:
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
        |> Enum.join(),
      example: validated_template("""
        <FlyMapEx.render
          marker_groups={[
            %{
              nodes: ["ams", "lhr"],
              style: :warning,
              label: "Maintenance Mode"
            },
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
          ]}
        />
      """)
    }
  end
end
