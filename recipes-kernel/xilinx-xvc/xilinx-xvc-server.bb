DESCRIPTION = "Server for Xilinx Virtual Cable"

PV = "1.1"
PR = "r1"
SRCREV="067232f9fb78972b76cd3c70c7a4c7c46b841221"

LICENSE = "CC0-1.0"
LIC_FILES_CHKSUM = "file://xvcServer.c;beginline=0;endline=7;md5=d7978666874a6ca6d8fae19fc46bb1d1"

SRC_URI = "\
  git://github.com/Xilinx/XilinxVirtualCable.git \
  file://xvc-server-service \
"

S = "${WORKDIR}/git/zynqMP/src/user"

FILES_${PN} = "\
  /opt/xilinx/xvcServer_ioctl \
  /etc/init.d/xvc-server-service \
  /etc/rc5.d/S95xvc-server-service \
"

EXTRA_OEMAKE = "'MYCC=${CC}'"
INSANE_SKIP_${PN} = "ldflags"

RDEPENDS_${PN} = "bash"

do_compile() {
  oe_runmake xvcServer_ioctl
}

do_install() {
  # init script
  install -d ${D}${sysconfdir}/init.d
  install -d ${D}${sysconfdir}/rc5.d
  install -m 0755 ${WORKDIR}/xvc-server-service  ${D}${sysconfdir}/init.d/
  ln -sf ../init.d/xvc-server-service  ${D}${sysconfdir}/rc5.d/S95xvc-server-service

  install -d ${D}/opt/xilinx/
  install -m 0755 xvcServer_ioctl ${D}/opt/xilinx/
}
