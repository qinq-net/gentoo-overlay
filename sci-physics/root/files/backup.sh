# NB: ROOT uses bundled LLVM, because it is patched and API-incompatible with
# system LLVM.
# NB: As of 6.00.0.1 cmake is not ready as it can't fully replace configure,
# e.g. for afs and geocad.

# src_configure() {
# 	local -a myconf
# 	# Some compilers need special care
# 	case $(tc-getCXX) in
# 		*clang++*)
# 			myconf=(
# 				--with-clang
# 				--with-f77="$(tc-getFC)"
# 			)
# 		;;
# 		*icc*|*icpc*)
# 			# For icc we need to provide architecture manually
# 			# and not to tamper with tc-get*
# 			use x86 && myconf=( linuxicc )
# 			use amd64 && myconf=( linuxx8664icc )
# 		;;
# 		*)	# gcc goes here too
# 			myconf=(
# 				--with-cc="$(tc-getCC)"
# 				--with-cxx="$(tc-getCXX)"
# 				--with-f77="$(tc-getFC)"
# 				--with-ld="$(tc-getCXX)"
# 			)
# 		;;
# 	esac
# 
# 	# the configure script is not the standard autotools
# 	myconf+=(
# 		--prefix="${EPREFIX}/usr"
# 		--etcdir="${EPREFIX}/etc/root"
# 		--libdir="${EPREFIX}/usr/$(get_libdir)/${PN}"
# 		--docdir="${EPREFIX}${DOC_DIR}"
# 		--tutdir="${EPREFIX}${DOC_DIR}/examples/tutorials"
# 		--testdir="${EPREFIX}${DOC_DIR}/examples/tests"
# 		--disable-werror
# 		--nohowto
# 	)
# 
# 	if use minimal; then
# 		myconf+=( $(usex X --gminimal --minimal) )
# 	else
# 		myconf+=(
# 			--with-afs-shared=yes
# 			--with-sys-iconpath="${EPREFIX}/usr/share/pixmaps"
# 			--disable-builtin-ftgl
# 			--disable-builtin-freetype
# 			--disable-builtin-glew
# 			--disable-builtin-pcre
# 			--disable-builtin-zlib
# 			--disable-builtin-lzma
# 			--enable-astiff
# 			--enable-explicitlink
# 			--enable-gdml
# 			--enable-memstat
# 			--enable-shadowpw
# 			--enable-shared
# 			--enable-soversion
# 			--enable-table
# 			--fail-on-missing
# 			--cflags='${CFLAGS}'
# 			--cxxflags='${CXXFLAGS}'
# 			$(use_enable X x11)
# 			$(use_enable X asimage)
# 			$(use_enable X xft)
# 			$(use_enable afs)
# 			$(use_enable avahi bonjour)
# 			$(use_enable fits fitsio)
# 			$(use_enable fftw fftw3)
# 			$(use_enable geocad)
# 			$(use_enable graphviz gviz)
# 			$(use_enable http)
# 			$(use_enable kerberos krb5)
# 			$(use_enable ldap)
# 			$(use_enable math genvector)
# 			$(use_enable math gsl-shared)
# 			$(use_enable math mathmore)
# 			$(use_enable math minuit2)
# 			$(use_enable math roofit)
# 			$(use_enable math tmva)
# 			$(use_enable math vc)
# 			#$(use_enable math vdt)
# 			$(use_enable math unuran)
# 			$(use_enable mysql)
# 			$(usex mysql \
# 				"--with-mysql-incdir=${EPREFIX}/usr/include/mysql" "")
# 			$(use_enable odbc)
# 			$(use_enable opengl)
# 			$(use_enable oracle)
# 			$(use_enable postgres pgsql)
# 			$(usex postgres \
# 				"--with-pgsql-incdir=$(pg_config --includedir)" "")
# 			$(use_enable prefix rpath)
# 			$(use_enable pythia6)
# 			$(use_enable pythia8)
# 			$(use_enable python)
# 			$(use_enable qt4 qt)
# 			$(use_enable qt4 qtgsi)
# 			$(use_enable sqlite)
# 			$(use_enable ssl)
# 			$(use_enable xml)
# 			$(use_enable xrootd)
# 			$(use_enable imt)
# 			${EXTRA_ECONF}
# 		)
# 	fi
# 
# 	./configure ${myconf[@]} || die "configure failed"
# }
#  
# src_compile() {
# 	emake \
# 		OPT="${CXXFLAGS}" \
# 		F77OPT="${FFLAGS}" \
# 		ROOTSYS="${S}" \
# 		LD_LIBRARY_PATH="${S}/lib"
# 	use emacs && ! use minimal && elisp-compile build/misc/*.el
# }
