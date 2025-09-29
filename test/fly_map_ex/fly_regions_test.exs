defmodule FlyMapEx.FlyRegionsTest do
  use ExUnit.Case, async: false

  alias FlyMapEx.FlyRegions

  setup do
    original = Application.get_env(:fly_map_ex, :custom_regions)

    Application.put_env(:fly_map_ex, :custom_regions, %{
      "dev" => %{name: "Developer", coordinates: {47.6, -122.3}}
    })

    on_exit(fn ->
      if is_nil(original) do
        Application.delete_env(:fly_map_ex, :custom_regions)
      else
        Application.put_env(:fly_map_ex, :custom_regions, original)
      end
    end)

    :ok
  end

  test "fly_regions/0 merges custom regions" do
    regions = FlyRegions.fly_regions()

    assert regions["dev"] == {47.6, -122.3}
    assert regions["sjc"] == {37, -122}
  end

  test "valid?/1 recognises custom region codes" do
    assert FlyRegions.valid?("dev")
    refute FlyRegions.valid?("unknown")
  end

  test "coordinates/1 returns custom coordinates" do
    assert {:ok, {47.6, -122.3}} = FlyRegions.coordinates("dev")
  end

  test "num_fly_regions/0 counts custom regions" do
    assert FlyRegions.num_fly_regions() >= 1
    assert FlyRegions.num_fly_regions() == map_size(FlyRegions.fly_regions())
  end
end
