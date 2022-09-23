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
XSCTH_OVL = "${@' -overlay 1' if d.getVar('FPGA_MNGR_RECONFIG_ENABLE') == '1' else ''}"
XSCTH_MISC = "-out_dts ${DT_FROM_BD_DTS_FILENAME} ${XSCTH_OVL}"

do_configure_append() {
    # Support multiple FPGA variants in one single Yocto image.

    for XSA_FILE in ${DEPLOY_DIR_IMAGE}/Xilinx-${MACHINE}_*.${HDF_EXT}; do
        XSA_BASENAME=$(basename -s .xsa ${XSA_FILE})
        FPGA_VARIANT=$(echo ${XSA_BASENAME} | cut -d_ -f2)

        echo "XSA_BASENAME: ${XSA_BASENAME}"
        echo "FPGA_VARIANT: ${FPGA_VARIANT}"

        # Copied / adapted from xsctbase.bbclass
        if [ -d "${S}/patches" ]; then
            rm -rf ${S}/patches
        fi
        if [ -d "${S}/.pc" ]; then
            rm -rf ${S}/.pc
        fi

        export MISC_ARG="-out_dts app_from_bd_${FPGA_VARIANT}.dts ${XSCTH_OVL}"

        if [ -n "${XSCTH_APP}" ]; then
            export APP_ARG=' -app "${XSCTH_APP}"'
        fi

        echo "MISC_ARG is ${MISC_ARG}"
        echo "APP_ARG is ${APP_ARG}"

        VAR_HW_ARG="-processor ${XSCTH_PROC} -hdf ${XSA_FILE} -arch ${XSCTH_ARCH}"

        echo "Using xsct from: $(which xsct)"
        echo "cmd is: xsct -sdx -nodisp ${XSCTH_SCRIPT} ${PROJ_ARG} ${VAR_HW_ARG} ${APP_ARG} ${MISC_ARG}"

        eval xsct -sdx -nodisp ${XSCTH_SCRIPT} ${PROJ_ARG} ${VAR_HW_ARG} ${APP_ARG} ${MISC_ARG}
    done
}

do_install() {
    install -d ${D}/opt/mtca-tech-lab/dt
    install -m 0644 ${B}/dts_app/${DT_FROM_BD_DTS_FILENAME} ${D}/opt/mtca-tech-lab/dt/
    install -m 0644 ${B}/dts_app/app_from_bd_*.dts ${D}/opt/mtca-tech-lab/dt/
}

FILES_${PN} = "/opt/mtca-tech-lab/dt/${DT_FROM_BD_DTS_FILENAME}"
FILES_${PN} += "/opt/mtca-tech-lab/dt/app_from_bd_*.dts"

SYSROOT_DIRS_append = "/opt/mtca-tech-lab"
