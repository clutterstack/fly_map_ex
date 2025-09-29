defmodule FlyMapEx.JSON do
  @moduledoc """
  JSON helper functions with graceful fallback behaviour.

  FlyMapEx honours the host application's configured JSON library by
  checking `Phoenix.json_library/0` when Phoenix is available. If that
  is not defined we fall back to Jason when it is loaded, providing a
  clear error when no JSON encoder can be resolved.
  """

  @doc """
  Encode a term to JSON using the configured library.
  """
  @spec encode!(term) :: binary
  def encode!(value) do
    json_library().encode!(value)
  end

  defp json_library do
    cond do
      Code.ensure_loaded?(Phoenix) and function_exported?(Phoenix, :json_library, 0) ->
        Phoenix.json_library()

      Code.ensure_loaded?(Jason) ->
        Jason

      true ->
        raise RuntimeError,
              "No JSON library available. Configure :phoenix, :json_library or add Jason to your dependencies."
    end
  end
end
