defmodule DemoWeb.Live.Content.LiveComp do
  @moduledoc """
  A content page that's a LiveComponent
  """

  use DemoWeb, :live_component

  def doc_metadata do
    %{
      title: "A LiveView Page",
      description: "Test a LiveComponent as a way to encapsulate the handlers and stuff needed for a type of interactive page",
      template: :stage_template
    }
  end


end
