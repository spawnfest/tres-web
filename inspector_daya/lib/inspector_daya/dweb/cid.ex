defmodule InspectorDaya.Dweb.Cid do
  @moduledoc """
  This module contains various operations to handle CIDs, such encoding, decoding, transforming etc..

  CID - Self-describing content-addressed identifiers for distributed systems
  """

  # TODO typedoc for decoded_cid

  @typedoc """

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

  # TODO typedoc for multibase_details
  @type multibase_details :: %{
          encoding: String.t(),
          code: String.t(),
          description: String.t()
        }

  # TODO typedoc for multicodec_details
  @type multicodec_details :: %{
          name: String.t(),
          tag: String.t(),
          code: String.t(),
          description: String.t()
        }

  # TODO typedoc for multihash_details
  @type multihash_details :: %{
          multihash_algo: String.t(),
          code: multicodec_details(),
          digest: String.t()
        }

  @type cid_properties :: %{
          multibase: String.t(),
          version: String.t(),
          multicodec: String.t(),
          multihash_algo: String.t(),
          digest: String.t()
        }
  # TODO: Expand the doc
  @doc """
  Decodes a CID in detail
  """
  @spec decode(cid :: String.t()) :: {:ok, decoded_cid()} | {:error, String.t()}
  def decode(cid) do
    with true <- CID.cid?(cid),
         {:ok, humanize} <- CID.humanize(cid),
         {:ok, {cid_struct, multibase}} <- CID.decode(cid) do
      %CID{version: version, codec: codec, multihash: _multihash} = cid_struct
        IO.inspect(multibase, label: :multibase_prefix)
      {:ok,
       %{
         humanize: humanize,
         multibase: multibase_prefix_details(multibase),
         version: version,
         multicodec: multicodec_prefix_details(codec),
         multihash: multihash_details(cid),
         v0: cid_v0(cid_struct, get_cid_properties(cid)),
         v1: cid_v1(cid_struct)
       }}
    else
      false -> {:error, "Not a valid encoded CID"}
      {:error, reason} -> {:error, "Unable to decode CID due to #{reason}"}
    end
  end

  @spec multibase_prefix_details(Multibase.encoding_id()) :: multibase_details()
  defp multibase_prefix_details(multibase) do
    "#{:code.priv_dir(:inspector_daya)}/multibase.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode()
    |> Enum.find(fn {:ok, [encoding, _code, _description, _status]} ->
      IO.inspect(encoding)
      encoding == to_string(multibase) |> String.replace("_", "")
    end)
    |> IO.inspect()
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
    "#{:code.priv_dir(:inspector_daya)}/multicodec.csv"
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
    |> get_cid_properties()
    |> then(fn cid_props ->
      %{
        multihash_algo: cid_props.multihash_algo,
        code: multicodec_prefix_details(cid_props.multihash_algo),
        digest: cid_props.digest
      }
    end)
  end

  @spec get_cid_properties(String.t()) :: cid_properties()
  defp get_cid_properties(cid) do
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

  @spec cid_v0(CID.t(), multihash_details()) :: String.t() | nil
  defp cid_v0(
         %CID{version: 0} = cid_struct,
         %{multibase: "base58_btc", multicodec: "dag-pb", multihash_algo: "sha2_256"} =
           _props
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

  defp cid_v0(_, _), do: nil

  @spec cid_v1(CID.t()) :: String.t()
  defp cid_v1(%CID{version: 1} = cid_struct) do
    CID.encode!(cid_struct)
  end

  defp cid_v1(cid_struct) do
    {:ok, cid_struct_v1} = cid_struct |> CID.to_version(1)
    CID.encode!(cid_struct_v1, :base32_lower)
  end
end
