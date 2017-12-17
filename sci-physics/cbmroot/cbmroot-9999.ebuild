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
ROOT_REQUIRED_USE="pythia6,pythia8,math"
inherit subversion cmake-utils root

LICENSE="GPL-2"
SLOT="0"
IUSE="+fieldmaps pluto"
REQUIRED_USE="!root_target_root6_11 !root_target_root6_12"

DEPEND="
	$(get_root_deps sci-physics/FairRoot -onlyreco)
	dev-cpp/gtest:=
	dev-libs/boost:=
	net-libs/zeromq:=
	pluto? (
		sci-physics/pluto:=
		$(get_root_deps sci-physics/FairRoot pluto)
		)"
RDEPEND="${DEPEND}"
PDEPEND="fieldmaps? ( sci-physics/cbmroot-fieldmaps:12a
                      sci-physics/cbmroot-fieldmaps:12b
                      sci-physics/cbmroot-fieldmaps:16a )"

src_prepare() {
	epatch "${FILESDIR}/${PN}-2017.07-nofairsoft.patch"
	epatch "${FILESDIR}/${PN}-2017.07-boost.patch"
	epatch "${FILESDIR}/${PN}-2017.12-macro-insdir.patch"
	epatch "${FILESDIR}/${PN}-2017.07-mvd-rpath.patch"
	cmake-utils_src_prepare
}

_root_multibuild_wrapper() {
	debug-print-function ${FUNCNAME} "${@}"
	local rootpv=${MULTIBUILD_VARIANT##root}
	rootpv=${rootpv//_/.}
	export ROOT_DIR="${EPREFIX}/opt/root/${rootpv}"
	export FAIRROOTPATH=${ROOT_DIR}
	mycmakeargs+=(
		-DROOT_DIR=${EPREFIX}/opt/root/${rootpv}
		-DCMAKE_INSTALL_PREFIX=${EPREFIX}/opt/root/${rootpv}
		-DGEANT3_PATH=${ROOT_DIR}
	)
	"${@}"
}

src_configure() {
	export SIMPATH="${EPREFIX}/usr"
	local mycmakeargs=(
		"-DBOOST_ROOT=${EPREFIX}/usr"
		"-DBOOST_INCLUDEDIR=${EPREFIX}/usr/include/boost"
		"-DBOOST_LIBRARYDIR=${EPREFIX}/usr/$(get_libdir)"
		)
	root_src_configure
}

src_install() {
	root_src_install
	find ${D} -name 'check_system.sh' -delete
	if use fieldmaps; then
		ln -s ${EPREFIX}/usr/share/cbmroot/input/field_v12a.root 
		ln -s ${EPREFIX}/usr/share/cbmroot/input/field_v12b.root 
		ln -s ${EPREFIX}/usr/share/cbmroot/input/field_v16a.root
	fi
}

