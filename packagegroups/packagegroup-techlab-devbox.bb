DESCRIPTION = "Utilities for developer shell"

inherit packagegroup

TECHLAB_DEVBOX_PACKAGES = " \
    ntpdate              \
    tzdata               \
    zsh                  \
    oh-my-zsh            \
    tmux                 \
    python3-ranger       \
    fzf                  \
    zsh                  \
"

TECHLAB_DEVBOX_PACKAGES += "${@bb.utils.contains('DISTRO_FEATURES', 'desy-login-support', 'desy-login-support', '' ,d)}"

RDEPENDS_${PN} = "${TECHLAB_DEVBOX_PACKAGES}"
