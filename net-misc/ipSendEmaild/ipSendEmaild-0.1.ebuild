# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit systemd

DESCRIPTION="send a email containing ip status automatically"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ssl"

DEPEND=""
RDEPEND="
sys-apps/iproute2
ssl? (
	net-mail/sendEmail[ssl]
	dev-perl/Net-SSLeay
	)
!ssl? ( 
	net-mail/sendEmail )"

src_unpack() {
	mkdir -pv ${S}
}
src_install() {
	newinitd "${FILESDIR}"/ipSendEmaild.rc6.4 ipSendEmaild
	systemd_dounit "${FILESDIR}"/ipSendEmaild.service
	mkdir -pv "${ED}"/usr/sbin
	install -Dvm755 "${FILESDIR}"/ipSendEmaild "${ED}"/usr/sbin/ipSendEmaild
	mkdir -pv "${ED}"/etc/ipSendEmaild/
}
pkg_postinst() {
	for i in /etc/ipSendEmaild/{from,fromuser,passwd,to,server}
	do if [ ! -e "$i" ]; then
		touch "$i"
		chmod 600 "$i"
	fi;done
	elog "You should file your information in \`/etc/ipSendEmaild/'"
	elog "\tfrom: email address to send from (address only)"
	elog "\tfromuser: [from] username of send server"
	elog "\tpasswd: passphrase of [from] user"
	elog "\tto: address to send to (can add name)"
	elog "\tserver: SMTP server to be used"
	}

