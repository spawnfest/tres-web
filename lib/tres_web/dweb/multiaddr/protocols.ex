defmodule TresWeb.Dweb.Multiaddr.Protocols do
  @moduledoc """
  Module contains functions to parse a libp2p multiaddr
  and gives a result demonstrating the interpretation of the multiaddr

  The multiaddress is parsed from left to right , however the address is interpreted from right to
  left, creating layers for the connection.
  """

  defstruct [:name, :size, :path, :parameter]
  alias TresWeb.Dweb.Multiaddr.Protocols

  @spec new(String.t(), integer(), boolean()) :: Protocol | {:error, any}
  def new(name, size, path) do
    __MODULE__.__struct__(
      name: name,
      size: size,
      path: path
    )
  end

  @doc """
  Parses a multi address string and gives the list of protocols(including parameters) involved as a list
  in the order of interpretation

  Returns :error if the string is malformed or missing parameters to protocols that require it.
  ##Examples
  iex(2)> TresWeb.Dweb.Multiaddr.Protocols.parse_multiaddr("/dns4/example.com/tcp/1234/tls/ws/tls")
  {:ok,
  [
   %TresWeb.Dweb.Multiaddr.Protocols{
     name: "dns4",
     parameter: "example.com",
     path: false,
     size: -1
   },
   %TresWeb.Dweb.Multiaddr.Protocols{
     name: "tcp",
     parameter: "1234",
     path: false,
     size: 16
   },
   %TresWeb.Dweb.Multiaddr.Protocols{
     name: "tls",
     parameter: nil,
     path: false,
     size: 0
   },
   %TresWeb.Dweb.Multiaddr.Protocols{
     name: "ws",
     parameter: nil,
     path: false,
     size: 0
   },
   %TresWeb.Dweb.Multiaddr.Protocols{
     name: "tls",
     parameter: nil,
     path: false,
     size: 0
   }
  ]}

  iex(3)> TresWeb.Dweb.Multiaddr.Protocols.parse_multiaddr("/dns4/example.com/tcp/tls/ws/tls")
  {:error, "required parameter"}
  """
  @spec parse_multiaddr(String.t()) :: {:error, any} | {:ok, list(Protocols)}
  def parse_multiaddr("") do
    {:error, "empty multiaddr string"}
  end

  def parse_multiaddr(multi_addr) do
    tokens = String.split(multi_addr, "/", trim: true)
    parse_tokens(tokens, [])
  end

  @spec get_protocol(String.t()) :: {:ok, Protocols} | {:error, any}
  def get_protocol("ipfs"), do: get_protocol("p2p")
  def get_protocol("ip4"), do: {:ok, new("ip4", 32, false)}
  def get_protocol("ip6"), do: {:ok, new("ip6", 128, false)}
  def get_protocol("ipcidr"), do: {:ok, new("ipcidr", 8, false)}
  def get_protocol("ip6zone"), do: {:ok, new("ip6zone", -1, false)}
  def get_protocol("tcp"), do: {:ok, new("tcp", -1, false)}
  def get_protocol("dns"), do: {:ok, new("dns", -1, false)}
  def get_protocol("dns4"), do: {:ok, new("dns4", -1, false)}
  def get_protocol("dns6"), do: {:ok, new("dns6", -1, false)}
  def get_protocol("dnsaddr"), do: {:ok, new("dnsaddr", -1, false)}
  def get_protocol("udp"), do: {:ok, new("udp", 16, false)}
  def get_protocol("dccp"), do: {:ok, new("dccp", 16, false)}
  def get_protocol("tls"), do: {:ok, new("tls", 0, false)}
  def get_protocol("ws"), do: {:ok, new("ws", 0, false)}
  def get_protocol("wss"), do: {:ok, new("wss", 0, false)}
  def get_protocol("noise"), do: {:ok, new("noise", 0, false)}
  def get_protocol("unix"), do: {:ok, new("unix", -1, true)}
  def get_protocol("p2p"), do: {:ok, new("p2p", -1, false)}
  def get_protocol("p2p-circuit"), do: {:ok, new("p2p-circuit", 0, false)}
  def get_protocol("sctp"), do: {:ok, new("sctp", 16, false)}
  def get_protocol("onion"), do: {:ok, new("onion", 296, false)}
  def get_protocol("onion3"), do: {:ok, new("onion3", 296, false)}
  def get_protocol("garlic64"), do: {:ok, new("garlic64", -1, false)}
  def get_protocol("garlic32"), do: {:ok, new("garlic32", -1, false)}
  def get_protocol("utp"), do: {:ok, new("utp", 0, false)}
  def get_protocol("udt"), do: {:ok, new("udt", 0, false)}
  def get_protocol("quic"), do: {:ok, new("quic", 0, false)}
  def get_protocol("http"), do: {:ok, new("http", 0, false)}
  def get_protocol("https"), do: {:ok, new("https", 0, false)}
  def get_protocol("p2p-webrtc-direct"), do: {:ok, new("p2p-webrtc-direct", 0, false)}
  def get_protocol("webrtc"), do: {:ok, new("webrtc", 0, false)}
  def get_protocol(_), do: {:error, "protocol name not found"}

  @spec parse_tokens(list(String.t()), list(Protocols), :ok | :error) ::
          {:ok, list(Protocols)} | {:error, any}
  defp parse_tokens(_, _, error \\ :ok)

  defp parse_tokens(_, _, {:error, error}) do
    {:error, error}
  end

  defp parse_tokens([], result, _) do
    case Enum.count(result) do
      0 -> {:error, "empty string"}
      _ -> {:ok, Enum.reverse(result)}
    end
  end

  defp parse_tokens([head | tail], result, _) do
    with {:ok, protocol} <- get_protocol(head),
         {%Protocols{} = p, tokens} <- check_path_parameter(protocol, tail) do
      parse_tokens(tokens, [p | result])
    else
      {:error, err_message} -> parse_tokens(nil, nil, {:error, err_message})
    end
  end

  @spec check_path_parameter(Protocols, list(String.t())) ::
          {:error, any} | {Protocols, list(String.t())}
  defp check_path_parameter(%Protocols{path: true} = protocol, tail) do
    case Enum.count(tail) do
      0 ->
        {:error, "path needed for protocol " <> protocol.name}

      _ ->
        protocol = %{protocol | parameter: Enum.join(tail, "/")}
        {protocol, []}
    end
  end

  defp check_path_parameter(%Protocols{size: size} = protocol, tail) when size != 0 do
    with {:ok, param, tokens} <- get_parameter(tail) do
      protocol = %{protocol | parameter: param}
      {protocol, tokens}
    end
  end

  defp check_path_parameter(protocol, tail) do
    {protocol, tail}
  end

  @spec get_parameter(list(String.t())) ::
          {:ok, String.t(), list(String.t())} | {:error, String.t()}
  defp get_parameter([]) do
    {:error, "required parameter"}
  end

  defp get_parameter([head | tail]) do
    case get_protocol(head) do
      {:error, _} -> {:ok, head, tail}
      _ -> {:error, "required parameter"}
    end
  end
end
