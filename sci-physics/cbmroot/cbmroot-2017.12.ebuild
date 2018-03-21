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
ROOT_COMPAT="root6_04 root6_05 root6_06 root6_08 root6_10"
inherit cmake-utils fairroot

LICENSE="GPL-2"
SLOT="0"
IUSE="+fieldmaps pluto"

DEPEND="
	sci-physics/cbmroot-sources:${PV}=
	$(get_root_deps sci-physics/FairRoot:= "-onlyreco(-)")
	dev-cpp/gtest:=
	dev-libs/boost:=
	net-libs/zeromq:=
	sci-libs/gsl:=
	pluto? (
		sci-physics/pluto:=
		$(get_root_deps sci-physics/FairRoot pluto)
		)"
RDEPEND="${DEPEND}"
PDEPEND="fieldmaps? ( sci-physics/cbmroot-fieldmaps:12a
                      sci-physics/cbmroot-fieldmaps:12b
                      sci-physics/cbmroot-fieldmaps:16a )"

CMAKE_USE_DIR="${EPREFIX}/usr/src/${P}"
SANDBOX_WRITE+=":${EPREFIX}/usr/src/${P}/external"
SANDBOX_WRITE+=":${EPREFIX}/usr/src/${P}/KF/KFParticle"
SANDBOX_WRITE+=":${EPREFIX}/usr/src/${P}/KF/KFParticlePerformance"

src_unpack() {
	default
	mkdir -pv "${S}"
}

src_prepare() {
	default
}

src_configure() {
	export SIMPATH="${EPREFIX}/usr"
	local mycmakeargs=(
		"-DBOOST_ROOT=${EPREFIX}/usr"
		"-DBOOST_INCLUDEDIR=${EPREFIX}/usr/include/boost"
		"-DBOOST_LIBRARYDIR=${EPREFIX}/usr/$(get_libdir)"
		"-DGSL_DIR=${EPREFIX}/usr"
		)
	root_src_configure
}

src_install() {
	root_src_install
	find ${D} -name 'check_system.sh' -delete
	if use fieldmaps; then
		local targets=( $(get_root_targets) )
		for target in ${targets}; do
			local rootpv=${target##root}
			rootpv=${rootpv//_/.}
			dodir /opt/root/${rootpv}/share/cbmroot/input
			ln -s ${EPREFIX}/usr/share/cbmroot/input/field_v12a.root ${D}/opt/root/${rootpv}/share/cbmroot/input/
			ln -s ${EPREFIX}/usr/share/cbmroot/input/field_v12b.root ${D}/opt/root/${rootpv}/share/cbmroot/input/ 
			ln -s ${EPREFIX}/usr/share/cbmroot/input/field_v16a.root ${D}/opt/root/${rootpv}/share/cbmroot/input/
		done
	fi
}

