SUMMARY = "Add group for UIO users"
LICENSE = "CLOSED"
PV = "1.0"
PR = "r0"

inherit useradd

USERADD_PACKAGES = "${PN}"

USERADD_PARAM_${PN} = ""
GROUPADD_PARAM_${PN} = "uio_users"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
ALLOW_EMPTY_${PN} = "1"
