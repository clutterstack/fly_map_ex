defmodule DemoWeb.HomePageHTML do
  @moduledoc """
  This module contains pages rendered by HomePageController.
  """
  use DemoWeb, :html

  import DemoWeb.Components.PageTemplate

  embed_templates "home_page_html/*"
end