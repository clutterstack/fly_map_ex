defmodule FlyMapEx.Guides.Theming do
  @moduledoc """
  Theming guide for FlyMapEx - controlling overall visual presentation and branding.

  This guide demonstrates FlyMapEx's comprehensive theming system for customizing
  map backgrounds, borders, and neutral elements.
  """

  import FlyMapEx.Content.ValidatedExample

  @doc """
  Guide metadata for documentation generation and demo presentation.
  """
  def guide_metadata do
    %{
      title: "Map Themes",
      description:
        "Control overall visual presentation and branding with FlyMapEx's comprehensive theming system.",
      slug: "theming",
      sections: sections()
    }
  end

  @doc """
  Returns the sections (tabs) available in this guide.
  """
  def sections do
    [
      %{
        key: "presets",
        label: "Theme Presets",
        title: "Built-in Theme Presets"
      },
      %{
        key: "custom",
        label: "Custom Themes",
        title: "Custom Theme Creation"
      },
      %{
        key: "configuration",
        label: "Configuration",
        title: "Application-Level Theme Configuration"
      }
    ]
  end

  @doc """
  Returns content for a specific section.
  """
  def get_section("presets") do
    %{
      title: "Built-in Theme Presets",
      content: """
      Seven ready-to-use themes that control map background colours, borders, and neutral elements.

      Each preset is carefully designed for specific use cases, from clean light interfaces to dark mode applications and high-contrast accessibility requirements.
      """,
      example:
        validated_template("""
          <FlyMapEx.render
            marker_groups={[
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
            ]}
            theme={:dark}
          />
        """),
      tips: [
        "Start with :responsive for automatic light/dark adaptation",
        "Use :high_contrast for accessibility compliance",
        "Test themes with your actual marker colours",
        "Consider your application's overall design system"
      ],
      related_links: [
        {"Custom Themes", "#custom"},
        {"Configuration", "#configuration"}
      ]
    }
  end

  def get_section("custom") do
    %{
      title: "Custom Theme Creation",
      content: """
      Two approaches for creating custom themes: inline theme maps or config-registered themes.

      Custom themes give you complete control over the map's visual appearance, allowing perfect integration with your brand colours and design system.
      """,
      example:
        validated_template("""
          <FlyMapEx.render
            marker_groups={[
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
            ]}
            theme={%{
              land: "#f8fafc",
              ocean: "#e2e8f0",
              border: "#475569",
              neutral_marker: "#64748b",
              neutral_text: "#334155"
            }}
          />
        """),
      theme_structure: [
        %{
          component: "land",
          description: "Countries and land masses",
          example: "#f8fafc"
        },
        %{
          component: "ocean",
          description: "Water bodies",
          example: "#e2e8f0"
        },
        %{
          component: "border",
          description: "Country borders and coastlines",
          example: "#475569"
        },
        %{
          component: "neutral_marker",
          description: "Default region markers",
          example: "#64748b"
        },
        %{
          component: "neutral_text",
          description: "Labels and region names",
          example: "#334155"
        }
      ],
      code_examples: [
        %{
          title: "Method 1: Inline Custom Theme",
          language: "heex",
          code: """
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
          """
        },
        %{
          title: "Method 2: Config-Registered Themes",
          language: "elixir",
          code: """
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
          """
        }
      ],
      tips: [
        "Use hex codes for precise colour control",
        "Test themes with both light and dark marker colours",
        "Consider colour accessibility and contrast",
        "Config-registered themes are reusable across your application"
      ],
      related_links: [
        {"Theme Presets", "#presets"},
        {"Configuration", "#configuration"}
      ]
    }
  end

  def get_section("configuration") do
    %{
      title: "Application-Level Theme Configuration",
      content: """
      Set default themes and create custom theme registries in your application config.

      Application-level configuration allows you to establish consistent theming across your entire application while supporting environment-specific customization.
      """,
      example:
        validated_template("""
          <FlyMapEx.render
            marker_groups={[
              %{
                nodes: ["sjc", "fra", "ams"],
                style: %{colour: "#3b82f6", size: 8},
                label: "Production Environment"
              }
            ]}
            theme={:responsive}
          />
        """),
      theme_resolution_priority: [
        %{
          priority: 1,
          source: "Inline theme prop",
          example: "<FlyMapEx.render theme={:dark} />",
          description: "Component-level override"
        },
        %{
          priority: 2,
          source: "Custom themes",
          example: "config :fly_map_ex, :custom_themes",
          description: "Application-registered themes"
        },
        %{
          priority: 3,
          source: "Application default",
          example: "config :fly_map_ex, :default_theme",
          description: "Application-wide default"
        },
        %{
          priority: 4,
          source: "Library default",
          example: ":light theme",
          description: "FlyMapEx fallback"
        }
      ],
      environment_patterns: [
        %{
          environment: "Development",
          recommendation: ":light for debugging visibility",
          reason: "High contrast aids development"
        },
        %{
          environment: "Production",
          recommendation: ":responsive for automatic adaptation",
          reason: "Adapts to user preferences"
        },
        %{
          environment: "Testing",
          recommendation: ":high_contrast for accessibility testing",
          reason: "Ensures accessibility compliance"
        }
      ],
      code_examples: [
        %{
          title: "Complete Configuration Example",
          language: "elixir",
          code: """
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
          """
        }
      ],
      tips: [
        "Use :responsive as your default for broad compatibility",
        "Register brand themes in config for consistency",
        "Environment-specific configs help with testing",
        "Override at the component level for special cases"
      ],
      related_links: [
        {"Theme Presets", "#presets"},
        {"Custom Themes", "#custom"},
        {"Marker Styling", "marker_styling"}
      ]
    }
  end

  def get_section(_unknown), do: nil

  @doc """
  Returns all sections for this guide.
  """
  def all_sections do
    sections()
    |> Enum.map(& &1.key)
    |> Enum.map(&get_section/1)
    |> Enum.reject(&is_nil/1)
  end
end
