DESCRIPTION = "Support for flash image recovery"

inherit packagegroup

FLASH_RECOVERY_SUPPORT_PACKAGES = " \
    util-linux-sfdisk               \
    util-linux-partx                \
    e2fsprogs                       \
    rsync                           \
"

RDEPENDS_${PN} = "${FLASH_RECOVERY_SUPPORT_PACKAGES}"
