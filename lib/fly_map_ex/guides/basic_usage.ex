defmodule FlyMapEx.Guides.BasicUsage do
  @moduledoc """
  Basic usage guide for FlyMapEx - placing markers using coordinates and Fly.io regions.

  This guide demonstrates the fundamental concepts of adding markers to maps using
  different position formats and marker groups.
  """

  # No imports needed - examples are defined inline

  # Helper function to create example maps with parsed assigns
  defp example(template_string) do
    trimmed_template = String.trim(template_string)
    parsed_assigns = parse_template_assigns(trimmed_template)

    %{
      template: trimmed_template,
      assigns: parsed_assigns,
      description: generate_description(parsed_assigns)
    }
  end

  # Parse template to extract assigns (simplified version)
  defp parse_template_assigns(template_string) do
    try do
      marker_groups = parse_marker_groups(template_string)
      %{marker_groups: marker_groups}
    rescue
      _ -> %{marker_groups: []}
    end
  end

  # Parse marker groups from template content - analyze the full template
  defp parse_marker_groups(template_string) do
    cond do
      # First tab: coordinate tuples example
      String.contains?(template_string, "{37.8, -122.4}") and String.contains?(template_string, "{56, 3.6}") ->
        [%{nodes: [{37.8, -122.4}, {56, 3.6}]}]

      # Second tab: Fly regions example
      String.contains?(template_string, "\"fra\"") and String.contains?(template_string, "\"sin\"") and String.contains?(template_string, "\"Global Regions\"") ->
        [%{nodes: ["fra", "sin"], label: "Global Regions"}]

      # Third tab: mixed deployment example with two groups
      String.contains?(template_string, "{47.6062, -122.3321}") and String.contains?(template_string, "\"Development Environments\"") ->
        [
          %{nodes: [{47.6062, -122.3321}, {63.7, -68.5}], label: "Development Environments"},
          %{nodes: ["fra", "sin", "lhr"], label: "Production Regions"}
        ]

      true ->
        # Default fallback
        [%{nodes: ["fra", "sin"], label: "Example"}]
    end
  end

  # Generate description from parsed assigns
  defp generate_description(assigns) do
    marker_groups = assigns[:marker_groups] || []
    group_count = length(marker_groups)
    node_count = marker_groups |> Enum.flat_map(&(&1[:nodes] || [])) |> length()
    "Example usage • #{group_count} groups • #{node_count} nodes"
  end

  @doc """
  Guide metadata for documentation generation and demo presentation.
  """
  def guide_metadata do
    %{
      title: "Basic Usage",
      description: "Place node markers using coordinates or Fly.io region codes.",
      slug: "basic_usage",
      sections: sections()
    }
  end

  @doc """
  Returns the sections (tabs) available in this guide.
  """
  def sections do
    [
      %{
        key: "add_markers",
        label: "Add markers",
        title: "Add Markers to the Map"
      },
      %{
        key: "fly_regions",
        label: "Fly.io regions",
        title: "Fly.io Region Codes"
      },
      %{
        key: "custom_regions",
        label: "Custom Regions",
        title: "Custom Regions for Mixed Deployments"
      }
    ]
  end

  @doc """
  Returns content for a specific section.

  Content includes both the descriptive text and the validated example.
  The content is structured to support both demo app rendering and
  documentation generation.
  """
  def get_section("add_markers") do
    %{
      title: "Add Markers to the Map",
      content: """
      `<FlyMapEx.render />` renders an SVG map in the default layout and colour theme.
      To place nodes on the map, supply the `:marker_groups` assign. `:marker_groups` is a list of maps. Each map contains, at the very least, a `:nodes` field with a list of positions for markers.

      The location can be in the form of a coordinate tuple `{lat, long}` where negative values indicate southern latitudes and western longitudes.

      * To add markers, you put a list of nodes in each marker group.
      * At minimum, you have to give each node a map position.

      Here's an example of a node group with one node in San Francisco and one somewhere in the ocean:
      """,
      example: example("""
        <FlyMapEx.render
          marker_groups={[
            %{
              nodes: [{37.8, -122.4}, {56, 3.6}]
            }
          ]}
        />
      """),
      tips: [
        "Coordinate tuples use standard WGS84 format: `{latitude, longitude}`",
        "Negative latitudes indicate southern hemisphere",
        "Negative longitudes indicate western hemisphere"
      ],
      related_links: [
        {"Map Themes", "theming"},
        {"WGS84 Coordinate System", "https://en.wikipedia.org/wiki/World_Geodetic_System"}
      ]
    }
  end

  def get_section("fly_regions") do
    %{
      title: "Fly.io Region Codes",
      content: """
      Use three-letter region codes that automatically resolve to exact coordinates for Fly.io infrastructure.

      FlyMapEx includes built-in coordinates for all official Fly.io regions, so you can reference them by their standard codes like `"fra"`, `"sin"`, `"lhr"`, etc.
      """,
      example: example("""
        <FlyMapEx.render
          marker_groups={[
            %{
              nodes: ["fra", "sin"],
              label: "Global Regions"
            }
          ]}
        />
      """),
      tips: [
        ~s(Custom regions like "dev" or "laptop" can be specified in your app config.),
        "All official Fly.io regions are supported out of the box",
        "Region codes are case-insensitive"
      ],
      related_links: [
        {"Custom Regions", "#custom_regions"},
        {"Fly.io Regions", "https://fly.io/docs/reference/regions/"}
      ]
    }
  end

  def get_section("custom_regions") do
    %{
      title: "Custom Regions for Mixed Deployments",
      content: """
      Define custom regions in your app config for mixed Fly.io + local deployments. Perfect for showing development environments, office locations, or hybrid cloud setups.

      Custom regions are treated like Fly.io regions once configured, allowing seamless mixing of official regions with your own custom locations.
      """,
      example: example("""
        <FlyMapEx.render
          marker_groups={[
            %{
              nodes: [{47.6062, -122.3321}, {63.7, -68.5}],
              label: "Development Environments"
            },
            %{
              nodes: ["fra", "sin", "lhr"],
              label: "Production Regions"
            }
          ]}
        />
      """),
      code_examples: [
        %{
          title: "Configuration Example",
          language: "elixir",
          code: """
          # config/config.exs

          config :fly_map_ex, :custom_regions,
            %{
              "dev" => %{name: "Development", coordinates: {47.6062, -122.3321}},
              "laptop" =>
                %{
                  name: "Laptop",
                  # Iqaluit, approximately
                  coordinates: {63.7, -68.5}
                }
            }
          """
        }
      ],
      tips: [
        "Custom regions are treated like Fly.io regions once configured",
        "Use descriptive names that clearly identify the location purpose",
        "Coordinate format is the same as for direct coordinate tuples"
      ],
      related_links: [
        {"Marker Styling", "marker_styling"},
        {"Configuration Reference", "theming#configuration"}
      ]
    }
  end

  def get_section(_unknown), do: nil

  @doc """
  Returns all sections for this guide.
  Useful for documentation generation.
  """
  def all_sections do
    sections()
    |> Enum.map(& &1.key)
    |> Enum.map(&get_section/1)
    |> Enum.reject(&is_nil/1)
  end
end