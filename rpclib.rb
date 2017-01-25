class Rpclib < Formula
  desc "TODO"
  homepage "https://github.com/rpclib/rpclib"

  stable do
    url "https://github.com/rpclib/rpclib.git"
    #url "https://github.com/rpclib/rpclib.git",
    #    :tag => "v1.0.0"
      #CHECKME
      #:revision => "6bd588b3a570e3a9cd9cdd28a21b299387fe982d174ea1d8f47756d62c582b9f"
    revision 2
    version "1.0.0"
  end

  depends_on "cmake" => :build

  def install
    #args = ["-DINSTALL_EXTRA_LIBS=ON", "-DBUILD_UNIT_TESTS=OFF"]
    args = []
    system "cmake", *args
    system "make"
    system "make", "install"

    # system "./configure", "--prefix=#{prefix}"
    # system "make", "install"

  end
end
