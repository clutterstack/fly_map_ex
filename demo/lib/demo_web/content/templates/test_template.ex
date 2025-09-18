defmodule DemoWeb.Content.TestTemplate do
  @moduledoc """
  A template to render content from within PageLive.
  """

  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div>
    <p>in the heex of TestTemplate.render</p>
    <p>The current page is {@current_page}</p>
    <DemoWeb.Components.MapWithCodeComponent.map_with_code />
    </div>
    """
  end



end
