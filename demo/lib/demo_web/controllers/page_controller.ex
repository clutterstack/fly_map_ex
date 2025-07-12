defmodule DemoWeb.PageController do
  use DemoWeb, :controller

  alias DemoWeb.Helpers.ContentLoader

  def home(conn, _params) do
     marker_groups=[
    %{
      nodes: ["sjc", "fra"],
      label: "Production Servers"
    },
    %{
      nodes: ["ams", "lhr"],
      label: "Staging Environment"
    },
    %{
      nodes: ["ord"],
      label: "Development"
    },
    %{
      nodes: ["nrt", "syd"],
      label: "Testing"
    }
]
    render(conn, :home, groups: marker_groups)
  end

  def show(conn, %{"page" => slug}) do
    case ContentLoader.get_page(slug) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(DemoWeb.ErrorHTML)
        |> render(:"404")

      page ->
        render(conn, :show, page: page)
    end
  end
end
