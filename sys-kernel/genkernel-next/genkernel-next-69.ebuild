# Copyright 2017-2019 Gentoo Authors and QIN Yuhao
# Distributed under the terms of the GNU General Public License v2

EAPI=6

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/qinq-net/genkernel-next"
	EGIT_BRANCH="zfs-load"
	inherit git-r3
	KEYWORDS=""
	REQUIRED_USE="zfs-encryption"
else
	KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~x86"
	SRC_URI="https://github.com/Sabayon/genkernel-next/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	PATCHES="
		${FILESDIR}/genkernel-next-68-kmod-ext.patch
		${FILESDIR}/genkernel-next-68-firmware-subdir.patch"
fi
inherit bash-completion-r1

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

src_unpack() {
	if [[ ${PV} == "9999" ]]; then
		git-r3_src_unpack
	elif use "zfs-encryption"; then
		PATCHES+=" ${FILESDIR}/${PN}-69-zfs-load.patch"
		default
	fi
}

src_prepare() {
	default
	sed -i "/^GK_V=/ s:GK_V=.*:GK_V=${PV}:g" "${S}/genkernel" || \
		die "Could not setup release"
}

src_install() {
	default

	doman "${S}"/genkernel.8

	newbashcomp "${S}"/genkernel.bash genkernel
}
