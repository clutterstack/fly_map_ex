defmodule DemoWeb.Helpers.SyntaxHighlighter do
  @moduledoc """
  Syntax highlighting utilities using Makeup with DaisyUI-compatible styling.

  This module provides compile-time syntax highlighting for code examples,
  specifically optimized for Elixir/HEEx templates with theme-aware styling.
  """

  @doc """
  Highlights code with syntax highlighting using Makeup.

  Automatically detects language based on content or uses provided language.
  Returns highlighted HTML with DaisyUI-compatible CSS classes.

  ## Examples

      highlight_code(~s(<FlyMapEx.render />), :heex)
      highlight_code("defmodule MyModule do", :elixir)
      highlight_code("<div>content</div>")  # Auto-detects
  """
  def highlight_code(code, language \\ nil) do
    language = language || detect_language(code)

    case language do
      :heex -> highlight_heex(code)
      :elixir -> highlight_elixir(code)
      :html -> highlight_html(code)
      _ -> fallback_highlight(code)
    end
  end

  @doc """
  Highlights HEEx/EEx template code.
  """
  def highlight_heex(code) do
    try do
      code
      |> Makeup.highlight(language: "heex", formatter_opts: formatter_opts())
      |> extract_highlighted_content()
    rescue
      _ -> fallback_highlight(code)
    end
  end

  @doc """
  Highlights Elixir code.
  """
  def highlight_elixir(code) do
    try do
      code
      |> Makeup.highlight(language: "elixir", formatter_opts: formatter_opts())
      |> extract_highlighted_content()
    rescue
      _ -> fallback_highlight(code)
    end
  end

  @doc """
  Highlights HTML code.
  """
  def highlight_html(code) do
    try do
      code
      |> Makeup.highlight(language: "html", formatter_opts: formatter_opts())
      |> extract_highlighted_content()
    rescue
      _ -> fallback_highlight(code)
    end
  end

  @doc """
  Detects the programming language based on code content.
  """
  def detect_language(code) do
    cond do
      # HEEx/Phoenix component patterns
      String.contains?(code, "<.") or
      String.contains?(code, "<FlyMapEx") or
      String.contains?(code, "<%") ->
        :heex

      # Elixir patterns
      String.contains?(code, "defmodule") or
      String.contains?(code, "def ") or
      String.contains?(code, "%{") ->
        :elixir

      # HTML patterns
      String.contains?(code, "<div") or
      String.contains?(code, "<span") ->
        :html

      # Default to HEEx for component examples
      true ->
        :heex
    end
  end

  @doc """
  Generates CSS from a Makeup style map.
  """
  def generate_css_from_style(style_name \\ :autumn_style) do
    style_map = apply(Makeup.Styles.HTML.StyleMap, style_name, [])

    css_rules = for {token_type, token_style} <- style_map.styles do
      class_name = token_type_to_css_class(token_type)
      css_properties = token_style_to_css(token_style)

      if css_properties != "" do
        ".syntax-highlight .highlight .#{class_name} { #{css_properties} }"
      end
    end

    Enum.filter(css_rules, & &1) |> Enum.join("\n")
  end

  # Private functions

  defp formatter_opts do
    [
      css_class: "highlight",
      highlight_tag: "span",
      stylesheet: :autumn_style  # Use Makeup's autumn theme
    ]
  end

  defp extract_highlighted_content(html) do
    # Extract content from <pre class="highlight"><code>...</code></pre>
    # and return just the highlighted spans wrapped in our highlight div
    case Regex.run(~r/<pre[^>]*><code>(.*?)<\/code><\/pre>/s, html, capture: :all_but_first) do
      [content] -> ~s(<div class="highlight">#{content}</div>)
      _ -> fallback_highlight("Error extracting content")
    end
  end

  defp fallback_highlight(code) do
    # Fallback to plain code with basic escaping
    code
    |> Phoenix.HTML.html_escape()
    |> Phoenix.HTML.safe_to_string()
    |> wrap_in_highlight_div()
  end

  defp wrap_in_highlight_div(escaped_code) do
    ~s(<div class="highlight">#{escaped_code}</div>)
  end

  # Convert Makeup token types to CSS class names
  defp token_type_to_css_class(token_type) do
    case token_type do
      :keyword -> "k"
      :keyword_declaration -> "kd"
      :keyword_namespace -> "kn"
      :keyword_pseudo -> "kp"
      :keyword_reserved -> "kr"
      :keyword_type -> "kt"
      :name -> "n"
      :name_attribute -> "na"
      :name_builtin -> "nb"
      :name_class -> "nc"
      :name_constant -> "no"
      :name_decorator -> "nd"
      :name_entity -> "ni"
      :name_exception -> "ne"
      :name_function -> "nf"
      :name_function_magic -> "fm"
      :name_label -> "nl"
      :name_namespace -> "nn"
      :name_other -> "nx"
      :name_property -> "py"
      :name_tag -> "nt"
      :name_variable -> "nv"
      :name_variable_class -> "vc"
      :name_variable_global -> "vg"
      :name_variable_instance -> "vi"
      :name_variable_magic -> "vm"
      :string -> "s"
      :string_affix -> "sa"
      :string_backtick -> "sb"
      :string_char -> "sc"
      :string_delimiter -> "dl"
      :string_doc -> "sd"
      :string_double -> "s2"
      :string_escape -> "se"
      :string_heredoc -> "sh"
      :string_interpol -> "si"
      :string_other -> "sx"
      :string_regex -> "sr"
      :string_single -> "s1"
      :string_symbol -> "ss"
      :string_sigil -> "ss"
      :number -> "m"
      :number_bin -> "mb"
      :number_float -> "mf"
      :number_hex -> "mh"
      :number_integer -> "mi"
      :number_integer_long -> "il"
      :number_oct -> "mo"
      :literal -> "l"
      :literal_date -> "ld"
      :operator -> "o"
      :operator_word -> "ow"
      :punctuation -> "p"
      :comment -> "c"
      :comment_hashbang -> "ch"
      :comment_multiline -> "cm"
      :comment_preproc -> "cp"
      :comment_preproc_file -> "cpf"
      :comment_single -> "c1"
      :comment_special -> "cs"
      :generic -> "g"
      :generic_deleted -> "gd"
      :generic_emph -> "ge"
      :generic_error -> "gr"
      :generic_heading -> "gh"
      :generic_inserted -> "gi"
      :generic_output -> "go"
      :generic_prompt -> "gp"
      :generic_strong -> "gs"
      :generic_subheading -> "gu"
      :generic_traceback -> "gt"
      :error -> "err"
      :whitespace -> "w"
      :text -> ""
      :other -> ""
      _ -> Atom.to_string(token_type)
    end
  end

  # Convert Makeup TokenStyle to CSS properties
  defp token_style_to_css(token_style) do
    properties = []

    properties = if token_style.color do
      ["color: #{token_style.color}" | properties]
    else
      properties
    end

    properties = if token_style.background_color do
      ["background-color: #{token_style.background_color}" | properties]
    else
      properties
    end

    properties = if token_style.font_weight do
      ["font-weight: #{token_style.font_weight}" | properties]
    else
      properties
    end

    properties = if token_style.font_style do
      ["font-style: #{token_style.font_style}" | properties]
    else
      properties
    end

    properties = if token_style.text_decoration do
      ["text-decoration: #{token_style.text_decoration}" | properties]
    else
      properties
    end

    Enum.join(properties, "; ")
  end
end