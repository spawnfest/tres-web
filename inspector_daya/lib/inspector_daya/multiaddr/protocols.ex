defmodule InspectorDaya.Multiaddr.Protocols do
  defstruct [:name, :size, :path, :parameter]
  alias InspectorDaya.Multiaddr.Protocols

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
    protocol = %{protocol | parameter: Enum.join(tail, "/")}
    {protocol, []}
  end

  def check_path_parameter(%Protocols{size: size, name: name} = protocol, tail) when size != 0 do
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
    {:ok, head, tail}
  end

  def get_protocol(name) do
    case name do
      "ip4" ->
        {:ok, new(name, 32, false)}

      "tcp" ->
        {:ok, new(name, 16, false)}

      "udp" ->
        {:ok, new(name, 16, false)}

      "dccp" ->
        {:ok, new(name, 16, false)}

      "ip6" ->
        {:ok, new(name, 128, false)}

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

      "dns4" ->
        {:ok, new(name, -1, false)}

      "p2p" ->
        {:ok, new(name, -1, false)}

      _ ->
        {:error, "protocol name not found"}
    end
  end
end

# dns, dns4, dns6, dnsaddr,
