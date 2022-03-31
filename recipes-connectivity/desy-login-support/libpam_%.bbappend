# Override pam.d files from upstream recipe
# Use pam_krb5 & pam_mkhomedir

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
