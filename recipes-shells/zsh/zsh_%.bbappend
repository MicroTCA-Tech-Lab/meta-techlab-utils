# Enable dynamic zsh modules (some modules that oh-my-zsh depends on cannot be statically linked)
EXTRA_OECONF:remove += " --disable-dynamic"
EXTRA_OECONF:append += " --enable-dynamic"

# Raise alternatives priority for zsh
ALTERNATIVE_PRIORITY = "110"

# do_install:prepend() {
# Save dynamic modules & functions from being deleted by the original recipe
#    mkdir -p ${D}/usr/share_saved
#    ln -s ${D}/usr/share_saved ${D}/usr/share
#}

#do_install:append() {
# Restore dynamic modules & functions
#    mv ${D}/usr/share_saved ${D}/usr/share
#}

# Depend on base-files to make sure we can append zsh to /etc/shells
RDEPENDS:${PN} = "          \
    base-files              \
"

# To set zsh as default shell:
# Either put this into the image recipe:
#   inherit extrausers
#   EXTRA_USERS_PARAMS = "usermod -s /bin/zsh root"
# or this into the local.conf:
#   INHERIT += "extrausers"
#   EXTRA_USERS_PARAMS = "usermod -s /bin/zsh root"
