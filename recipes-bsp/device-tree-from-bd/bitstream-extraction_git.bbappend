bitfile_from_xsa() {
    XSA_PATH=$1
    PL_VARIANT=$2

    # Copied / adapted from xsctbase.bbclass
    if [ -d "${S}/patches" ]; then
        rm -rf ${S}/patches
    fi
    if [ -d "${S}/.pc" ]; then
        rm -rf ${S}/.pc
    fi

    export MISC_ARG="-hwpname ${XSCTH_PROJ}-${PL_VARIANT}-hwproj -hdf_type ${HDF_EXT}"
    if [ -n "${XSCTH_APP}" ]; then
        export APP_ARG=' -app "${XSCTH_APP}"'
    fi

    echo "MISC_ARG is ${MISC_ARG}"
    echo "APP_ARG is ${APP_ARG}"

    VAR_HW_ARG="-processor ${XSCTH_PROC} -hdf ${XSA_PATH} -arch ${XSCTH_ARCH}"

    echo "Using xsct from: $(which xsct)"
    echo "cmd is: xsct -sdx -nodisp ${XSCTH_SCRIPT} ${PROJ_ARG} ${VAR_HW_ARG} ${APP_ARG} ${MISC_ARG}"

    eval xsct -sdx -nodisp ${XSCTH_SCRIPT} ${PROJ_ARG} ${VAR_HW_ARG} ${APP_ARG} ${MISC_ARG}
}

do_configure_append() {
    if [ ${FPGA_MNGR_RECONFIG_ENABLE} = "1" ]; then
        # Support multiple PL variants in one single Yocto image.
        HW_DESIGNS=${RECIPE_SYSROOT}/opt/xilinx/hw-design
        for PL_VARIANT in $(cat ${HW_DESIGNS}/pl-variants); do
            echo "PL_VARIANT: ${PL_VARIANT}"
            bitfile_from_xsa ${HW_DESIGNS}/${PL_VARIANT}/design.xsa ${PL_VARIANT}
        done
    fi
}

do_install_append() {
    if [ ${FPGA_MNGR_RECONFIG_ENABLE} = "1" ]; then
        HW_DESIGNS=${RECIPE_SYSROOT}/opt/xilinx/hw-design
        for PL_VARIANT in $(cat ${HW_DESIGNS}/pl-variants); do
            HWPROJ_VAR=${XSCTH_WS}/${XSCTH_PROJ}-${PL_VARIANT}-hwproj;
            echo HWPROJ: "${HWPROJ_VAR}"

            install -d ${D}/boot/bitstream-${PL_VARIANT}
            install -Dm 0644 ${HWPROJ_VAR}/*.bit ${D}/boot/bitstream-${PL_VARIANT}
        done
    fi
}

FILES_${PN} += "/boot/bitstream-*/*.bit"

# for .xsa files
DEPENDS += " external-hdf"
