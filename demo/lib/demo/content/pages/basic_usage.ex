defmodule DemoWeb.Content.BasicUsage do
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
        key: "add_markers",
        label: "Add markers"
      },
      %{
        key: "fly_regions",
        label: "Fly.io regions"
      },
      %{
        key: "custom_regions",
        label: "Custom Regions"
      }
    ]
  end

  @doc """
   All the content for each tab:
  * `content`: Info to go into the info panel
  * `example`: A description for the code panel label, an optional code comment,
    and the assigns to pass to the FlyMapEx.render component.
  """

  def get_content("blank_map") do
    %{
      content:
        [
          ContentHelpers.convert_markdown(
          ~s"""
          `<FlyMapEx.render />` renders an SVG map in the default layout and colour theme.
          """
          ),
          ContentHelpers.info_box(
            :primary,
            "Refs",
            ContentHelpers.convert_markdown(
              ~s"""
              TK link map themes

              TK link WGS 84
              """
            )
          ),
        ],
      example: validated_template("""
        <FlyMapEx.render />
      """)
    }
  end

  def get_content("add_markers") do
    %{
      content:
        [
          ContentHelpers.content_section(
            "Add markers to the map",
            ~s"""

            `<FlyMapEx.render />` renders an SVG map in the default layout and colour theme.
              To place nodes on the map, supply the `:marker_groups` assign. `:marker_groups` is a list of maps. Each map contains, at the very least, a `:nodes` field with a list of positions for markers. The marker

              The location can be in the form of a coordinate tuple `{lat, long}` where negative values indicate southern latitudes and western longitudes.

            * To add markers, you put a list of nodes in each marker group.
            * At minimum, you have to give each node a map position.


            Here's an example of a node group with one node in San Francisco and one somewhere in the ocean
            """
          ),
          ContentHelpers.info_box(
            :primary,
            "Refs",
            ContentHelpers.convert_markdown(
              ~s"""
              TK link map themes

              TK link WGS 84
              """
            )
          ),
        ]
        |> Enum.join(),
      example: validated_template("""
        <FlyMapEx.render
          marker_groups={[
            %{
              nodes: [{37.8, -122.4}, {56, 3.6}]
            }
          ]}
        />
      """)
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
            ~s(Custom regions like "dev" or "laptop" can be specified in your app config.)
          )
        ]
        |> Enum.join(),
      example: validated_template("""
        <FlyMapEx.render
          marker_groups={[
            %{
              nodes: ["fra", "sin"],
              label: "Global Regions"
            }
          ]}
        />
      """)
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
                "laptop" =>
                  %{
                    name: "Laptop",
                    # Iqaluit, approximately
                    coordinates: {63.7, -68.5}
                  }
              }
            """
          ),
          ContentHelpers.pro_tip(
            "Custom regions are treated like Fly.io regions once configured."
          )
        ]
        |> Enum.join(),
      example: validated_template("""
        <FlyMapEx.render
          marker_groups={[
            %{
              nodes: ["dev", "laptop"]
            },
            %{
              nodes: ["fra", "sin", "lhr"]
            }
          ]}
        />
      """)
    }
  end
end
