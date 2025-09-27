defmodule DemoWeb.PageLive do
  @moduledoc """
  LiveView to hold content
  """

  use DemoWeb, :live_view

  def mount(%{"page_id" => current_page}, _session, socket) do
    case DemoWeb.RouteRegistry.get_route_module(current_page) do
      {:ok, page_module} ->
        try do
          %{:title => title, :description => description, :template => template} =
            apply(page_module, :doc_metadata, [])

          template_module = Module.concat(DemoWeb.Content, template)

          socket =
            socket
            |> assign(title: title, description: description, template_module: template_module)
            |> assign(page_module: page_module)
            |> assign(current_page: current_page)

          {:ok, socket}
        rescue
          error ->
            require Logger
            Logger.error("Error loading content module #{inspect(page_module)}: #{inspect(error)}")
            {:ok, redirect(socket, to: "/404")}
        end

      {:error, reason} ->
        require Logger
        Logger.info("Invalid content path '#{current_page}': #{reason}")
        {:ok, redirect(socket, to: "/404")}
    end
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
