DESCRIPTION = "Crate device tree nodes from Xilinx Block Diagram"
SECTION = "bsp"
LICENSE="CLOSED"

inherit xsctbase

# copied from fpga-manager-util_1.0.bb
REPO ??= "git://github.com/xilinx/device-tree-xlnx.git;protocol=https"
BRANCH ??= "master"
BRANCHARG = "${@['nobranch=1', 'branch=${BRANCH}'][d.getVar('BRANCH') != '']}"
SRC_URI = "${REPO};${BRANCHARG}"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

SRCREV ??= "bc8445833318e9320bf485ea125921eecc3dc97a"
PV = "xilinx+git${SRCPV}"

# custom part

DT_FROM_BD_DTS_FILENAME ?= "app_from_bd.dts"

SRC_URI_append = " \
    file://gen_dt_from_bd.tcl \
"

XSCTH_SCRIPT = "${WORKDIR}/gen_dt_from_bd.tcl"
XSCTH_MISC = "-out_dts ${DT_FROM_BD_DTS_FILENAME} ${@' -overlay 1' if d.getVar('FPGA_MNGR_RECONFIG_ENABLE') == '1' else ''}"

do_install() {
    install -d ${D}/opt/mtca-tech-lab/dt
    install -m 0644 ${B}/dts_app/${DT_FROM_BD_DTS_FILENAME} ${D}/opt/mtca-tech-lab/dt/
}

FILES_${PN} = "/opt/mtca-tech-lab/dt/${DT_FROM_BD_DTS_FILENAME}"

SYSROOT_DIRS_append = "/opt/mtca-tech-lab"
