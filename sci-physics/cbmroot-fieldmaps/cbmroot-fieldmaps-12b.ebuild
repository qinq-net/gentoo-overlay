# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Magnetic fieldmaps for CbmRoot"
HOMEPAGE="https://redmine.cbm.gsi.de/projects/cbmroot"
CBMROOT_FIELDMAP="field_v${PV}.root"
SRC_COM="http://redmine.cbm.gsi.de/projects/cbmroot/repository/raw/fieldmaps"
SRC_URI="${SRC_COM}/${CBMROOT_FIELDMAP}"
unset d

LICENSE="GPL-2"
SLOT="${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="sci-physics/cbmroot"
DEPEND="${RDEPEND}"

RESTRICT="fetch"
pkg_nofetch() {
	einfo "The website of GSI is using a certificate not supported by wget(1)."
	einfo "Thus fieldmap files should be fetched manually. You can fetch them "
	einfo "by invoking command: "
	einfo
	einfo "wget -c ${SRC_URI} --no-check-certificate -O ${DISTDIR}/${CBMROOT_FIELDMAP}"
}

S="${WORKDIR}"

src_unpack() {
	# unpack in destination only to avoid copy
	return
}

src_install() {
	dodir "${EPREFIX}/usr/share/cbmroot/input"
	insinto "${EPREFIX}/usr/share/cbmroot/input/"
	doins ${DISTDIR}/${CBMROOT_FIELDMAP}
}
