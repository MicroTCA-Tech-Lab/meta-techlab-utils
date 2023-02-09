DESCRIPTION = "udmabuf(User space mappable DMA Buffer)"
LICENSE = "BSD"
PV = "4.0.0"
PR = "r0"

SRC_URI = "git://github.com/ikwzm/udmabuf.git;protocol=https"
SRCREV = "9b943d49abc9c92a464e4c71e83d1c479ebbf80e"

LIC_FILES_CHKSUM = "file://LICENSE;md5=bebf0492502927bef0741aa04d1f35f5" 

S = "${WORKDIR}/git"

inherit module

# https://lists.yoctoproject.org/pipermail/meta-intel/2018-September/005546.html
DEPENDS += "xz-native bc-native bison-native"

RPROVIDES_${PN} += " kernel-module-u-dma-buf kernel-module-u-dma-buf-mgr"
KERNEL_MODULE_AUTOLOAD += " u-dma-buf u-dma-buf-mgr"
KERNEL_MODULE_PROBECONF += "u-dma-buf"

# Copied from module.bbclass, with added CONFIG_U_DMA_BUF_MGR
module_do_compile() {
	unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
	oe_runmake KERNEL_PATH=${STAGING_KERNEL_DIR}   \
		   KERNEL_VERSION=${KERNEL_VERSION}    \
		   CC="${KERNEL_CC}" LD="${KERNEL_LD}" \
		   AR="${KERNEL_AR}" \
	           O=${STAGING_KERNEL_BUILDDIR} \
		   KBUILD_EXTRA_SYMBOLS="${KBUILD_EXTRA_SYMBOLS}" \
           CONFIG_U_DMA_BUF_MGR=m \
		   ${MAKE_TARGETS}
}
