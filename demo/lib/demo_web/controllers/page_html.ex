defmodule DemoWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use DemoWeb, :html
  import DemoWeb.Helpers.ContentHelpers

  embed_templates "page_html/*"


  # Put a function component in
  def greet(assigns) do
    ~H"""
    <h2>Hello World, from {@messenger}!</h2>
    """
  end

  # Could put HEEx here instead of in page_html/ template files:
  # def home(assigns) do
  #   ~H"""
  # ...
  #   """

end
