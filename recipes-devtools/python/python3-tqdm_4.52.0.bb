SUMMARY = "Fast, Extensible Progress Meter"
HOMEPAGE = "http://tqdm.github.io/"
SECTION = "devel/python"

LICENSE = "MIT & MPL-2.0"
LIC_FILES_CHKSUM = "file://LICENCE;md5=7ea57584e3f8bbde2ae3e1537551de25"

SRC_URI[md5sum] = "eccf60439e665178b8a2d33f7d465376"
SRC_URI[sha256sum] = "18d6a615aedd09ec8456d9524489dab330af4bd5c2a14a76eb3f9a0e14471afe"

inherit pypi setuptools3

BBCLASSEXTEND = "native nativesdk"
