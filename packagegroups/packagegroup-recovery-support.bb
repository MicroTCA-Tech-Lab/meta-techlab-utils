DESCRIPTION = "Support for flash image recovery"

inherit packagegroup

FLASH_RECOVERY_SUPPORT_PACKAGES = " \
    util-linux-sfdisk               \
    util-linux-partx                \
    e2fsprogs                       \
    e2fsprogs-resize2fs             \
    parted                          \
    rsync                           \
"

RDEPENDS_${PN} = "${FLASH_RECOVERY_SUPPORT_PACKAGES}"
