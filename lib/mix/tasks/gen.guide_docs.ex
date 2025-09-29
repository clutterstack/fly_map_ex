defmodule Mix.Tasks.Gen.GuideDocs do
  @moduledoc """
  Generates markdown documentation from FlyMapEx guide modules.

  This task reads the structured content from guide modules and generates
  both individual guide markdown files and a combined examples overview.

  ## Usage

      mix gen.guide_docs

  ## Generated Files

  - `documentation/guides/basic_usage.md`
  - `documentation/guides/marker_styling.md`
  - `documentation/guides/theming.md`

  All files are generated from the library guide modules to ensure consistency
  between demo app content and documentation.
  """

  use Mix.Task

  @shortdoc "Generates markdown documentation from FlyMapEx guide modules"

  @guide_modules [
    FlyMapEx.Guides.BasicUsage,
    FlyMapEx.Guides.MarkerStyling,
    FlyMapEx.Guides.Theming
  ]

  def run(_args) do
    # Determine the correct project root (look for mix.exs with FlyMapEx)
    project_root = find_project_root()

    # Ensure the documentation directories exist
    guides_dir = Path.join(project_root, "documentation/guides")
    File.mkdir_p!(guides_dir)

    # Generate individual guide files
    Enum.each(@guide_modules, fn module -> generate_guide_file(module, project_root) end)

    Mix.shell().info("Guide files generated.")
    Mix.shell().info("Now run `mix docs`.")
  end

  defp find_project_root do
    cwd = File.cwd!()

    # Check if current directory has FlyMapEx mix.exs
    if has_flymap_mix_file?(cwd) do
      cwd
    else
      # Check parent directory
      parent = Path.join(cwd, "..")

      if has_flymap_mix_file?(parent) do
        Path.expand(parent)
      else
        # Default to current directory
        cwd
      end
    end
  end

  defp has_flymap_mix_file?(dir) do
    mix_file = Path.join(dir, "mix.exs")

    File.exists?(mix_file) and
      File.read!(mix_file) |> String.contains?("FlyMapEx.MixProject")
  end

  defp generate_guide_file(guide_module, project_root) do
    metadata = apply(guide_module, :guide_metadata, [])
    sections = apply(guide_module, :all_sections, [])

    content =
      [
        "# #{metadata.title}",
        "",
        metadata.description,
        "",
        Enum.map(sections, &generate_section_markdown/1)
      ]
      |> List.flatten()
      |> Enum.join("\n")

    file_path = Path.join(project_root, "documentation/guides/#{metadata.slug}.md")
    File.write!(file_path, content)
    Mix.shell().info("Wrote documentation/guides/#{metadata.slug}.md")
  end

  defp generate_section_markdown(section) do
    [
      "## #{section.title}",
      "",
      section.content,
      "",
      generate_example_code(section.example),
      "",
      generate_additional_content(section),
      ""
    ]
    |> List.flatten()
    |> Enum.reject(&(&1 == ""))
  end

  defp generate_example_code(example) when is_map(example) do
    [
      "```heex",
      String.trim(example.template),
      "```"
    ]
  end

  defp generate_example_code(_), do: []

  defp generate_additional_content(section) do
    content_parts = []

    # Add code examples
    content_parts =
      if Map.has_key?(section, :code_examples) and section.code_examples do
        code_sections =
          Enum.map(section.code_examples, fn code_example ->
            [
              "### #{code_example.title}",
              "",
              "```#{code_example.language}",
              String.trim(code_example.code),
              "```",
              ""
            ]
          end)

        content_parts ++ List.flatten(code_sections)
      else
        content_parts
      end

    # Add style parameters table
    content_parts =
      if Map.has_key?(section, :style_parameters) and section.style_parameters do
        table_content = [
          "### Style Parameters",
          "",
          "| Parameter | Description | Examples |",
          "|-----------|-------------|----------|",
          Enum.map(section.style_parameters, fn param ->
            examples =
              if Map.has_key?(param, :examples), do: Enum.join(param.examples, ", "), else: ""

            "| `#{param.parameter}` | #{param.description} | #{examples} |"
          end),
          ""
        ]

        content_parts ++ List.flatten(table_content)
      else
        content_parts
      end

    # Add tips as bullet points
    content_parts =
      if Map.has_key?(section, :tips) and is_list(section.tips) and length(section.tips) > 0 do
        tips_content = [
          "### Tips",
          "",
          Enum.map(section.tips, fn tip -> "- #{tip}" end),
          ""
        ]

        content_parts ++ List.flatten(tips_content)
      else
        content_parts
      end

    # Add related links
    content_parts =
      if Map.has_key?(section, :related_links) and is_list(section.related_links) and
           length(section.related_links) > 0 do
        links_content = [
          "### Related",
          "",
          Enum.map(section.related_links, fn {title, link} ->
            if String.starts_with?(link, "http") do
              "- [#{title}](#{link})"
            else
              # Convert guide slugs to proper markdown file references
              guide_link =
                cond do
                  # Keep anchor links as-is
                  String.starts_with?(link, "#") ->
                    link

                  String.contains?(link, "#") ->
                    # Handle guide#anchor format
                    [guide_slug, anchor] = String.split(link, "#", parts: 2)
                    "#{guide_slug}.md##{anchor}"

                  link == "basic_usage" ->
                    "basic_usage.md"

                  link == "marker_styling" ->
                    "marker_styling.md"

                  link == "theming" ->
                    "theming.md"

                  # Convert other slugs to .md files
                  true ->
                    "#{link}.md"
                end

              "- [#{title}](#{guide_link})"
            end
          end),
          ""
        ]

        content_parts ++ List.flatten(links_content)
      else
        content_parts
      end

    content_parts
  end
end
