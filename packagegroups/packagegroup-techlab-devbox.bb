DESCRIPTION = "Utilities for developer shell"

inherit packagegroup

TECHLAB_DEVBOX_PACKAGES = " \
    ntpdate             \
    tzdata              \
    libpam              \
    pam-ssh-agent-auth  \
    pam-krb5            \
    pam-plugin-mkhomedir \
    zsh                 \
    oh-my-zsh           \
    tmux                \
    python3-ranger      \
    fzf                 \
    zsh                 \
    nss-pam-ldapd        \
    desy-login-support   \
"

RDEPENDS_${PN} = "${TECHLAB_DEVBOX_PACKAGES}"
