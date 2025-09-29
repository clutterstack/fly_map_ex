defmodule FlyMapEx.ConfigTest do
  use ExUnit.Case, async: false

  alias FlyMapEx.Config

  setup do
    original = Application.get_env(:fly_map_ex, :custom_regions)

    on_exit(fn ->
      if is_nil(original) do
        Application.delete_env(:fly_map_ex, :custom_regions)
      else
        Application.put_env(:fly_map_ex, :custom_regions, original)
      end
    end)

    :ok
  end

  describe "defaults" do
    test "marker_opacity/0 returns default value" do
      assert Config.marker_opacity() == 1.0
    end

    test "animation_opacity_range/0 returns default tuple" do
      assert Config.animation_opacity_range() == {0.5, 1.0}
    end

    test "layout_mode/0 returns default layout" do
      assert Config.layout_mode() == :side_by_side
    end

    test "custom_regions/0 returns empty map when unset" do
      Application.delete_env(:fly_map_ex, :custom_regions)
      assert Config.custom_regions() == %{}
    end

    test "custom_region_codes/0 returns empty list when unset" do
      Application.delete_env(:fly_map_ex, :custom_regions)
      assert Config.custom_region_codes() == []
    end
  end

  describe "custom region configuration" do
    test "reads configured regions" do
      Application.put_env(:fly_map_ex, :custom_regions, %{
        "dev" => %{name: "Developer", coordinates: {47.6, -122.3}},
        "lab" => %{name: "Lab", coordinates: {52.5, 13.4}}
      })

      assert Config.custom_regions()["dev"][:name] == "Developer"
      assert Config.custom_region_codes() == ["dev", "lab"]
    end
  end
end
