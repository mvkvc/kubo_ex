defmodule KuboEx.RpcError do
  @moduledoc """
  KuboEx.RpcError is a module for handling RPC errors.
  """

  defexception [:code, :message, :meta]

  @type rpc_error_status :: 400 | 403 | 404 | 405 | 500
  @type t :: %__MODULE__{
          code: atom(),
          message: String.t(),
          meta: map()
        }

  @doc """
  Returns a new KuboEx.RpcError struct.
  """
  @spec new(atom(), binary(), map()) :: KuboEx.RpcError.t()
  def new(code, message, meta \\ %{}) when is_binary(message) do
    %__MODULE__{code: code, message: message, meta: Map.new(meta)}
  end

  @doc """
  Returns a new KuboEx.RpcError struct for a changeset error.
  """
  @spec changeset(Ecto.Changeset.t()) :: KuboEx.RpcError.t()
  def changeset(%Ecto.Changeset{action: action, errors: errors}) do
    new(:changeset, "Changeset error: #{action} - #{inspect(errors)}", %{
      action: action,
      errors: errors
    })
  end

  @doc """
  Returns a new KuboEx.RpcError struct for a JSON error.
  """
  @spec json(binary()) :: KuboEx.RpcError.t()
  def json(message) do
    new(:json, "JSON error: #{message}")
  end

  @doc """
  Returns a new KuboEx.RpcError struct for a HTTP error.
  """
  @spec http(atom()) :: KuboEx.RpcError.t()
  def http(reason) do
    new(:http, "HTTP error: #{reason}", %{reason: reason})
  end

  @doc """
  Returns a new KuboEx.RpcError struct for a RPC error.
  """
  @spec rpc(rpc_error_status()) :: KuboEx.RpcError.t()
  def rpc(status) do
    new(:rpc, "RPC error: #{status} - #{rpc_status_lookup(status)}", %{status: status})
  end

  @doc """
  Lookup the RPC error message for a given status code.
  """
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
