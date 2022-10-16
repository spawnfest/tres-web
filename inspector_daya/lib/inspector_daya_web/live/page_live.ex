defmodule InspectorDayaWeb.PageLive do
  @moduledoc false
  use InspectorDayaWeb, :live_view
  alias InspectorDaya.Dweb.Ipfs

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       cid: "",
       decoded_details_display: "none",
       decoded_multiaddr_display: "none",
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
       },
       ipfs_details: %{
         hash: "",
         links: [],
         size: 0,
         type: ""
       },
       layers: []
     )}
  end

  @impl true
  def handle_params(%{"cid" => cid} = _params, _uri, socket) do
    socket = decode_input(cid, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("decode", %{"cid-value" => cid} = _params, socket) do
    socket = decode_input(cid, socket)
    {:noreply, push_redirect(socket, to: "/#{socket.assigns.cid}")}
  end

  @impl true
  def handle_event("decode", %{"value" => cid} = _params, socket) do
    socket = decode_input(cid, socket)
    {:noreply, push_redirect(socket, to: "/#{socket.assigns.cid}")}
  end

  defp decode_input(input, socket) do
    if CID.cid?(input) do
      decode_cid(input, socket)
    else
      decode_multiaddr(input, socket)
    end
  end

  defp decode_multiaddr(maddr_string, socket) do
    encoded_maddr_string =
      case Base.decode64(maddr_string) do
        :error -> Base.encode64(maddr_string)
        _decoded -> maddr_string
      end

    layers =
      [
        %{
          name: "dns4",
          size: -1,
          path: false,
          parameter: "example.com"
        },
        %{
          name: "tcp",
          size: 16,
          path: false,
          parameter: "1234"
        },
        %{
          name: "tls",
          size: 0,
          path: false,
          parameter: nil
        },
        %{
          name: "ws",
          size: 0,
          path: false,
          parameter: nil
        },
        %{
          name: "tls",
          size: 0,
          path: false,
          parameter: nil
        }
      ]
      |> Enum.with_index()
      |> Enum.map(fn {layer, index} -> layer |> Map.put(:display, display(index)) end)

    socket
    |> assign(cid: encoded_maddr_string)
    |> assign(decoded_multiaddr_display: "flex")
    |> assign(layers: layers |> Enum.reverse())
  end

  defp decode_cid(cid, socket) do
    {:ok, cid_details} = InspectorDaya.Dweb.Cid.decode(cid)

    {:ok,
     %{
       "Objects" => %{
         ^cid => %{
           "Hash" => hash,
           "Links" => links,
           "Size" => size,
           "Type" => type
         }
       }
     }} = Ipfs.file_ls(cid)

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

  defp display(index), do: %{index: index + 1, color: random_color(), size: (index + 1) * 150}

  def random_color do
    "rgb(#{Enum.random(0..127)},#{Enum.random(85..170)},#{Enum.random(128..255)})"
  end
end
