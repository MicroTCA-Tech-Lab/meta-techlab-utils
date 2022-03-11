# Enable dynamic zsh modules (some modules that oh-my-zsh depends on cannot be statically linked)
EXTRA_OECONF_remove = "--disable-dynamic"
EXTRA_OECONF_append = " --enable-dynamic"

# Raise alternatives priority for zsh
ALTERNATIVE_PRIORITY = "110"

# TODO: Add to .zshrc
# ZSH_DISABLE_COMPFIX=true

do_install_append () {
    # Override do_install_append() from base recipe which deletes dynamic functions
}