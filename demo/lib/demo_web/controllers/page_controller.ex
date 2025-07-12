defmodule DemoWeb.PageController do
  use DemoWeb, :controller

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
end
