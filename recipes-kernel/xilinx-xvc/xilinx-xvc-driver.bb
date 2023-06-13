DESCRIPTION = "Linux kernel driver for Xilinx Virtual Cable"

inherit module

PV = "1.1"
PR = "r1"
SRCREV="a0d58e8335f969e90e544b99bb63454f8603a533"

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
