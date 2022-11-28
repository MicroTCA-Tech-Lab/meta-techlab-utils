# This is a modified version of the original "image-buildinfo" class
# Recent versions of git refuse to parse the layers and abort with
# "unsafe repository ('some-repo' is owned by someone else)"
# This modified version adds a config option to avoid that error

#
# Writes build information to target filesystem on /etc/build
#
# Copyright (C) 2014 Intel Corporation
# Author: Alejandro Enedino Hernandez Samaniego <alejandro.hernandez@intel.com>
#
# Licensed under the MIT license, see COPYING.MIT for details
#
# Usage: add INHERIT += "image-buildinfo" to your conf file
#

# Modified versions of original metadata_scm functions
def run_git(cmdline, cwd):
    import bb.process
    result, _ = bb.process.run('git -c safe.directory="*" ' + cmdline, cwd=cwd)
    return result.strip()

def mod_get_metadata_git_branch(path):
    try:
        rev = run_git('rev-parse --abbrev-ref HEAD', path)
    except bb.process.ExecutionError:
        rev = '<unknown>'
    return rev

def mod_get_metadata_git_revision(path):
    try:
        rev = run_git('rev-parse HEAD', path)
    except bb.process.ExecutionError:
        rev = '<unknown>'
    return rev

# Desired variables to display 
IMAGE_BUILDINFO_VARS ?= "DISTRO DISTRO_VERSION"

# Desired location of the output file in the image.
IMAGE_BUILDINFO_FILE ??= "${sysconfdir}/build"

# From buildhistory.bbclass
def image_buildinfo_outputvars(vars, d):
    vars = vars.split()
    ret = ""
    for var in vars:
        value = d.getVar(var) or ""
        if (d.getVarFlag(var, 'type') == "list"):
            value = oe.utils.squashspaces(value)
        ret += "%s = %s\n" % (var, value)
    return ret.rstrip('\n')

# Gets git branch's status (clean or dirty)
def layer_status_modified(path):
    import subprocess
    try:
        subprocess.check_output("""cd %s; export PSEUDO_UNLOAD=1; set -e;
                                git diff --quiet --no-ext-diff
                                git diff --quiet --no-ext-diff --cached""" % path,
                                shell=True,
                                stderr=subprocess.STDOUT)
        return False
    except subprocess.CalledProcessError as ex:
        # Silently treat errors as "modified", without checking for the
        # (expected) return code 1 in a modified git repo. For example, we get
        # output and a 129 return code when a layer isn't a git repo at all.
        return True

# Returns layer revisions along with their respective status
def get_layer_revs(d):
    layers = (d.getVar("BBLAYERS") or "").split()
    name_branch_rev_stat = [
        (
            os.path.basename(l),
            mod_get_metadata_git_branch(l).strip(),
            mod_get_metadata_git_revision(l),
            layer_status_modified(l)
        )
        for l in layers
    ]
    name_pad = max(len(n[0]) for n in name_branch_rev_stat)
    medadata_revs = ["%s = %s:%s %s" %
    (
        s[0].ljust(name_pad),
        s[1], s[2], ' -- modified' if s[3] else ''
    )
    for s in name_branch_rev_stat]
    return '\n'.join(medadata_revs)

# Returns False if any layer is modified
def all_layers_clean(d):
    layers = (d.getVar("BBLAYERS") or "").split()
    return not any(layer_status_modified(l) for l in layers)

def buildinfo_target(d):
        # Get context
        if d.getVar('BB_WORKERCONTEXT') != '1':
                return ""
        # Single and list variables to be read
        vars = (d.getVar("IMAGE_BUILDINFO_VARS") or "")
        return image_buildinfo_outputvars(vars, d)


def layers_vs_pinned_mismatch(d, manifests_dir):
    import xml.etree.ElementTree as ET

    PINNED_XML = "pinned.xml"
    name_map = {'meta-poky': 'poky', 'meta-oe': 'meta-openembedded'}
    # Get pinned revs as dict
    try:
        tree = ET.parse(os.path.join(manifests_dir, PINNED_XML))
    except FileNotFoundError:
        return f'{PINNED_XML} not found'

    root = tree.getroot()
    pinned_revs = {
        e.get('name'): e.get('revision')
        for e in root if e.tag == 'project'
    }

    # Get current working revs as dict
    layers = (d.getVar("BBLAYERS") or "").split()
    layers_revs = {
        os.path.basename(l): mod_get_metadata_git_revision(l)
        for l in layers
    }

    result = '' 
    for ln, lr in layers_revs.items():
        n = ln if ln not in name_map else name_map[ln]
        if n not in pinned_revs:
            continue
        
        if lr != pinned_revs[n]:
            result += f'{n}: mismatch: {lr}, pinned {pinned_revs[n]}\n'

    return result

def image_version_info(d):
    import bb.process

    work_dir = d.getVar('WORKDIR')
    file_dir = os.path.dirname(d.getVar('FILE'))

    # no better way to find repo?
    # (we could run "repo --show-toplevel", but that works only if it's in the PATH)
    repo_dir = os.path.join(file_dir, '..', '..', '..', '..', '.repo')
    manifests_dir = os.path.join(repo_dir, 'manifests')

    # Get revision of manifests
    manifests_rev = run_git('--no-pager describe --always --tags --match=[vV]*.* --abbrev=8 --long',
                            cwd=manifests_dir).strip()
    
    m_ver_str = 'Manifest: '
    # e.g. v0.0-0-gb3d299c0
    try:
        m_version, m_num_commits, m_hash = manifests_rev.split('-')
        if m_num_commits != '0':
            m_ver_str += manifests_rev
        else:
            m_ver_str += m_version

    except ValueError:
        m_hash = manifests_rev
        m_ver_str += f'N/A ({m_hash})'

    # Check if layers have checked-in (clean) state or modified
    layers_clean = all_layers_clean(d)
    layer_status = 'Layers: ' + ('clean' if layers_clean else 'modified')

    # Check if checked-in layers have same commit SHA as the pinned manifest
    pin_mismatch = layers_vs_pinned_mismatch(d, manifests_dir)
    pin_clean = (pin_mismatch == '')

    # Image version is only available if layers are unmodified and have same SHA as pinned
    image_version = f'Image version: ' + (
        m_ver_str if pin_clean and layers_clean else 'N/A'
    )
    return '\n'.join((m_ver_str, layer_status, pin_mismatch, image_version))

# Write build information to target filesystem
python buildinfo () {
    if not d.getVar('IMAGE_BUILDINFO_FILE'):
        return
    with open(d.expand('${IMAGE_ROOTFS}${IMAGE_BUILDINFO_FILE}'), 'w') as build:
        build.writelines((
            '''************************
* Build Configuration: *
************************
''',
            buildinfo_target(d),
            '\n',
            '''
************************
* Layer Revisions:     *
************************
''',
            get_layer_revs(d),
            '\n\n',
            '''************************
* Image Version:       *
************************
''',
            image_version_info(d),
            '\n',
       ))
}

IMAGE_PREPROCESS_COMMAND += "buildinfo;"
