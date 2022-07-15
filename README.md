#Bash Scripts 

This reposistory is for stroring the bash scripts wiriten during devops training

##Percona Store Script

This script is used to backup and resptore mysql databases to and from AWS s3 bucket.

To use this script you need to have mysql and AWS client installed on you worksation.

the syntax for using the script is:
    for backup:
        percona_store -u <mysql-user> -b <s3-bucket-name> (additional parrameters can be view with -h oprion)
        select backup
        enter mysql password
    for restore:
        percona_store -u <mysql-user> -b <s3-bucket-name> -n <name-of-the-backup-file-in-s3-bucket>(additional parrameters can be view with -h oprion)
        select backup
        enter mysql password

###All backup files follow this nameing convention: <date-time-of-the-backup>-backup.sql