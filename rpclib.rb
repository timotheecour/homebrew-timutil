class Rpclib < Formula
  desc "rpclib is a modern C++ msgpack-RPC server and client library"
  homepage "http://rpclib.net"
  url "https://github.com/rpclib/rpclib.git",
    #TODO: why not: "v1.0.0" instead of "1.0.0" ? (cf camlistore.rb has :tag => "0.9" but boot2docker.rb has :tag => "v0.2.0")
    :tag => "1.0.0"
    :revision => "c8144d458c2b903c5a13cc08529d5866a012d095"

  version "1.0.0"

  depends_on "cmake" => :build

  def install
    args = std_cmake_args
    system "cmake", *args
    system "make"
    system "make", "install"
  end
end
