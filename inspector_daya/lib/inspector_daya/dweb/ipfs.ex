defmodule InspectorDaya.Dweb.Ipfs do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:5001/api/v0"
  plug Tesla.Middleware.JSON

  adapter(Tesla.Adapter.Hackney)

  def post_it(path, params \\ %{}) do
    post(path, params)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:ok, %Tesla.Env{status: 400, body: body}} -> {:error, body}
      {:ok, %Tesla.Env{status: 500, body: body}} -> {:error, body}
      {:ok, %Tesla.Env{status: 404}} -> {:error, "NOT FOUND"}
      {:error, reason} -> {:error, reason}
    end
  end

  def file_ls(cid) do
    post_it("/file/ls?arg=#{cid}")
  end
end
