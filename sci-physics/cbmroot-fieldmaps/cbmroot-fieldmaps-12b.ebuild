# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Magnetic fieldmaps for CbmRoot"
HOMEPAGE="https://redmine.cbm.gsi.de/projects/cbmroot"
CBMROOT_FIELDMAPS="field_v${PV}.root"
SRC_COM="http://redmine.cbm.gsi.de/projects/cbmroot/repository/raw/fieldmaps"
for d in ${CBMROOT_FIELDMAPS}; do
	SRC_URI="${SRC_URI} ${SRC_COM}/${d}"
done
unset d

LICENSE="GPL-2"
SLOT="${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="sci-physics/cbmroot"
DEPEND="${RDEPEND}
	net-misc/wget"
# Server has no valid cert for Gentoo
FETCHCOMMAND="/usr/bin/wget --no-check-certificate \${URI} -P \${DISTFILES}" 
RESUMECOMMAND="/usr/bin/wget -c --no-check-certificate \${URI} -P \${DISTFILES}" 

S="${WORKDIR}"

src_unpack() {
	# unpack in destination only to avoid copy
	return
}

src_install() {
	dodir "${EPREFIX}/usr/share/cbmroot/input"
	for d in ${CBMROOT_FIELDMAPS}; do
		install -Dvm644 ${DISTDIR}/${d} "${D}/usr/share/cbmroot/input/"
	done
}
