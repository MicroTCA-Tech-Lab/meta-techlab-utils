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
    re_hdfname = re.compile(r'(.+)[-_][vV]?(\d+\.\d+\.\d+)(-(\d+)-g([0-9a-f]+))?')

    # Get HDF version info from filename
    # e.g. 'zu19eg_1.2.3-4-g10ba99f8.xsa'
    def hdf_verinfo(hdf_fullname):
        m = re_hdfname.match(hdf_fullname)
        if not m:
            return None
        g = m.groups() # ('zu19eg', '1.3.5', '-4-g10ba99f8', '4', '10ba99f8')
        if not all(g[2:]):
            return g[1]
        return f'{g[1]}-git0+{g[4]}'

    # Get HDF basename from filename
    def hdf_basename(hdf_fullname):
        m = re_hdfname.match(hdf_fullname)
        if not m:
            return hdf_fullname.replace('.xsa', '')
        return m.groups()[0]
    
    # Resolve single PL file pointed at by HDF_PATH (may contain glob) and pick up version/name
    def handle_single_hdf():
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

    # Find files found in src_dir matching the PL_VARIANTS; return SRC_URI string
    def src_uri_from_dir(hdf_list, src_dir):
        xsa_file_list = Path(src_dir).rglob('*.' + d.getVar('HDF_EXT'))
        return ' '.join(
            'file://' + str(xsa_path.relative_to(src_dir))
            for xsa_path in xsa_file_list
            if hdf_basename(xsa_path.stem) in hdf_list
        )

    ############################################################################################

    hdf_list = (d.getVar('PL_VARIANTS') or '').split()

    if not hdf_list:
        # Use single HDF (no PL_VARIANTS)
        return handle_single_hdf()

    # OK, we have PL_VARIANTS. If we also have PL_VARIANTS_DIR, populate the SRC_URI from it
    pl_var_dir = d.getVar('PL_VARIANTS_DIR')
    if pl_var_dir:
        d.setVar('SRC_URI', src_uri_from_dir(hdf_list, pl_var_dir))

    # Get HDF versions from filenames in the SRC_URI list:
    # 1) Get base names for all SRC_URI files that are HDF files
    base_names = [
        os.path.basename(s) for s in d.getVar('SRC_URI').split()
        if s.endswith('.' + d.getVar('HDF_EXT'))
    ]

    try:
        # Sort base names to hdf_list order
        hdf_paths = [
            next(filter(lambda b: hdf_basename(b) == h, base_names))
            for h in hdf_list
        ]
    except Exception as e:
        raise RuntimeError(f'{e}: base_names {base_names}, hdf_list {hdf_list}')

    d.setVar('PL_VARIANTS_PATHS', ' '.join(hdf_paths))

    # Get versions from file names
    hdf_vers = [hdf_verinfo(n) for n in hdf_paths]
    d.setVar('PL_VARIANTS_VERSIONS', ' '.join(v or 'None' for v in hdf_vers))

    # Get default variant
    pl_variants_default = d.getVar('PL_VARIANTS_DEFAULT') or hdf_list[0]
    d.setVar('HDF_ABSPATH', hdf_paths[hdf_list.index(pl_variants_default)])

    # Split package into subpackages
    pn, ps = d.getVar('PN'), d.getVar('PL_PKG_SUFFIX')
    subpkgs = []
    for hdf, hdf_vers in zip(hdf_list, hdf_vers):
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
