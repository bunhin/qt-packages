#!/bin/sh
# This attempts to install xTuple on a yum-enabled system. Production deployments might benefit from a more manual approach than running this script in its entirety.

export yumrepopath="http://www.xtuple.org/sites/default/files/build/dist" ;

# We check whether present repositories provide qtwebkit.
yum info qtwebkit > /dev/null 2> /dev/null ;
if [ "$?" != 0 ] ;
then
	echo "qtwebkit is not available from presently configured repositories." ;
	# Try to add EPEL in order to satisfy the missing dependency if appropriate.
	if [ "`grep '^CentOS release 5[\. ]' /etc/redhat-release`" != "" ] ;
	then
		( cd /tmp && wget -a epel-dl.log http://dl.fedoraproject.org/pub/epel/5/`uname -m`/epel-release-5-4.noarch.rpm && sudo rpm -Uvh epel-release-5-4.noarch.rpm && rm epel-release-5-4.noarch.rpm epel-dl.log ; )
	elif [ "`grep '^CentOS release 6[\. ]' /etc/redhat-release`" != "" ] ;
	then
		( cd /tmp && wget -a epel-dl.log http://dl.fedoraproject.org/pub/epel/6/`uname -m`/epel-release-6-8.noarch.rpm && sudo rpm -Uvh epel-release-6-8.noarch.rpm && rm epel-release-6-8.noarch.rpm epel-dl.log ; )
	elif [ "`grep '^Red Hat [A-Za-z ]*release 5[\. ]' /etc/redhat-release`" != "" ] ;
	then
		( cd /tmp && wget -a epel-dl.log http://dl.fedoraproject.org/pub/epel/5/`uname -m`/epel-release-5-4.noarch.rpm && sudo rpm -Uvh epel-release-5-4.noarch.rpm && rm epel-release-5-4.noarch.rpm epel-dl.log ; )
	elif [ "`grep '^Red Hat [A-Za-z ]*release 6[\. ]' /etc/redhat-release`" != "" ] ;
	then
		( cd /tmp && wget -a epel-dl.log http://dl.fedoraproject.org/pub/epel/6/`uname -m`/epel-release-6-8.noarch.rpm && sudo rpm -Uvh epel-release-6-8.noarch.rpm && rm epel-release-6-8.noarch.rpm epel-dl.log ; )
	else
		echo "There is no built-in rule for this system. Please add the correct epel repository for your system and try again." ;
	fi ;
fi ;
# Check again.
yum info qtwebkit > /dev/null 2> /dev/null ;
if [ "$?" = 0 ] ;
then	
	if [ ! -e /etc/yum.repos.d/xtuple.repo ] ;
	then
		# We add the xtuple repository.
		cat > /etc/yum.repos.d/xtuple.repo << ACEOF
[xtuple]
name=xTuple
baseurl="$yumrepopath"/\$basearch
enabled=1
gpgcheck=0
ACEOF
	fi ;
	# yum can be touchy.
	yum clean metadata rpmdb ;
	yum --enablerepo=xtuple clean metadata ;
	# Install the packages.
	yum install xtuple-client xtuple-database xtuple-server yum-plugin-versionlock ;
	# Lock the package versions of all xtuple versions so as to avert database mismatches.
	yum versionlock add xtuple-client xtuple-database xtuple-server ;
	# Start the PostgreSQL service .
	/etc/init.d/postgresql start &&
	# Wait for PostgreSQL to really start .
	sleep 8 &&
	# Create and provision the xTuple database with standard options.
	/usr/lib/xtuple/database_setup.sh ;
	# Modify the PostgreSQL configuration so as to allow md5 authentication.
	(
		cd /var/lib/pgsql/data ;
		if [ "`cat pg_hba.conf | grep '\(host\)\([ \t]\+\)\(all\|xtuple\)\([ \t]\+\)\(all\)\([ \t]\+\)\(127.0.0.1/32\)\([ \t]\+\)\(md5\|password\)'`" = "" ] ;
		then
			mv pg_hba.conf pg_hba.conf.prextuple ;
			cat pg_hba.conf.prextuple | sed -e 's/\(host\)\([ \t]\+\)\(all\)\([ \t]\+\)\(all\)\([ \t]\+\)\(127.0.0.1\/32\)\([ \t]\+\)\([a-z]\+\)/\1\2xtuple\4\5\6\7\8md5\n\1\2\3\4\5\6\7\8\9/g' -e 's/\(host\)\([ \t]\+\)\(all\)\([ \t]\+\)\(all\)\([ \t]\+\)\(::1\/128\)\([ \t]\+\)\([a-z]\+\)/\1\2xtuple\4\5\6\7\8md5\n\1\2\3\4\5\6\7\8\9/g' > pg_hba.conf ;
		fi ;
	)
	# Restart PostgreSQL.
	/etc/init.d/postgresql restart ;
	# Enable the init job for PostgreSQL.
	chkconfig postgresql on ;
fi ;

# The following uninstall command may be helpful for testing the functionality of the script; it is not suitable for uninstalling the product in a non-testing environment as it removes things (such as PostgreSQL) on which other products may depend.
# sudo -u postgres psql -c 'drop database xtuple;' ; mv /var/lib/pgsql/data/pg_hba.conf.prextuple /var/lib/pgsql/pg_hba.conf ; /etc/init.d/postgresql stop ; chkconfig postgresql off ; yum remove xtuple-client xtuple-server postgresql postgresql-contrib postgresql-server xtuple-database qtwebkit epel-release ; rm -f /etc/yum.repos.d/xtuple.repo ; yum clean metadata rpmdb ;

