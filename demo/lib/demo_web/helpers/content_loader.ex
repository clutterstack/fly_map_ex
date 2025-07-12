defmodule DemoWeb.Helpers.ContentLoader do
  @moduledoc """
  Loads and parses Markdown content files with front matter support.
  Content is loaded at compile time for performance.
  """

  @content_dir "content"

  defmodule Page do
    @moduledoc """
    Represents a parsed content page.
    """
    defstruct [:slug, :title, :description, :nav_order, :content, :raw_content]

    @type t :: %__MODULE__{
            slug: String.t(),
            title: String.t(),
            description: String.t() | nil,
            nav_order: integer() | nil,
            content: String.t(),
            raw_content: String.t()
          }
  end

  @doc """
  Gets a page by its slug. Returns nil if not found.
  """
  @spec get_page(String.t()) :: Page.t() | nil
  def get_page(slug) do
    case Map.get(all_pages(), slug) do
      nil -> nil
      page -> page
    end
  end

  @doc """
  Returns all available pages as a map with slug as key.
  """
  @spec all_pages() :: %{String.t() => Page.t()}
  def all_pages do
    load_all_pages()
  end

  @doc """
  Returns pages sorted by nav_order (if present) then by title.
  Useful for navigation menus.
  """
  @spec navigation_pages() :: [Page.t()]
  def navigation_pages do
    all_pages()
    |> Map.values()
    |> Enum.sort_by(fn page ->
      {page.nav_order || 999, page.title}
    end)
  end

  @doc """
  Checks if a page exists for the given slug.
  """
  @spec page_exists?(String.t()) :: boolean()
  def page_exists?(slug) do
    Map.has_key?(all_pages(), slug)
  end

  defp load_all_pages do
    content_path = Path.join([File.cwd!(), @content_dir])

    if File.exists?(content_path) do
      content_path
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".md"))
      |> Enum.map(fn filename ->
        file_path = Path.join(content_path, filename)
        slug = Path.basename(filename, ".md")
        content = File.read!(file_path)
        parse_content(slug, content)
      end)
      |> Enum.into(%{}, fn page -> {page.slug, page} end)
    else
      %{}
    end
  end

  # Parse front matter and content
  def parse_content(slug, raw_content) do
    case String.split(raw_content, "---", parts: 3) do
      ["", front_matter, content] ->
        # Has front matter
        metadata = parse_front_matter(front_matter)
        html_content = DemoWeb.Helpers.ContentHelpers.convert_markdown(String.trim(content))

        %Page{
          slug: slug,
          title: metadata["title"] || String.replace(slug, "-", " ") |> String.capitalize(),
          description: metadata["description"],
          nav_order: parse_nav_order(metadata["nav_order"]),
          content: html_content,
          raw_content: raw_content
        }

      _ ->
        # No front matter, just content
        html_content = DemoWeb.Helpers.ContentHelpers.convert_markdown(String.trim(raw_content))

        %Page{
          slug: slug,
          title: String.replace(slug, "-", " ") |> String.capitalize(),
          description: nil,
          nav_order: nil,
          content: html_content,
          raw_content: raw_content
        }
    end
  end

  defp parse_front_matter(front_matter) do
    front_matter
    |> String.split("\n")
    |> Enum.reduce(%{}, fn line, acc ->
      case String.split(line, ":", parts: 2) do
        [key, value] ->
          Map.put(acc, String.trim(key), String.trim(value))

        _ ->
          acc
      end
    end)
  end

  defp parse_nav_order(nil), do: nil
  defp parse_nav_order(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> nil
    end
  end
  defp parse_nav_order(value) when is_integer(value), do: value
end