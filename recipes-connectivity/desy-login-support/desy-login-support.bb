DESCRIPTION = "DESY login support"
SECTION = "connectivity"
LICENSE = "CLOSED"

PR = "r0"

SRC_URI = " \
    git://git@msktechvcs.desy.de/techlab/software/internal/desy-login-support.git;protocol=ssh \
"

SRC_URI[md5sum] = "934bd36a4a3b1e7912fdff3ae764c7b6"
SRC_URI[sha256sum] = "09810190e0cf9ebf141ad780b994fce8198098fbeca418ec51df59eb51747182"

SRCREV = "f5e664efd84ea6289bcae7e8d258293d2f0af5d1"

S = "${WORKDIR}/git"

do_install() {
    mkdir -p ${D}/etc
    cp ${B}/conf/krb5.conf ${D}/etc
}

FILES:${PN} = "               \
    /etc/krb5.conf            \
"

RDEPENDS:${PN} = "          \
    base-files              \
    pam-krb5                \
    pam-plugin-mkhomedir    \
    nss-pam-ldapd           \
    ca-certificates         \
"
