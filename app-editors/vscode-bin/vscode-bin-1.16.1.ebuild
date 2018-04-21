# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils gnome2-utils pax-utils xdg-utils
BASE_PN="vscode"

DESCRIPTION="Multiplatform code editor from Microsoft"
HOMEPAGE="https://code.visualstudio.com"
BASE_URI="https://vscode-update.azurewebsites.net/${PV}"
SRC_URI="
	x86? ( ${BASE_URI}/linux-ia32/stable ->  ${P}-x86.tar.gz )
	amd64? ( ${BASE_URI}/linux-x64/stable -> ${P}-amd64.tar.gz )
	"
RESTRICT="bindist mirror strip"

LICENSE="MS-vscode-EULA"
SLOT="0"
KEYWORDS="~x86 ~amd64 -*"
IUSE=""

DEPEND="
	!app-editors/vscode"
RDEPEND="
	${DEPEND}
	app-crypt/libsecret:0
	dev-libs/atk:0
	dev-libs/expat:0
	dev-libs/glib:2
	dev-libs/nspr:0
	dev-libs/nss:0
	gnome-base/gconf:2
	media-libs/alsa-lib:0
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	net-misc/curl:0
	net-print/cups:0
	sys-apps/dbus:0
	sys-devel/gcc
	sys-libs/glibc:2.2
	x11-libs/cairo:0
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:2
	x11-libs/libX11:0
	x11-libs/libxcb:0/1.12
	x11-libs/libXcomposite:0
	x11-libs/libXcursor:0
	x11-libs/libXdamage:0
	x11-libs/libXext:0
	x11-libs/libXfixes:0
	x11-libs/libXi:0
	x11-libs/libxkbfile:0
	x11-libs/libXrandr:0
	x11-libs/libXrender:0
	x11-libs/libXScrnSaver:0
	x11-libs/libXtst:0
	x11-libs/pango:0
"

QA_PRESTRIPPED="
	opt/${BASE_PN}/code
	opt/${BASE_PN}/bin/code
	opt/${BASE_PN}/libnode.so
	opt/${BASE_PN}/resources/app/node_modules/vscode-ripgrep/bin/rg
"

pkg_setup(){
	use amd64 && S="${WORKDIR}/VSCode-linux-x64" || S="${WORKDIR}/VSCode-linux-ia32"
}

src_install(){
	pax-mark m code
	insinto "/opt/${BASE_PN}"
	doins -r *
	dosym "/opt/${BASE_PN}/bin/code" "/usr/bin/${BASE_PN}"
	make_desktop_entry "${BASE_PN}" "Visual Studio Code" "${BASE_PN}" "Utility;TextEditor;Development;IDE;"
	doicon "${FILESDIR}/${BASE_PN}.png"
	fperms +x "/opt/${BASE_PN}/code"
	fperms +x "/opt/${BASE_PN}/bin/code"
	fperms +x "/opt/${BASE_PN}/libnode.so"
	fperms +x "/opt/${BASE_PN}/resources/app/node_modules/vscode-ripgrep/bin/rg"
	insinto "/usr/share/licenses/${BASE_PN}"
	newins "resources/app/LICENSE.txt" "LICENSE"
}

pkg_postinst(){
	xdg_desktop_database_update
	gnome2_icon_cache_update

	elog "Microsoft Visual Studio Code is successfully installed."
	elog "You could search for extensions and additional tools here:"
	elog "https://code.visualstudio.com/docs/setup/additional-components"
}

pkg_postrm() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
}
