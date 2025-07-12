defmodule DemoWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use DemoWeb, :html

  import DemoWeb.Components.PageTemplate

  embed_templates "page_html/*"
end
