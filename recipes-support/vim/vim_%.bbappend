# For headless setups (w/o X11), remove vim's gtk/x11 dependency introduced by Petalinux

PACKAGECONFIG_remove = "${@bb.utils.contains('DISTRO_FEATURES', 'x11', '', 'gtkgui x11', d)}"
