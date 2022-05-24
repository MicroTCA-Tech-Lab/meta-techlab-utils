DESCRIPTION = "Linux kernel driver for Xilinx Virtual Cable"

inherit module

PV = "1.1"
PR = "r1"
SRCREV="067232f9fb78972b76cd3c70c7a4c7c46b841221"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"


SRC_URI = "\
  git://github.com/Xilinx/XilinxVirtualCable.git \
"

# This also works on Zynq 7000
S = "${WORKDIR}/git/zynqMP/src/driver"

SRC_URI_append_damc-fmc1z7io = "\
  file://0001-Modify-Makefile-for-Zynq7000.patch \
"

RPROVIDES_${PN} += "kernel-module-xilinx-xvc-driver"
KERNEL_MODULE_AUTOLOAD += "xilinx_xvc_driver"
