SUMMARY = "Add group for UIO users"
LICENSE = "CLOSED"
PV = "1.0"
PR = "r0"

inherit useradd

USERADD_PACKAGES = "${PN}"

USERADD_PARAM:${PN} = ""
GROUPADD_PARAM:${PN} = "uio_users"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
ALLOW_EMPTY:${PN} = "1"
