defmodule KuboEx.Rpc do
  @moduledoc """
  https://docs.ipfs.tech/reference/kubo/rpc/
  """
  def request(config, command, opts \\ []) do
    endpoint = config.endpoint
    url = endpoint <> "/api/v0/" <> Enum.join(command, "/")
    options = [query: opts]

    result =
      case HTTPoison.post(url, "", options) do
        {:ok, response} ->
          body = Jason.decode!(response.body)
          {:ok, {response.status_code, body}}

        {:error, reason} ->
          {:error, reason}
      end

    case result do
      {:ok, {200, body}} -> {:ok, body}
      {:ok, {code, _}} -> {:error, parse_status_code(code)}
      {:error, reason} -> {:error, reason}
    end
  end

  def parse_status_code(200), do: :ok

  def parse_status_code(code) do
    reason =
      case code do
        # TODO: Convert to atoms or other non string type
        500 -> "RPC endpoint returned an error"
        400 -> "Malformed RPC, argument type error, etc"
        403 -> "RPC call forbidden"
        404 -> "RPC endpoint doesn't exist"
        405 -> "HTTP Method Not Allowed"
        _ -> "Unknown error"
      end

    {:error, reason}
  end

  def id(config, opts \\ []) do
    request(config, ["id"], opts)
  end
end
