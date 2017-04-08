# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3 linux-info

DESCRIPTION="Arch Linux kernel module for RTL8812AU, RTL8821AU based on v4.3.20 driver from Realtek"
HOMEPAGE="https://github.com/Grawp/rtl8812au_8821au"
EGIT_REPO_URI="https://github.com/Grawp/rtl8812au_rtl8821au"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_compile() {
	set_arch_to_kernel
	make KSRC="${KV_DIR}" KVER="${KV_FULL}"
}

src_install() {
	insinto "/lib/modules/${KV_FULL}/kernel/drivers/net/wireless/"
	doins 8812au.ko
	#emake MODDESTDIR="${ED}/lib/modules/${KV_FULL}/kernel/drivers/net/wireless/" install
}
