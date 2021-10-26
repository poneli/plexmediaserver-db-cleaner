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
	sudo systemctl stop plexmediaserver
	cd "$plexdir"
	printf "Backing up database to file %s ... \n" "$plexdb_bak"
	sudo cp "$plexdb" "$plexdb_bak"
	printf "Plex dB is %sMB before cleanup/fix ... \n" "$plexdb_size"
	printf "Dumping dB to file dump.sql ... \n"
	sudo "$plexsqlite" "$plexdb" ".output dump.sql" ".dump"
	sleep 1
	printf "Deleting old Plex dB ... \n"
	sudo rm "$plexdb"
	printf "Importing new Plex dB from dump.sql ... \n"
	sudo "$plexsqlite" "$plexdb" ".read dump.sql"
	sleep 1
	printf "Changing owner of Plex dB ... \n"
	sudo chown plex:plex "$plexdb"
	printf "Plex dB is %sMB after cleanup/fix ... \n" "$plexdb_size"
	printf "Cleanup files ... \n"
	sudo rm dump.sql com.plexapp.plugins.library.db-shm com.plexapp.plugins.library.db-wal 2>&1 >/dev/null
	printf "Starting plexmediaserver ... \n"
	sudo systemctl start plexmediaserver
	printf "Done ... \n"
exit 0
