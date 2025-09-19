defmodule DemoWeb.PageLive do
  @moduledoc """
  LiveView to hold content
  """

  use DemoWeb, :live_view

  def mount(%{"page_id" => current_page}, _session, socket) do
    page_module = Module.concat(DemoWeb.Content, Demo.ContentMap.get_page_module(current_page))
    # content = apply(module, :get_content, [])

    %{:title => title, :description => description, :template => template} =
      apply(page_module, :doc_metadata, [])

    template_module = Module.concat(DemoWeb.Content, template)

    socket =
      socket
      |> assign(title: title, description: description, template_module: template_module)
      |> assign(page_module: page_module)
      |> assign(current_page: current_page)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <DemoWeb.Layouts.app flash={@flash} current_page={@current_page}>
      <:title>{@title}</:title>
      <:description>{@description}</:description>
      <.live_component module={@template_module} id={@current_page} page_module={@page_module} />
    </DemoWeb.Layouts.app>
    """
  end
end
