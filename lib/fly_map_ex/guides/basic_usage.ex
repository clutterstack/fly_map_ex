defmodule FlyMapEx.Guides.BasicUsage do
  @moduledoc """
  Basic usage guide for FlyMapEx - placing markers using coordinates and Fly.io regions.

  This guide demonstrates the fundamental concepts of adding markers to maps using
  different position formats and marker groups.
  """

  import FlyMapEx.Content.ValidatedExample


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
      `<FlyMapEx.render />` renders just an SVG map in the default layout and colour theme.

      To place nodes on the map, supply the `:marker_groups` assign; a list of maps that must contain at least a `:nodes` field indicating where to put the markers on the map.

      Use latitude and longitude, Fly.io region (airport) codes, or custom-configured named locations for map positions.

      Here's an example with two node groups: one with a node in San Francisco and one somewhere in the North Sea, using `{lat, long}` notation; and one with a node in Frankfurt and a node in Singapore, using Fly.io region (airport) codes.
      """,
      example: validated_template("""
        <FlyMapEx.render
          marker_groups={[
            %{nodes: [{37.8, -122.4}, {56, 3.6}]},
            %{nodes: ["fra", "sin"]}
          ]}
        />
      """),
      tips: [
        "Coordinate tuples use standard WGS84 format: `{latitude, longitude}` where negative values mean western or southern hemispheres."
      ],
      related_links: [
        {"Map Themes", "theming"},
        {"WGS84 Coordinate System", "https://en.wikipedia.org/wiki/World_Geodetic_System"},
        {"Custom Regions", "#custom_regions"},
        {"Fly.io Regions", "https://fly.io/docs/reference/regions/"}
      ]
    }
  end

  def get_section("custom_regions") do
    %{
      title: "Configure custom regions",
      content: """
      Define custom regions in your app config for mixed Fly.io + local deployments. Perfect for showing development environments, office locations, or hybrid cloud setups.

      Custom regions are treated like Fly.io regions once configured, allowing seamless mixing of official regions with your own custom locations.
      """,
      example: validated_template("""
        <FlyMapEx.render
          marker_groups={[
            %{nodes: [{37.8, -122.4}, {56, 3.6}]},
            %{nodes: ["fra", "sin"]},
            %{nodes: ["laptop"]}
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
