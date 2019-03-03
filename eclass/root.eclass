# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: root.eclass
# @MAINTAINER:
# QIN Yuhao
# @AUTHOR:
# QIN Yuhao
# @BLURB: 
# @DESCRIPTION: Managing packages depending on ROOT

inherit multibuild cmake-utils
EXPORT_FUNCTIONS src_configure src_compile src_test src_install

if [[ "${ROOT_COMPAT}" != "" ]]; then
	ROOT_TARGETS=${ROOT_COMPAT}
else
	ROOT_TARGETS="root5_32 root5_34 root6_04 root6_05 root6_06 root6_08 root6_10 root6_11 root6_12 root6_13 root6_14"
fi

if [[ "${ROOT_REQUIRED_USE}" != "" ]]; then
	_ROOT_REQUIRED_USE="[${ROOT_REQUIRED_USE}]"
fi
for target in ${ROOT_TARGETS}; do
	IUSE_ROOT_TARGETS+=" root_target_${target}"
done
IUSE+=$IUSE_ROOT_TARGETS
REQUIRED_USE+="|| (${IUSE_ROOT_TARGETS} )"
get_root_deps() {
	if [[ ! -z "$2" ]]; then
		local extra_use=",$2"
	fi
	for target in ${ROOT_TARGETS}; do
		echo "root_target_${target}? ( ${1}[root_target_${target}${extra_use}] )"
	done
}
make_root_deps() {
	for target in ${ROOT_TARGETS}; do
		local my_pv=${target##root}
		my_pv=${my_pv//_/.}
		echo "root_target_${target}? ( sci-physics/root:${my_pv}${_ROOT_REQUIRED_USE} )"
	done
}
get_root_targets() {
	for target in ${ROOT_TARGETS}; do
		if use root_target_${target}; then
			echo ${target}
		fi
	done
}
RDEPEND+="$(make_root_deps)"
DEPEND+="${RDEPEND}"

root_src_configure() {
	local MULTIBUILD_VARIANTS=( $(get_root_targets) )
	multibuild_foreach_variant _root_multibuild_wrapper cmake-utils_src_configure $@
}

root_src_compile() {
	local MULTIBUILD_VARIANTS=( $(get_root_targets) )
	multibuild_foreach_variant cmake-utils_src_compile $@
}

root_src_test() {
	local MULTIBUILD_VARIANTS=( $(get_root_targets) )
	multibuild_foreach_variant cmake-utils_src_test $@
}

root_src_install() {
	local MULTIBUILD_VARIANTS=( $(get_root_targets) )
	multibuild_foreach_variant cmake-utils_src_install $@
}

_root_multibuild_wrapper() {
	debug-print-function ${FUNCNAME} "${@}"
	local rootpv=${MULTIBUILD_VARIANT##root}
	rootpv=${rootpv//_/.}
	export ROOT_DIR="${EPREFIX}/usr/$(get_libdir)/root/${rootpv}"
	echo $ROOT_DIR
	export ROOTSYS="${ROOT_DIR}"
	export PATH="${ROOT_DIR}/bin:${PATH}"
	mycmakeargs+=(
		-DROOT_DIR="${ROOT_DIR}"
		-DCMAKE_INSTALL_PREFIX="${ROOT_DIR}"
	)
	"${@}"
}


