# desy-login-support

This recipe configures a Yocto Linux system to use DESY LDAP/Kerberos services to allow users to login with their DESY credentials.
Logged in users are automatically added to the sudo and dialout groups.

## Troubleshooting

* If you can't login, check the system log (`/var/log/messages` or `journalctl` depending on system type) for error messages.
* Enter `getent passwd <username>` to verify that LDAP is working and provides information about your user account.
* Different user accounts can require different shells, and if the required shell is not available on the target then the login will fail. Make sure that at least `/bin/bash` and `/bin/zsh` are available.
* `dropbear` cannot use PAM, so trying to use this configuration with it will fail. The target system will have to use `ssh-server-openssh` instead.
* Installing openssh via dnf is not enough - make sure to have something like `IMAGE_FEATURES += " ssh-server-openssh"` in your image recipe, so openssh is included at image build time and dropear is removed.
