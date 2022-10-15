defmodule InspectorDaya.FileFetcher do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:8080/ipfs"
  plug Tesla.Middleware.JSON

  adapter(Tesla.Adapter.Hackney)

  def hit(path) do
    get(path)
    |> case do
      {:ok, %Tesla.Env{status: 301, body: body}} -> {:ok, body}
      {:ok, %Tesla.Env{status: 400, body: body}} -> {:error, body}
      {:ok, %Tesla.Env{status: 500, body: body}} -> {:error, body}
      {:ok, %Tesla.Env{status: 404}} -> {:error, "NOT FOUND"}
      {:error, reason} -> {:error, reason}
    end
    |> then(fn {:ok, body} ->
      File.write!("#{:code.priv_dir(:inspector_daya)}/timage.jpg", body)
    end)
  end
end
