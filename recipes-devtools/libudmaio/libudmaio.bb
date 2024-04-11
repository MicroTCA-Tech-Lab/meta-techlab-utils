DESCRIPTION = "Userspace DMA I/O library"
LICENSE = "BSD-3-Clause"

DEPENDS = "boost"
RDEPENDS:${PN} = "boost-log boost-program-options"

inherit pkgconfig cmake
require libudmaio-version.inc

SRC_URI = "git://github.com/MicroTCA-Tech-Lab/libudmaio.git;protocol=https;branch=${LIBUDMAIO_BRANCH}"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=e218aa5496fc02972b9c9425e527094c"

EXTRA_OECMAKE += "-DCMAKE_SKIP_RPATH=TRUE"

S="${WORKDIR}/git"

RDEPENDS:${PN} = "uio-users-group uio-users-udev-rule"
