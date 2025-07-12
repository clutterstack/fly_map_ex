defmodule DemoWeb.Pages.AboutPage do
  @moduledoc """
  About page demonstrating pure markdown content with the new simplified system.
  """
  
  import DemoWeb.Helpers.ContentHelpers
  
  @title "About FlyMapEx"
  @description "Learn more about the FlyMapEx library and its capabilities."
  @nav_order 1
  @keywords "about, flymap, elixir, phoenix, documentation"
  @slug "about"
  
  def content(_assigns) do
    convert_markdown("""
    # About FlyMapEx
    
    FlyMapEx is a Phoenix LiveView library designed to make it easy to display 
    interactive world maps with Fly.io region markers. It was built to help 
    developers visualize their global infrastructure and deployments.
    
    ## Key Features
    
    - **Interactive Maps**: Click and interact with regions
    - **Multiple Themes**: Choose from dashboard, monitoring, presentation styles
    - **Real-time Updates**: LiveView integration for dynamic data
    - **Responsive Design**: Works on all screen sizes
    - **Easy Integration**: Simple component-based API
    
    ## Getting Started
    
    Check out the interactive stages to learn how to use FlyMapEx in your applications.
    """) <>
    info_box(:primary, "Documentation", 
      "Visit our GitHub repository for complete documentation and examples.")
  end
end