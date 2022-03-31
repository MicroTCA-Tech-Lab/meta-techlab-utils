# Override nsswitch.conf from upstream recipe

FILESEXTRAPATHS_prepend := "${@bb.utils.contains('DISTRO_FEATURES', 'desy-login-support', '${THISDIR}/files:', '' ,d)}"
