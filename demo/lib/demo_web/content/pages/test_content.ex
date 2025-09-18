defmodule DemoWeb.Content.TestContent do
  @moduledoc """
  A content page to be rendered from PageLive.

  Needs to specify metadata (title, template) and assigns to pass to the template.
  """

  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div>
    <p>in the heex of test_content</p>
    <DemoWeb.Components.MapWithCodeComponent.map_with_code />
    </div>
    """
  end

  def doc_metadata do
    %{
      title: "TestContent Function Component",
      description: "Wraps MapWithCodeComponent.map_with_code with default code. I don't think the template value does anything yet.",
      template: "TestTemplate"
    }
  end

  def get_content do
      "Oh yeah, this is get_content"
  end


end
