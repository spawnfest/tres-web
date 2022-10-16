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
