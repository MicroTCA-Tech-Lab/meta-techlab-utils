# Override nslcd.conf & ldap.conf of upstream recipe
# Point to DESY LDAP servers

SRC_URI:append = " \
    git://git@msktechvcs.desy.de/huesmann/desy-login-support.git;protocol=ssh \
"
SRCREV = "f5e664efd84ea6289bcae7e8d258293d2f0af5d1"

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','desy-login-support','true','false',d)}; then
        cp ${WORKDIR}/git/conf/ldap.conf ${D}/etc/ldap.conf
        cp ${WORKDIR}/git/conf/nslcd.conf ${D}/etc/nslcd.conf
    fi
}
