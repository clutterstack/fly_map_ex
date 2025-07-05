defmodule FlyMapEx.ConfigTest do
  use ExUnit.Case, async: true

  doctest FlyMapEx.Config

  alias FlyMapEx.Config

  describe "configuration functions" do
    test "marker_opacity/0 returns default value" do
      assert Config.marker_opacity() == 1.0
    end

    test "hover_opacity/0 returns default value" do
      assert Config.hover_opacity() == 1.0
    end

    test "default_marker_radius/0 returns default value" do
      assert Config.default_marker_radius() == 2
    end

    test "animation_opacity_range/0 returns default tuple" do
      assert Config.animation_opacity_range() == {0.5, 1.0}
    end
  end
end
