# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Software for simulation, reconstruction, and data analysis for the CBM experiment (source tree)"
HOMEPAGE="https://redmine.cbm.gsi.de/projects/cbmroot"
if [[ ${PV} == "9999" ]]; then
	ESVN_REPO_URI="https://subversion.gsi.de/cbmsoft/cbmroot/trunk"
	KEYWORDS=""
else
	monthnames=(invalid JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC)
	RELEASE_MONTH=${monthnames[${PV:(-2)}]}
	unset monthnames
	RELEASE_YEAR=${PV:2:2}
	ESVN_REPO_URI="https://subversion.gsi.de/cbmsoft/cbmroot/release/${RELEASE_MONTH}${RELEASE_YEAR}"
	KEYWORDS="~x86 ~amd64 ~x86-linux ~amd64-linux"
fi
inherit subversion cmake-utils

LICENSE="GPL-2"
SLOT="${PV}/${PR}"

PATCHES=(
	"${FILESDIR}/${PN}-2017.07-nofairsoft.patch"
	"${FILESDIR}/${PN}-2017.07-boost.patch"
	"${FILESDIR}/${PN}-2017.12-macro-insdir.patch"
	"${FILESDIR}/${PN}-2017.07-mvd-rpath.patch"
	)

src_configure() {
	default
}

src_compile() {
	default
}

src_test() {
	default
}

src_install() {
	dodir /usr/src
	mv -vT "${S}" "${ED}usr/src/cbmroot-${PV}" || die
	fowners -R portage:portage "/usr/src/cbmroot-${PV}/external"
	dodir /usr/src/cbmroot-${PV}/KF/KFParticle{,Performance}
	fowners -R portage:portage /usr/src/cbmroot-${PV}/KF/KFParticle{,Performance}
}

pkg_preinst() {
	chown -vR portage:portage ${ED}/usr/src/cbmroot-${PV}/external
	chown -vR portage:portage ${ED}/usr/src/cbmroot-${PV}/KF/KFParticle{,Performance}
}

