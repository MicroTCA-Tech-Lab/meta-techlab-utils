DESCRIPTION = "AXI DMA demo"
LICENSE = "CLOSED"
PV = "0.9.3"
PR = "r0"

# pybind11 should be version 2.6 or higher
#  - Bitbake does not respect version specification (e.g. "(>= 2.6)")
DEPENDS = "libudmaio python3-pybind11-native (>= 2.6)"
RDEPENDS_${PN} = "libudmaio python3-pybind11 (>= 2.6) python3-bitstruct"

inherit pypi setuptools3

SRCREV = "c7fcc77fd2cf9990c77d4e0bde59c650bf71aa0d"
SRC_URI = "git://github.com/MicroTCA-Tech-Lab/libudmaio.git;protocol=https"

S="${WORKDIR}/git/pyudmaio"

