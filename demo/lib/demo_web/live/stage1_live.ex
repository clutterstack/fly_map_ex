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
      single_coordinates: [
        %{
          nodes: [%{coordinates: {37.7749, -122.4194}, label: "San Francisco"}],
          label: "Single Node"
        }
      ],
      single_region: [
        %{
          nodes: ["sjc"],
          label: "Single Server"
        }
      ],
      multiple_nodes: [
        %{
          nodes: ["sjc", "fra", "ams", "lhr"],
          label: "Global Deployment"
        }
      ],
      multiple_groups: [
        %{
          nodes: ["sjc", "fra"],
          label: "Production Servers"
        },
        %{
          nodes: ["ams", "lhr"],
          label: "Staging Environment"
        }
      ]
    }
  end

  def stage_tabs do
    [
      %{
        key: "library_intro",
        label: "About",
        content: get_intro_content()
      },
      %{
        key: "single_coordinates",
        label: "Coordinates",
        content: get_coordinates_content()
      },
      %{
        key: "single_region",
        label: "Fly Regions",
        content: get_region_content()
      },
      %{
        key: "multiple_nodes",
        label: "Multiple",
        content: get_multiple_content()
      },
      %{
        key: "multiple_groups",
        label: "Groups",
        content: get_groups_content()
      }
    ]
  end

  def stage_navigation, do: StageConfig.stage_navigation(:stage1)

  def get_current_description(example) do
    case example do
      "single_coordinates" -> "Single node with custom coordinates"
      "single_region" -> "Single node using Fly.io region code"
      "multiple_nodes" -> "Multiple nodes in one group"
      "multiple_groups" -> "Multiple groups with different purposes"
      "library_intro" -> "About FlyMapEx library"
      _ -> "Unknown example"
    end
  end

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

  def default_example, do: "library_intro"

  # Content generation functions using ContentHelpers

  defp get_intro_content do
  [
    ContentHelpers.content_section(
      "About FlyMapEx",
      "An over-engineered library for putting markers on a simple map."
    ),
    ContentHelpers.info_box(
      :primary,
      "Coordinate Format",
      coordinate_format_content()
    ),
    ContentHelpers.use_cases(
      "When to Use",
      [
        {"Custom locations", "not covered by Fly.io regions"},
        {"Office locations", "data centres, or business sites"},
        {"Precise geographic mapping", "requirements"},
        {"Integration", "with external coordinate data"}
      ]
    ),
    ContentHelpers.pro_tip(
      "Use WGS84 coordinates (standard GPS format). FlyMapEx automatically transforms them to map projection."
    ),
    "</div>"  # Consider moving this to where the opening <div> was created, if needed
  ]
  |> Enum.join()
end

  defp get_coordinates_content do
    [
    ContentHelpers.content_section(
      "Custom Coordinates",
      "Use exact latitude and longitude coordinates for precise placement anywhere on the map."
    ),
    ContentHelpers.info_box(
      :primary,
      "Coordinate Format",
      coordinate_format_content()
    ),
    ContentHelpers.use_cases(
      "When to Use",
      [
        {"Custom locations", "not covered by Fly.io regions"},
        {"Office locations", "data centres, or business sites"},
        {"Precise geographic mapping", "requirements"},
        {"Integration", "with external coordinate data"}
      ]
    ),
    ContentHelpers.pro_tip(
      "Use WGS84 coordinates (standard GPS format). FlyMapEx automatically transforms them to map projection."
    ),
    "</div>"
    ]
    |> Enum.join()
  end

  defp get_region_content do
    [
    ContentHelpers.content_section(
      "Fly.io Region Codes",
      "Use three-letter region codes that automatically resolve to exact coordinates for Fly.io infrastructure."
    ),
    ContentHelpers.info_box(
      :success,
      "Popular Regions",
      popular_regions_content()
    ),
    ContentHelpers.use_cases(
      "Benefits",
      [
        {"Automatically validated", "region codes"},
        {"Smaller bundle size", "than coordinates"},
        {"Perfect for Fly.io", "infrastructure mapping"},
        {"Easy to remember", "and type"}
      ]
    ),
    ContentHelpers.pro_tip(
      ~s(Use "dev" for development environments - maps to Seattle coordinates.),
      type: :warning
    ),
    "</div>"
    ]
    |> Enum.join()
  end

  defp get_multiple_content do
    [
      ContentHelpers.content_section(
        "Multiple Nodes in One Group",
        "Combine multiple nodes under a single label and styling for logical organization."
      ),
      ContentHelpers.info_box(
        :secondary,
        "Array of Nodes",
        multiple_nodes_content()
      ),
      ContentHelpers.use_cases(
        "Use Cases",
        [
          {"Global deployment", "across multiple regions"},
          {"Load-balanced services", "in multiple zones"},
          {"Geographic redundancy", "planning"},
          {"Service mesh", "or CDN endpoints"}
        ]
      ),
      ContentHelpers.pro_tip(
        "Group related nodes together (e.g., all production servers, all staging environments).",
        type: :best_practice
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  defp get_groups_content do
    [
      ContentHelpers.content_section(
        "Multiple Groups",
        "Organize nodes into distinct groups with different purposes, environments, or statuses."
      ),
      ContentHelpers.status_steps([
        {:operational, "Production Servers", "Critical production infrastructure", "bg-primary"},
        {:staging, "Staging Environment", "Pre-production testing servers", "bg-success"}
      ]),
      ContentHelpers.use_cases(
        "Grouping Strategies",
        [
          {"Environment-based", "Production, Staging, Development"},
          {"Service-based", "API, Database, CDN, Cache"},
          {"Status-based", "Healthy, Warning, Error, Maintenance"},
          {"Geographic-based", "US-East, EU-West, Asia-Pacific"}
        ]
      ),
      ContentHelpers.pro_tip(
        "Each group automatically appears in the legend with its label and colour.",
        type: :best_practice
      ),
      "</div>"
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
          #{ContentHelpers.feature_list([
            "Standard latitude and longitude",
            "Range: -90 to 90 (latitude), -180 to 180 (longitude)",
            "Example: {37.7749, -122.4194} for San Francisco",
            "Use when you need precise custom locations"
          ])}
        </div>
        <div>
          <h4 class="font-semibold text-base-content mb-2">Fly.io Region Codes</h4>
          #{ContentHelpers.feature_list([
            "Pre-defined 3-letter codes",
            ~s(Examples: "sjc", "fra", "ams", "lhr"),
            "Automatically resolved to exact coordinates",
            "Use for Fly.io infrastructure mapping"
          ])}
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
          #{ContentHelpers.parameter_doc("Custom Node", "map", "coordinates and label", ~s(%{coordinates: {lat, lng}, label: "Name"}))}
          #{ContentHelpers.parameter_doc("Mixed", "list", "combination of types", ~s(["sjc", %{coordinates: {40.7128, -74.0060}, label: "NYC"}]))}
        </div>
      </div>
    </div>
    """
  end

  defp get_production_tips_content do
    ~s"""
    <div class="space-y-4">
      #{ContentHelpers.use_cases("Performance Considerations", [
        {"Groups with fewer than 20 nodes", "render efficiently"},
        {"Use region codes when possible", "for smaller bundle size"},
        {"Consider grouping related nodes", "for better organization"}
      ])}
      #{ContentHelpers.use_cases("Common Patterns", [
        {"Environment-based", "Production, Staging, Development"},
        {"Service-based", "API Servers, Databases, CDN"},
        {"Status-based", "Healthy, Warning, Error"},
        {"Region-based", "US East, EU West, Asia Pacific"}
      ])}
    </div>
    """
  end

  # Helper content functions

  defp coordinate_format_content do
    ~s"""
    <div class="space-y-2 text-sm">
      #{ContentHelpers.parameter_doc("Latitude", "number", "North/South position (-90 to 90)", nil)}
      #{ContentHelpers.parameter_doc("Longitude", "number", "East/West position (-180 to 180)", nil)}
      #{ContentHelpers.parameter_doc("Example", "tuple", "San Francisco coordinates", "{37.7749, -122.4194}")}
    </div>
    """
  end

  defp popular_regions_content do
    ContentHelpers.color_grid([
      {"bg-base-100", ~s("sjc" - San Jose, US)},
      {"bg-base-100", ~s("fra" - Frankfurt, DE)},
      {"bg-base-100", ~s("lhr" - London, UK)},
      {"bg-base-100", ~s("nrt" - Tokyo, JP)}
    ], cols: 2)
  end

  defp multiple_nodes_content do
    ~s"""
    <div class="space-y-2 text-sm">
      #{ContentHelpers.parameter_doc("Simple List", "list", "array of region codes", ~s(["sjc", "fra", "ams"]))}
      #{ContentHelpers.parameter_doc("Mixed Types", "list", "can combine region codes and coordinates", nil)}
      #{ContentHelpers.parameter_doc("Shared Properties", "inherit", "all nodes inherit group label and styling", nil)}
    </div>
    """
  end

  # Override context name for better code generation
  def get_context_name(example) do
    case example do
      "single_coordinates" -> "coordinates"
      "single_region" -> "region"
      "multiple_nodes" -> "multiple"
      "multiple_groups" -> "groups"
      "library_intro" -> "intro"
      _ -> "example"
    end
  end
end
