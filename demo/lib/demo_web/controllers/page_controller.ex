defmodule DemoWeb.PageController do
  use DemoWeb, :controller

  alias DemoWeb.Helpers.PageDiscovery

  def show(conn, params) do
    slug = params["page"] || "home"
    case PageDiscovery.get_page(slug) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(DemoWeb.ErrorHTML)
        |> render(:"404")

      page ->
        # Get marker groups if the page module defines them
        marker_groups = get_marker_groups(page.module)
        
        # Build assigns for the page
        base_assigns = %{
          page_title: page.title,
          page_description: page.description,
          page_slug: page.slug,
          seo_keywords: page.keywords,
          marker_groups: marker_groups,
          flash: conn.assigns[:flash] || %{}
        }
        
        # Generate content
        content = page.module.content(base_assigns)
        content_assigns = Map.put(base_assigns, :page_content, content)
        
        render(conn, :show, content_assigns)
    end
  end
  
  defp get_marker_groups(module) do
    if function_exported?(module, :marker_groups, 0) do
      apply(module, :marker_groups, [])
    else
      nil
    end
  end
end
