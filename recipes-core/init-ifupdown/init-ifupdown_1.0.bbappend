# Delete nfsroot script from upstream
# Allow ifup even if we're booting from NFS - we're gonna be okay.
# (kernel dhcpc won't set time and hostname, but udhcpc will - so make sure udhcpc is called even if we're booting from NFS)

do_install:append () {
	rm -f ${D}${sysconfdir}/network/if-pre-up.d/nfsroot
}
