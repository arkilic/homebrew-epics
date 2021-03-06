# vim: ts=2 sw=2 sts=2 expandtab

require_relative './epics-base'

class EpicsAreaDetector1 < Formula
  desc "EPICS AreaDetector [R1]"
  homepage "http://cars9.uchicago.edu/software/epics/areaDetector.html"
  url "http://cars.uchicago.edu/software/pub/areaDetectorR1-9-1.tgz"
  version "1-9-1"
  sha256 "90476d41129a721daf6b5c81ac511ad06f5dd3596ef01a541fce32c11a071889"

  depends_on "graphicsmagick"
  depends_on "hdf5"
  depends_on "szip"
  depends_on "netcdf"
  depends_on "nexusformat" => ["without-hdf4"]

  depends_on "epics-base"
  depends_on "epics-asyn"
  depends_on "epics-sscan"
  depends_on "epics-calc"
  depends_on "epics-busy"
  depends_on "epics-autosave"

  def install
    ENV.deparallelize
    paths = {:ASYN=>get_package_prefix('epics-asyn'),
             :CALC=>get_package_prefix('epics-calc'),
             :SSCAN=>get_package_prefix('epics-sscan'),
             :BUSY=>get_package_prefix('epics-busy'),
             :AUTOSAVE=>get_package_prefix('epics-autosave'),
             :AREA_DETECTOR=>buildpath,
             }

    fix_epics_release_file(paths)

    # PvAPI problems (ref http://www.aps.anl.gov/epics/tech-talk/2014/msg01350.php)
    # ... screw this homebrew patch system, I can't figure it out

    # comment out all prosilica lines
    inreplace "ADApp/Makefile", /^(.*prosilica.*)$/, "# \\1"
    # and remove the support files from the plugin dependencies
    inreplace("ADApp/Makefile",
              /^# (pluginSrc_DEPEND_DIRS = .*)prosilicaSupport (.*)$/,
              "\\1 \\2")
    inreplace "ADApp/commonDriverMakefile", /^(.*PvAPI.*)$/, "# \\1"
    inreplace "ADApp/pluginSrc/Makefile", /^USR_CXXFLAGS.*-DHAVE_PVAPI$/, ""

    system("make",
           "INSTALL_LOCATION=#{prefix}",
           *get_epics_make_variables())

    wrap_epics_binaries()

    # dependency headers are somehow copied over during the install step
    FileUtils.rm Dir.glob(include/'H5*')
    FileUtils.rm Dir.glob(include/'hdf5*.h')
    FileUtils.rm Dir.glob(include/'netcdf.h')
    FileUtils.rm Dir.glob(include/'tiff*.h')
  end

  test do
    system "echo exit | simDetectorApp"
  end
end
