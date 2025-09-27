defmodule DemoWeb.Content.ValidatedExample do
  @moduledoc """
  Demo app alias for the main library's ValidatedExample module.

  This module simply delegates to FlyMapEx.Content.ValidatedExample to maintain
  backward compatibility while centralizing the validation logic in the main library.
  """

  # Delegate all macros and functions to the main library module
  defdelegate parse_template(template_string), to: FlyMapEx.Content.ValidatedExample

  defmacro validated_template(heex_string) do
    quote do
      FlyMapEx.Content.ValidatedExample.validated_template(unquote(heex_string))
    end
  end
end