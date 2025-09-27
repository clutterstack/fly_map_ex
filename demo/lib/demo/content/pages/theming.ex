defmodule DemoWeb.Content.Theming do
  @moduledoc """
  Demo app wrapper for FlyMapEx.Guides.Theming.

  This module provides a thin adapter layer between the library guide
  and the demo app's presentation requirements.
  """

  use DemoWeb.Content.GenericGuide, guide: FlyMapEx.Guides.Theming
end
