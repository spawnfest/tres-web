defmodule InspectorDaya.Dweb.Ipfs do
  @moduledoc """
  An ipfs client module, which talks to the local ipfs-daemon

  Inspector will communicate with the local ipfs daemon (both will be packed inside docker-compose)
  The communication is via normal REST POST api call
  """
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:5001/api/v0"
  plug Tesla.Middleware.JSON

  adapter(Tesla.Adapter.Hackney)

  @doc """
  Returns list of directories and related info of the CID
  """
  @spec file_ls(String.t()) :: {:ok, map()} | {:error, term()}
  def file_ls(cid), do: request_post("/file/ls?arg=#{cid}")

  @spec request_post(String.t(), map()) :: {:ok, map()} | {:error, term()}
  defp request_post(path, params \\ %{}) do
    post(path, params)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:ok, %Tesla.Env{status: _, body: body}} -> {:error, body}
      {:error, reason} -> {:error, reason}
    end
  end
end
