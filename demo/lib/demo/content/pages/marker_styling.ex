defmodule DemoWeb.Content.MarkerStyling do
  @moduledoc """
  Demo app wrapper for FlyMapEx.Guides.MarkerStyling.

  This module provides a thin adapter layer between the library guide
  and the demo app's presentation requirements.
  """

  use DemoWeb.Content.GenericGuide, guide: FlyMapEx.Guides.MarkerStyling
end
