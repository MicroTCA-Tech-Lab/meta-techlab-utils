DESCRIPTION = "IPython-enabled pdb"
HOMEPAGE = "https://github.com/gotcha/ipdb"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://COPYING.txt;md5=ce5277785b5e90142013c37baa935b20"

SRC_URI[sha256sum] = "c85398b5fb82f82399fc38c44fe3532c0dde1754abee727d8f5cfcc74547b334"

PYPI_PACKAGE = "ipdb"

inherit pypi setuptools3

# CLEANBROKEN = "1"

RDEPENDS_${PN} += "python3-ipython"

