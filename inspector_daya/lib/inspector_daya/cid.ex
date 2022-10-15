defmodule InspectorDaya.Cid do
  def decode(cid) do
    {:ok, humanize} = CID.humanize(cid)

    {:ok, {cid_struct, multibase}} = CID.decode(cid)
    %CID{version: version, codec: codec, multihash: _multihash} = cid_struct

    %{
      humanize: humanize,
      multibase: multibase_prefix_details(multibase),
      version: version,
      multicodec: multicodec_prefix_details(codec),
      multihash: multihash_details(cid),
      v0: cid_v0(cid_struct, cid_properties(cid)),
      v1: cid_v1(cid_struct, cid_properties(cid))
    }
  end

  def multibase_prefix_details(multibase) do
    "#{:code.priv_dir(:inspector_daya)}/multibase.csv"
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

  def multicodec_prefix_details(multicodec) do
    "#{:code.priv_dir(:inspector_daya)}/multicodec.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode()
    # |> Enum.take(2)
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

  def multihash_details(cid) do
    cid
    |> cid_properties()
    |> then(fn cid_props ->
      %{
        multihash_algo: cid_props.multihash_algo,
        code: multicodec_prefix_details(cid_props.multihash_algo),
        digest: cid_props.digest
      }
    end)
  end

  def cid_properties(cid) do
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

  def cid_v0(
        cid_struct,
        %{multibase: "base58_btc", multicodec: "dag-pb", multihash_algo: "sha2_256", version: 0} =
          _props
      ) do
    cid_struct |> CID.encode!()
  end

  def cid_v0(
        cid_struct,
        %{multibase: "base58_btc", multicodec: "dag-pb", multihash_algo: "sha2_256"} = _props
      ) do
    {:ok, cid_struct_v0} = cid_struct |> CID.to_version(0)
    CID.encode!(cid_struct_v0)
  end

  def cid_v0(_, _), do: nil

  def cid_v1(%{version: 1} = cid_struct, _) do
    CID.encode!(cid_struct)
  end

  def cid_v1(cid_struct, _) do
    {:ok, cid_struct_v1} = cid_struct |> CID.to_version(1)
    CID.encode!(cid_struct_v1)
  end
end
