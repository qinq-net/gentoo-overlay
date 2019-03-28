# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Lightweight and fast C++ Logging Library"
HOMEPAGE="https://github.com/FairRootGroup/FairLogger"
SRC_URI="https://github.com/FairRootGroup/FairLogger/archive/v${PV}.tar.gz -> ${P}.tar.gz"

inherit cmake-utils

LICENSE="LGPL-3"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	>=dev-util/cmake-3.9.4
	dev-libs/boost:="
RDEPEND="${DEPEND}"
BDEPEND=""

src_configure()
{
	local mycmakeargs=(
		-DFairLogger_GIT_VERSION=${PV}
	)
	cmake-utils_src_configure
}
