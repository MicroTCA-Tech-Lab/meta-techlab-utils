SUMMARY = "Seamless operability between C++11 and Python"
HOMEPAGE = "https://github.com/wjakob/pybind11"
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=774f65abd8a7fe3124be2cdf766cd06f"

DEPENDS = "boost"

SRC_URI = "git://github.com/pybind/pybind11.git \
           file://0001-Do-not-strip-binaries.patch \
           file://0001-Do-not-check-pointer-size-when-cross-compiling.patch \
"
SRCREV = "8de7772cc72daca8e947b79b83fea46214931604"

S = "${WORKDIR}/git"

BBCLASSEXTEND = "native"

# Make sure python3-pybind11-native uses Yocto native Python (instead of build host's Python)
# Fixes python3-pybind11-native on Ubuntu 20.04 build hosts
EXTRA_OECMAKE =  "-DPYBIND11_TEST=OFF \
		-DPYTHON_EXECUTABLE=${RECIPE_SYSROOT_NATIVE}/usr/bin/python3-native/python3.8 \
"
inherit cmake setuptools3 python3native

do_configure() {
	cmake_do_configure
}

do_compile() {
	cd ${S}
	distutils3_do_compile
	cmake_do_compile
}

do_install() {
	cd ${S}
	distutils3_do_install
	cmake_do_install
}

BBCLASSEXTEND = "native nativesdk"
