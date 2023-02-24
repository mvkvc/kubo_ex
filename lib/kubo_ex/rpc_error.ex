defmodule KuboEx.RpcError do
  defexception [:code, :message, :meta]

  def new(code, message, meta \\ %{}) when is_binary(message) do
    %__MODULE__{code: code, message: message, meta: Map.new(meta)}
  end

  def json(message) do
    new(:json, "JSON error: #{message}")
  end

  def http(reason) do
    new(:http, "HTTP error: #{reason}", reason: reason)
  end

  def rpc(status) do
    new(:rpc, "RPC error: #{status} - #{rpc_status_lookup(status)}", status: status)
  end

  def rpc_status_lookup(code) do
    case code do
      500 -> "RPC endpoint returned an error"
      400 -> "Malformed RPC, argument type error, etc"
      403 -> "RPC call forbidden"
      404 -> "RPC endpoint doesn't exist"
      405 -> "HTTP Method Not Allowed"
      _ -> "Unknown error"
    end
  end
end
