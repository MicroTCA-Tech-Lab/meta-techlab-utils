SUMMARY = "Kerberos PAM module for either MIT Kerberos or Heimdal"
SECTION = "connectivity"
HOMEPAGE = "https://www.eyrie.org/~eagle/software/pam-krb5"

LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a03bfa27d91da14863a7027f861df764"

SRC_URI = "https://archives.eyrie.org/software/kerberos/pam-krb5-4.11.tar.gz"

SRC_URI[md5sum] = "5cd8fa5abf76a6a7aaffcd3ee16c640f"
SRC_URI[sha256sum] = "503cbe2cb1aff4bdfda3bcf7f93f94fb6ba52c26d708934e7039b2182fe10b20"

DEPENDS = "libpam krb5"

inherit features_check
REQUIRED_DISTRO_FEATURES = "pam"

inherit autotools

EXTRA_OECONF = "--libdir=${base_libdir}"

FILES_${PN} += "${base_libdir}/security/pam_krb5.so"
