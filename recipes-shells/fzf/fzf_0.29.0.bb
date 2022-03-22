DESCRIPTION = "Fuzzy finder"
SECTION = "shells"
HOMEPAGE = "https://github.com/junegunn/fzf"

GO_IMPORT = "github.com/junegunn/fzf"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=bba7e28399b614707a33394aba4249d1"

# Put all dependencies into a monster SRC_URI
# Avoid bloating the Yocto layer with go recipes that are only dependencies of fzf
    
SRC_URI = "\
         git://${GO_IMPORT};protocol=https;rev=0.29.0 \
         git://github.com/mattn/go-isatty;protocol=https;name=go-isatty;destsuffix=${PN}-${PV}/src/github.com/mattn/go-isatty;rev=v0.0.14 \
         git://github.com/mattn/go-runewidth;protocol=https;name=go-runewidth;destsuffix=${PN}-${PV}/src/github.com/mattn/go-runewidth;rev=v0.0.13 \
         git://github.com/mattn/go-shellwords;protocol=https;name=go-shellwords;destsuffix=${PN}-${PV}/src/github.com/mattn/go-shellwords;rev=v1.0.12 \
         git://github.com/rivo/uniseg;protocol=https;name=uniseg;destsuffix=${PN}-${PV}/src/github.com/rivo/uniseg;rev=v0.2.0 \
         git://github.com/saracen/walker;protocol=https;name=walker;destsuffix=${PN}-${PV}/src/github.com/saracen/walker;rev=v0.1.2 \
         git://github.com/golang/term;protocol=https;name=term;destsuffix=${PN}-${PV}/src/golang.org/x/term;rev=de623e64d2a6562fa463152da80477d4aa07fca0 \
         git://github.com/golang/sync;protocol=https;name=sync;destsuffix=${PN}-${PV}/src/golang.org/x/sync;rev=036812b2e83c0ddf193dd5a34e034151da389d09 \
         git://github.com/golang/sys;protocol=https;name=sys;destsuffix=${PN}-${PV}/src/golang.org/x/sys;rev=0f9fa26af87c481a6877a4ca1330699ba9a30673 \
         "

inherit go
