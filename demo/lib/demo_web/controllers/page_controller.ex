defmodule DemoWeb.PageController do
  use DemoWeb, :controller

  alias DemoWeb.Helpers.PageDiscovery

  def show(conn, params) do
    slug = params["page"] || conn.path_params["page"] || "home"
    case PageDiscovery.get_page(slug) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(DemoWeb.ErrorHTML)
        |> render(:"404")

      page ->

        # Build assigns for the page
        base_assigns = %{
          page_title: page.title,
          page_description: page.description,
          page_slug: page.slug,
          seo_keywords: page.keywords,
          flash: conn.assigns[:flash] || %{}
        }

        # Generate content
        content = page.module.content(base_assigns)
        content_assigns = Map.put(base_assigns, :page_content, content)

        render(conn, :show, content_assigns)
    end
  end

end
