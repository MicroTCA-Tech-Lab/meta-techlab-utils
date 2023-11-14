require recipes-graphics/ttf-fonts/ttf.inc

SUMMARY = "Liberation Mono Powerline"
LICENSE = "OFL"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=07289bf524c9c68a93aafaff680104aa"
PR = "r0"

SRC_URI = "git://github.com/powerline/fonts.git"
SRCREV = "e80e3eba9091dac0655a0a77472e10f53e754bb0"

S = "${WORKDIR}/git/LiberationMono"

PACKAGES = "ttf-liberation-powerline"
FONT_PACKAGES = "ttf-liberation-powerline"

FILES:${PN} += "${datadir}/fonts/truetype/*.ttf"
