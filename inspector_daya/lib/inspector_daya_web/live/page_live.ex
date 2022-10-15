defmodule InspectorDayaWeb.PageLive do
  @moduledoc false
  use InspectorDayaWeb, :live_view
  # alias InspectorDayaWeb.Router.Helpers, as: Routes
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
         version: 0,
        },
        ipfs_details: %{
          hash: "",
          links: [],
          size: 0,
          type: ""
        }
     )}
  end

  @impl true
  def handle_params(%{"cid" => cid}=_params, _uri, socket) do
    socket = decode(cid, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("decode", %{"cid-value" => cid} = _params, socket) do
    socket = decode(cid, socket)
    {:noreply, push_redirect(socket, to: "/#{cid}")}
  end

  @impl true
  def handle_event("decode", %{"value" => cid} = _params, socket) do
    cid |> IO.inspect(label: "CID")
    socket = decode(cid, socket)
    {:noreply, push_redirect(socket, to: "/#{cid}")}
  end

  defp decode(cid, socket) do
    cid_details = InspectorDaya.Cid.decode(cid)

    {:ok, %{"Objects" => %{
      ^cid => %{
        "Hash" => hash,
        "Links" => links,
        "Size" => size,
        "Type" => type
      }
    }}} = Ipfx.file_ls(cid)

      ipfs_details = %{
        hash: hash,
        links: links,
        size: size,
        type: type
      }
    socket
    |> assign(cid: cid)
    |> assign(decoded_details_display: "block")
    |> assign(cid_details: cid_details)
    |> assign(ipfs_details: ipfs_details)
  end
end
