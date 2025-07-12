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
    # Get all loaded modules and filter for DemoWeb.Pages.*
    :code.all_loaded()
    |> Enum.map(fn {module, _} -> module end)
    |> Enum.filter(&is_page_module?/1)
  end
  
  defp is_page_module?(module) do
    module_name = to_string(module)
    String.starts_with?(module_name, "Elixir.DemoWeb.Pages.")
  end
  
  defp extract_page_metadata(module) do
    # Ensure module is loaded
    Code.ensure_loaded(module)
    
    %Page{
      slug: get_module_attribute(module, :slug) || derive_slug_from_module(module),
      title: get_module_attribute(module, :title) || "Untitled Page",
      description: get_module_attribute(module, :description),
      nav_order: get_module_attribute(module, :nav_order),
      keywords: get_module_attribute(module, :keywords),
      module: module
    }
  end
  
  defp get_module_attribute(module, attribute) do
    case module.__info__(:attributes) do
      attributes when is_list(attributes) ->
        case Keyword.get(attributes, attribute) do
          [value] -> value
          _ -> nil
        end
      _ -> nil
    end
  end
  
  defp derive_slug_from_module(module) do
    module
    |> to_string()
    |> String.replace("Elixir.DemoWeb.Pages.", "")
    |> String.replace("Page", "")
    |> Macro.underscore()
  end
end