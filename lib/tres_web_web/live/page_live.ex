defmodule TresWebWeb.PageLive do
  @moduledoc false
  use TresWebWeb, :live_view
  alias TresWeb.Dweb.Ipfs
  alias TresWeb.Dweb.Multiaddr.Protocols

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       cid: "",
       decoded_details_display: "none",
       decoded_multiaddr_display: "none",
       show_cid_details: false,
       show_explorer_details: false,
       clicked_cid: "",
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
           codec_details: %{code: "", description: "", name: "", tag: ""},
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
  def handle_event("show-cid-details", _params, socket) do
    socket =
      socket
      |> assign(:show_cid_details, true)
      |> assign(:show_explorer_details, false)

    {:noreply, socket}
  end

  @impl true
  def handle_event("show-explorer-details", _params, socket) do
    socket =
      socket
      |> assign(:show_cid_details, false)
      |> assign(:show_explorer_details, true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("clicked-cid", params, socket) do
    params |> IO.inspect(label: "CLICKED")

    socket =
      socket
      |> assign(:clicked_cid, params["clicked-cid"])

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

    decoded_maddr_string =
      case Base.decode64(maddr_string) do
        :error -> maddr_string
        {:ok, decoded} -> decoded
      end

    {:ok, layers} =
      decoded_maddr_string
      |> Protocols.parse_multiaddr()

    layers =
      layers
      |> Enum.with_index()
      |> Enum.map(fn {layer, index} ->
        layer
        |> Map.from_struct()
        |> Map.put(:display, display(index))
      end)

    socket
    |> assign(cid: encoded_maddr_string)
    |> assign(decoded_multiaddr_display: "flex")
    |> assign(layers: layers |> Enum.reverse())
  end

  defp decode_cid(cid, socket) do
    {:ok, cid_details} = TresWeb.Dweb.Cid.decode(cid)

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
    |> assign(:clicked_cid, cid)
    |> assign(decoded_details_display: "block")
    |> assign(cid_details: cid_details)
    |> assign(ipfs_details: ipfs_details)
    |> assign(ipfs_details: ipfs_details)
    |> assign(show_cid_details: true)
  end

  defp display(index), do: %{index: index + 1, color: random_color(), size: (index + 1) * 150}

  def random_color do
    "rgb(#{Enum.random(0..127)},#{Enum.random(85..170)},#{Enum.random(128..255)})"
  end
end
