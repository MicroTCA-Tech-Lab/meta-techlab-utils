DESCRIPTION = "Utilities for developer shell"

inherit packagegroup

TECHLAB_DEVBOX_PACKAGES = " \
    ntpdate             \
    libpam              \
    pam-ssh-agent-auth  \
    pam-krb5            \
    zsh                 \
    oh-my-zsh           \
    tmux                \
    fzf                 \
"

RDEPENDS_${PN} = "${TECHLAB_DEVBOX_PACKAGES}"
