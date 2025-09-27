defmodule DemoWeb.Content.BasicUsage do
  @moduledoc """
  Demo app wrapper for FlyMapEx.Guides.BasicUsage.

  This module provides a thin adapter layer between the library guide
  and the demo app's presentation requirements.
  """

  alias FlyMapEx.Guides.BasicUsage, as: LibraryGuide
  alias DemoWeb.Adapters.GuideAdapter

  @doc """
  Gives the PageLive LiveView the title and description to populate slots in Layouts.app/1,
  and the live_component to use as a template for rendering the content in this module.
  """

  def doc_metadata do
    GuideAdapter.adapt_metadata(LibraryGuide)
  end

  def tabs do
    GuideAdapter.adapt_tabs(LibraryGuide)
  end

  @doc """
  Delegates to library guide content via adapter.
  """
  def get_content(section_key) do
    GuideAdapter.adapt_content(LibraryGuide, section_key)
  end
end
