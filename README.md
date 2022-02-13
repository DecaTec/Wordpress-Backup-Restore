<a href="https://codeberg.org/DecaTec/Wordpress-Backup-Restore">
    <img alt="Get it on Codeberg" src="https://get-it-on.codeberg.org/get-it-on-blue-on-white.png" height="60">
</a>

### ⚠️ Archived, moved to Codeberg: https://codeberg.org/DecaTec/Wordpress-Backup-Restore ⚠️

Thus, this GitHub repository is **outdated** and **not longer maintained on GitHub**. Please update your references.

# Wordpress-Backup-Restore

This repository contains two bash scripts for backup/restore of [Wordpress](https://wordpress.org).

## General information

For a complete backup of any Wordpress instance, you'll have to backup these items:
- The Wordpress file directory (usually */var/www/wordpress*)
- The Wordpress database

The scripts take care of these items to backup automatically.

**Important:**

- After cloning or downloading the repository, you'll have to edit the scripts so that they represent your current Wordpress installation (directories, users, etc.). All values which need to be customized are marked with *TODO* in the script's comments.

## Backup

In order to create a backup, simply call the script *WordpressBackup.sh* on your Wordpress machine.
If this script is called without parameter, the backup is saved in a directory with the current time stamp in your main backup directory: As an example, this would be */media/hdd/wordpress_backup/20170910_132703*.
The backup script can also be called with a parameter specifiying the main backup directory, e.g. *./WordpressBackup.sh /media/hdd/nwordpress_backup*. In this case, the directory specified will be used as main backup directory. 

## Restore

For restore, just call *WordpressRestore.sh*. This script expects at least one parameter specifying the name of the backup to be restored. In our example, this would be *20170910_132703* (the time stamp of the backup created before). The full command for a restore would be *./WordpressRestore.sh 20170910_132703*.
You can also specify the main backup directory with a second parameter, e.g. *./WordpressRestore.sh 20170910_132703 /media/hdd/wordpress_backup*.
