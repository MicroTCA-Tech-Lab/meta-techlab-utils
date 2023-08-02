require pl-variants.inc

# Different PL bitstream variants to be included in the Yocto image can be
# placed into PL_VARIANTS_DIR which must then be specified in the project-
# specific external-hdf.bbapend or in conf/local.conf.

HDF_NAME = "only-used-for-git"
HDF_EXT = "xsa"

python do_install() {
    import shutil

    hw_path = os.path.join(d.getVar('D'), 'opt', 'xilinx', 'hw-design')
    os.makedirs(hw_path, exist_ok=True)

    if d.getVar('PL_VARIANTS'):
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
                write_hdf_attr(d, 'version', var_vers, var_name)

    else:
        # Put single design from HDF_PATH
        shutil.copy(d.getVar('HDF_ABSPATH'), os.path.join(hw_path, 'design.xsa'))
        write_hdf_attr(d, 'version', d.getVar('PKGV'))
        write_hdf_attr(d, 'hdf-suffix', d.getVar('HDF_SUFFIX'))
}

do_deploy() {
# One single .xsa has to be deployed for FSBL to pick up the PS configuration
    install -d ${DEPLOYDIR}
    install -m 0644 ${HDF_ABSPATH} ${DEPLOYDIR}/Xilinx-${MACHINE}.${HDF_EXT}
}

python () {
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

    def hdf_basename(hdf_fullname):
        m = re_ver.match(hdf_fullname)
        if not m:
            return hdf_fullname
        return m.groups()[0]

    if not d.getVar('PL_VARIANTS'):
        # Resolve HDF_PATH (may contain glob) and pick up PL version/name
        hdf_path = os.path.join(d.getVar('S'), d.getVar('HDF_PATH'))
        try:
            hdf_path = sorted(Path('/').glob(hdf_path[1:]))[0]
            print(f'HDF_PATH_RESOLVED: ' + str(hdf_path))
            set_var_dynamic(d, 'HDF_ABSPATH', '', str(hdf_path))
            set_var_dynamic(d, 'HDF_SUFFIX', '', '-' + hdf_basename(hdf_path.stem))
            hdf_vers = hdf_verinfo(hdf_path.stem)
            set_var_dynamic(d, 'PKGV', 'None', hdf_vers)
        except Exception as e:
            set_var_dynamic(d, 'PKGV', 'None')
            print(f'xsa not found')
        d.setVar('SUBPKGS', '')
        return

    hdflist, hdfpath, hdfvers = d.getVar('PL_VARIANTS').split(), [], []
    src_dir = d.getVar('PL_VARIANTS_DIR')

    # Get HDF paths and versions
    print(f'hdflist: {hdflist}, src_dir: {src_dir}')
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

    # Get default variant
    print("Determining the default PL variant:")
    pl_variants_default = d.getVar('PL_VARIANTS_DEFAULT') or hdflist[0]
    d.setVar('HDF_ABSPATH', hdfpath[hdflist.index(pl_variants_default)])

    # Split into subpackages
    pn, ps = d.getVar('PN'), d.getVar('PL_PKG_SUFFIX')
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

# Can be set for unique HDF package names in package feed
# (e.g. set PL_PKG_SUFFIX to 'kaldera-ctrl', then the RPM package will be named 'external-hdf-kaldera-ctrl')
PL_PKG_SUFFIX ?= ""
HDF_SUFFIX ?= ""
PKG_${PN} = "${PN}${PL_PKG_SUFFIX}${HDF_SUFFIX}"
PKG_${PN}-lic = "${PN}${PL_PKG_SUFFIX}${HDF_SUFFIX}-lic"
PACKAGES = "${SUBPKGS} ${PN}"

FILES_${PN} += "    \
  /opt/xilinx/hw-design/version \
  /opt/xilinx/hw-design/hdf-suffix \
  /opt/xilinx/hw-design/pl-variants \
"

# Override "do_install[noexec]" from upstream
# TODO: Is this still necessary when dependencies are properly declared?
python () {
  d.delVarFlag('do_install', 'noexec')
}