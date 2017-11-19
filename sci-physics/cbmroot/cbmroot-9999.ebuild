# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Software for simulation, reconstruction, and data analysis for the CBM experiment"
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
SLOT="0"
IUSE="+fieldmaps pluto"

DEPEND="
	sci-physics/FairRoot:=[-onlyreco]
	>=sci-physics/root-6:=[pythia6,pythia8,math]
	dev-cpp/gtest:=
	dev-libs/boost:=
	net-libs/zeromq:=
	pluto? (
		sci-physics/pluto:=
		sci-physics/FairRoot:=[pluto]
		)"
RDEPEND="${DEPEND}"
PDEPEND="fieldmaps? ( sci-physics/cbmroot-fieldmaps:* )"

src_prepare() {
	epatch "${FILESDIR}/${PN}-2017.07-nofairsoft.patch"
	epatch "${FILESDIR}/${PN}-2017.07-boost.patch"
	epatch "${FILESDIR}/${PN}-2017.07-getstring.patch"
	if [[ ${PV} == 2017.07 ]]; then 
		epatch "${FILESDIR}/${PN}-2017.07-external.patch"
	fi
	epatch "${FILESDIR}/${PN}-2017.07-macro-insdir.patch"
	epatch "${FILESDIR}/${PN}-2017.07-mvd-rpath.patch"
	epatch "${FILESDIR}/${PN}-2017.10-include.patch"
	cmake-utils_src_prepare
}

src_configure() {
	export SIMPATH="${EPREFIX}/usr"
	export FAIRROOTPATH="${EPREFIX}/usr"
	local mycmakeargs=(
		"-DBOOST_ROOT=${EPREFIX}/usr"
		"-DBOOST_INCLUDEDIR=${EPREFIX}/usr/include/boost"
		"-DBOOST_LIBRARYDIR=${EPREFIX}/usr/$(get_libdir)"
		)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	# libdir is hardcoded into CMakeLists
	mv -Tv ${D}/usr/lib ${D}/usr/$(get_libdir)
	rm -v ${D}/usr/bin/check_system.sh #Provided by sci-physics/FairRoot
	# For the headers installation
	cp -v ${D}/usr/include/report/*.h ${D}/usr/include/
	rm -v ${D}/usr/include/*LinkDef.h
}

