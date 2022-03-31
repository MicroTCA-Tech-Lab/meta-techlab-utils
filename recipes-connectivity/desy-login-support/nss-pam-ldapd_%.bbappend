# Override nslcd.conf & ldap.conf from upstream recipe
# Point to DESY LDAP servers

SRC_URI_append = " \
    git://git@msktechvcs.desy.de/huesmann/desy-login-support.git;protocol=ssh \
"
SRCREV = "f5e664efd84ea6289bcae7e8d258293d2f0af5d1"

do_install_append() {
    cp ${WORKDIR}/git/conf/ldap.conf ${D}/etc/ldap.conf
    cp ${WORKDIR}/git/conf/nslcd.conf ${D}/etc/nslcd.conf
}
