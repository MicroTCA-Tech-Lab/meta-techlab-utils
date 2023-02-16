# Fix for build w/o pulseaudio
RDEPENDS_${PN}_append = " ${@bb.utils.contains('DISTRO_FEATURES','pulseaudio','','libltdl',d)}"
