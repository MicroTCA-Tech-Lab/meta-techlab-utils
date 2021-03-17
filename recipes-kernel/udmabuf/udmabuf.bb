CRIPTION = "udmabuf(User space mappable DMA Buffer)"
LICENSE = "BSD"
PV = "3.2.2"
PR = "r0"

SRC_URI = "git://github.com/ikwzm/udmabuf.git;tag=v${PV}"

LIC_FILES_CHKSUM = "file://LICENSE;md5=bebf0492502927bef0741aa04d1f35f5" 

S = "${WORKDIR}/git"

inherit module

# https://lists.yoctoproject.org/pipermail/meta-intel/2018-September/005546.html
DEPENDS += "xz-native bc-native bison-native"

# patches
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append = " file://0001-Update-Makefile-for-Yocto-env-variables.patch \
    file://udmabuf.sh \
"

FILES_${PN} = " \
    /lib \
    /lib/modules \
    /lib/modules/5.4.0-xilinx-v2020.1 \
    /lib/modules/5.4.0-xilinx-v2020.1/extra \
    /lib/modules/5.4.0-xilinx-v2020.1/extra/u-dma-buf.ko \
    ${sysconfdir}/rcS.d/S80udmabuf \
    ${sysconfdir}/init.d/udmabuf.sh \
"

RPROVIDES_${PN} += "kernel-module-u-dma-buf-5.4.0-xilinx-v2020.1"

do_install_append() {
    install -d ${D}${sysconfdir}/init.d
    install -d ${D}${sysconfdir}/rcS.d

    install -m 0755 ${WORKDIR}/udmabuf.sh  ${D}${sysconfdir}/init.d/

    ln -sf ../init.d/udmabuf.sh  ${D}${sysconfdir}/rcS.d/S80udmabuf
}
