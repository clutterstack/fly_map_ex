defmodule DemoWeb.Content.Theming do
  @moduledoc """
  A content page to be rendered from PageLive within the StageTemplate live_component.
  """

  alias DemoWeb.Helpers.ContentHelpers

  @doc """
  Gives the PageLive LiveView the title and description to populate slots in Layouts.app/1,
  and the live_component to use as a template for rendering the content in this module.
  """

  def doc_metadata do
    %{
      title: "Map Themes",
      description: "Control overall visual presentation and branding with FlyMapEx's comprehensive theming system.",
      template: "StageTemplate"
    }
  end

  def tabs do
    [
      %{
        key: "presets",
        label: "Theme Presets"
      },
      %{
        key: "custom",
        label: "Custom Themes"
      },
      %{
        key: "configuration",
        label: "Configuration"
      }
    ]
  end

  @doc """
   All the content for each tab:
  * `content`: Info to go into the info panel
  * `example`: A description for the code panel label, an optional code comment,
    and the assigns to pass to the FlyMapEx.render component.
  """


  def get_content("presets") do
    %{
      content:
        [
          ContentHelpers.content_section(
            "Built-in Theme Presets",
            "Seven ready-to-use themes that control map background colours, borders, and neutral elements."
          ),
          ContentHelpers.status_steps([
            {:light, ":light", "Clean, bright theme with gray land masses and dark borders",
             "bg-base-100"},
            {:dark, ":dark", "Dark background with subtle borders for dark mode interfaces",
             "bg-base-300"},
            {:minimal, ":minimal", "Transparent backgrounds with subtle borders for overlays",
             "bg-base-200"},
            {:cool, ":cool", "Blue-toned theme suitable for technical applications", "bg-info"},
            {:warm, ":warm", "Earth-toned theme with warm colours for friendly interfaces",
             "bg-warning"},
            {:high_contrast, ":high_contrast", "Maximum contrast theme for accessibility",
             "bg-base-content"},
            {:responsive, ":responsive", "CSS variable-based theme that adapts to system preferences",
             "bg-primary"}
          ])
        ]
        |> Enum.join(),
      example: %{
        marker_groups: [
          %{
            nodes: ["sjc", "fra", "ams"],
            style: %{colour: "#3b82f6", size: 8},
            label: "Production Servers"
          },
          %{
            nodes: ["lhr", "syd"],
            style: %{colour: "#f59e0b", size: 8},
            label: "Staging Environment"
          }
        ],
        description: "Built-in theme presets",
        code_comment:
          "FlyMapEx includes seven preset themes: :light, :dark, :minimal, :cool, :warm, :high_contrast, and :responsive. Each controls map background colours and neutral elements."
      }
    }
  end

  def get_content("custom") do
    %{
      content:
        [
          ContentHelpers.content_section(
            "Custom Theme Creation",
            "Two approaches for creating custom themes: inline theme maps or config-registered themes."
          ),
          ContentHelpers.info_box(
            :primary,
            "Theme Structure",
            ContentHelpers.titled_list(
              [
                "land → Countries and land masses",
                "ocean → Water bodies",
                "border → Country borders and coastlines",
                "neutral_marker → Default region markers",
                "neutral_text → Labels and region names"
              ],
              type: :arrows
            )
          ),
          ContentHelpers.code_snippet("""
          # Method 1: Inline custom theme
          <FlyMapEx.render
            marker_groups={@groups}
            theme=%{
              land: "#f8fafc",
              ocean: "#e2e8f0",
              border: "#475569",
              neutral_marker: "#64748b",
              neutral_text: "#334155"
            }
          />
          """),
          ContentHelpers.code_snippet("""
          # Method 2: Config-registered themes
          # config/config.exs
          config :fly_map_ex, :custom_themes,
            corporate: %{
              land: "#f8fafc",
              ocean: "#e2e8f0",
              border: "#475569",
              neutral_marker: "#64748b",
              neutral_text: "#334155"
            },
            sunset: %{
              land: "#fef3c7",
              ocean: "#fbbf24",
              border: "#d97706",
              neutral_marker: "#b45309",
              neutral_text: "#92400e"
            }

          # Usage
          <FlyMapEx.render theme={:corporate} />
          """)
        ]
        |> Enum.join(),
      example: %{
        marker_groups: [
          %{
            nodes: ["sjc", "fra"],
            style: %{colour: "#10b981", size: 8},
            label: "Primary Services"
          },
          %{
            nodes: ["ams", "lhr"],
            style: %{colour: "#f59e0b", size: 8},
            label: "Secondary Services"
          }
        ],
        description: "Custom theme creation methods",
        code_comment:
          "Two ways to create custom themes: inline theme maps or config-registered themes. Define land, ocean, border, neutral_marker, and neutral_text properties."
      }
    }
  end

  def get_content("configuration") do
    %{
      content:
        [
          ContentHelpers.content_section(
            "Application-Level Theme Configuration",
            "Set default themes and create custom theme registries in your application config."
          ),
          ContentHelpers.code_snippet("""
          # config/config.exs
          config :fly_map_ex,
            default_theme: :responsive,
            custom_themes: %{
              corporate: %{
                land: "#f8fafc",
                ocean: "#e2e8f0",
                border: "#475569",
                neutral_marker: "#64748b",
                neutral_text: "#334155"
              },
              brand: %{
                land: "#fef3c7",
                ocean: "#fed7aa",
                border: "#d97706",
                neutral_marker: "#92400e",
                neutral_text: "#451a03"
              }
            }
          """),
          ContentHelpers.ul_with_bold(
            "Theme Resolution Priority",
            [
              {"1. Inline theme prop", "<FlyMapEx.render theme={:dark} />"},
              {"2. Custom themes", "config :fly_map_ex, :custom_themes"},
              {"3. Application default", "config :fly_map_ex, :default_theme"},
              {"4. Library default", ":light theme"}
            ]
          ),
          ContentHelpers.ul_with_bold(
            "Environment Patterns",
            [
              {"Development", ":light for debugging visibility"},
              {"Production", ":responsive for automatic adaptation"},
              {"Testing", ":high_contrast for accessibility testing"}
            ]
          )
        ]
        |> Enum.join(),
      example: %{
        marker_groups: [
          %{
            nodes: ["sjc", "fra", "ams"],
            style: %{colour: "#3b82f6", size: 8},
            label: "Production Environment"
          }
        ],
        description: "Application-level theme configuration",
        code_comment:
          "Set default themes in config.exs for consistent theming across your app. Theme resolution: inline props → custom themes → app default → library default."
      }
    }
  end
end
