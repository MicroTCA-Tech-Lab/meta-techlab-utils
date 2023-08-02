# Helper functions to propagate values from external-hdf to bitstream-extraction and friends

def write_hdf_attr(d, attr_name, attr_val, attr_subdir=''):
    HW_PATH_W = os.path.join(d.getVar('D'), 'opt', 'xilinx', 'hw-design')
    if not attr_val:
        return
    with open(os.path.join(HW_PATH_W, attr_subdir, attr_name), 'w') as f:
        f.write(attr_val)

def read_hdf_attr(d, attr_name, attr_subdir=''):
    HW_PATH_R = os.path.join(d.getVar('RECIPE_SYSROOT'), 'opt', 'xilinx', 'hw-design')
    attr_path = os.path.join(HW_PATH_R, attr_subdir, attr_name)
    if not os.path.isfile(attr_path):
        return None
    with open(attr_path, 'r') as f:
        return f.readline().strip()

# Set variable which will change between BitBake tasks
# To suppress the "metadata is not deterministic" error, we set a constant vardepvalue
def set_var_dynamic(d, var_name, var_val_default, var_val=None):
    d.setVar(var_name, var_val or var_val_default)
    d.setVarFlag(var_name, 'vardepvalue', var_val_default)

# Create subpackages according to PL_VARIANTS and their versions
# Called by consumers of PL_VARIANTS (bitstream-extraction, fpga-manager-util, ...)
# The calling recipe must DEPEND on external-hdf
#
# files_str_cb: callback returning a string for FILES_ of the subpackage
#
def make_pl_subpackages(d, files_str_cb):
    if not d.getVar('PL_VARIANTS'):
        set_var_dynamic(d, 'PKGV', d.getVar('PV'), read_hdf_attr(d, 'version'))
        set_var_dynamic(d, 'HDF_SUFFIX', '', read_hdf_attr(d, 'hdf-suffix'))
        d.setVar('SUBPKGS', '')
        return

    subpkgs = []
    pn, ps, pv = d.getVar('PN'), (d.getVar('PL_PKG_SUFFIX') or ''), (d.getVar('PL_VARIANTS') or '')

    for hdf in pv.split():
        # Create a subpackage for each variant
        subpkg = pn + '-' + hdf
        subpkgs.append(subpkg)
        d.setVar('PKG_' + subpkg, pn + ps + '-' + hdf)
        d.setVar('FILES_' + subpkg, files_str_cb(hdf))

        ver_str_default = d.getVar('PKGV') # Use top level package version (PKGV) as default
        ver_str = read_hdf_attr(d, 'version', hdf)

        set_var_dynamic(d, 'PKGV_' + subpkg, ver_str_default, ver_str)

    set_var_dynamic(d, 'SUBPKGS', '', ' '.join(subpkgs))
