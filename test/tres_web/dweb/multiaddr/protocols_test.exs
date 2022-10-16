defmodule TresWeb.Dweb.Multiaddr.ProtocolsTest do
  use ExUnit.Case

  alias TresWeb.Dweb.Multiaddr.Protocols

  describe "test get protocols" do
    test "get ip4" do
      {:ok, p} = Protocols.get_protocol("ip4")
      assert p.name == "ip4"
      assert p.size == 32
      assert p.path == false
    end
  end

  describe "test empty string" do
    test "parse empty string" do
      assert {:error, "empty multiaddr string"} == Protocols.parse_multiaddr("")
    end
  end

  describe "test malformed string" do
    test "parse malformed string" do
      {status, _} = Protocols.parse_multiaddr("////")
      assert status == :error
    end
  end

  describe "test multiaddr with tcp, dns4 and tls" do
    test "parse sample address " do
      {status, parsed_address} =
        Protocols.parse_multiaddr("/dns4/example.com/tcp/1234/tls/ws/tls")

      assert status == :ok
      assert Enum.count(parsed_address) == 5
    end
  end

  describe "test with invalid parameters" do
    test "test without parameter and non empty following protocol" do
      {status, _} = Protocols.parse_multiaddr("tcp/tls")
      assert status == :error
    end

    test "test with no parameter" do
      {status, _} = Protocols.parse_multiaddr("dns/ecample.com/tls/tcp")
      assert status == :error
    end
  end

  describe "test path parameter" do
    test "test with path parameter" do
      {status, [head | _tail]} = Protocols.parse_multiaddr("/unix/path/to/sock")
      assert status == :ok
      assert head.parameter == "path/to/sock"
    end

    test "test with empty path" do
      {status, _} = Protocols.parse_multiaddr("/unix")
      assert status == :error
    end
  end

  test "test invalid protocol" do
    assert {:error, "protocol name not found"} == Protocols.get_protocol("invalid")
  end

  test "test get protocols" do
    protocols = [
      "ip4",
      "ip6",
      "ipcidr",
      "ip6zone",
      "tcp",
      "dns",
      "dns4",
      "dns6",
      "dnsaddr",
      "udp",
      "dccp",
      "tls",
      "ws",
      "wss",
      "noise",
      "unix",
      "p2p",
      "p2p-circuit",
      "sctp",
      "onion",
      "onion3",
      "garlic32",
      "garlic64",
      "utp",
      "udt",
      "quic",
      "http",
      "https",
      "p2p-webrtc-direct",
      "webrtc",
      "ipfs"
    ]

    Enum.map(protocols, fn name ->
      {status, _} = Protocols.get_protocol(name)
      assert status == :ok
    end)
  end
end
