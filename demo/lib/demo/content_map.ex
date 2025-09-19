defmodule Demo.ContentMap do
  @sections %{
    "1" => [
      {:text, "You wake up in a forest."},
      {:choice, "Look around", to: "2"},
      {:choice, "Go back to sleep", to: "3"}
    ],
    "2" => [
      {:text, "You see a path."},
      {:choice, "Follow it", to: "4"}
    ]
  }

  # path_parameter: module_name
  @path_modules %{
    "test_content" => "TestContent",
    "test_content_live" => "TestContentLive",
    "node_placement" => "NodePlacement",
    "live_comp" => "LiveComp",
    "marker_styling"=> "MarkerStyling",
    "theming" => "Theming",
    "interactive_builder" => "InteractiveBuilder"
  }

  def get(id), do: Map.fetch!(@sections, id)
  def get_page_module(id), do: Map.fetch!(@path_modules, id)
end
