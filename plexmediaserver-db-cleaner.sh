#!/bin/bash
#### Description: Upgrades plexmediaserver for debian/ubuntu based distros
####
#### Written by: poneli on 2021 October 3
#### Published on: https://github.com/poneli/
#### =====================================================================
#### <VARIABLES>
plexsqlite="/usr/lib/plexmediaserver/Plex SQLite"
plexdir="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases" # No trailing slash
plexdb="com.plexapp.plugins.library.db"
plexdb_bak="com.plexapp.plugins.library.db.bak"
plexdb_size=$(du -km "$plexdir/$plexdb" | awk '{print $1}')
#### </VARIABLES>
if [[ $EUID -gt 0 ]]; then
	printf "Run with sudo... \n"
	exit
fi
	printf "Stopping plexmediaserver ... \n"
	systemctl stop plexmediaserver
	printf "Backing up database to file %s ... \n" "$plexdb_bak"
	cp "$plexdir/$plexdb" "$plexdir/$plexdb_bak"
	printf "Plex dB is %sMB before cleanup/fix ... \n" "$plexdb_size"
	printf "Dumping dB to file dump.sql ... \n"
	$plexsqlite "$plexdir/$plexdb" ".output "$plexdir/dump.sql"" ".dump"
	printf "Deleting old Plex dB ... \n"
	rm "$plexdir/$plexdb"
	printf "Importing new Plex dB from dump.sql ... \n"
	$plexsqlite "$plexdir/$plexdb" ".read "$plexdir/dump.sql""
	printf "Changing owner of Plex dB ... \n"
	chown plex:plex "$plexdir/$plexdb"
	printf "Plex dB is %sMB after cleanup/fix ... \n" "$plexdb_size"
	printf "Cleanup files ... \n"
	rm "$plexdir/dump.sql" "$plexdir/com.plexapp.plugins.library.db-shm" "$plexdir/com.plexapp.plugins.library.db-wal"
	printf "Starting plexmediaserver ... \n"
	printf "Done ... \n"
exit 0
