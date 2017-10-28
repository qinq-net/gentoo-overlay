# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="The utility to manipulate machine owner keys"
HOMEPAGE="https://github.com/lcp/mokutil"
inherit autotools
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/lcp/mokutil.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/lcp/mokutil/archive/${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi
LICENSE=""
SLOT="0"
IUSE=""

DEPEND="
	dev-libs/openssl:=
	sys-libs/efivar:="
RDEPEND="${DEPEND}"

src_prepare() {
	default
	eautoreconf
}
