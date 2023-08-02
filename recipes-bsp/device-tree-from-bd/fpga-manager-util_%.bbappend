require pl-variants.inc

do_compile_prepend() {
    if [ "${PL_VARIANTS}" != "" ]; then
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

do_install_prepend() {
    if [ "${PL_VARIANTS}" != "" ]; then
        for VARIANT_DIR in ${XSCTH_WS}/var-*/; do
            echo VARIANT_DIR: ${VARIANT_DIR}
            PL_VARIANT=$(echo $(basename ${VARIANT_DIR}) | cut -d- -f2-)
            echo PL_VARIANT: ${PL_VARIANT}

            VAR_DESTDIR=${D}/lib/firmware/base/${PL_VARIANT}

            # Install base hdf bin & dtbo
            # We force the binfile name to 'pl-full.bit.bin' both here and in device-tree.bbappend
            install -Dm 0644 ${VARIANT_DIR}/*.bit.bin_base ${VAR_DESTDIR}/pl-full.bit.bin
            install -Dm 0644 ${VARIANT_DIR}/base.dtbo ${VAR_DESTDIR}
        done
        return
    fi
}

# Anonymous python function is called after parsing in each BitBake task (do_...)
python () {
    make_pl_subpackages(d, lambda hdf: f'/lib/firmware/base/{hdf}/*')
}

DEPENDS += " bitstream-extraction external-hdf"

PL_PKG_SUFFIX ?= ""
HDF_SUFFIX ?= ""
PKG_${PN} = "${PN}${PL_PKG_SUFFIX}${HDF_SUFFIX}"
PKG_${PN}-lic = "${PN}${PL_PKG_SUFFIX}${HDF_SUFFIX}-lic"
PKG_${PN}-base = "${PN}${PL_PKG_SUFFIX}${HDF_SUFFIX}-base"
ALLOW_EMPTY_${PN}-base = "1"
PACKAGES = "${SUBPKGS} ${PN}"
