defmodule InspectorDaya.Dweb.CidTest do
  @moduledoc """
  Tests for `InspectorDaya.Dweb.Cid` module
  """

  use ExUnit.Case
  alias InspectorDaya.Dweb.Cid

  describe "decode/1" do
    test "valid decoding of cid" do
      assert {:ok, decoded_data} = Cid.decode("QmZCDSGV7PRJjRb2PFyopKzsU79LgmPo7AziaB89XFXyP3")

      assert %{
               humanize:
                 "base58_btc - CIDv0 - dag-pb - sha2_256 - a147555676b0a2d64a374a0961fcb3362bbf0c5e2f931b9cd5904c99a210d0ae",
               multibase: %{code: "z", description: "base58 bitcoin", encoding: "base58btc"},
               multicodec: %{
                 code: "0x70",
                 description: "MerkleDAG protobuf",
                 name: "dag-pb",
                 tag: "ipld"
               },
               multihash: %{
                 code: %{code: "0x12", description: "", name: "sha2-256", tag: "multihash"},
                 digest: "a147555676b0a2d64a374a0961fcb3362bbf0c5e2f931b9cd5904c99a210d0ae",
                 multihash_algo: "sha2_256"
               },
               v0: "QmZCDSGV7PRJjRb2PFyopKzsU79LgmPo7AziaB89XFXyP3",
               v1: "bafybeifbi5kvm5vqulleun2kbfq7zmzwfo7qyxrpsmnzzvmqjsm2eegqvy",
               version: 0
             } = decoded_data
    end

    test "invalid  cid" do
      assert {:error, "Not a valid encoded CID"} =
               Cid.decode("QmZCDSGV7PRJjRb2PFyopKzsU79LgmPo7AziaB89FXyP3")
    end

    test "invalid cid 1" do
      assert {:error, "Not a valid encoded CID"} =
               Cid.decode(<<0, "Zdj7WhuEjrB52m1BisYCtmjH1hSKa7yZ3jEZ9JcXaFRD51wVz">>)
    end

    test "valid cidv1" do
      assert {:ok, decoded_data} =
               Cid.decode("bafybeifbi5kvm5vqulleun2kbfq7zmzwfo7qyxrpsmnzzvmqjsm2eegqvy")

      assert %{version: 1, v1: "bafybeifbi5kvm5vqulleun2kbfq7zmzwfo7qyxrpsmnzzvmqjsm2eegqvy"} =
               decoded_data
    end

    test "Valid cidv1 to cidv0 compatible conversion" do
      digest = :crypto.hash(:sha256, "hello world")
      {:ok, multihash} = Multihash.encode(:sha2_256, digest)
      codec = "dag-pb"
      cid_struct = %CID{version: 1, multihash: multihash, codec: codec}
      cid = CID.encode!(cid_struct)
      assert {:ok, %{version: 1, v0: "Qm" <> _}} = Cid.decode(cid)
    end

    test "Invalid cidv1 to cidv0 compatible conversion" do
      digest = :crypto.hash(:sha256, "hello world")
      {:ok, multihash} = Multihash.encode(:sha2_256, digest)
      codec = "dag-pb"
      cid_struct = %CID{version: 1, multihash: multihash, codec: codec}
      cid = CID.encode!(cid_struct, :base32_lower)
      assert {:ok, %{version: 1, v0: nil}} = Cid.decode(cid)
    end
  end
end
