# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Managing the installed ROOT environment"
HOMEPAGE="https://github.com/qinq-net/gentoo-overlay/tree/master/app-eselect/eselect-root"

inherit desktop xdg-utils

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

desktop_install() {
	domenu ${FILESDIR}/root.desktop
	doicon ${FILESDIR}/root-system-bin.png
	insinto /usr/share/icons/hicolor/48x48/mimetypes
	doins ${FILESDIR}/application-x-root.png
	insinto /usr/share/icons/hicolor/48x48/apps
	doins ${FILESDIR}/root-system-bin.xpm
}

src_unpack() {
	mkdir -pv ${S}
}

src_install() {
	default
	desktop_install
	insinto /usr/share/eselect/modules
	doins ${FILESDIR}/root.eselect
}

pkg_postinst() {
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}
