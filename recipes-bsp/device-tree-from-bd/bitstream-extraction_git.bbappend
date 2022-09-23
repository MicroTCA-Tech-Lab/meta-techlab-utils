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

        export MISC_ARG="-hwpname ${XSCTH_PROJ}_${FPGA_VARIANT}_hwproj -hdf_type ${HDF_EXT}"
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

do_install_append() {
    for HWPROJ_VAR in ${XSCTH_WS}/${XSCTH_PROJ}_*_hwproj; do
        echo $HWPROJ_VAR
        HWPROJ_BASENAME=$(basename ${HWPROJ_VAR})
        FPGA_VARIANT=$(echo ${HWPROJ_BASENAME} | cut -d_ -f2)
        if [ -e ${HWPROJ_VAR}/*.bit ]; then
            install -d ${D}/boot/bitstream_${FPGA_VARIANT}
            install -Dm 0644 ${HWPROJ_VAR}/*.bit ${D}/boot/bitstream_${FPGA_VARIANT}
        fi
    done
}

FILES_${PN} += "/boot/bitstream_*/*.bit"
