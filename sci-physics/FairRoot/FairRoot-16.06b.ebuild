# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A simulation, reconstruction and analysis framework that is based on the ROOT system."
HOMEPAGE="https://github.com/FairRootGroup/FairRoot"
EGIT_REPO_URI="https://github.com/FairRootGroup/FairRoot.git"
if [[ ${PV} == "9999" ]] ; then
	KEYWORDS=""
	EGIT_CLONE_TYPE=single+tags
else
	EGIT_COMMIT="v-${PV}"
	KEYWORDS="~amd64 ~x86"
	EGIT_CLONE_TYPE=single
fi
inherit git-r3 cmake-utils

LICENSE="LGPL-3"
SLOT="0"
IUSE="pluto onlyreco"

DEPEND="
	dev-util/cmake
	sci-physics/root:=[math,http]
	sci-libs/gsl:=
	dev-cpp/gtest:=
	dev-libs/icu:=
	dev-libs/boost:=
	!onlyreco? (
		sci-physics/root:=[pythia6,pythia8]
		sci-physics/hepmc:=
		dev-libs/xerces-c:=
		sci-physics/geant:4
		sci-physics/geant-data:4
		pluto? (
			sci-physics/pluto:=
			)
		sci-physics/geant-vmc:3
		sci-physics/vgm:=
		)
	media-libs/mesa:=
	net-libs/zeromq:=
	dev-libs/protobuf:=
	dev-libs/flatbuffers:=
	dev-libs/msgpack:=
	dev-libs/nanomsg:="
RDEPEND="${DEPEND}"
## TODO: add support for the following dependencies
#	sci-physics/geant-vmc:4
#	sci-physics/geant-python
#	sci-physics/millepede:2

src_prepare() {
	epatch \
		"${FILESDIR}/${PN}-16.06b-libpythia.patch"
	cmake-utils_src_prepare
}

src_configure() {
	export SIMPATH=${EPREFIX}/usr
	#sed -i -e "s/set(LIBRARY_OUTPUT_PATH \"\${CMAKE_BINARY_DIR}\/lib\")/set(LIBRARY_OUTPUT_PATH \"\${CMAKE_BINARY_DIR}\/$(get_libdir)\")/" ${S}/CMakeLists.txt ${S}/templates/project_template/CMakeLists.txt
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	mv -bTv ${D}/usr/lib ${D}/usr/$(get_libdir)
}
