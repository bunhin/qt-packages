#!/bin/sh

basepath="`dirname "$0"`" ;
sudo -u postgres echo "sudo to postgres successful." && (
if [ "`sudo -u postgres psql -c '\l' | grep '^ xtuple '`" != "" ] ;
then
	echo "PostgreSQL database xtuple already exists; aborting." ;
else
	sudo -u postgres psql -U postgres -f "$basepath"/init.sql ;
	sudo -u postgres createdb -U postgres xtuple ;
	sudo -u postgres pg_restore -U postgres -d xtuple "$basepath"/postbooks_quickstart.backup -v ;
fi
)

