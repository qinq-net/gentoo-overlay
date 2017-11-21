# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 cmake-utils fortran-2
DESCRIPTION="CERN's detector description and simulation Tool"
HOMEPAGE="https://github.com/FairRootGroup/geant3"
EGIT_REPO_URI="https://github.com/vmc-project/geant3.git"
EGIT_COMMIT="v2-5"

LICENSE="GPL-2"
SLOT="3"
KEYWORDS=""
IUSE="examples"

RDEPEND="
	sci-physics/root:=[pythia6]
	!sci-physics/geant:3"
DEPEND="${RDEPEND}"

src_install() {
	cmake-utils_src_install
	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
