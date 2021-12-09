DESCRIPTION = "lsuio - list available UIO modules"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=94d55d512a9ba36caa9b7df079bae19f"

SRC_URI = "https://www.osadl.org/uploads/media/lsuio-${PV}.tar.gz"
SRC_URI[sha256sum] = "c88b3850248b2d3419e025abd7b9b0991c8bd33a2d4983f9608408a29900bfb5"

inherit autotools
