SUMMARY = "Pygments is a syntax highlighting package written in Python"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=98419e351433ac106a24e3ad435930bc"

PYPI_PACKAGE = "Pygments"

inherit pypi setuptools3

SRC_URI[sha256sum] = "4e426f72023d88d03b2fa258de560726ce890ff3b630f88c21cbb8b2503b8c6a"

# RDEPENDS_${PN} += " \
#	"

FILES_${PN} += "${datadir}/*"
