# Override pam.d files from upstream recipe
# Use pam_krb5 & pam_mkhomedir

FILESEXTRAPATHS_prepend := "${@bb.utils.contains('DISTRO_FEATURES', 'desy-login-support', '${THISDIR}/files:', '' ,d)}"
