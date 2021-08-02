
# specify the repo branch name as a work-around for the upstream
# branch rename (master -> main)
# https://github.com/coreos/go-systemd/issues/371

SRC_URI = "git://${PKG_NAME}.git;branch=main"

