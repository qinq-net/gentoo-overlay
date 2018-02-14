# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A simulation, reconstruction and analysis framework that is based on the ROOT system."
HOMEPAGE="https://github.com/FairRootGroup/FairRoot"
EGIT_REPO_URI="https://github.com/FairRootGroup/FairRoot.git"
_USE_EGIT_REPO=n
if [[ ${PV} == *"9999" ]] ; then
	inherit git-r3
	_USE_EGIT_REPO=y
	KEYWORDS=""
	if [[ ${PV} != "9999" ]] ; then
		EGIT_BRANCH="v-${PV%%.9999}_patches"
	fi
else
	SRC_URI="https://github.com/FairRootGroup/FairRoot/archive/v-${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${PN}-v-${PV}"
fi
ROOT_REQUIRED_USE="pythia6,pythia8,math,http"
ROOT_COMPAT="root6_04 root6_05 root6_06 root6_08 root6_10 root6_11 root6_12"
inherit cmake-utils fairroot

LICENSE="LGPL-3"
SLOT="0/${PV}"
IUSE="pluto +fairmq onlyreco go"

DEPEND="
	>=dev-util/cmake-3.9.4
	sci-libs/gsl
	dev-cpp/gtest:=
	dev-libs/icu
	fairmq? (
		>=dev-libs/boost-1.64:=
		net-libs/zeromq[static-libs]
		)
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
	dev-libs/protobuf
	dev-libs/flatbuffers[static-libs]"
RDEPEND="${DEPEND}"
## TODO: add support for the following dependencies
#	sci-physics/geant-vmc:4
#	sci-physics/geant-python
#	sci-physics/millepede:2
#	dev-libs/msgpack[c]
#	dev-libs/nanomsg[static-libs]
#	IWYU
#	DDS
#	CUDA
PATCHES=(
	"${FILESDIR}/${PN}-17.10a-libpythia.patch"
	"${FILESDIR}/${PN}-17.10a-FairSoft.patch"
	"${FILESDIR}/${PN}-17.10b-FairMQ.patch"
	"${FILESDIR}/${PN}-17.10b-GSL.patch"
	)

src_prepare() {
	cmake-utils_src_prepare
	einfo "Swapping libdir"
	sed -i "s/\${SIMPATH}\/lib/\${SIMPATH}\/$(get_libdir)/g" `find ${S}/cmake -name '*.cmake'`
}
src_configure() {
	export SIMPATH=${EPREFIX}/usr
	local mycmakeargs=(
		-DSIMPATH="${EPREFIX}/usr"
		-DBOOST_ROOT="${EPREFIX}/usr"
		-DBOOST_INCLUDEDIR="${EPREFIX}/usr/include/boost"
		-DBOOST_LIBRARYDIR="${EPREFIX}/usr/$(get_libdir)"
		-DDISABLE_GO="$(usex go OFF ON)"
		)
	root_src_configure
}
