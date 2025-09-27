defmodule DemoWeb.Adapters.GuideAdapter do
  @moduledoc """
  Adapter module for converting library guide content to demo app format.

  This module bridges the gap between FlyMapEx.Guides content structure and
  the demo app's expected format, allowing the demo to present library guides
  with minimal coupling.
  """

  alias DemoWeb.Helpers.ContentHelpers

  @doc """
  Converts library guide metadata to demo app doc_metadata format.
  """
  def adapt_metadata(guide_module) do
    metadata = apply(guide_module, :guide_metadata, [])

    %{
      title: metadata.title,
      description: metadata.description,
      template: "StageTemplate"
    }
  end

  @doc """
  Converts library guide sections to demo app tabs format.
  """
  def adapt_tabs(guide_module) do
    apply(guide_module, :sections, [])
    |> Enum.map(fn section ->
      %{
        key: section.key,
        label: section.label
      }
    end)
  end

  @doc """
  Converts library guide section content to demo app content format.

  Takes the structured content from library guides and formats it using
  ContentHelpers to match what the demo app expects.
  """
  def adapt_content(guide_module, section_key) do
    case apply(guide_module, :get_section, [section_key]) do
      nil ->
        nil

      section ->
        %{
          content: format_section_content(section),
          example: section.example
        }
    end
  end

  # Private helper to format section content using ContentHelpers
  defp format_section_content(section) do
    content_parts = [
      # Main content section
      ContentHelpers.content_section(section.title, section.content)
    ]

    # Add code examples if present
    content_parts =
      if Map.has_key?(section, :code_examples) and is_list(section.code_examples) and length(section.code_examples) > 0 do
        content_parts ++ Enum.map(section.code_examples, fn code_example ->
          ContentHelpers.code_snippet(code_example.code)
        end)
      else
        content_parts
      end

    # Add style parameters if present (for marker styling guide)
    content_parts =
      if Map.has_key?(section, :style_parameters) and is_list(section.style_parameters) and length(section.style_parameters) > 0 do
        formatted_params = Enum.map(section.style_parameters, fn param ->
          {param.parameter, param.description}
        end)
        content_parts ++ [ContentHelpers.ul_with_bold("Style Parameters", formatted_params)]
      else
        content_parts
      end

    # Add available styles if present (for marker styling semantic section)
    content_parts =
      if Map.has_key?(section, :available_styles) and is_list(section.available_styles) and length(section.available_styles) > 0 do
        formatted_styles = Enum.map(section.available_styles, fn style ->
          {style.style, style.description}
        end)
        content_parts ++ [ContentHelpers.ul_with_bold("Available Semantic Styles", formatted_styles)]
      else
        content_parts
      end

    # Add common patterns if present (for marker styling mixed section)
    content_parts =
      if Map.has_key?(section, :common_patterns) and is_list(section.common_patterns) and length(section.common_patterns) > 0 do
        formatted_patterns = Enum.map(section.common_patterns, fn pattern ->
          {pattern.pattern, pattern.description}
        end)
        content_parts ++ [ContentHelpers.ul_with_bold("Common Patterns", formatted_patterns)]
      else
        content_parts
      end

    # Add theme resolution priority if present (for theming configuration)
    content_parts =
      if Map.has_key?(section, :theme_resolution_priority) and is_list(section.theme_resolution_priority) and length(section.theme_resolution_priority) > 0 do
        formatted_priority = Enum.map(section.theme_resolution_priority, fn item ->
          {"#{item.priority}. #{item.source}", item.example}
        end)
        content_parts ++ [ContentHelpers.ul_with_bold("Theme Resolution Priority", formatted_priority)]
      else
        content_parts
      end

    # Add environment patterns if present (for theming configuration)
    content_parts =
      if Map.has_key?(section, :environment_patterns) and is_list(section.environment_patterns) and length(section.environment_patterns) > 0 do
        formatted_env = Enum.map(section.environment_patterns, fn env ->
          {env.environment, env.recommendation}
        end)
        content_parts ++ [ContentHelpers.ul_with_bold("Environment Patterns", formatted_env)]
      else
        content_parts
      end

    # Add production tip if present
    content_parts =
      if Map.has_key?(section, :production_tip) and is_binary(section.production_tip) and section.production_tip != "" do
        content_parts ++ [ContentHelpers.pro_tip(section.production_tip, type: :production)]
      else
        content_parts
      end

    # Add tips as pro_tip if present
    content_parts =
      if Map.has_key?(section, :tips) and is_list(section.tips) and length(section.tips) > 0 do
        content_parts ++ [ContentHelpers.pro_tip(Enum.join(section.tips, " • "))]
      else
        content_parts
      end

    Enum.join(content_parts)
  end
end