# Copyright 2019 QIN Yuhao
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Automates and significantly simplifies a deployment of user defined processes and their dependencies on any resource management system using a given topology."
HOMEPAGE="http://dds.gsi.de/"
SRC_URI="http://dds.gsi.de/releases/dds/${PV}/${P}-Source.tar.gz"
S="${WORKDIR}/${P}-Source"
RESTRICT="mirror"

inherit cmake-utils

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	>=dev-util/cmake-3.11.0
	>=dev-libs/boost-1.67:="
RDEPEND="${DEPEND}"
BDEPEND=""

src_configure()
{
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${EPREFIX%/}/usr/lib/${PN}"
	)
	cmake-utils_src_configure
}

src_install()
{
	cmake-utils_src_install
	DDS_LOCATION="${EPREFIX%/}/usr/lib/DDS"
	DDSENV=9999${PN}
	cat > ${DDSENV} <<- EOF || die
	DDS_LOCATION="${DDS_LOCATION}"
	PATH="${DDS_LOCATION}/bin"
	ROOTPATH="${DDS_LOCATION}/bin"
	LDPATH="${DDS_LOCATION}/lib"
	EOF
	doenvd ${DDSENV}
	cat > DDS_env.sh <<- EOF
	eval LOCAL_DDS="\${HOME}/.DDS"
	## create a default configuration file if needed
	DDS_CFG=\$(dds-user-defaults --ignore-default-sid -p)
	if [ -z "\${DDS_CFG}" ]; then
		mkdir -pv \${LOCAL_DDS}
		dds-user-defaults --ignore-default-sid -d -c "\${LOCAL_DDS}/DDS.cfg"
	fi

	## set log directory for the server
	eval DDS_LOG_LOCATION=\$(dds-user-defaults --ignore-default-sid --key server.log_dir)
	export DDS_LOG_LOCATION
	EOF
	insinto ${EPREFIX%/}/etc/profile.d
	doins DDS_env.sh
}

pkg_postinst()
{
	einfo "Please source /etc/profile after installation to make DDS available."
}

