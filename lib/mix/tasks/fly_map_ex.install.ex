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

    copy_static_group(Path.join(static_dir, "css"), Path.join(assets_path, "css"), force?)
    copy_static_group(Path.join(static_dir, "js"), Path.join(assets_path, "js"), force?)

    Mix.shell().info("\nDone!\n")
    Mix.shell().info("Add the CSS to your bundler, e.g. in assets/css/app.css:")
    Mix.shell().info("  @import '../vendor/fly_map_ex/css/fly_map_ex.css';")
    Mix.shell().info("\nImport the LiveView hook in assets/js/app.js:")

    Mix.shell().info(
      "  import { createRealTimeMapHook } from '../vendor/fly_map_ex/js/real_time_map_hook.js'"
    )

    Mix.shell().info("  let Hooks = { RealTimeMap: createRealTimeMapHook(socket) }")
  end

  defp copy_static_group(source_dir, target_dir, force?) do
    files = Path.wildcard(Path.join(source_dir, "*"))

    case files do
      [] ->
        raise Mix.Error,
              "Unable to find FlyMapEx static assets in #{source_dir}. Ensure the dependency is compiled."

      _ ->
        Enum.each(files, fn source ->
          copy_file(source, Path.join(target_dir, Path.basename(source)), force?)
        end)
    end
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
