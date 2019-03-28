# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="C++ Message Queuing Library and Framework"
HOMEPAGE="https://github.com/FairRootGroup/FairMQ"
if [[ ${PV} == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/FairRootGroup/FairMQ"
else
	SRC_URI="https://github.com/FairRootGroup/FairMQ/archive/v${PV}.tar.gz -> ${P}.tar.gz"
fi

inherit cmake-utils

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+nanomsg asiofi dds pmix test doc"
RESTRICT="mirror"

RDEPEND="
	>=dev-libs/boost-1.64:=
	dds? ( >=dev-util/DDS-2.2 )
	pmix? ( >=sys-cluster/pmix-2.1.4 )
	nanomsg? (
		>=dev-libs/nanomsg-1.1.3:=[static-libs]
		>=dev-libs/msgpack-3.1.0:=[cxx,static-libs]
	)
	>=sci-physics/FairLogger-1.2.0:=
	>=net-libs/zeromq-4.1.5:=[fairroot,static-libs]
	"
DEPEND="${RDEPEND}
	doc? ( >=app-doc/doxygen-1.8.8[dot] )
	test? ( >=dev-cpp/gtest-1.7.0 )
	dev-util/cmake"
BDEPEND=""

src_configure()
{
	local mycmakeargs=(
		-DBUILD_NANOMSG_TRANSPORT=$(usex nanomsg)
		-DBUILD_OFI_TRANSPORT=$(usex asiofi)
		-DBUILD_FAIRMQ=ON
		-DZEROMQ_ROOT=${EPREFIX%/}/usr
		-DBUILD_TESTING=$(usex test)
		-DBUILD_DDS_PLUGIN=$(usex dds)
		-DBUILD_PMIX_PLUGIN=$(usex pmix)
		-DBUILD_DOCS=$(usex doc)
	)
	if use dds; then
		mycmakeargs+="-DDDS_ROOT=${DDS_LOCATION}"
	fi
	if use pmix; then
		mycmakeargs+="-DPMIX_ROOT=${EPREFIX%/}/usr"
	fi
	cmake-utils_src_configure
}
