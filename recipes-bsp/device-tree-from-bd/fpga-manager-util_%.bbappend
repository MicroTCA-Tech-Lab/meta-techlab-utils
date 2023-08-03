require pl-variants.inc

do_compile_prepend() {
    # Generate bin file for variants
    for PL_VARIANT in ${PL_VARIANTS}; do
        BITPATH=${RECIPE_SYSROOT}/boot/bitstream/variants/${PL_VARIANT}/*.bit
        VAR_DESTDIR=${XSCTH_WS}/var-${PL_VARIANT}
        mkdir -p ${VAR_DESTDIR}
        hdf=base
        generate_bin
        mv *.bit.bin_base ${VAR_DESTDIR}
    done
}

do_install_prepend() {
    if [ "${PL_VARIANTS}" != "" ]; then
        for PL_VARIANT in ${PL_VARIANTS}; do
            VAR_DESTDIR=${D}/lib/firmware/xilinx/base/${PL_VARIANT}

            # Install base hdf bin & dtbo
            # We force the binfile name to 'pl-full.bit.bin' both here and in device-tree.bbappend
            install -Dm 0644 ${XSCTH_WS}/var-${PL_VARIANT}/*.bit.bin_base ${VAR_DESTDIR}/pl-full.bit.bin
            install -Dm 0644 ${RECIPE_SYSROOT}/boot/devicetree/pl-var-${PL_VARIANT}.dtbo ${VAR_DESTDIR}/base.dtbo
        done
        return
    fi
}

# Anonymous python function is called after parsing in each BitBake task (do_...)
python () {
    make_pl_subpackages(d, lambda hdf: f'/lib/firmware/base/{hdf}/*')

    # Make sure that the main package RDEPENDS on its subpackages
    rdep = 'RDEPENDS_' + d.getVar('PN')
    d.setVar(rdep, (d.getVar(rdep) or '') + ' ' + d.getVar('SUBPKGS'))
}

DEPENDS += " bitstream-extraction external-hdf"

PL_PKG_SUFFIX ?= ""
HDF_SUFFIX ?= ""
PKG_${PN} = "${PN}${PL_PKG_SUFFIX}${HDF_SUFFIX}"
PKG_${PN}-lic = "${PN}${PL_PKG_SUFFIX}${HDF_SUFFIX}-lic"
PKG_${PN}-base = "${PN}${PL_PKG_SUFFIX}${HDF_SUFFIX}-base"
ALLOW_EMPTY_${PN}-base = "1"
PACKAGES = "${SUBPKGS} ${PN}"
