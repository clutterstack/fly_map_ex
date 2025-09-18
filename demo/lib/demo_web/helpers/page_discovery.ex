defmodule DemoWeb.Helpers.PageDiscovery do
  @moduledoc """
  Simple page discovery for DemoWeb.Pages.* modules.

  Discovers pages defined as modules under DemoWeb.Pages and extracts
  their metadata from module attributes.
  """

  defmodule Page do
    @moduledoc """
    Represents a discovered page with its metadata.
    """
    defstruct [:slug, :title, :description, :nav_order, :keywords, :module]

    @type t :: %__MODULE__{
            slug: String.t(),
            title: String.t(),
            description: String.t() | nil,
            nav_order: integer() | nil,
            keywords: String.t() | nil,
            module: module()
          }
  end

  @doc """
  Returns all discovered pages as a map with slug as the key.
  """
  @spec all_pages() :: %{String.t() => Page.t()}
  def all_pages do
    discover_page_modules()
    |> Enum.map(&extract_page_metadata/1)
    |> Enum.into(%{}, fn page -> {page.slug, page} end)
  end

  @doc """
  Gets a specific page by slug. Returns nil if not found.
  """
  @spec get_page(String.t()) :: Page.t() | nil
  def get_page(slug) do
    Map.get(all_pages(), slug)
  end

  @doc """
  Returns pages sorted by nav_order then by title for navigation.
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

  # Private functions

  defp discover_page_modules do
    # Force loading of all DemoWeb.Pages modules by checking filesystem
    ensure_pages_loaded()

    # Get all loaded modules and filter for DemoWeb.Pages.*
    :code.all_loaded()
    |> Enum.map(fn {module, _} -> module end)
    |> Enum.filter(&is_page_module?/1)
  end

  defp ensure_pages_loaded do
    # Get the lib directory path
    lib_path = Path.join([File.cwd!(), "lib", "demo_web", "pages"])

    if File.exists?(lib_path) do
      File.ls!(lib_path)
      |> Enum.filter(&String.ends_with?(&1, ".ex"))
      |> Enum.each(fn filename ->
        module_name =
          filename
          |> String.replace(".ex", "")
          |> Macro.camelize()

        module = String.to_atom("Elixir.DemoWeb.Pages.#{module_name}")
        Code.ensure_loaded(module)
      end)
    end
  end

  defp is_page_module?(module) do
    module_name = to_string(module)
    String.starts_with?(module_name, "Elixir.DemoWeb.Pages.")
  end

  defp extract_page_metadata(module) do
    # Ensure module is loaded
    Code.ensure_loaded(module)

    # Get metadata from the page_metadata/0 function if it exists
    metadata =
      if function_exported?(module, :page_metadata, 0) do
        apply(module, :page_metadata, [])
      else
        %{}
      end

    %Page{
      slug: metadata[:slug] || derive_slug_from_module(module),
      title: metadata[:title] || "Untitled Page",
      description: metadata[:description],
      nav_order: metadata[:nav_order],
      keywords: metadata[:keywords],
      module: module
    }
  end

  defp derive_slug_from_module(module) do
    module
    |> to_string()
    |> String.replace("Elixir.DemoWeb.Pages.", "")
    |> String.replace("Page", "")
    |> Macro.underscore()
  end
end
