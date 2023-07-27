require hdf-info.inc

# Different PL bitstream variants to be included in the Yocto image can be
# placed into PL_VARIANTS_DIR which must then be specified in the project-
# specific external-hdf.bbapend or in conf/local.conf.

HDF_NAME = "only-used-for-git"
HDF_EXT = "xsa"

python do_install() {
    import shutil

    hw_path = os.path.join(d.getVar('D'), 'opt', 'xilinx', 'hw-design')
    os.makedirs(hw_path, exist_ok=True)

    if d.getVar('FPGA_MNGR_RECONFIG_ENABLE') == '1':
        # Put design.xsa into subfolders for each variant
        for var_name, var_path, var_vers in zip(
            d.getVar('PL_VARIANTS').split(),
            d.getVar('PL_VARIANTS_PATHS').split(),
            d.getVar('PL_VARIANTS_VERSIONS').split()):

            var_dest = os.path.join(hw_path, var_name)
            print(f'installing {var_path} to {var_dest}')
            os.makedirs(var_dest, exist_ok=True)
            shutil.copy(var_path, os.path.join(var_dest, 'design.xsa'))

            if var_vers != 'None':
                with open(os.path.join(var_dest, 'version'), 'w') as f:
                    f.write(var_vers)

    else:
        shutil.copy(
            os.path.join(d.getVar('WORKDIR'), d.getVar('HDF_PATH')),
            os.path.join(hw_path, 'design.xsa'))
}

do_deploy() {
    # One single .xsa has to be deployed for FSBL to pick up the PS configuration
    install -d ${DEPLOYDIR}
    install -m 0644 ${WORKDIR}/${HDF_PATH} ${DEPLOYDIR}/Xilinx-${MACHINE}.${HDF_EXT}
}

# Can be set for unique HDF package names in package feed
# (e.g. set PKG_SUFFIX to 'kaldera-ctrl', then the RPM package will be named 'external-hdf-kaldera-ctrl')
PKG_SUFFIX ?= ""

python () {
    if d.getVar('FPGA_MNGR_RECONFIG_ENABLE', True) != '1':
        d.setVar('PL_VARIANTS_FILES', '')
        return

    from pathlib import Path
    import re
    re_ver = re.compile(r'(.+)[-_](\d+\.\d+\.\d+)(-(\d+)-g([0-9a-f]+))?')

    # Get HDF basename and version info from filename
    # e.g. 'zu19eg_1.2.3-4-g10ba99f8.xsa'
    def hdf_verinfo(hdf_fullname):
        m = re_ver.match(hdf_fullname)
        if not m:
            return None
        g = m.groups() # ('zu19eg', '1.3.5', '-4-g10ba99f8', '4', '10ba99f8')
        if not all(g[2:]):
            return g[1]
        return f'{g[1]}-git0+{g[4]}'

    hdflist, hdfpath, hdfvers = d.getVar('PL_VARIANTS').split(), [], []

    src_dir = d.getVar('PL_VARIANTS_DIR')

    for hdf in hdflist:
        hdf_path = next(Path(src_dir).rglob(f'{hdf}*.' + d.getVar('HDF_EXT')))
        rel_path = hdf_path.relative_to(src_dir)
        hdfpath.append(str(rel_path))
        hdfvers.append(hdf_verinfo(hdf_path.stem))
        print(f'  Using {hdf} @ {hdfpath[-1]}, vers {hdfvers[-1]}')

    # hdflist now contains the variants names; hdfpath contains full paths of the .xsa files
    d.setVar('PL_VARIANTS_PATHS', ' '.join(hdfpath))
    d.setVar('PL_VARIANTS_VERSIONS', ' '.join(v or 'None' for v in hdfvers))
    d.setVar('SRC_URI', ' '.join([f" {d.getVar('HDF_BASE')}{i}" for i in hdfpath]))

    print("Determining the default PL variant:")
    pl_variants_default = d.getVar('PL_VARIANTS_DEFAULT')
    d.setVar('HDF_PATH', hdfpath[hdflist.index(pl_variants_default)])

    # Split into subpackages
    pn, ps = d.getVar('PN', True), d.getVar('PKG_SUFFIX', True)
    subpkgs = []
    for hdf, hdf_vers in zip(hdflist, hdfvers):
        subpkg = pn + '-' + hdf
        subpkgs.append(subpkg)
        var_dest = os.path.join('/opt/xilinx/hw-design', hdf)
        d.setVar('FILES_' + subpkg, ' '.join((
            os.path.join(var_dest, 'design.xsa'),
            (os.path.join(var_dest, 'version') if hdf_vers else '')
        )))
        d.setVar('PKG_' + subpkg, pn + ps + '-' + hdf)
        if hdf_vers:
            d.setVar('PKGV_' + subpkg, hdf_vers)
    d.setVar('SUBPKGS', ' '.join(subpkgs))
}

PKG_${PN} = "${PN}${PKG_SUFFIX}"
PKG_${PN}-lic = "${PN}${PKG_SUFFIX}-lic"
PACKAGES = "${SUBPKGS} ${PN}"

FILES_${PN} += "${PL_VARIANTS_FILES}"
