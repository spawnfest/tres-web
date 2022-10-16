defmodule InspectorDaya.Dweb.IpfsTest do
  @moduledoc """
  Tests for InspectorDaya.Dweb.Ipfs
  """

  use ExUnit.Case
  alias InspectorDaya.Dweb.Ipfs

  describe "file_ls/1" do
    test "valid file list fetch" do
      Tesla.Mock.mock(fn
        %{
          method: :post,
          url:
            "http://localhost:5001/api/v0/file/ls?arg=QmbcLhh7kw2C25RE8Ct5XBG25QKA5HHiNkCq3zFDnSV6QG"
        } ->
          %Tesla.Env{
            status: 200,
            body: %{
              "Arguments" => %{
                "QmbcLhh7kw2C25RE8Ct5XBG25QKA5HHiNkCq3zFDnSV6QG" =>
                  "QmbcLhh7kw2C25RE8Ct5XBG25QKA5HHiNkCq3zFDnSV6QG"
              },
              "Objects" => %{
                "QmbcLhh7kw2C25RE8Ct5XBG25QKA5HHiNkCq3zFDnSV6QG" => %{
                  "Hash" => "QmbcLhh7kw2C25RE8Ct5XBG25QKA5HHiNkCq3zFDnSV6QG",
                  "Links" => nil,
                  "Size" => 26368,
                  "Type" => "File"
                }
              }
            }
          }
      end)

      assert {:ok, %{"Arguments" => _arguments}} =
               Ipfs.file_ls("QmbcLhh7kw2C25RE8Ct5XBG25QKA5HHiNkCq3zFDnSV6QG")
    end

    @tag :cid_fetch
    test "invalid cid fetch" do
      Tesla.Mock.mock(fn
        %{
          method: :post,
          url:
            "http://localhost:5001/api/v0/file/ls?arg=QmbcLhh7kw2C25RE8Ct5XBG25QKA5HHiNkCq3zFDnSV6Q"
        } ->
          {:ok,
           %Tesla.Env{
             status: 400,
             body: %{
               "Code" => 0,
               "Message" =>
                 "invalid path \"QmbcLhh7kw2C25RE8Ct5XBG25QKA5HHiNkCq3zFDnSV6Q\": selected encoding not supported",
               "Type" => "error"
             }
           }}
      end)

      assert {:error, %{"Code" => 0}} =
               Ipfs.file_ls("QmbcLhh7kw2C25RE8Ct5XBG25QKA5HHiNkCq3zFDnSV6Q")
    end

    test "Error on fetching" do
      Tesla.Mock.mock(fn
        %{
          method: :post,
          url:
            "http://localhost:5001/api/v0/file/ls?arg=QmbcLhh7kw2C25RE8Ct5XBG25QKA5HHiNkCq3zFDnSV"
        } ->
          {:error, "Invalid path"}
      end)

      assert {:error, "Invalid path"} =
               Ipfs.file_ls("QmbcLhh7kw2C25RE8Ct5XBG25QKA5HHiNkCq3zFDnSV")
    end
  end
end
