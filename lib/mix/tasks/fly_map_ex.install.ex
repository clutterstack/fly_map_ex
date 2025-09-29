defmodule Mix.Tasks.FlyMapEx.Install do
  @shortdoc "Copy FlyMapEx CSS and JS assets into your Phoenix project"
  @moduledoc """
  Copies the FlyMapEx static assets into your Phoenix application's `assets/vendor`
  directory so they can be imported by your bundler.

  ## Examples

      $ mix fly_map_ex.install
      $ mix fly_map_ex.install --assets-path assets/vendor/fly_map
      $ mix fly_map_ex.install --force
  """

  use Mix.Task

  @switches [assets_path: :string, force: :boolean]
  @aliases [a: :assets_path, f: :force]

  @impl Mix.Task
  def run(args) do
    Mix.shell().info("Copying FlyMapEx assets...")

    {opts, _, _} = OptionParser.parse(args, switches: @switches, aliases: @aliases)

    assets_path = opts[:assets_path] || Path.join(["assets", "vendor", "fly_map_ex"])
    force? = opts[:force] || false

    static_dir = Application.app_dir(:fly_map_ex, "priv/static")

    css_files = Path.wildcard(Path.join([static_dir, "css", "*.css"]))
    js_files = Path.wildcard(Path.join([static_dir, "js", "*.js"]))

    ensure_has_files!(css_files ++ js_files)

    copy_files(css_files, assets_path, force?)
    copy_files(js_files, assets_path, force?)

    Mix.shell().info("\nDone!\n")
    Mix.shell().info("Add the CSS to your bundler, e.g. in assets/css/app.css:")
    Mix.shell().info("  @import '../vendor/fly_map_ex/fly_map_ex.css';")
    Mix.shell().info("\nImport the LiveView hook in assets/js/app.js:")

    Mix.shell().info(
      "  import { createRealTimeMapHook } from '../vendor/fly_map_ex/real_time_map_hook.js'"
    )

    Mix.shell().info("  let Hooks = { RealTimeMap: createRealTimeMapHook(socket) }")
  end

  defp ensure_has_files!([]) do
    raise Mix.Error,
          "Unable to find FlyMapEx static assets. Ensure the dependency is compiled."
  end

  defp ensure_has_files!(_), do: :ok

  defp copy_files(files, assets_path, force?) do
    Enum.each(files, fn source ->
      target = Path.join([assets_path, Path.basename(source)])
      copy_file(source, target, force?)
    end)
  end

  defp copy_file(source, target, force?) do
    if File.exists?(target) and not force? do
      Mix.shell().info("  ! skipping #{relative_path(target)} (exists, pass --force to overwrite)")
    else
      target |> Path.dirname() |> File.mkdir_p!()
      File.cp!(source, target)
      Mix.shell().info("  * copied #{relative_path(target)}")
    end
  end

  defp relative_path(path) do
    Path.relative_to(path, File.cwd!())
  end
end
