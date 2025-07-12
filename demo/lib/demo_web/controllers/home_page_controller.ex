defmodule DemoWeb.HomePageController do
  @moduledoc """
  Home page using the PageBase behaviour.
  Demonstrates map integration with structured content.
  """

  use DemoWeb.Controllers.PageBase
  use Phoenix.Component

  # Required PageBase callbacks
  def page_title, do: "FlyMapEx Demo Application"
  
  def page_description do
    "This demo showcases FlyMapEx, a Phoenix LiveView library for displaying interactive world maps with Fly.io region markers."
  end
  
  def page_slug, do: "home"

  # Optional callbacks
  def nav_order, do: 0  # First in navigation

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

  def page_theme, do: :responsive

  def page_content(_assigns) do
    markdown_content = DemoWeb.Helpers.ContentHelpers.convert_markdown("""
    * Interactive World Maps: Display Fly.io regions with customizable markers and themes
    * Real-time Updates: LiveView components that respond to data changes
    * Multiple Themes: Dashboard, monitoring, presentation, and more
    * Responsive Design: Works seamlessly on desktop and mobile devices
    * Flexible Configuration: Easy to customize colours, animations, and layouts
    """)
    
    Phoenix.HTML.raw("""
    <div>
      <div style="margin-bottom: 1.5rem;">
        <!-- Map component will be rendered here -->
        <p><em>FlyMapEx map component would render here</em></p>
      </div>
    
      #{markdown_content}
        
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="bg-primary/10 border border-primary/20 rounded-lg p-4">
          <h4 class="font-medium text-primary mb-2">Get Started</h4>
          <p class="text-sm text-primary/80">
            Explore the interactive stages to learn how to use FlyMapEx in your own applications.
          </p>
        </div>
        <div class="bg-success/10 border border-success/20 rounded-lg p-4">
          <h4 class="font-medium text-success mb-2">Live Example</h4>
          <p class="text-sm text-success/80">
            The map above shows real Fly.io regions with sample data to demonstrate the library's capabilities.
          </p>
        </div>
      </div>
    </div>
    """)
  end
end