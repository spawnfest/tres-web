defmodule TresWebWeb.PageController do
  use TresWebWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
