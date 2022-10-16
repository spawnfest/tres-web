defmodule InspectorDaya.Dweb.Multiaddr.Protocols do
  defstruct [:name, :size, :path, :parameter]
  alias InspectorDaya.Dweb.Multiaddr.Protocols

  def new(name, size, path) do
    __MODULE__.__struct__(
      name: name,
      size: size,
      path: path
    )
  end

  def parse_multiaddr("") do
    {:error, "empty multiaddr string"}
  end

  def parse_multiaddr(multi_addr) do
    tokens = String.split(multi_addr, "/", trim: true)
    parse_tokens(tokens, [])
  end

  def parse_tokens(_, _, error \\ :ok)

  def parse_tokens(_, _, {:error, error}) do
    {:error, error}
  end

  def parse_tokens([], result, _) do
    case Enum.count(result) do
      0 -> {:error, "empty string"}
      _ -> {:ok, Enum.reverse(result)}
    end
  end

  def parse_tokens([head | tail], result, _) do
    with {:ok, protocol} <- get_protocol(head),
         {%Protocols{} = p, tokens} <- check_path_parameter(protocol, tail) do
      parse_tokens(tokens, [p | result])
    else
      {:error, err_message} -> parse_tokens(nil, nil, {:error, err_message})
    end
  end

  def check_path_parameter(%Protocols{path: true} = protocol, tail) do
    case Enum.count(tail) do
      0 ->
        {:error, "path needed for protocol " <> protocol.name}

      _ ->
        protocol = %{protocol | parameter: Enum.join(tail, "/")}
        {protocol, []}
    end
  end

  def check_path_parameter(%Protocols{size: size} = protocol, tail) when size != 0 do
    with {:ok, param, tokens} <- get_parameter(tail) do
      protocol = %{protocol | parameter: param}
      {protocol, tokens}
    end
  end

  def check_path_parameter(protocol, tail) do
    {protocol, tail}
  end

  def get_parameter([]) do
    {:error, "required parameter"}
  end

  def get_parameter([head | tail]) do
    case get_protocol(head) do
      {:error, _} -> {:ok, head, tail}
      _ -> {:error, "required parameter"}
    end
  end

  def get_protocol("ipfs") do
    get_protocol("p2p")
  end

  def get_protocol(name) do
    case name do
      "ip4" ->
        {:ok, new(name, 32, false)}

      "ip6" ->
        {:ok, new(name, 128, false)}

      "ipcidr" ->
        {:ok, new(name, 8, false)}

      "ip6zone" ->
        {:ok, new(name, -1, false)}

      "tcp" ->
        {:ok, new(name, 16, false)}

      "dns" ->
        {:ok, new(name, -1, false)}

      "dns4" ->
        {:ok, new(name, -1, false)}

      "dns6" ->
        {:ok, new(name, -1, false)}

      "dnsaddr" ->
        {:ok, new(name, -1, false)}

      "udp" ->
        {:ok, new(name, 16, false)}

      "dccp" ->
        {:ok, new(name, 16, false)}

      "tls" ->
        {:ok, new(name, 0, false)}

      "ws" ->
        {:ok, new(name, 0, false)}

      "wss" ->
        {:ok, new(name, 0, false)}

      "noise" ->
        {:ok, new(name, 0, false)}

      "unix" ->
        {:ok, new(name, -1, true)}

      "p2p" ->
        {:ok, new(name, -1, false)}

      "p2p-circuit" ->
        {:ok, new(name, 0, false)}

      "sctp" ->
        {:ok, new(name, 16, false)}

      "onion" ->
        {:ok, new(name, 296, false)}

      "onion3" ->
        {:ok, new(name, 296, false)}

      "garlic64" ->
        {:ok, new(name, -1, false)}

      "garlic32" ->
        {:ok, new(name, -1, false)}

      "utp" ->
        {:ok, new(name, 0, false)}

      "udt" ->
        {:ok, new(name, 0, false)}

      "quic" ->
        {:ok, new(name, 0, false)}

      "http" ->
        {:ok, new(name, 0, false)}

      "https" ->
        {:ok, new(name, 0, false)}

      "p2p-webrtc-direct" ->
        {:ok, new(name, 0, false)}

      "webrtc" ->
        {:ok, new(name, 0, false)}

      _ ->
        {:error, "protocol name not found"}
    end
  end
end
