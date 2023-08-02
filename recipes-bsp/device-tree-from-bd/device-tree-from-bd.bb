require pl-variants.inc

DESCRIPTION = "Crate device tree nodes from Xilinx Block Diagram"
SECTION = "bsp"
LICENSE="CLOSED"

inherit xsctbase

# copied from fpga-manager-util_1.0.bb
require recipes-bsp/device-tree/device-tree.inc

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

PV = "xilinx+git${SRCPV}"

# custom part

# This package is specific to the actual board
PACKAGE_ARCH = "${MACHINE_ARCH}"

DT_FROM_BD_DTS_FILENAME ?= "app_from_bd.dts"

SRC_URI_append = " \
    file://gen_dt_from_bd.tcl \
"

XSCTH_SCRIPT = "${WORKDIR}/gen_dt_from_bd.tcl"
XSCTH_OVL = "${@' -overlay 1' if d.getVar('FPGA_MNGR_RECONFIG_ENABLE') == '1' else ''}"
XSCTH_MISC = "-out_dts ${DT_FROM_BD_DTS_FILENAME} ${XSCTH_OVL}"

dts_from_xsa() {
    XSA_PATH=$1
    PL_VARIANT=$2

    # Copied / adapted from xsctbase.bbclass
    if [ -d "${S}/patches" ]; then
        rm -rf ${S}/patches
    fi
    if [ -d "${S}/.pc" ]; then
        rm -rf ${S}/.pc
    fi

    export MISC_ARG="-out_dts app_from_bd_${PL_VARIANT}.dts ${XSCTH_OVL}"

    if [ -n "${XSCTH_APP}" ]; then
        export APP_ARG=' -app "${XSCTH_APP}"'
    fi

    echo "MISC_ARG is ${MISC_ARG}"
    echo "APP_ARG is ${APP_ARG}"

    VAR_HW_ARG="-processor_ip ${XSCTH_PROC_IP} -hdf ${XSA_PATH} -arch ${XSCTH_ARCH}"

    echo "Using xsct from: $(which xsct)"
    echo "cmd is: xsct -sdx -nodisp ${XSCTH_SCRIPT} ${PROJ_ARG} ${VAR_HW_ARG} ${APP_ARG} ${MISC_ARG}"

    eval xsct -sdx -nodisp ${XSCTH_SCRIPT} ${PROJ_ARG} ${VAR_HW_ARG} ${APP_ARG} ${MISC_ARG}
}

do_configure_append() {
    # Support multiple PL variants in one single Yocto image.

    HW_DESIGNS=${RECIPE_SYSROOT}/opt/xilinx/hw-design
    for PL_VARIANT in ${PL_VARIANTS}; do
        echo "PL_VARIANT: ${PL_VARIANT}"
        dts_from_xsa ${HW_DESIGNS}/${PL_VARIANT}/design.xsa ${PL_VARIANT}
    done
}

do_install() {
    install -d ${D}/opt/mtca-tech-lab/dt
    install -m 0644 ${B}/dts_app/${DT_FROM_BD_DTS_FILENAME} ${D}/opt/mtca-tech-lab/dt/
    for PL_VARIANT in ${PL_VARIANTS}; do
        install -m 0644 ${B}/dts_app/app_from_bd_${PL_VARIANT}.dts ${D}/opt/mtca-tech-lab/dt/
    done
}

# Anonymous python function is called after parsing in each BitBake task (do_...)
python () {
    make_pl_subpackages(d, lambda hdf: f'/opt/mtca-tech-lab/dt/app_from_bd_{hdf}.dts')
}

FILES_${PN} = "/opt/mtca-tech-lab/dt/${DT_FROM_BD_DTS_FILENAME}"

SYSROOT_DIRS_append = "/opt/mtca-tech-lab"

# for .xsa files
DEPENDS += " external-hdf"

PL_PKG_SUFFIX ?= ""
HDF_SUFFIX ?= ""
PKG_${PN} = "${PN}${PL_PKG_SUFFIX}${HDF_SUFFIX}"
PKG_${PN}-lic = "${PN}${PL_PKG_SUFFIX}${HDF_SUFFIX}-lic"
PACKAGES = "${SUBPKGS} ${PN}"
