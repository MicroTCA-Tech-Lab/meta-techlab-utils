SUMMARY = "A console file manager with VI key bindings"
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://PKG-INFO;md5=1af13e76455aea2b4dee45fdf990c68a"

PYPI_PACKAGE = "ranger-fm"

inherit pypi setuptools3

SRC_URI[sha256sum] = "9476ed1971c641f4ba3dde1b8b80387f0216fcde3507426d06871f9d7189ac5e"

RDEPENDS_${PN} += "  \
    python3-pygments \
    "

FILES_${PN} += "${datadir}/*"

do_install_append() {
    # Our /usr/bin/env insists on -S for further arguments
    sed -i -e 's#!/usr/bin/env python3 -O#!/usr/bin/env -S python3 -O#g' ${D}/usr/bin/ranger
}
