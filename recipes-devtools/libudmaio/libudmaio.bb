DESCRIPTION = "Userspace DMA I/O library"
LICENSE = "BSD"
PV = "1.3.0"
PR = "r0"

DEPENDS = "boost"
RDEPENDS_${PN} = "boost-log boost-program-options"

inherit pkgconfig cmake

SRCREV = "704810aa1e2744b53a4e356354cdedb1e8f2fed6"
SRC_URI = "git://github.com/MicroTCA-Tech-Lab/libudmaio.git;protocol=https"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=e218aa5496fc02972b9c9425e527094c"

EXTRA_OECMAKE += "-DCMAKE_SKIP_RPATH=TRUE"

S="${WORKDIR}/git"

RDEPENDS_${PN} = "uio-users-group uio-users-udev-rule"
