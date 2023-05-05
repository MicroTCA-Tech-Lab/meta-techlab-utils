do_compile_prepend() {
    if [ ${FPGA_MNGR_RECONFIG_ENABLE} = "1" ]; then
        # Generate bin file for variants
        for BITSTREAM_VAR in ${RECIPE_SYSROOT}/boot/bitstream-*/; do
            echo BITSTREAM: ${BITSTREAM_VAR}
            BITSTREAM_BASENAME=$(basename ${BITSTREAM_VAR})
            PL_VARIANT=$(echo ${BITSTREAM_BASENAME} | cut -d- -f2-)
            echo PL_VARIANT: ${PL_VARIANT}
        
            VAR_DESTDIR=${XSCTH_WS}/var-${PL_VARIANT}
            mkdir -p ${VAR_DESTDIR}
            cp ${RECIPE_SYSROOT}/boot/devicetree/pl-var-${PL_VARIANT}.dtbo ${VAR_DESTDIR}/base.dtbo

            BITPATH=${BITSTREAM_VAR}/*.bit
            hdf=base
            generate_bin
            mv *.bit.bin_base ${VAR_DESTDIR}
        done
    fi
}

# disable upstream do_install()
# FIXME: Don't override this if FPGA_MNGR_RECONFIG_ENABLE not set
do_install() {
    if [ ${FPGA_MNGR_RECONFIG_ENABLE} = "1" ]; then
        for VARIANT_DIR in ${XSCTH_WS}/var-*/; do
            echo VARIANT_DIR: ${VARIANT_DIR}
            PL_VARIANT=$(echo $(basename ${VARIANT_DIR}) | cut -d- -f2-)
            echo PL_VARIANT: ${PL_VARIANT}
        
            VAR_DESTDIR=${D}/lib/firmware/base/${PL_VARIANT}

            # Install base hdf bin & dtbo
            newname=`basename -s .bin_base ${VARIANT_DIR}/*.bit.bin_base`
            install -Dm 0644 ${VARIANT_DIR}/*.bit.bin_base ${VAR_DESTDIR}/${newname}.bin
            install -Dm 0644 ${VARIANT_DIR}/base.dtbo ${VAR_DESTDIR}
        done
    fi
}

DEPENDS += " bitstream-extraction"
