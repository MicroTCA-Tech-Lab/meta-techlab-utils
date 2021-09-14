DESCRIPTION = "udmabuf(User space mappable DMA Buffer)"
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
"

RPROVIDES_${PN} += "kernel-module-u-dma-buf-5.4.0-xilinx-v2020.2"
KERNEL_MODULE_AUTOLOAD += "u-dma-buf"
KERNEL_MODULE_PROBECONF += " u-dma-buf "
module_conf_u-dma-buf = "options u_dma_buf udmabuf0=0x1000000"
