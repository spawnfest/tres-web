defmodule InspectorDayaWeb.PageController do
  use InspectorDayaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
