#!/bin/bash

DIRECTORY="/tmp/data/backups/mysql/"
DATE=$(date +"%d-%m-%Y-%H:%M")

function main(){
  mysql_check
  handle_args "$@"
  select_action
  exit 0
}

#select to either backup or restore
function select_action(){
  local COUNTER=4
  select mode in RESTORE BACKUP
  do 
    case $mode in
      RESTORE)
        restore 
        break
        ;;
      BACKUP)
        backup
        break
        ;;
      *)
        COUNTER=$((COUNTER-1))
        if [ $COUNTER == 0 ]; then
          echo "Ivalid option $REPLY. Command execution aborted"
          exit 2
        fi
        echo "Ivalid option $REPLY. Number of tries left: $COUNTER"
        ;;
    esac
  done
}

# Check that mysql is installed 
function mysql_check(){
  if ! which mysql; then
    echo "ERROR: MySQL missing. Please install MySQL before running this command"
    exit 1
  fi
}

#handle the options passed to the script and their arguments
function handle_args(){
  PARSED_ARGUMENTS=$(getopt -a -n percona_store -o hs:u:p:b:d:t: -l help,mysql-server:,mysql-user:,mysql-password:,s3bucket:,s3bucket-connection-details:target-dir: "$@")
  while :; do
    case $1 in 
     -h|--help)
        help
        exit
        ;;
     -u|--mysql-user)
        USER=$2
        argument_log "user"
        shift 2
        ;;
     -n|--name)
        NAME=$2
        argument_log "name"
        shift 2
        ;;
     -b|--s3bucket)
        BUCKET=$2
        argument_log "s3 bucket"
        shift 2
        ;;
     -c|--aws-configs)
        CONFIGS=$2
        argument_log "aws configurations file"
        shift 2
        ;;
     -t|--target-dir)
        DIRECTORY=$2
        argument_log "target directory"
        shift 2
        ;;
     -?*)
        echo "Invalid option $1"
        exit 1
      ;;
     *)
        break;;
    esac
  done
  echo
}

function restore(){
  echo "*******************RESTORE SELECTED*******************"
  echo
  restore_check
  echo "starting restoring process"
  aws_download
  mysql -u "$USER" -p < "$DIRECTORY/$NAME"
  echo "restoring process finsihed"

}

function backup(){
  echo "*******************BACKUP SELECTED*******************"
  echo
  echo "starting backup process"
  local_backup
  aws_upload
  echo "backup process finsihed"
}

function local_backup(){
  backup_check
  configure_backup
  mysqldump -u "$USER" --all-databases > "$DIRECTORY/$DATE-backup.sql"
}

function aws_upload(){
  aws_check
  aws_config
  aws s3 cp "$DIRECTORY/$DATE-backup.sql" s3://"$BUCKET"/
}

function aws_download(){
  aws_check
  aws s3 cp s3://"$BUCKET"/"$NAME" "$DIRECTORY"
}

#check that aws client is installed before trying to connect to s3 bucket
function aws_check(){
  echo "checking for aws client"

  if ! which aws >> /dev/null 2>&1; then
    echo "ERROR: AWS client missing. Please install aws client before running the script"
    exit 1
  fi
}

function aws_config(){
  if [ -z "$CONFIGS" ]; then
    aws configure import --csv "$CONFIGS"
  fi
}

# check that everything necessary to restore is ready
function restore_check(){
  echo "restore checks running"

  if [ ! -d "$DIRECTORY"/ ]; then
    echo "no file $DIRECTORY exists on local machine"
    exit 1
  fi

  echo "restore checks over"
}


# check that everything necessary to backup is ready
function backup_check(){
  echo "backup checks running"

  if [ -z "$USER" ]; then
    echo "ERROR: user not passed to the script"
    exit 1
  fi

  echo "backup checks over"
}

# configure necessary files and directories for a backup
function configure_backup(){
  if [ ! -d "$DIRECTORY"/ ]; then
    echo "creating a backup directory at $DIRECTORY"
    mkdir -p "$DIRECTORY"
  fi
}

function argument_log(){
  echo "LOG: SQL $* specifed"
}


###################################################################################################
# Help
function help(){
  echo
  echo "Usage: percona_store [OPTION]... [PARAMETER]"
  echo "percona_store is a script for making backups to AWS s3 bucket and restoring percona databases"
  echo "OPTIONS"
  echo "  -h|--help                                 display this help and exit"
  echo "  -u|--mysql-user                           specify the user of mysql server"
  echo "  -b|--s3bucket                             specify the name of s3 bucket"
  echo "  -c|--aws-configs                          specify the csv file to be used for configuring aws access"
  echo "  -t|--target-dir                           specify the path to directory or file to stroe the backup.   /data/backups/mysql/ by default"
  echo
}
###################################################################################################

main "$@"