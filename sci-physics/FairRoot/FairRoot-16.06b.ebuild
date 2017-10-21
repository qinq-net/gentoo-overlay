# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A simulation, reconstruction and analysis framework that is based on the ROOT system."
HOMEPAGE="https://github.com/FairRootGroup/FairRoot"
EGIT_REPO_URI="https://github.com/FairRootGroup/FairRoot.git"
EGIT_CLONE_TYPE=single+tags
EGIT_COMMIT="v-${PV}"
inherit git-r3 cmake-utils multilib

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pluto onlyreco"

DEPEND="
	dev-util/cmake
	sci-physics/root[http]
	sci-libs/gsl
	dev-cpp/gtest
	dev-libs/icu
	dev-libs/boost
	!onlyreco? (
		sci-physics/root[pythia6,pythia8]
		sci-physics/hepmc
		dev-libs/xerces-c
		sci-physics/geant:4
		sci-physics/geant-data:4
		pluto? (
			sci-physics/pluto
			)
		sci-physics/geant-vmc:3
		sci-physics/vgm
		)
	media-libs/mesa
	sci-physics/root
	net-libs/zeromq
	dev-libs/protobuf
	dev-libs/flatbuffers
	dev-libs/msgpack
	dev-libs/nanomsg
	www-servers/apache"
RDEPEND="${DEPEND}"
## TODO: add support for the following dependencies
#	sci-physics/geant-vmc:4
#	sci-physics/geant-python
#	sci-physics/millepede:2

src_configure() {
	export SIMPATH=${EPREFIX}/usr
	cmake-utils_src_configure
}
