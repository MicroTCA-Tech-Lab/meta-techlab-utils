DESCRIPTION = "Utilities for developer shell"

inherit packagegroup

TECHLAB_DEVBOX_PACKAGES = " \
    ntpdate             \
    tzdata              \
    libpam              \
    pam-ssh-agent-auth  \
    pam-krb5            \
    zsh                 \
    oh-my-zsh           \
    tmux                \
    python3-ranger      \
    fzf                 \
    zsh                 \
"

DEFAULT_TIMEZONE = "Europe/Berlin"
RDEPENDS_${PN} = "${TECHLAB_DEVBOX_PACKAGES}"
