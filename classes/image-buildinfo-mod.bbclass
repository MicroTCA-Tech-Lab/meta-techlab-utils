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
def mod_get_metadata_git_branch(path):
    import bb.process

    try:
        rev, _ = bb.process.run('git -c safe.directory="*" rev-parse --abbrev-ref HEAD', cwd=path)
    except bb.process.ExecutionError:
        rev = '<unknown>'
    return rev.strip()

def mod_get_metadata_git_revision(path):
    import bb.process

    try:
        rev, _ = bb.process.run('git -c safe.directory="*" rev-parse HEAD', cwd=path)
    except bb.process.ExecutionError:
        rev = '<unknown>'
    return rev.strip()

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
def get_layer_git_status(path):
    import subprocess
    try:
        subprocess.check_output("""cd %s; export PSEUDO_UNLOAD=1; set -e;
                                git diff --quiet --no-ext-diff
                                git diff --quiet --no-ext-diff --cached""" % path,
                                shell=True,
                                stderr=subprocess.STDOUT)
        return ""
    except subprocess.CalledProcessError as ex:
        # Silently treat errors as "modified", without checking for the
        # (expected) return code 1 in a modified git repo. For example, we get
        # output and a 129 return code when a layer isn't a git repo at all.
        return "-- modified"

# Returns layer revisions along with their respective status
def get_layer_revs(d):
    layers = (d.getVar("BBLAYERS") or "").split()
    name_branch_rev_stat = [
        (
            os.path.basename(l),
            mod_get_metadata_git_branch(l).strip(),
            mod_get_metadata_git_revision(l),
            get_layer_git_status(l)
        )
        for l in layers
    ]
    name_pad = max(len(n[0]) for n in name_branch_rev_stat)
    medadata_revs = ["%s = %s:%s %s" %
    (
        s[0].ljust(name_pad),
        s[1], s[2], s[3]
    )
    for s in name_branch_rev_stat]
    return '\n'.join(medadata_revs)

def buildinfo_target(d):
        # Get context
        if d.getVar('BB_WORKERCONTEXT') != '1':
                return ""
        # Single and list variables to be read
        vars = (d.getVar("IMAGE_BUILDINFO_VARS") or "")
        return image_buildinfo_outputvars(vars, d)

# Write build information to target filesystem
python buildinfo () {
    if not d.getVar('IMAGE_BUILDINFO_FILE'):
        return
    with open(d.expand('${IMAGE_ROOTFS}${IMAGE_BUILDINFO_FILE}'), 'w') as build:
        build.writelines((
            '''-----------------------
Build Configuration:  |
-----------------------
''',
            buildinfo_target(d),
            '''
-----------------------
Layer Revisions:      |
-----------------------
''',
            get_layer_revs(d),
            '''
'''
       ))
}

IMAGE_PREPROCESS_COMMAND += "buildinfo;"
