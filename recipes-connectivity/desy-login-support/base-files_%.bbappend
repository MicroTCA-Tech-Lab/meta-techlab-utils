# Override nsswitch.conf from upstream recipe

FILESEXTRAPATHS:prepend := "${@bb.utils.contains('DISTRO_FEATURES', 'desy-login-support', '${THISDIR}/files:', '' ,d)}"
