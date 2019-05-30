#!/bin/bash

#
# Bash script for creating backups of Wordpress.
#
# Version 0.1.0
#
# Usage:
# 	- With backup directory specified in the script:  ./WordpressBackup.sh
# 	- With backup directory specified by parameter: ./WordpressBackup.sh <BackupDirectory> (e.g. ./WordpressBackup.sh /media/hdd/wordpress_backup)
#

#
# IMPORTANT
# You have to customize this script (directories, users, etc.) for your actual environment.
# All entries which need to be customized are tagged with "TODO".
#

# Variables
backupMainDir=$1

if [ -z "$backupMainDir" ]; then
    # TODO: The directory where you store the Wordpress backups (when not specified by args)
    backupMainDir='/media/hdd/wordpress_backup'
fi

echo "Backup directory: $backupMainDir"

currentDate=$(date +"%Y%m%d_%H%M%S")

# The actual directory of the current backup - this is a subdirectory of the main directory above with a timestamp
backupdir="${backupMainDir}/${currentDate}/"

# TODO: The directory of your Wordpress installation (this is a directory under your web root)
wordpressFileDir='/var/www/wordpress'

# TODO: The service name of the web server. Used to start/stop web server (e.g. 'systemctl start <webserverServiceName>')
webserverServiceName='nginx'

# TODO: Your Wordpress database name
wordpressDatabase='wordpress_db'

# TODO: Your Wordpress database user
dbUser='wordpress_db_user'

# TODO: The password of the Wordpress database user
dbPassword='mYpAsSw0rd'

# TODO: The maximum number of backups to keep (when set to 0, all backups are kept)
maxNrOfBackups=0

# File name for file backup
# If you prefer another file name, you'll also have to change the WordpressRestore.sh script.
fileNameBackupFileDir='wordpress-filedir.tar.gz'

# File name for database dump
fileNameBackupDb='wordpress-db.sql'

# Function for error messages
errorecho() { cat <<< "$@" 1>&2; }

# Capture CTRL+C
trap CtrlC INT

function CtrlC() {
	echo "Backup cancelled."
	exit 1
}

#
# Check for root
#
if [ "$(id -u)" != "0" ]
then
	errorecho "ERROR: This script has to be run as root!"
	exit 1
fi

#
# Check if backup dir already exists
#
if [ ! -d "${backupdir}" ]
then
	mkdir -p "${backupdir}"
else
	errorecho "ERROR: The backup directory ${backupdir} already exists!"
	exit 1
fi

#
# Stop web server
#
echo "Stopping web server..."
systemctl stop "${webserverServiceName}"
echo "Done"
echo

#
# Backup file directory
#
echo "Creating backup of Wordpress file directory..."
tar -cpzf "${backupdir}/${fileNameBackupFileDir}" -C "${wordpressFileDir}" .
echo "Done"
echo

#
# Backup DB
#
echo "Backup Wordpress database..."

if ! [ -x "$(command -v mysqldump)" ]; then
    errorecho "ERROR: MySQL/MariaDB not installed (command mysqldump not found)."
    errorecho "ERROR: No backup of database possible!"
else
    mysqldump --single-transaction -h localhost -u "${dbUser}" -p"${dbPassword}" "${wordpressDatabase}" > "${backupdir}/${fileNameBackupDb}"
fi

echo "Done"
echo


#
# Start web server
#
echo "Starting web server..."
systemctl start "${webserverServiceName}"
echo "Done"
echo


#
# Delete old backups
#
if [ ${maxNrOfBackups} != 0 ]
then
	nrOfBackups=$(ls -l ${backupMainDir} | grep -c ^d)

	if [[ ${nrOfBackups} > ${maxNrOfBackups} ]]
	then
		echo "Removing old backups..."
		ls -t ${backupMainDir} | tail -$(( nrOfBackups - maxNrOfBackups )) | while read -r dirToRemove; do
			echo "${dirToRemove}"
			rm -r "${backupMainDir}/${dirToRemove:?}"
			echo "Done"
			echo
		done
	fi
fi

echo
echo "DONE!"
echo "Backup created: ${backupdir}"