defmodule ProtocolsTest do
  use ExUnit.Case

  alias InspectorDaya.Multiaddr.Protocols

  describe "test get protocols" do
    test "get ip4" do
      {:ok, p} = Protocols.get_protocol("ip4")
      assert p.name == "ip4"
      assert p.size == 32
      assert p.path == false
    end
  end

  describe "test empty string" do
    assert {:error, "empty multiaddr string"} == Protocols.parse_multiaddr("")
  end

  describe "test multiaddr with tcp, dns4 and tls" do
    {status, parsed_address} = Protocols.parse_multiaddr("/dns4/example.com/tcp/1234/tls/ws/tls")
    assert status == :ok
    assert Enum.count(parsed_address) == 5
  end
end
