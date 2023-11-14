SUMMARY = "Add a udev rule to set the ownership of uio devices"
LICENSE = "CLOSED"
PV = "1.0"
PR = "r1"

RDEPENDS:${PN} = "uio-users-group"

SRC_URI = " \
    file://70-uio.rules \
    file://70-u-dma-buf.rules \
"

do_install () {
    install -d ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 ${WORKDIR}/70-uio.rules ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 ${WORKDIR}/70-u-dma-buf.rules ${D}${sysconfdir}/udev/rules.d/
}

FILES:${PN} += " \
    ${sysconfdir}/udev/rules.d/70-uio.rules \
    ${sysconfdir}/udev/rules.d/70-u-dma-buf.rules \
"

pkg_postinst_ontarget:${PN}() {
#!/bin/sh -e
udevadm control --reload-rules && udevadm trigger
}
