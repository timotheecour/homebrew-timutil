class Rpclib < Formula
  desc "TODO"
  homepage "https://github.com/rpclib/rpclib"
  url "https://github.com/rpclib/rpclib",
    :tag => "v1.0.0"
  version "1.0.0"

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
