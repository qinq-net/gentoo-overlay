# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit root versionator

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vmc-project/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="http://ivana.home.cern.ch/ivana/${PN}.${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
	S="${WORKDIR}/${PN}.${PV}"
fi

DESCRIPTION="Virtual Geometry Model for High Energy Physics Experiments"
HOMEPAGE="http://ivana.home.cern.ch/ivana/VGM.html"

LICENSE="GPL-2"
SLOT="0"
IUSE="doc +examples +geant4 +root test"
REQUIRED_USE="root"

RDEPEND="
	sci-physics/clhep:=
	geant4? ( >=sci-physics/geant-4.10.03 )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen[dot] )
	test? ( sci-physics/geant-vmc[g4root] )"
RESTRICT="
	!geant4? ( test )
	!root? ( test )
	!test? ( test )"

DOCS=(
	doc/README
	doc/todo.txt
	doc/VGMhistory.txt
	doc/VGM.html
	doc/VGMversions.html
)

src_configure() {
	local mycmakeargs=(
		-DCLHEP_DIR="${EROOT}usr"
		-DEXTERNAL_CLHEP_LIBRARY_DIR=ON
		-DWITH_EXAMPLES="$(usex examples)"
		-DINSTALL_EXAMPLES="$(usex examples)"
		-DWITH_GEANT4="$(usex geant4)"
		-DWITH_ROOT="$(usex root)"
		-DWITH_TEST="$(usex test)"
	)
	if use test && use root && use geant4; then
		mycmakeargs+=( -DWITH_G4ROOT=yes )
	else
		mycmakeargs+=( -DWITH_G4ROOT=no )
	fi
	root_src_configure
}

src_compile() {
	root_src_compile
	if use doc; then
		cd packages
		doxygen || die
	fi
}

src_test() {
	cd "${BUILD_DIR}"/test || die
	./test_suite.sh || die
}

src_install() {
	root_src_install
	use doc && local HTML_DOCS=( doc/html/. )
	einstalldocs
}
