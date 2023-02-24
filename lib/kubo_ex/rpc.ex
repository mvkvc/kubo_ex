defmodule KuboEx.Rpc do
  @moduledoc false

  alias Ecto.Changeset
  alias KuboEx.RpcError

  @spec build_url(String.t(), [String.t()]) :: String.t()
  def build_url(endpoint, command) do
    Path.join([endpoint, "api/v0", Enum.join(command, "/")])
  end

  @spec post(String.t(), Keyword.t()) ::
          {:ok, HTTPoison.Response.t()} | {:error, KuboEx.RpcError.t()}
  def post(url, options) do
    with {:error, %HTTPoison.Error{reason: reason}} <- HTTPoison.post(url, "", [], options) do
      {:error, RpcError.http(reason)}
    end
  end

  @spec check_status(HTTPoison.Response.t()) ::
          {:ok, String.t()} | {:error, KuboEx.RpcError.t()}
  def check_status(response) do
    case response do
      %HTTPoison.Response{status_code: 200} -> {:ok, response.body}
      %HTTPoison.Response{status_code: code} -> {:error, RpcError.rpc(code)}
    end
  end

  @spec decode(String.t()) ::
          {:ok, map()} | {:error, KuboEx.RpcError.t()}
  def decode(response) do
    with {:error, _} <- Jason.decode(response) do
      {:error, RpcError.json("could not decode: #{inspect(response)}")}
    end
  end

  @spec changeset_apply(Changeset.t()) ::
          {:ok, map()} | {:error, KuboEx.RpcError.t()}
  def changeset_apply(changeset) do
    with {:error, error_changeset} <- Changeset.apply_action(changeset, :update) do
      {:error, RpcError.changeset(error_changeset)}
    end
  end

  @spec request(KuboEx.config(), [String.t()], Keyword.t()) ::
          {:ok, map()} | {:error, KuboEx.RpcError.t()}
  def request(config, command, opts \\ []) do
    url = build_url(config.endpoint, command)
    options = [params: opts]

    with {:ok, response} <- post(url, options),
         {:ok, body} <- check_status(response) do
      decode(body)
    end
  end

  @spec split_fname({atom(), pos_integer()}) :: [String.t()]
  def split_fname(fname) do
    fname
    |> elem(0)
    |> to_string()
    |> String.split("_")
  end

  @spec call(KuboEx.config(), [String.t()], Keyword.t(), map(), [fun()]) ::
          map() | {:error, KuboEx.RpcError.t()}
  def call(config, command, opts \\ [], types \\ %{}, changesets \\ []) do
    opts = Enum.into(opts, %{})

    changeset =
      {opts, types}
      |> Changeset.cast(opts, Map.keys(types))

    changeset =
      Enum.reduce(changesets, changeset, fn f, acc ->
        f.(acc)
      end)

    with {:ok, opts} <- changeset_apply(changeset),
         {:ok, result} <- request(config, command, Map.to_list(opts)) do
      result
    end
  end

  @spec id(KuboEx.config(), Keyword.t()) ::
          map() | {:error, KuboEx.RpcError.t()}
  def id(config, opts \\ ["peerid-base": "b58mh"]) do
    types = %{
      arg: :string,
      format: :string,
      "peerid-base": :string
    }

    changesets = [
      &Changeset.validate_inclusion(&1, :"peerid-base", ["b58mh", "base36", "k", "base32", "b"])
    ]

    call(config, split_fname(__ENV__.function), opts, types, changesets)
  end

  @spec files_ls(KuboEx.config(), Keyword.t()) ::
          map() | {:error, KuboEx.RpcError.t()}
  def files_ls(config, opts \\ [arg: "/"]) do
    types = %{
      arg: :string,
      long: :boolean,
      U: :boolean
    }

    call(config, split_fname(__ENV__.function), opts, types)
  end
end
