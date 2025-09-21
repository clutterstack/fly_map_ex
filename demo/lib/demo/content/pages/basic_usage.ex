defmodule DemoWeb.Content.BasicUsage do
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
      title: "Basic use",
      description: "Place node markers using coordinates or Fly.io region codes.",
      template: "StageTemplate"
    }
  end

  def tabs do
    [
      %{key: "blank_map",
        label: "Blank map"
      },
      %{
        key: "by_coords",
        label: "Coordinate positioning"
      },
      %{
        key: "fly_regions",
        label: "Fly.io regions"
      },
      %{
        key: "custom_regions",
        label: "Custom Regions"
      },
      %{
        key: "multiple",
        label: "Multiple"
      }
    ]
  end

  @doc """
   All the content for each tab:
  * `content`: Info to go into the info panel
  * `example`: A description for the code panel label, an optional code comment,
    and the assigns to pass to the FlyMapEx.node_map component.
  """

  def get_content("blank_map") do
    %{
      content:
        [
          ContentHelpers.convert_markdown(
          ~s"""
          ## The SVG World Map


          * the map is an SVG image generated using data from the Natural Earth and
          * it uses the equirectangular projection -- a trivial conversion from (latitude, longitude) to Cartesian (y, x).

          """
          )
        ],
      example: %{
          marker_groups: [],
          description: "SVG world map foundation",
          code_comment:
            "The base SVG world map with country borders, land masses, and ocean areas. All themes control the colours of these geographic elements."
      }
    }
  end

  def get_content("by_coords") do
    %{
      content:
        [
          ContentHelpers.content_section(
            "Custom Coordinates",
            ~s"""
              Use latitude and longitude coordinates

            * To add markers, you put a list of nodes in each marker group.
            * At minimum, you have to give each node a map position.
            * You can also give it a label. If you don't, it gets a default one.
            * Talk about style if we talk about labels

            Here's an example of a node group with one node in San Francisco and one somewhere in the ocean
            """
          )
        ]
        |> Enum.join(),
      example: %{
        description: "Markers placed by coordinates",
        code_comment: "Nodes can be positioned with `{latitude, longitude}` tuples.",
        marker_groups: [
          %{
            # San Francisco, somewhere in the North Sea
            nodes: [{37.8, -122.4}, {56, 3.6}]
          },
          %{
            # Iqaluit approximately
            nodes: [{63.7, 68.5}]
          }
        ]
      }
    }
  end

  def get_content("fly_regions") do
    %{
      content:
        [
          ContentHelpers.content_section(
            "Fly.io Region Codes",
            ~s"""
            Use three-letter region codes that automatically resolve to exact coordinates for Fly.io infrastructure.

            """
          ),
          ContentHelpers.pro_tip(
            ~s(Custom regions like "dev", "laptop-chris", "office-nyc" can be configured in your app config for mixed Fly.io + local deployments.)
          )
        ]
        |> Enum.join(),
      example: %{
        marker_groups: [
          %{
            nodes: ["fra", "sin"]
          }
        ],
        description: "Markers placed using Fly.io region code",
        code_comment: "Use 3-letter region codes for Fly.io worker locations."
      }
    }
  end

  def get_content("multiple") do
    %{
      content:
        [
          ContentHelpers.content_section(
            "Multiple node groups",
            "Combine multiple nodes under a single label and styling for logical organization."
          ),
          ContentHelpers.pro_tip(
            "Group related nodes together (e.g., all production servers, all staging environments).",
            type: :best_practice
          )
        ]
        |> Enum.join(),
      example: %{
        marker_groups: [
          %{
            nodes: ["sjc", "fra", "syd"]
          },
          %{
            nodes: ["ams", "lhr", "dfw"]
          },
          %{
            nodes: [
              {47.0, -27.2}
            ]
          }
        ],
        description: "Multiple groups with different purposes",
        code_comment: "Separate groups allow different styling and organization"
      }
    }
  end

  def get_content("custom_regions") do
    %{
      content:
        [
          ContentHelpers.content_section(
            "Custom Regions for Mixed Deployments",
            "Define custom regions in your app config for mixed Fly.io + local deployments. Perfect for showing development environments, office locations, or hybrid cloud setups."
          ),
          ContentHelpers.code_snippet(
            """
            # config/config.exs

            config :fly_map_ex, :custom_regions,
              %{
                "dev" => %{name: "Development", coordinates: {47.6062, -122.3321}},
                "laptop-chris" =>
                     %{name: "Chris's Laptop", coordinates: {49.2827, -123.1207}},
                "office-nyc" => %{name: "NYC Office", coordinates: {40.7128, -74.0060}}
              }
            """
          ),
          ContentHelpers.pro_tip(
            "Custom regions are treated like Fly.io regions once configured."
          )
        ]
        |> Enum.join(),
      example: %{
        marker_groups: [
          %{
            nodes: ["dev", "laptop-chris", "office-nyc"]
          },
          %{
            nodes: ["fra", "sin", "lhr"]
          }
        ],
        description: "Mix of custom and Fly.io regions",
        code_comment:
          "Custom regions like 'dev' and 'laptop-chris' can be configured in your app config alongside standard Fly.io regions."
      }
    }
  end
end
