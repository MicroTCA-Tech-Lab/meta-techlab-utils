do_compile_append() {
    # Generate bin file for variants
    for BITSTREAM_VAR in ${RECIPE_SYSROOT}/boot/bitstream_*; do
        echo BITSTREAM: ${BITSTREAM_VAR}
        BITSTREAM_BASENAME=$(basename ${BITSTREAM_VAR})
        FPGA_VARIANT=$(echo ${BITSTREAM_BASENAME} | cut -d_ -f2)
        echo FPGA_VARIANT: ${FPGA_VARIANT}
    
        cp ${RECIPE_SYSROOT}/boot/devicetree/pl_var_${FPGA_VARIANT}.dtbo ${XSCTH_WS}/ovl_${FPGA_VARIANT}.dtbo

        BITPATH=${BITSTREAM_VAR}/*.bit
        hdf=${FPGA_VARIANT}
        generate_bin
    done
}

# disable upstream do_install()
do_install() {
    for OVL_VAR in ovl_*.dtbo; do
        echo OVL: ${OVL_VAR}
        OVL_BASENAME=$(basename -s .dtbo ${OVL_VAR})
        FPGA_VARIANT=$(echo ${OVL_BASENAME} | cut -d_ -f2)
        echo FPGA_VARIANT: ${FPGA_VARIANT}
    
        # Install base hdf artifact
        install -Dm 0644 ${OVL_VAR} ${D}/lib/firmware/base/${OVL_VAR}
        install -Dm 0644 *.bit.bin_${FPGA_VARIANT} ${D}/lib/firmware/base
    done
}
