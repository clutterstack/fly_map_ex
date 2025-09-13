defmodule DemoWeb.Stage1Live do
  @moduledoc """
  Stage 1: Defining Marker Groups

  This stage demonstrates the fundamental data structure and syntax options
  for FlyMapEx marker groups, including coordinates, regions, and grouping patterns.
  """

  use DemoWeb.Live.StageBase

  alias DemoWeb.Helpers.{ContentHelpers, StageConfig}

  # Required StageBase callbacks

  def stage_title, do: "Stage 1: Defining Marker Groups"

  def stage_description do
    "Learn the fundamental data structure and syntax options for FlyMapEx marker groups."
  end

  def stage_examples do
    %{
      blank_map: %{
        marker_groups: nil,
        description: "Just the map",
        code_comment: "An empty map with no markers\nUseful for displaying the world map alone"
      },
      by_coords: %{
        marker_groups: [
          %{
            # San Francisco, somewhere in the North Sea
            nodes: [{37.8, -122.4}, {56, 3.6}]
          }
        ],
        description: "Single node with custom coordinates",
        code_comment: "Use coordinate tuples for precise positioning anywhere on the map"
      },
      fly_regions: %{
        marker_groups: [
          %{
            nodes: ["fra", "sin"]
          }
        ],
        description: "Single node using Fly.io region code",
        code_comment: "Use 3-letter region codes for Fly.io infrastructure locations"
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
      }
    }
  end

  def stage_tabs do
    [
      %{
        key: "blank_map",
        label: "The map",
        content: get_blank_map_content()
      },
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
        key: "multiple_nodes",
        label: "Multiple",
        content: get_multiple_content()
      }
    ]
  end

  def stage_navigation, do: StageConfig.stage_navigation(:stage1)

  def get_advanced_topics do
    [
      %{
        id: "coordinate-systems",
        title: "Understanding Coordinate Systems",
        content: get_coordinate_systems_content()
      },
      %{
        id: "data-structure",
        title: "Marker Group Data Structure",
        content: get_data_structure_content()
      },
      %{
        id: "production-tips",
        title: "Production Usage Tips",
        content: get_production_tips_content()
      }
    ]
  end

  def default_example, do: "blank_map"

  def stage_theme, do: :responsive
  def stage_layout, do: :side_by_side

  # Content generation functions using ContentHelpers
  defp get_blank_map_content do
    [
      ContentHelpers.content_section(
        "Just a map",
        ~s"""

        Here's a map with an empty marker group
        """
      )
    ]
    |> Enum.join()
  end

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
        ~s(Use "dev" for development environments - maps to Seattle coordinates.)
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

  # Advanced topics content

  defp get_coordinate_systems_content do
    ~s"""
    <div class="space-y-4">
      <p class="text-sm text-base-content/80">
        FlyMapEx supports two coordinate systems for maximum flexibility:
      </p>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <h4 class="font-semibold text-base-content mb-2">WGS84 Geographic Coordinates</h4>
          #{ContentHelpers.titled_list(["Standard latitude and longitude", "Range: -90 to 90 (latitude), -180 to 180 (longitude)", "Example: {37.7749, -122.4194} for San Francisco", "Use when you need precise custom locations"])}
        </div>
        <div>
          <h4 class="font-semibold text-base-content mb-2">Fly.io Region Codes</h4>
          #{ContentHelpers.titled_list(["Pre-defined 3-letter codes", ~s(Examples: "sjc", "fra", "ams", "lhr"), "Automatically resolved to exact coordinates", "Use for Fly.io infrastructure mapping"])}
        </div>
      </div>
    </div>
    """
  end

  defp get_data_structure_content do
    ~s"""
    <div class="space-y-4">
      <p class="text-sm text-base-content/80">
        Each marker group follows a consistent structure:
      </p>
      #{ContentHelpers.code_snippet(~s"""
    %{
      nodes: [list_of_nodes],    # Required: nodes to display
      style: style_specification, # Optional: visual styling
      label: "Group Name"        # Required: legend label
    }
    """)}
      <div class="mt-4">
        <h4 class="font-semibold text-base-content mb-2">Node Specifications</h4>
        <div class="space-y-2 text-sm">
          #{ContentHelpers.parameter_doc("Region Code", "string", "3-letter region identifier", ~s("sjc"))}
          #{ContentHelpers.parameter_doc("Coordinate Tuple", "tuple", "lat/lng coordinates", ~s({40.7128, -74.0060}))}
          #{ContentHelpers.parameter_doc("Custom Region Label", "map", "custom label for region", ~s(%{label: "NYC Office", region: "lhr"}))}
          #{ContentHelpers.parameter_doc("Custom Node", "map", "coordinates and label", ~s(%{coordinates: {lat, lng}, label: "Name"}))}
          #{ContentHelpers.parameter_doc("Mixed", "list", "combination of types", ~s(["sjc", {40.7128, -74.0060}, %{label: "NYC", region: "lhr"}]))}
        </div>
      </div>
    </div>
    """
  end

  defp get_production_tips_content do
    ~s"""
    <div class="space-y-4">
      #{ContentHelpers.ul_with_bold("Performance Considerations", [{"Groups with fewer than 20 nodes", "render efficiently"}, {"Use region codes when possible", "for smaller bundle size"}, {"Consider grouping related nodes", "for better organization"}])}
      #{ContentHelpers.ul_with_bold("Common Patterns", [{"Environment-based", "Production, Staging, Development"}, {"Service-based", "API Servers, Databases, CDN"}, {"Status-based", "Healthy, Warning, Error"}, {"Region-based", "US East, EU West, Asia Pacific"}])}
    </div>
    """
  end

end
