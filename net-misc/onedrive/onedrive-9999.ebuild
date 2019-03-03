# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Free Client for OneDrive on Linux"
HOMEPAGE="https://skilion.github.io/onedrive/"
inherit eutils git-r3
EGIT_REPO_URI="https://github.com/abraunegg/onedrive"
#SRC_URI=""

LICENSE="GPL-v3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="net-misc/curl[curl_ssl_openssl]
		dev-db/sqlite
		dev-lang/dmd"
RDEPEND="${DEPEND}"

MAKEOPTS+=" PREFIX=${EPREFIX}/usr"
