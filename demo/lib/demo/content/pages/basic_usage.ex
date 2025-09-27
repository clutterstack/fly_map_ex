defmodule DemoWeb.Content.BasicUsage do
  @moduledoc """
  Demo app wrapper for FlyMapEx.Guides.BasicUsage.

  This module provides a thin adapter layer between the library guide
  and the demo app's presentation requirements.
  """

  use DemoWeb.Content.GenericGuide, guide: FlyMapEx.Guides.BasicUsage
end
