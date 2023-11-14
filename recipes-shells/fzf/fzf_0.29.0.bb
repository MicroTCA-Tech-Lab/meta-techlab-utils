DESCRIPTION = "Fuzzy finder"
SECTION = "shells"
HOMEPAGE = "https://github.com/junegunn/fzf"

GO_IMPORT = "github.com/junegunn/fzf"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=bba7e28399b614707a33394aba4249d1"

# Put all dependencies into a monster SRC_URI
# Avoid bloating the Yocto layer with go recipes that are only dependencies of fzf
    
SRC_URI = "\
         git://${GO_IMPORT};protocol=https \
         git://github.com/mattn/go-isatty;protocol=https;name=go-isatty;destsuffix=${BPN}-${PV}/src/github.com/mattn/go-isatty \
         git://github.com/mattn/go-runewidth;protocol=https;name=go-runewidth;destsuffix=${BPN}-${PV}/src/github.com/mattn/go-runewidth \
         git://github.com/mattn/go-shellwords;protocol=https;name=go-shellwords;destsuffix=${BPN}-${PV}/src/github.com/mattn/go-shellwords \
         git://github.com/rivo/uniseg;protocol=https;name=go-uniseg;destsuffix=${BPN}-${PV}/src/github.com/rivo/uniseg \
         git://github.com/saracen/walker;protocol=https;name=go-walker;destsuffix=${BPN}-${PV}/src/github.com/saracen/walker \
         git://github.com/golang/term;protocol=https;name=go-term;destsuffix=${BPN}-${PV}/src/golang.org/x/term \
         git://github.com/golang/sync;protocol=https;name=go-sync;destsuffix=${BPN}-${PV}/src/golang.org/x/sync \
         git://github.com/golang/sys;protocol=https;name=go-sys;destsuffix=${BPN}-${PV}/src/golang.org/x/sys \
         "

SRCREV="dc975e8974c4f569980676d9f605226368e20711"
SRCREV_go-isatty="504425e14f742f1f517c4586048b49b37f829c8e"
SRCREV_go-runewidth="df1ff59654317c1b5a3f860ffc47402931932104"
SRCREV_go-shellwords="973b9d5391598d4ee601db46fa32f6e186a356ac"
SRCREV_go-uniseg="75711fccf6a3e85bc74c241e2dddd06a9bc9e53d"
SRCREV_go-walker="2c746f29c263bb7437b6b4870e577335eb4871e1"
SRCREV_go-term="de623e64d2a6562fa463152da80477d4aa07fca0"
SRCREV_go-sync="036812b2e83c0ddf193dd5a34e034151da389d09"
SRCREV_go-sys="0f9fa26af87c481a6877a4ca1330699ba9a30673"

inherit go

do_install:append() {
    FZFSH_DIR=${D}/usr/lib/fzf/shell
    mkdir -p ${FZFSH_DIR}
    cp -r ${B}/src/${GO_IMPORT}/shell/* ${FZFSH_DIR}
}
