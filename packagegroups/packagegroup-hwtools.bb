DESCRIPTION = "Hardware-related tools"

inherit packagegroup

HW_TOOLS_PACKAGES = " \
    ethtool   \
    i2c-tools \
    phytool   \
    libgpiod  \
    lsuio     \
    udmabuf   \
    pyudmaio  \
"

RDEPENDS_${PN} = "${HW_TOOLS_PACKAGES}"
