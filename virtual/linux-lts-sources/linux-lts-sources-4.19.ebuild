# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Virtual for Linux LTS kernel sources"
SLOT="${PV}"
KEYWORDS="~alpha amd64 arm ~arm64 ~hppa ia64 ~mips ppc ppc64 ~s390 ~sh ~sparc x86"
IUSE="firmware"

RDEPEND="
	firmware? ( sys-kernel/linux-firmware )
	|| (
		=sys-kernel/gentoo-sources-${PV}*
		=sys-kernel/vanilla-sources-${PV}*
		=sys-kernel/ck-sources-${PV}*
		=sys-kernel/git-sources-${PV}*
		=sys-kernel/hardened-sources-${PV}*
		=sys-kernel/mips-sources-${PV}*
		=sys-kernel/openvz-sources-${PV}*
		=sys-kernel/pf-sources-${PV}*
		=sys-kernel/rt-sources-${PV}*
		=sys-kernel/tuxonice-sources-${PV}*
		=sys-kernel/xbox-sources-${PV}*
		=sys-kernel/zen-sources-${PV}*
		=sys-kernel/aufs-sources-${PV}*
		=sys-kernel/raspberrypi-sources-${PV}*
	)"
