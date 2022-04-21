# Override pam.d files from upstream recipe
# Use pam_krb5 & pam_mkhomedir

FILESEXTRAPATHS_prepend := "${@bb.utils.contains('DISTRO_FEATURES', 'desy-login-support', '${THISDIR}/files:', '' ,d)}"

GROUP_CONF_PATCH = "                                     \
    file://0001-Add-logged-in-users-to-sudo-group.patch  \
"

SRC_URI_append = "${@bb.utils.contains('DISTRO_FEATURES', 'desy-login-support', '${GROUP_CONF_PATCH}', '' ,d)}"
