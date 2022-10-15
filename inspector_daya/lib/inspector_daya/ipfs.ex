defmodule InspectorDaya.Ipfs do

  # {:ok, multihash}
  def block_details(cid) do
    Ipfx.block_get(cid)
  end

  # {:ok, JSON(list(%{HASH, NAME, TSIZE}))}
  def dag_get(cid) do
    Ipfx.dag_get(cid)
  end

#   {:ok,
#  %{
#    "BlockSize" => 8246,
#    "CumulativeSize" => 61655886776,
#    "DataSize" => 2,
#    "Hash" => "QmUh6QSTxDKX5qoNU1GoogbhTveQQV9JMeQjfFVchAtd5Q",
#    "LinksSize" => 8244,
#    "NumLinks" => 105
#  }}
  def object_stat(cid) do
    Ipfx.object_stat(cid)
  end

  # {:ok, %{"Hash" => "somehash", "Links" => [%{hash, name, size}, %{}]}}
  def object_links(cid) do
    Ipfx.object_links(cid)
  end

  # "QmUh6QSTxDKX5qoNU1GoogbhTveQQV9JMeQjfFVchAtd5Q"
#   {:ok,
#  %{
#    "Objects" => [
#      %{
#        "Hash" => "QmUh6QSTxDKX5qoNU1GoogbhTveQQV9JMeQjfFVchAtd5Q",
#        "Links" => [
#          %{
#            "Hash" => "QmQwhnitZWNrVQQ1G8rL4FRvvZBUvHcxCtUreskfnBzvD8",
#            "Name" => "QW5ub3VuY2VtZW50cw==",
#            "Size" => 0,
#            "Target" => "",
#            "Type" => 1
#          },
#          %{
#            "Hash" => "QmXPqQjySvisWjE11dkrANGmfvUsmPN5RP9oWVRnR7RQuu",
#            "Name" => "QXBvbGxvIDE0IE1hZ2F6aW5lIDY0L0xM",
#            "Size" => 0,
#            "Target" => "",
#            "Type" => 1
#          },
#      }]}}
  def ls(cid) do
    Ipfx.ls_cmd(cid)
  end

  def image_url(cid) do
    base_url = Application.get_env(:inspector_daya, :base_url)
    "#{base_url}/#{cid}"
  end
end
