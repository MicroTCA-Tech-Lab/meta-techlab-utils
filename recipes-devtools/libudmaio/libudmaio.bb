DESCRIPTION = "Userspace DMA I/O library"
LICENSE = "CLOSED"
PV = "0.9.3"
PR = "r0"

DEPENDS = "boost"
RDEPENDS_${PN} = "boost-log boost-program-options"

inherit pkgconfig cmake

SRCREV = "c7fcc77fd2cf9990c77d4e0bde59c650bf71aa0d"
SRC_URI = "git://github.com/MicroTCA-Tech-Lab/libudmaio.git;protocol=https"

EXTRA_OECMAKE += "-DCMAKE_SKIP_RPATH=TRUE"

S="${WORKDIR}/git"

RDEPENDS_${PN} = "uio-users-group uio-users-udev-rule"
