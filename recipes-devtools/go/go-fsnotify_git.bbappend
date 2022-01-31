
# specify the repo branch name as a work-around for the upstream
# branch rename (master -> main)
# https://github.com/fsnotify/fsnotify/issues/426

SRC_URI = "git://${PKG_NAME}.git;branch=main"

