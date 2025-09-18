defmodule DemoWeb.Content.NodePlacement do
  @moduledoc """
  A content page to be rendered from PageLive.

  Needs to specify metadata (title, template) and assigns that the template function component takes
  """

  use Phoenix.Component
  alias DemoWeb.Helpers.ContentHelpers

  def show(assigns) do
    ~H"""
    <.live_component module={DemoWeb.Content.StageTemplate}
      id={@current_page}
      content="value of content assign in node_placement.ex"
      page_module={@page_module}
      tabs={tabs()}
    />
    """
  end

  def doc_metadata do
    %{
      title: "NodePlacement Module",
      description: "This is a content module ",
    }
  end

  def get_content do
      "Oh yeah, this is get_content"
  end

  defp tabs do
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
