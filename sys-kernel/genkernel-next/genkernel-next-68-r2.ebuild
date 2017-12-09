# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

SRC_URI="https://github.com/Sabayon/genkernel-next/archive/v${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~x86"
inherit bash-completion-r1
inherit eutils

DESCRIPTION="Gentoo automatic kernel building scripts, reloaded"
HOMEPAGE="https://www.gentoo.org/"

LICENSE="GPL-2"
SLOT="0"

IUSE="cryptsetup dmraid gpg iscsi mdadm plymouth selinux zfs-encryption"
DOCS=( AUTHORS )

DEPEND="app-text/asciidoc
	sys-fs/e2fsprogs
	!sys-fs/eudev[-kmod,modutils]
	selinux? ( sys-libs/libselinux )"
RDEPEND="${DEPEND}
	!sys-kernel/genkernel
	cryptsetup? ( sys-fs/cryptsetup )
	dmraid? ( >=sys-fs/dmraid-1.0.0_rc16 )
	gpg? ( app-crypt/gnupg )
	iscsi? ( sys-block/open-iscsi )
	mdadm? ( sys-fs/mdadm )
	plymouth? ( sys-boot/plymouth )
	app-portage/portage-utils
	app-arch/cpio
	>=app-misc/pax-utils-0.6
	!<sys-apps/openrc-0.9.9
	sys-apps/util-linux
	sys-block/thin-provisioning-tools
	sys-fs/lvm2
	zfs-encryption? ( >=sys-fs/zfs-0.8 )"

src_prepare() {
	default
	sed -i "/^GK_V=/ s:GK_V=.*:GK_V=${PV}:g" "${S}/genkernel" || \
		die "Could not setup release"
	epatch "${FILESDIR}/genkernel-next-68-kmod-ext.patch"
	if use zfs-encryption; then
	    epatch "${FILESDIR}/genkernel-next-68-zfs-load.patch"
	fi
}

src_install() {
	default

	doman "${S}"/genkernel.8

	newbashcomp "${S}"/genkernel.bash genkernel
}
