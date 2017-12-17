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
ROOT_REQUIRED_USE="pythia6,pythia8,math,http"
inherit git-r3 cmake-utils root

LICENSE="LGPL-3"
SLOT="0/${PV}"
IUSE="pluto onlyreco"

DEPEND="
	dev-util/cmake
	sci-libs/gsl
	dev-cpp/gtest:=
	dev-libs/icu
	dev-libs/boost:=
	!onlyreco? (
		sci-physics/hepmc
		dev-libs/xerces-c
		sci-physics/geant:4[geant3]
		sci-physics/geant-data:4
		pluto? (
			sci-physics/pluto:=
			)
		|| (
			$(get_root_deps sci-physics/geant-vmc:3)
		)
		)
	media-libs/mesa
	net-libs/zeromq
	dev-libs/protobuf
	dev-libs/flatbuffers
	dev-libs/msgpack
	dev-libs/nanomsg"
RDEPEND="${DEPEND}"
## TODO: add support for the following dependencies
#	sci-physics/geant-vmc:4
#	sci-physics/geant-python
#	sci-physics/millepede:2

src_prepare() {
	epatch "${FILESDIR}/${PN}-16.06b-libpythia.patch"
	cmake-utils_src_prepare
}

_root_multibuild_wrapper() {
	debug-print-function ${FUNCNAME} "${@}"
	local rootpv=${MULTIBUILD_VARIANT##root}
	rootpv=${rootpv//_/.}
	export ROOT_DIR="${EPREFIX}/opt/root/${rootpv}"
	mycmakeargs+=(
		-DROOT_DIR=${EPREFIX}/opt/root/${rootpv}
		-DCMAKE_INSTALL_PREFIX=${EPREFIX}/opt/root/${rootpv}
		-DGEANT3_PATH=${ROOT_DIR}
	)
	"${@}"
}

src_configure() {
	export SIMPATH=${EPREFIX}/usr
	root_src_configure
}
