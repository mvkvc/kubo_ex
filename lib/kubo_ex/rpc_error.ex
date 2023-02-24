defmodule KuboEx.RpcError do
  defexception [:code, :message, :meta]

  @type rpc_error_status :: 400 | 403 | 404 | 405 | 500
  @type t :: %__MODULE__{
          code: atom(),
          message: String.t(),
          meta: map()
        }

  @spec new(atom(), binary(), map()) :: KuboEx.RpcError.t()
  def new(code, message, meta \\ %{}) when is_binary(message) do
    %__MODULE__{code: code, message: message, meta: Map.new(meta)}
  end

  @spec json(binary()) :: KuboEx.RpcError.t()
  def json(message) do
    new(:json, "JSON error: #{message}")
  end

  @spec http(atom()) :: KuboEx.RpcError.t()
  def http(reason) do
    new(:http, "HTTP error: #{reason}", %{reason: reason})
  end

  @spec rpc(rpc_error_status()) :: KuboEx.RpcError.t()
  def rpc(status) do
    new(:rpc, "RPC error: #{status} - #{rpc_status_lookup(status)}", %{status: status})
  end

  @spec rpc_status_lookup(rpc_error_status()) :: String.t()
  def rpc_status_lookup(code) do
    case code do
      400 -> "Malformed RPC, argument type error, etc"
      403 -> "RPC call forbidden"
      404 -> "RPC endpoint doesn't exist"
      405 -> "HTTP Method Not Allowed"
      500 -> "RPC endpoint returned an error"
      _ -> "Unknown RPC error"
    end
  end
end
