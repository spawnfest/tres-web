defmodule InspectorDaya.Dweb.Ipfs do

  def post_it(path, params \\ %{}) do
    Tesla.post(client(), path, params)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:ok, %Tesla.Env{status: 400, body: body}} -> {:error, body}
      {:ok, %Tesla.Env{status: 500, body: body}} -> {:error, body}
      {:ok, %Tesla.Env{status: 404}} -> {:error, "NOT FOUND"}
      {:error, reason} -> {:error, "SOMETHING WENT WRONG DUE TO #{inspect reason}"}
    end
  end

  def file_ls(cid) do
    post_it("/file/ls?arg=#{cid}")
  end

  # def image_url(cid) do
  #   base_url = Application.get_env(:inspector_daya, :base_url)
  #   "#{base_url}/#{cid}"
  # end

  @spec client :: Tesla.Client.t()
  defp client do
    middlewares = [
      {Tesla.Middleware.BaseUrl, base_url()},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middlewares, Application.get_env(:tesla, :adapter))
  end

  defp base_url do
    Application.get_env(:ipfs, :base_api_url)
  end

end
