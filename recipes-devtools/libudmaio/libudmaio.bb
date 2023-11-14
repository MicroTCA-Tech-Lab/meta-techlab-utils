DESCRIPTION = "Userspace DMA I/O library"
LICENSE = "BSD"
PV = "1.3.0"
PR = "r0"

DEPENDS = "boost"
RDEPENDS:${PN} = "boost-log boost-program-options"

inherit pkgconfig cmake

SRCREV = "38d5d8a3553bac994a65823b4c8f4ef1bdcbaa10"
SRC_URI = "git://github.com/MicroTCA-Tech-Lab/libudmaio.git;protocol=https"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=e218aa5496fc02972b9c9425e527094c"

EXTRA_OECMAKE += "-DCMAKE_SKIP_RPATH=TRUE"

S="${WORKDIR}/git"

RDEPENDS:${PN} = "uio-users-group uio-users-udev-rule"
