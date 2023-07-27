# Create subpackages according to PL_VARIANTS and their versions
# Called by consumers of PL_VARIANTS (bitstream-extraction, fpga-manager-util, ...)
# The calling recipe must DEPEND on external-hdf
#
# files_str_cb: callback returning a string for FILES_ of the subpackage
#
def make_pl_subpackages(d, files_str_cb):
    if d.getVar('FPGA_MNGR_RECONFIG_ENABLE') != '1':
        return

    subpkgs = []
    pn, ps = d.getVar('PN'), d.getVar('PKG_SUFFIX')
    hw_path = os.path.join(d.getVar('RECIPE_SYSROOT'), 'opt', 'xilinx', 'hw-design')

    for hdf in d.getVar('PL_VARIANTS').split():
        # Create a subpackage for each variant
        subpkg = pn + '-' + hdf
        subpkgs.append(subpkg)
        d.setVar('PKG_' + subpkg, pn + ps + '-' + hdf)
        d.setVar('FILES_' + subpkg, files_str_cb(hdf))

        # Determine version for subpackage, which will change between BitBake tasks
        # To suppress the "metadata is not deterministic" error, we set a constant vardepvalue
        ver_str, ver_str_default = None, d.getVar('PKGV') # Use top level package version (PKGV) as default
        ver_path = os.path.join(hw_path, hdf, 'version')
        if os.path.isfile(ver_path):
            with open(ver_path, 'r') as f:
                ver_str = f.readline().strip()

        d.setVar('PKGV_' + subpkg, ver_str or ver_str_default)
        d.setVarFlag('PKGV_' + subpkg, 'vardepvalue', ver_str_default)

    d.setVar('SUBPKGS', ' '.join(subpkgs))
