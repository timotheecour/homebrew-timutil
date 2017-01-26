require File.expand_path("../Requirements/cuda_requirement", __FILE__)

class Opencv3 < Formula
  desc "Open source computer vision library, version 3"
  homepage "http://opencv.org/"
  revision 4

  stable do
    url "https://github.com/opencv/opencv/archive/3.1.0.tar.gz"
    sha256 "f00b3c4f42acda07d89031a2ebb5ebe390764a133502c03a511f67b78bbd4fbf"

    resource "contrib" do
      url "https://github.com/opencv/opencv_contrib/archive/3.1.0.tar.gz"
      sha256 "ef2084bcd4c3812eb53c21fa81477d800e8ce8075b68d9dedec90fef395156e5"
    end

    patch do
      # patch fixing crash after 100s when using capturing device https://github.com/opencv/opencv/issues/5874
      # can be removed with next release
      url "https://github.com/opencv/opencv/commit/a2bda999211e8be9fbc5d40038fdfc9399de31fc.diff"
      sha256 "c1f83ec305337744455c2b09c83624a7a3710cfddef2f398bb4ac20ea16197e2"
    end

    patch do
      # patch fixes build error https://github.com/Homebrew/homebrew-science/issues/3147 when not using --without-opencl
      # can be removed with next release
      url "https://github.com/opencv/opencv/commit/c7bdbef5042dadfe032dfb5d80f9b90bec830371.diff"
      sha256 "106785f8478451575026e9bf3033e418d8509ffb93e62722701fa017dc043d91"
    end

    patch do
      # patch fixes build error when including example sources
      # can be removed with next release
      url "https://github.com/opencv/opencv/commit/cdb9c60dcb65e04e7c0bd6bef9b86841191c785a.diff"
      sha256 "a14499a8c16545cf1bb206cfe0ed8a65697100dca9b2ae5274516d1213a1a32b"
    end
  end

  bottle do
    sha256 "a09c8a723c7266f790db768d8a89c50e367071fa4c0015bdf632a94af37194fb" => :el_capitan
    sha256 "7c089cc50c50aed8a7f53096a61fe538eaec502a8d6e5be6a73f0bfa97c6bc75" => :yosemite
    sha256 "3492582fc4888a77d132a84444ff4271a4a6d8e49cb274abeb5fa6c0cc95e2df" => :mavericks
  end

  head do
    url "https://github.com/opencv/opencv.git"

    resource "contrib" do
      url "https://github.com/opencv/opencv_contrib.git"
    end
  end

  keg_only "opencv3 and opencv install many of the same files."

  deprecated_option "without-tests" => "without-test"

  option "32-bit"
  option "with-contrib", 'Build "extra" contributed modules'
  option "with-cuda", "Build with CUDA v7.0+ support"
  option "with-examples", "Install C and python examples (sources)"
  option "with-java", "Build with Java support"
  option "with-opengl", "Build with OpenGL support (must use --with-qt5)"
  option "with-quicktime", "Use QuickTime for Video I/O instead of QTKit"
  option "with-qt5", "Build the Qt5 backend to HighGUI"
  option "with-static", "Build static libraries"
  option "with-tbb", "Enable parallel code in OpenCV using Intel TBB"
  option "without-numpy", "Use a numpy you've installed yourself instead of a Homebrew-packaged numpy"
  option "without-opencl", "Disable GPU code in OpenCV using OpenCL"
  option "without-python", "Build without Python support"
  option "without-test", "Build without accuracy & performance tests"

  option :cxx11

  depends_on :ant => :build if build.with? "java"
  depends_on "cmake" => :build
  depends_on CudaRequirement => :optional
  depends_on "pkg-config" => :build

  depends_on "eigen" => :recommended
  depends_on "ffmpeg" => :optional
  depends_on "gphoto2" => :optional
  depends_on "gstreamer" => :optional
  depends_on "gst-plugins-good" if build.with? "gstreamer"
  depends_on "jasper" => :optional
  depends_on :java => :optional
  depends_on "jpeg"
  depends_on "libdc1394" => :optional
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "openexr" => :recommended
  depends_on "openni" => :optional
  depends_on "openni2" => :optional
  depends_on :python => :recommended unless OS.mac? && MacOS.version > :snow_leopard
  depends_on :python3 => :optional
  depends_on "qt5" => :optional
  depends_on "tbb" => :optional
  depends_on "vtk" => :optional

  with_python = build.with?("python") || build.with?("python3")
  pythons = build.with?("python3") ? ["with-python3"] : []
  depends_on "homebrew/python/numpy" => [:recommended] + pythons if with_python

  # dependencies use fortran, which leads to spurious messages about gcc
  cxxstdlib_check :skip

  resource "icv-macosx" do
    url "https://raw.githubusercontent.com/opencv/opencv_3rdparty/81a676001ca8075ada498583e4166079e5744668/ippicv/ippicv_macosx_20151201.tgz", :using => :nounzip
    sha256 "8a067e3e026195ea3ee5cda836f25231abb95b82b7aa25f0d585dc27b06c3630"
  end

  resource "icv-linux" do
    url "https://raw.githubusercontent.com/opencv/opencv_3rdparty/81a676001ca8075ada498583e4166079e5744668/ippicv/ippicv_linux_20151201.tgz", :using => :nounzip
    sha256 "4333833e40afaa22c804169e44f9a63e357e21476b765a5683bcb3760107f0da"
  end

  def arg_switch(opt)
    (build.with? opt) ? "ON" : "OFF"
  end

  def install
    ENV.cxx11 if build.cxx11?
    jpeg = Formula["jpeg"]
    dylib = OS.mac? ? "dylib" : "so"
    with_qt = build.with?("qt5")

    args = std_cmake_args + %W[
      -DBUILD_JASPER=OFF
      -DBUILD_JPEG=OFF
      -DBUILD_TIFF=OFF
      -DBUILD_OPENEXR=OFF
      -DBUILD_PNG=OFF
      -DBUILD_ZLIB=OFF
      -DCMAKE_OSX_DEPLOYMENT_TARGET=
      -DJPEG_INCLUDE_DIR=#{jpeg.opt_include}
      -DJPEG_LIBRARY=#{jpeg.opt_lib}/libjpeg.#{dylib}
    ]
    args << "-DBUILD_opencv_java=" + arg_switch("java")
    args << "-DBUILD_opencv_python2=" + arg_switch("python")
    args << "-DBUILD_opencv_python3=" + arg_switch("python3")
    args << "-DBUILD_TESTS=OFF" << "-DBUILD_PERF_TESTS=OFF" if build.without? "tests"
    args << "-DWITH_1394=" + arg_switch("libdc1394")
    args << "-DWITH_EIGEN=" + arg_switch("eigen")
    args << "-DWITH_FFMPEG=" + arg_switch("ffmpeg")
    args << "-DWITH_GPHOTO2=" + arg_switch("gphoto2")
    args << "-DWITH_GSTREAMER=" + arg_switch("gstreamer")
    args << "-DWITH_JASPER=" + arg_switch("jasper")
    args << "-DWITH_OPENEXR=" + arg_switch("openexr")
    args << "-DWITH_OPENGL=" + arg_switch("opengl")
    args << "-DWITH_QUICKTIME=" + arg_switch("quicktime")
    args << "-DWITH_QT=" + (with_qt ? "ON" : "OFF")
    args << "-DWITH_TBB=" + arg_switch("tbb")
    args << "-DWITH_VTK=" + arg_switch("vtk")

    if build.include? "32-bit"
      args << "-DCMAKE_OSX_ARCHITECTURES=i386"
      args << "-DOPENCV_EXTRA_C_FLAGS='-arch i386 -m32'"
      args << "-DOPENCV_EXTRA_CXX_FLAGS='-arch i386 -m32'"
    end

    if build.with? "cuda"
      args << "-DWITH_CUDA=ON"
      args << "-DCUDA_GENERATION=Kepler"
    else
      args << "-DWITH_CUDA=OFF"
    end

    if build.with? "contrib"
      resource("contrib").stage buildpath/"opencv_contrib"
      args << "-DOPENCV_EXTRA_MODULES_PATH=#{buildpath}/opencv_contrib/modules"
    end

    if build.with? "examples"
      args << "-DINSTALL_C_EXAMPLES=ON"
      args << "-DINSTALL_PYTHON_EXAMPLES=ON"
    end

    # OpenCL 1.1 is required, but Snow Leopard and older come with 1.0
    args << "-DWITH_OPENCL=OFF" if build.without?("opencl") || MacOS.version < :lion

    if build.with? "openni"
      args << "-DWITH_OPENNI=ON"
      # Set proper path for Homebrew's openni
      inreplace "cmake/OpenCVFindOpenNI.cmake" do |s|
        s.gsub! "/usr/include/ni", "#{Formula["openni"].opt_include}/ni"
        s.gsub! "/usr/lib", Formula["openni"].opt_lib
      end
    end

    if build.with? "openni2"
      args << "-DWITH_OPENNI2=ON"
      ENV["OPENNI2_INCLUDE"] ||= "#{Formula["openni2"].opt_include}/ni2"
      ENV["OPENNI2_REDIST"] ||= "#{Formula["openni2"].opt_lib}/ni2"
    end

    if build.with? "python"
      py_prefix = `python-config --prefix`.chomp
      py_lib = "#{py_prefix}/lib"
      args << "-DPYTHON2_EXECUTABLE=#{which "python"}"
      args << "-DPYTHON2_LIBRARY=#{py_lib}/libpython2.7.#{dylib}"
      args << "-DPYTHON2_INCLUDE_DIR=#{py_prefix}/include/python2.7"
    end

    if build.with? "python3"
      py3_config = `python3-config --configdir`.chomp
      py3_include = `python3 -c "import distutils.sysconfig as s; print(s.get_python_inc())"`.chomp
      py3_version = Language::Python.major_minor_version "python3"
      args << "-DPYTHON3_LIBRARY=#{py3_config}/libpython#{py3_version}.#{dylib}"
      args << "-DPYTHON3_INCLUDE_DIR=#{py3_include}"
    end

    args << "-DBUILD_SHARED_LIBS=OFF" if build.with?("static")

    if ENV.compiler == :clang && !build.bottle?
      args << "-DENABLE_SSSE3=ON" if Hardware::CPU.ssse3?
      args << "-DENABLE_SSE41=ON" if Hardware::CPU.sse4?
      args << "-DENABLE_SSE42=ON" if Hardware::CPU.sse4_2?
      args << "-DENABLE_AVX=ON" if Hardware::CPU.avx?
    end

    inreplace buildpath/"3rdparty/ippicv/downloader.cmake",
      "${OPENCV_ICV_PLATFORM}-${OPENCV_ICV_PACKAGE_HASH}",
      "${OPENCV_ICV_PLATFORM}"
    platform = OS.mac? ? "macosx" : "linux"
    resource("icv-#{platform}").stage buildpath/"3rdparty/ippicv/downloads/#{platform}"

    mkdir "macbuild" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <opencv/cv.h>
      #include <iostream>
      int main()
      {
        std::cout << CV_VERSION << std::endl;
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}", "-L#{lib}", "-o", "test"
    assert_equal `./test`.strip, version.to_s

    ENV["PYTHONPATH"] = lib/"python2.7/site-packages"
    assert_match version.to_s, shell_output("python -c 'import cv2; print(cv2.__version__)'")
  end
end
