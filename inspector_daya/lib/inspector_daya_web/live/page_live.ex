defmodule InspectorDayaWeb.PageLive do
  @moduledoc false
  use InspectorDayaWeb, :live_view
  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       cid: "",
       decoded_details_display: "none",
       cid_details: %{
         humanize: "",
         multibase: %{code: "", description: "", encoding: ""},
         multicodec: %{
           code: "",
           description: "",
           name: "",
           tag: ""
         },
         multihash: %{
           code: %{code: "", description: "", name: "", tag: ""},
           digest: "",
           multihash_algo: ""
         },
         v0: "",
         v1: "",
         version: 0
       }
     )}
  end

  @impl true
  def handle_event("decode", %{"cid-value" => cid} = _params, socket) do
    cid_details =
      InspectorDaya.Cid.decode(cid)
      |> IO.inspect()

    socket =
      socket
      |> assign(decoded_details_display: "block")
      |> assign(cid_details: cid_details)

    {:noreply, socket}
  end
end
