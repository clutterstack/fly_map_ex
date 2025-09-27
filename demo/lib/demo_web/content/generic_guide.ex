defmodule DemoWeb.Content.GenericGuide do
  @moduledoc """
  Provides macros for creating content wrapper modules for library guides.

  This module eliminates duplication by providing a single macro that generates
  the standard content interface (doc_metadata/0, tabs/0, get_content/1) for
  any FlyMapEx library guide module.

  ## Usage

      defmodule DemoWeb.Content.MyGuide do
        use DemoWeb.Content.GenericGuide, guide: FlyMapEx.Guides.BasicUsage
      end

  This generates the same interface as the original wrapper modules but without
  code duplication.
  """

  defmacro __using__(opts) do
    guide_module = Keyword.fetch!(opts, :guide)

    quote do
      alias DemoWeb.Adapters.GuideAdapter

      @guide_module unquote(guide_module)

      @doc """
      Gives the PageLive LiveView the title and description to populate slots in Layouts.app/1,
      and the live_component to use as a template for rendering the content in this module.
      """
      def doc_metadata do
        GuideAdapter.adapt_metadata(@guide_module)
      end

      def tabs do
        GuideAdapter.adapt_tabs(@guide_module)
      end

      @doc """
      Delegates to library guide content via adapter.
      """
      def get_content(section_key) do
        GuideAdapter.adapt_content(@guide_module, section_key)
      end
    end
  end
end