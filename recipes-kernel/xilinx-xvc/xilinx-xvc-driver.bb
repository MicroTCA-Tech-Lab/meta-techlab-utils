DESCRIPTION = "Linux kernel driver for Xilinx Virtual Cable"

inherit module

PV = "1.1"
PR = "r0"
SRCREV="067232f9fb78972b76cd3c70c7a4c7c46b841221"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"


SRC_URI = "\
  git://github.com/Xilinx/XilinxVirtualCable.git \
"

S = "${WORKDIR}/git/zynqMP/src/driver"
