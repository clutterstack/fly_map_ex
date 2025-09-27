defmodule Mix.Tasks.ConcatDocs do

  @moduledoc """
  A Mix task to combine separate documentation source files into single sections for ExDoc-generated docs.
  """
  use Mix.Task

  @dir "documentation/guides"

  def run(_) do
    parts = [
      "intro.md",
      "rest.md"
    ]

    contents =
      parts
      |> Enum.map(&File.read!(Path.join(@dir, &1)))
      |> Enum.join("\n\n")

    File.write!("README.md", contents)

    Mix.shell().info("Generated README.md")
  end
end
