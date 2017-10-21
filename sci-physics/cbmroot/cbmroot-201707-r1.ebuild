# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Software for simulation, reconstruction, and data analysis for the CBM experiment"
HOMEPAGE="https://redmine.cbm.gsi.de/projects/cbmroot"
ESVN_REPO_URI="https://subversion.gsi.de/cbmsoft/cbmroot/release/JUL17"

inherit subversion cmake-utils

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~x86-linux ~amd64-linux"
IUSE="+fieldmaps"

DEPEND="
	sci-physics/FairRoot:=[-onlyreco]
	>=sci-physics/root-6:=[pythia6,pythia8,math]"
RDEPEND="${DEPEND}"
PDEPEND="fieldmaps? ( sci-physics/cbmroot-fieldmaps:= )"

src_prepare() {
	epatch "${FILESDIR}/${PN}-201707-nofairsoft.patch"
	epatch "${FILESDIR}/${PN}-201707-boost.patch"
	epatch "${FILESDIR}/${PN}-201707-getstring.patch"
	epatch "${FILESDIR}/${PN}-201707-external.patch"
	epatch "${FILESDIR}/${PN}-201707-macro-insdir.patch"
	epatch "${FILESDIR}/${PN}-201707-mvd-rpath.patch"
	cmake-utils_src_prepare
}

src_configure() {
	export SIMPATH=${EPREFIX}/usr
	export FAIRROOTPATH=${EPREFIX}/usr
	local mycmakeargs=(
		"-DBOOST_ROOT=${EPREFIX}/usr"
		"-DBOOST_INCLUDEDIR=${EPREFIX}/usr/include/boost"
		"-DBOOST_LIBRARYDIR=${EPREFIX}/usr/$(get_libdir)"
		)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	mv -bTv ${D}/usr/lib ${D}/usr/$(get_libdir)
	rm ${D}/usr/bin/check_system.sh #Provided by sci-physics/FairRoot
}

