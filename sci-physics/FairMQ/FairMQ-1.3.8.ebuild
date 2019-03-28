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
IUSE="+nanomsg asiofi dds test doc"
RESTRICT="mirror"

RDEPEND="
	>=dev-libs/boost-1.64:=
	dds? ( >=dev-util/DDS-2.2 )
	nanomsg? (
		>=dev-libs/nanomsg-1.1.3:=
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
if ! [[ "${PV}" == "9999" ]]; then
	PATCHES="${FILESDIR}/${PN}-1.3.8-version.patch"
fi
PATCHES+=" ${FILESDIR}/${PN}-1.3.7-io_service.patch" # For Boost <= 1.67


src_configure()
{
	local mycmakeargs=(
		-DBUILD_NANOMSG_TRANSPORT=$(usex nanomsg)
		-DBUILD_OFI_TRANSPORT=$(usex asiofi)
		-DBUILD_FAIRMQ=ON
		-DZEROMQ_ROOT=${EPREFIX%/}/usr
		-DBUILD_TESTING=$(usex test)
		-DBUILD_DDS_PLUGIN=$(usex dds)
		-DBUILD_DOCS=$(usex doc)
		-DCMAKE_PROJECT_VERSION=${PV}
	)
	if use dds; then
		mycmakeargs+=" -DDDS_ROOT=${DDS_LOCATION}"
	fi
	cmake-utils_src_configure
}
