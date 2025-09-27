defmodule FlyMapEx.Guides.MarkerStyling do
  @moduledoc """
  Marker styling guide for FlyMapEx - visual customization and semantic meaning.

  This guide demonstrates FlyMapEx's comprehensive styling system, from automatic
  colour assignment to fully custom marker styles.
  """

  # No imports needed - examples are defined inline

  # Helper function to create example maps with parsed assigns
  defp example(template_string) do
    trimmed_template = String.trim(template_string)
    parsed_assigns = parse_template_assigns(trimmed_template)

    %{
      template: trimmed_template,
      assigns: parsed_assigns,
      description: generate_description(parsed_assigns)
    }
  end

  # Parse template to extract assigns for marker styling examples
  defp parse_template_assigns(template_string) do
    try do
      marker_groups = parse_marker_groups(template_string)
      %{marker_groups: marker_groups}
    rescue
      _ -> %{marker_groups: []}
    end
  end

  # Parse marker groups for styling examples - analyze the full template
  defp parse_marker_groups(template_string) do
    cond do
      # Automatic colors example - no styles, just labels with 4 groups
      String.contains?(template_string, "\"Production Servers\"") and
      String.contains?(template_string, "\"Staging Environment\"") and
      String.contains?(template_string, "\"Development\"") and
      String.contains?(template_string, "\"Testing\"") and
      not String.contains?(template_string, "style:") ->
        [
          %{nodes: ["sjc", "fra"], label: "Production Servers"},
          %{nodes: ["ams", "lhr"], label: "Staging Environment"},
          %{nodes: ["ord"], label: "Development"},
          %{nodes: ["nrt", "syd"], label: "Testing"}
        ]

      # Semantic styling example - has semantic styles
      String.contains?(template_string, "style: :operational,") and
      String.contains?(template_string, "style: :warning,") and
      String.contains?(template_string, "style: :danger,") and
      String.contains?(template_string, "style: :inactive,") ->
        [
          %{nodes: ["sjc", "fra"], style: :operational, label: "Production Servers"},
          %{nodes: ["ams", "lhr"], style: :warning, label: "Maintenance Mode"},
          %{nodes: ["ord"], style: :danger, label: "Failed Nodes"},
          %{nodes: ["nrt", "syd"], style: :inactive, label: "Offline Nodes"}
        ]

      # Custom styling example - single group with custom style map
      String.contains?(template_string, "colour: \"#8b5cf6\"") and
      String.contains?(template_string, "animation: :pulse") and
      String.contains?(template_string, "\"Custom Group\"") and
      not String.contains?(template_string, "style: :warning") ->
        [
          %{
            nodes: ["sjc", "fra"],
            style: %{colour: "#8b5cf6", size: 8, animation: :pulse, glow: true},
            label: "Custom Group"
          }
        ]

      # Mixed styling example - has both semantic and custom
      String.contains?(template_string, "style: :warning,") and
      String.contains?(template_string, "colour: \"#8b5cf6\"") ->
        [
          %{nodes: ["ams", "lhr"], style: :warning, label: "Maintenance Mode"},
          %{
            nodes: ["sjc", "fra"],
            style: %{colour: "#8b5cf6", size: 8, animation: :pulse, glow: true},
            label: "Custom Group"
          }
        ]

      true ->
        [%{nodes: ["sjc", "fra"], label: "Example"}]
    end
  end

  # Generate description from parsed assigns
  defp generate_description(assigns) do
    marker_groups = assigns[:marker_groups] || []
    group_count = length(marker_groups)
    node_count = marker_groups |> Enum.flat_map(&(&1[:nodes] || [])) |> length()
    "Example usage • #{group_count} groups • #{node_count} nodes"
  end

  @doc """
  Guide metadata for documentation generation and demo presentation.
  """
  def guide_metadata do
    %{
      title: "Marker Styles",
      description: "Master visual customization and semantic meaning through FlyMapEx's comprehensive styling system.",
      slug: "marker_styling",
      sections: sections()
    }
  end

  @doc """
  Returns the sections (tabs) available in this guide.
  """
  def sections do
    [
      %{
        key: "automatic",
        label: "Automatic",
        title: "Automatic Colours"
      },
      %{
        key: "semantic",
        label: "Semantic",
        title: "Semantic Styling"
      },
      %{
        key: "custom",
        label: "Custom",
        title: "Direct Style Maps"
      },
      %{
        key: "mixed",
        label: "Mixed",
        title: "Mixed Approaches"
      }
    ]
  end

  @doc """
  Returns content for a specific section.
  """
  def get_section("automatic") do
    %{
      title: "Automatic Colours",
      content: """
      If you don't specify a group's marker styles, a different colour is automatically assigned to each group.

      This provides instant visual distinction between different marker groups without requiring any styling configuration. FlyMapEx cycles through a carefully chosen colour palette that ensures good contrast and readability.
      """,
      example: example("""
        <FlyMapEx.render
          marker_groups={[
            %{
              nodes: ["sjc", "fra"],
              label: "Production Servers"
            },
            %{
              nodes: ["ams", "lhr"],
              label: "Staging Environment"
            },
            %{
              nodes: ["ord"],
              label: "Development"
            },
            %{
              nodes: ["nrt", "syd"],
              label: "Testing"
            }
          ]}
        />
      """),
      tips: [
        "Automatic colours follow a predefined sequence for consistency",
        "Each group gets a distinct colour automatically",
        "No configuration needed - just add your marker groups"
      ],
      related_links: [
        {"Semantic Styling", "#semantic"},
        {"Custom Styling", "#custom"}
      ]
    }
  end

  def get_section("semantic") do
    %{
      title: "Semantic Styling",
      content: """
      Preset marker styles to convey status and meaning at a glance.

      Semantic styles provide predefined combinations of colour, animation, and visual effects that correspond to common operational states. This creates consistency across your application and makes status immediately recognizable.
      """,
      example: example("""
        <FlyMapEx.render
          marker_groups={[
            %{
              nodes: ["sjc", "fra"],
              style: :operational,
              label: "Production Servers"
            },
            %{
              nodes: ["ams", "lhr"],
              style: :warning,
              label: "Maintenance Mode"
            },
            %{
              nodes: ["ord"],
              style: :danger,
              label: "Failed Nodes"
            },
            %{
              nodes: ["nrt", "syd"],
              style: :inactive,
              label: "Offline Nodes"
            }
          ]}
        />
      """),
      available_styles: [
        %{style: ":operational", description: "Green, steady - systems running normally"},
        %{style: ":warning", description: "Yellow/orange, pulsing - attention needed"},
        %{style: ":danger", description: "Red, pulsing - critical issues"},
        %{style: ":inactive", description: "Gray, static - offline or disabled"},
        %{style: ":primary", description: "Blue, animated - primary systems"},
        %{style: ":secondary", description: "Purple, static - secondary systems"}
      ],
      tips: [
        "Semantic styles are consistent across your entire application",
        "Use :operational for healthy systems, :warning for issues, :danger for failures",
        "Combine with automatic colours for mixed scenarios"
      ],
      related_links: [
        {"Mixed Approaches", "#mixed"},
        {"Custom Styling", "#custom"}
      ]
    }
  end

  def get_section("custom") do
    %{
      title: "Direct Style Maps",
      content: """
      Define fully custom marker styles using direct style maps - the primary interface for custom styling.

      Custom style maps give you complete control over marker appearance, allowing you to match your brand colours, create unique visual hierarchies, or implement custom status indicators.
      """,
      example: example("""
        <FlyMapEx.render
          marker_groups={[
            %{
              nodes: ["sjc", "fra"],
              style: %{
                colour: "#8b5cf6",
                size: 8,
                animation: :pulse,
                glow: true
              },
              label: "Custom Group"
            }
          ]}
        />
      """),
      style_parameters: [
        %{
          parameter: "colour/color",
          description: "Hex codes, named colours (:blue), CSS variables (var(--primary))",
          examples: ["#8b5cf6", ":blue", "var(--primary-colour)"]
        },
        %{
          parameter: "size",
          description: "Marker radius in pixels (default: 4)",
          examples: ["4", "8", "12"]
        },
        %{
          parameter: "animation",
          description: ":none, :pulse, :fade (default: :none)",
          examples: [":none", ":pulse", ":fade"]
        },
        %{
          parameter: "glow",
          description: "Boolean for enhanced visibility (default: false)",
          examples: ["true", "false"]
        }
      ],
      code_examples: [
        %{
          title: "Custom Style Example",
          language: "elixir",
          code: """
          %{
            nodes: ["sjc", "fra"],
            style: %{
              colour: "#8b5cf6",    # hex, named colour, or CSS variable
              size: 8,             # radius in pixels
              animation: :pulse,   # :none, :pulse, :fade
              glow: true           # boolean for glow effect
            },
            label: "Custom Group"
          }
          """
        }
      ],
      tips: [
        "Use hex codes for precise colour control",
        "CSS variables enable dynamic theming",
        "Animations draw attention - use sparingly",
        "Glow effects improve visibility on busy maps"
      ],
      related_links: [
        {"Mixed Approaches", "#mixed"},
        {"Map Themes", "theming"}
      ]
    }
  end

  def get_section("mixed") do
    %{
      title: "Mixed Approaches",
      content: """
      Combine different styling methods in one configuration for complex real-world scenarios.

      Real applications often need a mix of styling approaches - semantic styles for core monitoring, automatic colours for organization, and custom styles for special cases. FlyMapEx handles this seamlessly.
      """,
      example: example("""
        <FlyMapEx.render
          marker_groups={[
            %{
              nodes: ["ams", "lhr"],
              style: :warning,
              label: "Maintenance Mode"
            },
            %{
              nodes: ["sjc", "fra"],
              style: %{
                colour: "#8b5cf6",
                size: 8,
                animation: :pulse,
                glow: true
              },
              label: "Custom Group"
            }
          ]}
        />
      """),
      common_patterns: [
        %{
          pattern: "Primary systems",
          description: "Semantic styles for critical monitoring",
          example: "style: :operational"
        },
        %{
          pattern: "Secondary groups",
          description: "Auto-cycling for organization",
          example: "No style specified"
        },
        %{
          pattern: "Special alerts",
          description: "Custom styles for unique cases",
          example: "style: %{colour: \"#ff0000\", animation: :pulse}"
        },
        %{
          pattern: "Utility groups",
          description: "Atom shortcuts for simple cases",
          example: "style: :warning"
        }
      ],
      tips: [
        "Start with semantic styles for core functionality",
        "Add cycling and custom styles as needed",
        "Maintain visual hierarchy with consistent sizing",
        "Use animations strategically to guide attention"
      ],
      production_tip: "Start with semantic styles for core functionality, then add cycling and custom styles as needed.",
      related_links: [
        {"Semantic Styling", "#semantic"},
        {"Custom Styling", "#custom"},
        {"Basic Usage", "basic_usage"}
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