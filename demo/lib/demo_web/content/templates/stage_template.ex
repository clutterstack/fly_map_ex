defmodule DemoWeb.Content.StageTemplate do
  @moduledoc """
  A template to render content from within PageLive.
  """

  use DemoWeb, :live_component

  # use Phoenix.Component
    import DemoWeb.Components.InteractiveControls


  attr :tabs, :list, required: true
  attr :current_tab, :integer, default: 0
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :component_type, :atom, required: true
  attr :examples, :any, required: true
  attr :all_examples, :map, required: true
  attr :get_focused_code, :any, required: true
  attr :layout, :atom, default: :side_by_side
  attr :theme, :any, default: nil

  def render(assigns) do
    first_tab = assigns.tabs |> List.first() |> Map.get(:key)

    ~H"""
    <div>
    <p>in the heex of StageTemplate.render</p>
    <p>The current page module is {@page_module}</p>
    <p>Its content is {@content}</p>
    <p>TKTK the layout and components that go in here</p>
     <.content_panels
            tabs={@tabs}
            current_tab={@current_tab}
          />
    </div>
    """
  end


    @doc """
  Renders the side-by-side content panels with tabbed info and code examples.
  """
  attr :tabs, :list, required: true
  attr :current_tab, :integer, required: true
  attr :examples, :any, required: true
  attr :get_focused_code, :any, required: true

  def content_panels(assigns) do
    ~H"""
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
      <!-- Tabbed Info Panel -->
      <div>
        <.new_tabbed_info_panel
          tabs={@tabs}
          current={@current_tab}
        />
      </div>
    </div>
    """
  end


  @impl true
  def handle_event("switch_tab", %{"index" => idx_str}, socket) do
    idx = String.to_integer(idx_str)
        Logger.info("Switching to tab #{idx}")

    {:noreply, assign(socket, :current, idx)}
  end


  # Helper functions

  defp get_examples_count(examples) when is_nil(examples), do: 0
  defp get_examples_count(examples) when is_list(examples), do: length(examples)
  defp get_examples_count(_), do: 1

  defp count_total_nodes(examples) when is_nil(examples), do: 0

  defp count_total_nodes(examples) when is_list(examples) do
    Enum.reduce(examples, 0, fn group, acc ->
      nodes = group[:nodes] || []
      acc + length(nodes)
    end)
  end

  defp count_total_nodes(_), do: 0


end
