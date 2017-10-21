# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="http://root.cern.ch/git/root.git"
	KEYWORDS=""
else
	SRC_URI="ftp://root.cern.ch/${PN}/${PN}_v${PV}.source.tar.gz"
	KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
	S="${WORKDIR}/${PN}-${PV}"
fi

PYTHON_COMPAT=( python2_7 )

inherit elisp-common eutils fdo-mime fortran-2 multilib python-single-r1 \
	toolchain-funcs user versionator cmake-utils
CMAKE_BUILD_TYPE=Release

DESCRIPTION="C++ data analysis framework and interpreter from CERN"
HOMEPAGE="http://root.cern.ch/"
DOC_URI="ftp://root.cern.ch/${PN}/doc"

SLOT="0/$(get_version_component_range 1-3 ${PV})"
LICENSE="LGPL-2.1 freedist MSttfEULA LGPL-3 libpng UoI-NCSA"
IUSE="+X afs avahi doc emacs examples fits fftw geocad graphviz
	http kerberos ldap +math minimal mpi mysql odbc +opengl openmp
	oracle postgres	prefix pythia6 pythia8 python qt4 sqlite ssl
	xinetd xml xrootd ruby"

# TODO: add support for: davix
# TODO: ROOT-6 supports x32 ABI, but half of its dependencies doesn't
# TODO: unbundle: cling, vdt

REQUIRED_USE="
	mpi? ( math !openmp )
	opengl? ( X )
	openmp? ( math !mpi )
	python? ( ${PYTHON_REQUIRED_USE} )
	qt4? ( X )
"

CDEPEND="
	app-arch/xz-utils:0=
	>=dev-lang/cfortran-4.4-r2
	dev-libs/libpcre:3=
	media-fonts/dejavu
	media-libs/freetype:2=
	media-libs/giflib:0=
	media-libs/libpng:0=
	media-libs/tiff:0=
	>=sys-devel/clang-3.4:=
	sys-libs/zlib:0=
	virtual/jpeg:0
	virtual/shadow
	X? (
		media-libs/ftgl:0=
		media-libs/glew:0=
		x11-libs/libX11:0=
		x11-libs/libXext:0=
		x11-libs/libXpm:0=
		!minimal? (
			opengl? ( virtual/opengl virtual/glu x11-libs/gl2ps:0= )
			qt4? (
				dev-qt/qtgui:4=
				dev-qt/qtopengl:4=
				dev-qt/qt3support:4=
				dev-qt/qtsvg:4=
				dev-qt/qtwebkit:4=
				dev-qt/qtxmlpatterns:4=
			)
			x11-libs/libXft:0=
		)
	)
	!minimal? (
		afs? ( net-fs/openafs )
		avahi? ( net-dns/avahi:0=[mdnsresponder-compat] )
		emacs? ( virtual/emacs )
		fits? ( sci-libs/cfitsio:0= )
		fftw? ( sci-libs/fftw:3.0= )
		geocad? ( sci-libs/opencascade:= )
		graphviz? ( media-gfx/graphviz:0= )
		http? ( dev-libs/fcgi:0= )
		kerberos? ( virtual/krb5 )
		ldap? ( net-nds/openldap:0= )
		math? (
			sci-libs/gsl:0=
			sci-mathematics/unuran:0=
			mpi? ( virtual/mpi )
		)
		mysql? ( virtual/mysql )
		odbc? ( || ( dev-db/libiodbc:0 dev-db/unixODBC:0 ) )
		oracle? ( dev-db/oracle-instantclient-basic:0= )
		postgres? ( dev-db/postgresql:= )
		pythia6? ( sci-physics/pythia:6= )
		pythia8? ( >=sci-physics/pythia-8.1.80:8= )
		python? ( ${PYTHON_DEPS} )
		sqlite? ( dev-db/sqlite:3= )
		ssl? ( dev-libs/openssl:0= )
		xml? ( dev-libs/libxml2:2= )
		xrootd? ( >=net-libs/xrootd-3.3.5:0= )
		ruby? (
			dev-lang/ruby
			dev-ruby/rubygems
		)
	)"

# TODO: ruby is not yet ported to ROOT-6, reenable when (if?) ready
#
# TODO: root-6.00.01 crashes with system libafterimage
#			|| (
#				media-libs/libafterimage:0=[gif,jpeg,png,tiff]
#				>=x11-wm/afterstep-2.2.11:0=[gif,jpeg,png,tiff]
#			)
#			--disable-builtin-afterimage

DEPEND="${CDEPEND}
	virtual/pkgconfig"

RDEPEND="${CDEPEND}
	xinetd? ( sys-apps/xinetd )"

PDEPEND="doc? ( ~app-doc/root-docs-${PV}[http=,math=] )"

# install stuff in ${P} and not ${PF} for easier tracking in root-docs
DOC_DIR="/usr/share/doc/${P}"

die_compiler() {
	die "Need one of the following C++11 capable compilers:"\
		"    >=sys-devel/gcc[cxx]-4.8"\
		"    >=sys-devel/clang-3.4"\
		"    >=dev-lang/icc-13"
}

pkg_setup() {
	fortran-2_pkg_setup
	use python && python-single-r1_pkg_setup
	echo
	elog "There are extra options on packages not yet in Gentoo:"
	elog "Afdsmgrd, AliEn, castor, Chirp, dCache, gfal, Globus, gLite,"
	elog "HDFS, Monalisa, MaxDB/SapDB, SRP."
	elog "You can use the env variable EXTRA_ECONF variable for this."
	elog "For example, for SRP, you would set: "
	elog "EXTRA_ECONF=\"--enable-srp --with-srp-libdir=${EROOT%/}/usr/$(get_libdir)\""
	echo

	enewgroup rootd
	enewuser rootd -1 -1 /var/spool/rootd rootd

	use minimal && return

	if use math; then
		if use openmp; then
			if [[ $(tc-getCXX)$ == *g++* ]] && ! tc-has-openmp; then
				ewarn "You are using a g++ without OpenMP capabilities"
				die "Need an OpenMP capable compiler"
			else
				export USE_OPENMP=1 USE_PARALLEL_MINUIT2=1
			fi
		elif use mpi; then
			export USE_MPI=1 USE_PARALLEL_MINUIT2=1
		fi
	fi

	# check for supported compilers
	case $(tc-getCXX) in
		*g++*)
			if ! version_is_at_least "4.8" "$(gcc-version)"; then
				eerror "You are using a g++ without C++11 capabilities"
				die_compiler
			fi
		;;
		*clang++*)
			# >=clang-3.4 is already in DEPEND
		;;
		*icc*|*icpc*)
			if ! version_is_at_least "13" "$(has_version dev-lang/icc)"; then
				eerror "You are using an icc without C++11 capabilities"
				die_compiler
			fi
		;;
		*)
			ewarn "You are using an unsupported compiler."
			ewarn "Please report any issues upstream."
		;;
	esac
}

src_prepare() {
	# epatch \
	# 	"${FILESDIR}"/${PN}-5.28.00b-glibc212.patch \
	# 	"${FILESDIR}"/${PN}-5.32.00-afs.patch \
	# 	"${FILESDIR}"/${PN}-5.32.00-cfitsio.patch \
	# 	"${FILESDIR}"/${PN}-5.32.00-chklib64.patch \
	# 	"${FILESDIR}"/${PN}-6.00.01-dotfont.patch \
	# 	"${FILESDIR}"/${PN}-6.10.08-minuit2-cmakelist.patch
	default
	# make sure we use system libs and headers
	rm montecarlo/eg/inc/cfortran.h README/cfortran.doc || die
	#rm -r graf2d/asimage/src/libAfterImage || die
	rm -r graf3d/ftgl/{inc,src} || die
	rm -r graf2d/freetype/src || die
	rm -r graf3d/glew/{inc,src} || die
	rm -r core/pcre/src || die
	rm -r math/unuran/src/unuran-*.tar.gz || die
	LANG=C LC_ALL=C find core/zip -type f -name "[a-z]*" -print0 | \
		xargs -0 rm || die
	rm -r core/lzma/src/*.tar.gz || die
	rm graf3d/gl/src/gl2ps.* || die
	sed -i -e 's/^GLLIBS *:= .* $(OPENGLLIB)/& -lgl2ps/' \
		graf3d/gl/Module.mk || die

	# In Gentoo, libPythia6 is called libpythia6
	# iodbc is in /usr/include/iodbc
	# pg_config.h is checked instead of libpq-fe.h
	sed -i \
		-e 's:libPythia6:libpythia6:g' \
		-e 's:$ODBCINCDIR:$ODBCINCDIR /usr/include/iodbc:' \
		-e 's:libpq-fe.h:pg_config.h:' \
		configure || die "adjusting configure for Gentoo failed"

	# prefixify the configure script
	sed -i \
		-e 's:/usr:${EPREFIX}/usr:g' \
		configure || die "prefixify configure failed"

	# CSS should use local images
	sed -i -e 's,http://.*/images/,,' etc/html/ROOT.css || die "html sed failed"

	cmake-utils_src_prepare
}


src_configure() { # Using CMake
	export ORACLE_DIR="${EPREFIX}/usr/$(get_libdir)/oracle/12.2/client"
	local mycmakeargs=(
		#-Dafterimage=OFF
		#-DAFTERIMAGE_CONFIG_EXCUTABLE=
		-Dafdsmgrd=OFF
		-Dafs=$(usex X)
		-Dalien=OFF
		#-DALIEN_DIR=
		-Dall=OFF
		-Dastiff=ON
		-Dasimage=$(usex X)
		-Dbonjour=$(usex avahi)
		$(usex avahi \
			"-DBONJOUR_INCLUDE_DIR=${EPREFIX}/usr/include \
			-DAVAHI_INCLUDE_DIR=${EPREFIX}/usr/include/avahi-client \
			-DAVAHI_client_LIBRARY=${EPREFIX}/usr/$(get_libdir)" "")
		-Dbuiltin_afterimage=OFF
		-Dbuiltin_fttw3=OFF
		-Dbuiltin_ftgl=OFF
		-Dbuiltin_freetype=OFF
		-Dbuiltin_glew=OFF
		-Dbuiltin_pcre=OFF
		-Dbuiltin_zlib=OFF
		-Dbuiltin_lzma=OFF
		-Dbuiltin_davix=ON
		-Dbuiltin_gsl=OFF
		-Dbuiltin_cfitsio=OFF
		-Dbuiltin_xrootd=OFF
		-Dbuiltin_llvm=ON
		-Dbuiltin_tbb=ON
		-Dcxx11=ON
		-Dcxx14=OFF
		-Dcxx17=OFF
		-Dcastor=OFF
		#-DCASTOR_DIR=
		#-DCASTOR_INCLUDE_DIR=
		#-DCASTOR_shift_LIBRARY=
		-Dccache=OFF
		-Dchirp=OFF
		-Dcling=ON
		-Ddavix=OFF
		-Ddcache=OFF
		-Dexceptions=ON
		-Dexplicitlink=ON
		-Dfail-on-missing=ON
		-Dfftw3=$(usex fftw)
		#$(usex fftw \
		#	"-DFFTW_DIR=${EPREFIX}/usr \
		#	-DFFTW_INCLUDE_DIR=${EPREFIX}/usr/include \
		#	-DFFTW_LIBRARY=${EPREFIX}/usr/$(get_libdir)" "")
		-Dfitsio=$(usex fits)
		#$(usex fits \
		#	"-DCFITSIO=${EPREFIX}/usr \
		#	-DCFITSIO_INCLUDE_DIR=${EPREFIX}/usr/include \
		#	-DCFITSIO_LIBRARIES=${EPREFIX}/usr/$(get_libdir)" "")
		-Dfortran=ON
		-Dgdml=ON
		-Dgeocad=$(usex geocad)
		-Dgenvector=$(usex math)
		-Dgfal=OFF
		#-Dgl2ps=ON
		-Dglite=OFF
		-Dglobus=OFF
		-Dgnuinstall=ON
		-Dgsl-shared=$(usex math)
		-Dgviz=$(usex graphviz)
		#$(usex graphviz \
		#	"-DGRAPHVIZ=${EPREFIX}/usr \
		#	-DGRAPHVIZ_INCLUDE_DIR=${EPREFIX}/usr/include \
		#	-DGRAPHVIZ_CDT_LIBRARY=${EPREFIX}/usr/$(get_libdir) \
		#	-DGRAPHVIZ_GVC_LIBRARY=${EPREFIX}/usr/$(get_libdir) \
		#	-DGRAPHVIZ_PATHPLAN_LIBRARY=${EPREFIX}/usr/$(get_libdir)" "")
		-Dhdfs=OFF
		-Dhttp=$(usex http)
		-Dimt=ON
		-Djemalloc=OFF
		-Dkrb5=$(usex kerberos)
		-Dldap=$(usex ldap)
		-Dmathmore=$(usex math)
		-Dmemstat=ON
		-Dgminimal=OFF
		#-Dminuit2=$(usex math)# Potential buggy
		-Dmonalisa=OFF
		-Dmt=ON# from Arch Linux
		-Dmysql=$(usex mysql)
		-Dodbc=$(usex odbc)
		-Dopengl=$(usex opengl)
		-Doracle=$(usex oracle)
		$(usex oracle \
			"-DORACLE_PATH_INCLUDES=${EPREFIX}/usr/$(get_libdir)/oracle/12.2/client/rdbms/public \
			-DORACLE_PATH_LIB=${EPREFIX}/usr/$(get_libdir)/oracle/12.2/client/$(get_libdir)" "")
		-Dpgsql=$(usex postgres)
		$(usex postgres \
			"-DPOSTGRESQL_INCLUDE_DIR=$(pg_config --includedir)" "")
		-Dpythia6=$(usex pythia6)
		-Dpythia6_nolink=OFF
		-Dpythia8=$(usex pythia8)
		-Dpython=$(usex python)
		-Dqt=$(usex qt4)
		-Dqtgsi=$(usex qt4)
		-Droofit=$(usex math)
		-Droot7=OFF
		-Droottest=OFF
		-Druby=$(usex ruby)
		-Dr=OFF
		-Drfio=OFF
		-Drpath=$(usex prefix)
		-Dsapdb=OFF
		-Dshadowpw=ON
		-Dshared=ON
		-Dsoversion=ON
		-Dsqlite=$(usex sqlite)
		-Dsrp=OFF
		-Dssl=$(usex ssl)
		-Dtbb=OFF
		-Dtable=ON
		-Dtcmalloc=OFF
		-Dtesting=OFF
		-Dthreadd=ON
		-Dtmva=$(usex math)
		-Dunuran=$(usex math)
		#-Dvc=$(usex math)
		#-Dvdt=$(usex math)
		-Dxft=$(usex X)
		-Dxml=$(usex xml)
		-Dxrootd=$(usex xrootd)
		-Dx11=$(usex X)
	)
	cmake-utils_src_configure
}

src_compile() {
	sed -i -e 's/-lgsl/-lgsl -lgslcblas/' ${S}_build/math/mathmore/CMakeFiles/MathMore.dir/link.txt
	touch ${S}_build/tutorials/hsimple.root
	cmake-utils_src_compile
	rm ${S}_build/tutorials/hsimple.root
	make -C ${S}_build hsimple
}

daemon_install() {
	local daemons="rootd proofd"
	dodir /var/spool/rootd
	fowners rootd:rootd /var/spool/rootd
	dodir /var/spool/rootd/{pub,tmp}
	fperms 1777 /var/spool/rootd/{pub,tmp}

	for i in ${daemons}; do
		newinitd "${FILESDIR}"/${i}.initd ${i}
		newconfd "${FILESDIR}"/${i}.confd ${i}
	done
	if use xinetd; then
		insinto /etc/xinetd
		doins "${S}_build"/etc/daemons/{rootd,proofd}.xinetd
	fi
}

desktop_install() {
	cd "${S}_build"
	# tmva/test should exist
	echo "Icon=root-system-bin" >> etc/root.desktop
	domenu etc/root.desktop
	doicon build/package/debian/root-system-bin.png

	insinto /usr/share/icons/hicolor/48x48/mimetypes
	doins build/package/debian/application-x-root.png

	insinto /usr/share/icons/hicolor/48x48/apps
	doicon build/package/debian/root-system-bin.xpm
}

cleanup_install() {
	# Cleanup of files either already distributed or unused on Gentoo
	pushd "${ED}" > /dev/null
	rm usr/share/root/fonts/LICENSE || die
	rm etc/root/proof/*.sample || die
	rm -r etc/root/daemons || die
	# these should be in PATH
	mv etc/root/proof/utils/pq2/pq2* usr/bin/ || die
	rm ${DOC_DIR#/}/{INSTALL,LICENSE} || die
	use examples || rm -r ${DOC_DIR#/}/examples || die
}

src_install() {
	# Write access to /dev/random is required to run root.exe
	# More information at https://sft.its.cern.ch/jira/browse/ROOT-8146
	addwrite /dev/random

	mkdir -pv "${S}_build/tmva/test" || true
	DOCS=($(find README/* -maxdepth 1 -type f))
	cmake-utils_src_install
	dodoc README.md

	echo "LDPATH=${EPREFIX%/}/usr/$(get_libdir)/root" > 99root

	if ! use minimal; then
		use pythia8 && echo "PYTHIA8=${EPREFIX%/}/usr" >> 99root
		if use python; then
			echo "PYTHONPATH=${EPREFIX%/}/usr/$(get_libdir)/root" >> 99root
			python_optimize "${D}/usr/$(get_libdir)/root"
		fi
		use emacs && elisp-install ${PN} build/misc/*.{el,elc}
		if use examples; then
			# these should really be taken care of by the root make install
			insinto ${DOC_DIR}/examples/tutorials/tmva
			doins -r tmva/test
		fi
	fi
	doenvd 99root

	# The build system installs Emacs support unconditionally in the wrong
	# directory. Remove it and call elisp-install in case of USE=emacs.
	rm -r "${ED}"/usr/share/emacs || die

	daemon_install
	#desktop_install
	#cleanup_install

	# do not copress files used by ROOT's CLI (.credit, .demo, .license)
	docompress -x "${DOC_DIR}"/{CREDITS,LICENSE,examples/tutorials}
	# needed for .license command to work
	dosym "${ED}"usr/portage/licenses/LGPL-2.1 "${DOC_DIR}/LICENSE"
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
