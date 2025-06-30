defmodule FlyMapEx.Theme do
  @moduledoc """
  Background themes for FlyMapEx components.

  Themes only control background colors and overall visual styling.
  Marker styles are defined separately using FlyMapEx.Style.

  ## Usage

      <FlyMapEx.render marker_groups={groups} theme={:dark} />
      
      # Or with custom background
      <FlyMapEx.render marker_groups={groups} background={custom_bg} />
  """

  @doc """
  Get a background colour scheme by name.

  ## Available Themes

  * `:light` - Light background with dark borders
  * `:dark` - Dark background with subtle borders  
  * `:minimal` - Clean white background
  * `:cool` - Cool blue tones
  * `:warm` - Warm earth tones
  * `:high_contrast` - Maximum contrast for accessibility

  ## Examples

      iex> FlyMapEx.Theme.background(:dark)
      %{land: "#0f172a", ocean: "#aaaaaa", border: "#334155"}
  """
  def background(:light) do
    %{
      land: "#888888",
      ocean: "#aaaaaa",
      border: "#0f172a",
      neutral_marker: "#6b7280",
      neutral_text: "#374151"
    }
  end

  def background(:dark) do
    %{
      land: "#0f172a",
      ocean: "#aaaaaa",
      border: "#334155",
      neutral_marker: "#9ca3af",
      neutral_text: "#d1d5db"
    }
  end

  def background(:minimal) do
    %{
      land: "#ffffff",
      ocean: "#aaaaaa",
      border: "#e5e7eb",
      neutral_marker: "#6b7280",
      neutral_text: "#374151"
    }
  end

  def background(:cool) do
    %{
      land: "#f1f5f9",
      ocean: "#aaaaaa",
      border: "#64748b",
      neutral_marker: "#64748b",
      neutral_text: "#334155"
    }
  end

  def background(:warm) do
    %{
      land: "#fef7ed",
      ocean: "#aaaaaa",
      border: "#c2410c",
      neutral_marker: "#92400e",
      neutral_text: "#451a03"
    }
  end

  def background(:high_contrast) do
    %{
      land: "#ffffff",
      ocean: "#aaaaaa",
      border: "#000000",
      neutral_marker: "#404040",
      neutral_text: "#000000"
    }
  end

  def background(_), do: background(:light)

  @doc """
  Get a responsive background that adapts to CSS theme variables.

  This uses CSS custom properties that automatically change
  based on the current DaisyUI theme.

  ## Examples

      iex> FlyMapEx.Theme.responsive_background()
      %{
        land: "oklch(var(--color-base-100) / 1)",
        ocean: "oklch(var(--color-base-200) / 1)", 
        border: "oklch(var(--color-base-300) / 1)"
      }
  """
  def responsive_background do
    %{
      land: "oklch(var(--color-base-100) / 1)",
      ocean: "oklch(var(--color-base-200) / 1)",
      border: "oklch(var(--color-base-300) / 1)",
      neutral_marker: "oklch(var(--color-base-content) / 0.6)",
      neutral_text: "oklch(var(--color-base-content) / 0.8)"
    }
  end
end
