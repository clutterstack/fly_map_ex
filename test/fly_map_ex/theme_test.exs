defmodule FlyMapEx.ThemeTest do
  use ExUnit.Case, async: true

  doctest FlyMapEx.Theme

  alias FlyMapEx.Theme

  describe "map_theme/1" do
    test "returns correct theme for :light" do
      theme = Theme.map_theme(:light)
      
      assert theme.land == "#888888"
      assert theme.ocean == "#aaaaaa"
      assert theme.border == "#0f172a"
      assert theme.neutral_marker == "#6b7280"
      assert theme.neutral_text == "#374151"
    end

    test "returns correct theme for :dark" do
      theme = Theme.map_theme(:dark)
      
      assert theme.land == "#0f172a"
      assert theme.ocean == "#aaaaaa"
      assert theme.border == "#334155"
      assert theme.neutral_marker == "#9ca3af"
      assert theme.neutral_text == "#d1d5db"
    end

    test "falls back to light theme for unknown theme" do
      theme = Theme.map_theme(:unknown)
      light_theme = Theme.map_theme(:light)
      
      assert theme == light_theme
    end
  end

  describe "responsive_map_theme/0" do
    test "returns CSS variable-based theme" do
      theme = Theme.responsive_map_theme()
      
      assert theme.land == "oklch(var(--color-base-100) / 1)"
      assert theme.ocean == "oklch(var(--color-base-200) / 1)"
      assert theme.border == "oklch(var(--color-base-300) / 1)"
      assert theme.neutral_marker == "oklch(var(--color-base-content) / 0.6)"
      assert theme.neutral_text == "oklch(var(--color-base-content) / 0.8)"
    end
  end
end