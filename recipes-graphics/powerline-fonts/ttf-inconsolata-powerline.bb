require recipes-graphics/ttf-fonts/ttf.inc

SUMMARY = "Inconsolata for Powerline"
LICENSE = "OFL"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=bc4611721f8e99627b95bd8c2ab0de67"
PR = "r0"

SRC_URI = "git://github.com/powerline/fonts.git"
SRCREV = "e80e3eba9091dac0655a0a77472e10f53e754bb0"

S = "${WORKDIR}/git/Inconsolata"

PACKAGES = "ttf-inconsolata-powerline"
FONT_PACKAGES = "ttf-inconsolata-powerline"

FILES:${PN} += "${datadir}/fonts/truetype/*.ttf"
