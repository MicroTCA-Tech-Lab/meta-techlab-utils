DESCRIPTION = "DESY login support"
SECTION = "connectivity"
LICENSE = "CLOSED"

PR = "r0"

SRC_URI = "git://git@msktechvcs.desy.de/huesmann/desy-login-support.git;protocol=ssh"

SRC_URI[md5sum] = "934bd36a4a3b1e7912fdff3ae764c7b6"
SRC_URI[sha256sum] = "09810190e0cf9ebf141ad780b994fce8198098fbeca418ec51df59eb51747182"

SRCREV = "fedbc4c656232672414cdaa65c28b3a905627e4c"

S = "${WORKDIR}/git"

do_install() {
    OMZ_DIR=${D}/usr/local/oh-my-zsh
    mkdir -p ${D}/etc/ldap
    cp ${B}/conf/ldap.conf ${D}/etc/ldap
    cp ${B}/conf/krb5.conf ${D}/etc
    cp ${B}/conf/nslcd.conf ${D}/etc/nslcd.desy.conf
}

pkg_postinst_${PN} () {
    grep -q "passwd.*ldap" $D${sysconfdir}/nsswitch.conf || sed -i "s/^\(passwd.*\)$/\1 ldap/g" $D${sysconfdir}/nsswitch.conf

    PAM_CONF=$D${sysconfdir}/pam.d
#    grep -q "pam_krb5" ${PAM_CONF}/common-account  || echo "account required pam_krb5.so minimum_uid=1000" >> ${PAM_CONF}/common-account
#    grep -q "pam_krb5" ${PAM_CONF}/common-auth     || echo "auth [success=3 default=ignore] pam_krb5.so minimum_uid=1000" >> ${PAM_CONF}/common-auth
#    grep -q "pam_krb5" ${PAM_CONF}/common-password || echo "password [success=3 default=ignore] pam_krb5.so minimum_uid=1000 try_first_pass use_authtok" >> ${PAM_CONF}/common-password
#    grep -q "pam_krb5" ${PAM_CONF}/common-session  || echo "session optional pam_krb5.so minimum_uid=1000" >> ${PAM_CONF}/common-session
#    grep -q "pam_krb5" ${PAM_CONF}/common-session-noninteractive || echo "session optional pam_krb5.so minimum_uid=1000" >> ${PAM_CONF}/common-session-noninteractive
#    grep -q "pam_mkhomedir" ${PAM_CONF}/common-session           || echo "session optional pam_mkhomedir.so" >> ${PAM_CONF}/common-session
    mv $D${sysconfdir}/nslcd.desy.conf $D${sysconfdir}/nslcd.conf
}

FILES_${PN} = "/etc/ldap/ldap.conf /etc/krb5.conf /etc/nslcd.desy.conf"
RDEPENDS_${PN} = "pam-krb5 pam-plugin-mkhomedir nss-pam-ldapd"
