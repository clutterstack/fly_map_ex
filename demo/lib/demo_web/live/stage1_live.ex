defmodule DemoWeb.Stage1Live do
  @moduledoc """
  Stage 1: Defining Marker Groups

  This stage demonstrates the fundamental data structure and syntax options
  for FlyMapEx marker groups, including coordinates, regions, and grouping patterns.
  """

  use DemoWeb.Live.DocBase

  alias DemoWeb.Helpers.{ContentHelpers, StageConfig}

  # Required DocBase callbacks

  def doc_title, do: "Stage 1: Defining Marker Groups"

  def doc_description do
    "Learn the fundamental data structure and syntax options for FlyMapEx marker groups."
  end

  def doc_component_type, do: :map

  def doc_examples do
    %{
      by_coords: %{
        marker_groups: [
          %{
            # San Francisco, somewhere in the North Sea
            nodes: [{37.8, -122.4}, {56, 3.6}]
          },
          %{
            # Iqaluit approximately
            nodes: [{63.7, 68.5}]
          }
        ],
        description: "Markers placed by coordinates",
        code_comment: "Nodes can be positioned with `{latitude, longitude}` tuples."
      },
      fly_regions: %{
        marker_groups: [
          %{
            nodes: ["fra", "sin"]
          }
        ],
        description: "Markers placed using Fly.io region code",
        code_comment: "Use 3-letter region codes for Fly.io worker locations."
      },
      multiple_nodes: %{
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
      },
      custom_regions: %{
        marker_groups: [
          %{
            nodes: ["dev", "laptop-chris", "office-nyc"]
          },
          %{
            nodes: ["fra", "sin", "lhr"]
          }
        ],
        description: "Mix of custom and Fly.io regions",
        code_comment: "Custom regions like 'dev' and 'laptop-chris' can be configured in your app config alongside standard Fly.io regions."
      }
    }
  end

  def doc_tabs do
    [
      %{
        key: "by_coords",
        label: "Coordinate positioning",
        content: get_coordinates_content()
      },
      %{
        key: "fly_regions",
        label: "Fly.io regions",
        content: get_region_content()
      },
      %{
        key: "custom_regions",
        label: "Custom Regions",
        content: get_custom_regions_content()
      },
      %{
        key: "multiple_nodes",
        label: "Multiple",
        content: get_multiple_content()
      }
    ]
  end

  def doc_navigation, do: StageConfig.stage_navigation(:stage1)

  def doc_theme, do: :responsive
  def doc_layout, do: :side_by_side

  # Content generation functions using ContentHelpers

  defp get_coordinates_content do
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
    |> Enum.join()
  end

  defp get_region_content do
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
    |> Enum.join()
  end

  defp get_multiple_content do
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
    |> Enum.join()
  end

  defp get_custom_regions_content do
    [
      ContentHelpers.content_section(
        "Custom Regions for Mixed Deployments",
        "Define custom regions in your app config for mixed Fly.io + local deployments. Perfect for showing development environments, office locations, or hybrid cloud setups."
      ),
      ContentHelpers.code_snippet(
        "# config/config.exs\nconfig :fly_map_ex, :custom_regions, %{\n  \"dev\" => %{name: \"Development\", coordinates: {47.6062, -122.3321}},\n  \"laptop-chris\" => %{name: \"Chris's Laptop\", coordinates: {49.2827, -123.1207}},\n  \"office-nyc\" => %{name: \"NYC Office\", coordinates: {40.7128, -74.0060}}\n}"
      ),
      ContentHelpers.pro_tip(
        "Custom regions are treated like Fly.io regions once configured."
      )
    ]
    |> Enum.join()
  end



end
