defmodule TresWeb.Dweb.Cid do
  @moduledoc """
  Module contains various operations to handle CIDs, such as encoding, decoding, transforming etc..

  CID - Self-describing content-addressed identifiers for distributed systems
  """

  @typedoc """
  In-depth decoded details of the CID

  - humanize - Human readable CID
  - multibase - Details on multibase used
  - version - version of the CID
  - multicodec - Details on multicodec used
  - multihash - Details on multihash used
  - v0 - v0 version of the CID
  - v1 - v1 version of the CID
  """
  @type decoded_cid :: %{
          humanize: String.t(),
          multibase: multibase_details(),
          version: number(),
          multicodec: multicodec_details(),
          multihash: multihash_details(),
          v0: String.t(),
          v1: String.t()
        }

  @typedoc """
  Details of a Multibase

  - encoding - Base encoding method used
  - code - Code represending the encoding method
  - description - Description of base encoding method used
  """
  @type multibase_details :: %{
          encoding: String.t(),
          code: String.t(),
          description: String.t()
        }

  @typedoc """
  Details of a Multicodec

  - name - Name of the encoding used, ex: dag-pb
  - tag - Type of encoding used, ex: ipld
  - code - Hex code for the encoding name
  - description - Description about the codec
  """
  @type multicodec_details :: %{
          name: String.t(),
          tag: String.t(),
          code: String.t(),
          description: String.t()
        }

  @typedoc """
  Details of a Multihash

  - multihash_algo - Algorithm used for generating the hash
  - multicodec - Details of the multicodec used
  - digest - The actual data which will be in hashed form
  """
  @type multihash_details :: %{
          multihash_algo: String.t(),
          codec_details: multicodec_details(),
          digest: String.t()
        }

  @typedoc """
  Fields or parts contained in a CID

  - multibase - Represents the base encoding used when converting CIDs between string and binary formats
  - version - Version of the CID
  - multicodec - Encoding used to encode the data itself
  - multihash_algo - Algorithm used for generating the hash
  - digest - The actual data which will be in hashed form
  """
  @type cid_parts :: %{
          multibase: String.t(),
          version: String.t(),
          multicodec: String.t(),
          multihash_algo: String.t(),
          digest: String.t()
        }

  @doc """
  Decodes a CID in-depth

  ## Examples
      iex> TresWeb.Dweb.Cid.decode("QmZCDSGV7PRJjRb2PFyopKzsU79LgmPo7AziaB89XFXyP3")
      {:ok, %{
        humanize: "base58_btc - CIDv0 - dag-pb - sha2_256 - a147555676b0a2d64a374a0961fcb3362bbf0c5e2f931b9cd5904c99a210d0ae",
        multibase: %{code: "z", description: "base58 bitcoin", encoding: "base58btc"},
        multicodec: %{
          code: "0x70",
          description: "MerkleDAG protobuf",
          name: "dag-pb",
          tag: "ipld"
        },
        multihash: %{
          codec_details: %{code: "0x12", description: "", name: "sha2-256", tag: "multihash"},
          digest: "a147555676b0a2d64a374a0961fcb3362bbf0c5e2f931b9cd5904c99a210d0ae",
          multihash_algo: "sha2_256"
        },
        v0: "QmZCDSGV7PRJjRb2PFyopKzsU79LgmPo7AziaB89XFXyP3",
        v1: "bafybeifbi5kvm5vqulleun2kbfq7zmzwfo7qyxrpsmnzzvmqjsm2eegqvy",
        version: 0
      }}
      iex> TresWeb.Dweb.Cid.decode("A147555676B0A2D64A374A0961FCB3362BBF0C5E2F931B9CD5904C99A210D0AE")
      {:error, "unable to decode CID string"}
  """
  @spec decode(cid :: String.t()) :: {:ok, decoded_cid()} | {:error, String.t()}
  def decode(cid) do
    with {:ok, {cid_struct, multibase}} <- CID.decode(cid),
         {:ok, humanize} <- CID.humanize(cid),
         %CID{version: version, codec: codec, multihash: _multihash} <- cid_struct do
      {:ok,
       %{
         humanize: humanize,
         multibase: multibase_prefix_details(multibase),
         version: version,
         multicodec: multicodec_prefix_details(codec),
         multihash: multihash_details(cid),
         v0: cid_v0(cid_struct, get_cid_parts(cid)),
         v1: cid_v1(cid_struct)
       }}
    else
      {:error, reason} -> {:error, to_string(reason)}
    end
  end

  @spec multibase_prefix_details(Multibase.encoding_id()) :: multibase_details()
  defp multibase_prefix_details(multibase) do
    "#{:code.priv_dir(:tres_web)}/multibase.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode()
    |> Enum.find(fn {:ok, [encoding, _code, _description, _status]} ->
      encoding == to_string(multibase) |> String.replace("_", "")
    end)
    |> then(fn {:ok, [encoding, code, description, _status]} ->
      %{
        encoding: String.trim(encoding),
        code: String.trim(code),
        description: String.trim(description)
      }
    end)
  end

  @spec multicodec_prefix_details(binary()) :: multicodec_details()
  defp multicodec_prefix_details(multicodec) do
    "#{:code.priv_dir(:tres_web)}/multicodec.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode()
    |> Enum.find(fn {:ok, [name, _tag, _code, _status, _description]} ->
      name == multicodec |> String.replace("_", "-")
    end)
    |> then(fn {:ok, [name, tag, code, _status, description]} ->
      %{
        name: String.trim(name),
        tag: String.trim(tag),
        code: String.trim(code),
        description: String.trim(description)
      }
    end)
  end

  @spec multihash_details(String.t()) :: multihash_details()
  defp multihash_details(cid) do
    cid
    |> get_cid_parts()
    |> then(fn cid_props ->
      %{
        multihash_algo: cid_props.multihash_algo,
        codec_details: multicodec_prefix_details(cid_props.multihash_algo),
        digest: cid_props.digest
      }
    end)
  end

  @spec get_cid_parts(String.t()) :: cid_parts()
  defp get_cid_parts(cid) do
    CID.humanize(cid, "::")
    |> then(fn {:ok, props} -> props |> String.split("::") end)
    |> then(fn [multibase, version, multicodec, multihash_algo, digest] ->
      %{
        multibase: multibase,
        version: version,
        multicodec: multicodec,
        multihash_algo: multihash_algo,
        digest: digest
      }
    end)
  end

  @spec cid_v0(CID.t(), cid_parts()) :: String.t() | nil
  defp cid_v0(
         %CID{version: 0} = cid_struct,
         %{multibase: "base58_btc", multicodec: "dag-pb", multihash_algo: "sha2_256"} = _props
       ) do
    cid_struct |> CID.encode!()
  end

  defp cid_v0(
         cid_struct,
         %{multibase: "base58_btc", multicodec: "dag-pb", multihash_algo: "sha2_256"} = _props
       ) do
    cid_struct
    |> CID.to_version(0)
    |> then(fn {:ok, cid_struct_v0} -> CID.encode!(cid_struct_v0) end)
  end

  # Case where a cid struct can't be converted to V0, since multibase is incompatible
  defp cid_v0(_, _), do: nil

  @spec cid_v1(CID.t()) :: String.t()
  defp cid_v1(%CID{version: 1} = cid_struct), do: CID.encode!(cid_struct, :base32_lower)

  defp cid_v1(cid_struct) do
    {:ok, cid_struct_v1} = cid_struct |> CID.to_version(1)
    CID.encode!(cid_struct_v1, :base32_lower)
  end
end
