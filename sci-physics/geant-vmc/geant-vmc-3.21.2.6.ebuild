# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

ROOT_REQUIRED_USE="pythia6"
inherit cmake-utils fortran-2 root
DESCRIPTION="CERN's detector description and simulation Tool"
HOMEPAGE="https://github.com/FairRootGroup/geant3"
SRC_URI="https://root.cern.ch/download/vmc/geant3+_vmc.2.6.tar.gz"
S="${WORKDIR}/geant3+_vmc.2.6"

LICENSE="GPL-2"
SLOT="3"
KEYWORDS="~amd64 ~x86"
IUSE="examples"

RDEPEND="
	!sci-physics/geant:3"
DEPEND="${RDEPEND}"

src_install() {
	root_src_install
	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
