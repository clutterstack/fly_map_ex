defmodule DemoWeb.Pages.HomePage do
  @moduledoc """
  Home page demonstrating FlyMapEx library capabilities.
  """
  
  import DemoWeb.Helpers.ContentHelpers
  
  @title "FlyMapEx Demo Application"
  @description "This demo showcases FlyMapEx, a Phoenix LiveView library for displaying interactive world maps with Fly.io region markers."
  @nav_order 0
  @keywords "elixir, phoenix, maps, fly.io, interactive, world map"
  @slug "home"
  
  def marker_groups do
    [
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
    ]
  end

  def content(_assigns) do
    convert_markdown("""
    * Interactive World Maps: Display Fly.io regions with customizable markers and themes
    * Real-time Updates: LiveView components that respond to data changes
    * Multiple Themes: Dashboard, monitoring, presentation, and more
    * Responsive Design: Works seamlessly on desktop and mobile devices
    * Flexible Configuration: Easy to customize colours, animations, and layouts
    """) <>
    ~s"""
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-6">
      #{info_box(:primary, "Get Started", 
        "Explore the interactive stages to learn how to use FlyMapEx in your own applications.")}
      #{info_box(:success, "Live Example", 
        "The map above shows real Fly.io regions with sample data to demonstrate the library's capabilities.")}
    </div>
    """
  end
end