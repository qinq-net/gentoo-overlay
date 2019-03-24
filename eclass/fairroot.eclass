# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: fairroot.eclass
# @MAINTAINER:
# QIN Yuhao
# @AUTHOR:
# QIN Yuhao
# @BLURB: 
# @DESCRIPTION: Managing packages depending on FairRoot

inherit root

_root_multibuild_wrapper() {
	debug-print-function ${FUNCNAME} "${@}"
	export SIMPATH=${EPREFIX}/usr
	local rootpv=${MULTIBUILD_VARIANT##root}
	rootpv=${rootpv//_/.}
	export ROOT_DIR="${EPREFIX}/usr/lib/root/${rootpv}"
	export FAIRROOTPATH=${ROOT_DIR}
	export ROOTSYS=${ROOT_DIR}
	export PATH="${ROOT_DIR}/bin:${PATH}"
	mycmakeargs+=(
		-DROOT_DIR=${ROOT_DIR}
		-DCMAKE_INSTALL_PREFIX=${ROOT_DIR}
		-DGEANT3_PATH=${ROOT_DIR}
	)
	"${@}"
}
