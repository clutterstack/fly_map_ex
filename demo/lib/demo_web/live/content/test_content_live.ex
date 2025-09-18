defmodule DemoWeb.Live.Content.TestContentLive do
  @moduledoc """
  A content page to be rendered from PageLive.

  Needs to specify metadata (title, template) and assigns to pass to the template.
  """

  use DemoWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
    <p>in the heex of test_content_live</p>
    <DemoWeb.Components.MapWithCodeComponent.map_with_code />
    </div>
    """
  end

    def doc_metadata do
    %{
      title: "TestContent LiveComponent",
      description: "Wraps MapWithCodeComponent.map_with_code with default code.",
      template: :docs_layout
    }
  end

  def get_content do
      "Oh yeah, this is get_content"
  end


end
