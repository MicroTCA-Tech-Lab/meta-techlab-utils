DESCRIPTION = "Python bindings for Userspace DMA I/O library"
LICENSE = "BSD"
PV = "1.2.0"
PR = "r0"

# pybind11 should be version 2.6 or higher
#  - Bitbake does not respect version specification (e.g. "(>= 2.6)")
DEPENDS = "libudmaio python3-pybind11-native (>= 2.6)"
RDEPENDS_${PN} = "libudmaio python3-pybind11 (>= 2.6) python3-bitstruct"

inherit pypi setuptools3

SRCREV = "dfd24a10cb6bb0fde9f576cdfe7d5677fb492480"
SRC_URI = "git://github.com/MicroTCA-Tech-Lab/libudmaio.git;protocol=https"
LIC_FILES_CHKSUM = "file://../LICENSE.txt;md5=e218aa5496fc02972b9c9425e527094c"

S="${WORKDIR}/git/pyudmaio"

