#!/bin/bash:set number

function main(){
  #check
  handle_args "$@"
  select_action
  exit 0
}

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
    esac
  done
}

# Check that mysql is installed 
function check(){
  if ! which mysql; then
    echo "Please install MySQL before running this command"
    exit 1
  fi
}

function handle_args(){
  PARSED_ARGUMENTS=$(getopt -a -n percona_store -o hs:u:p:b:d:l -l help,mysql-server:,mysql-user:,mysql-password:,s3bucket:,s3bucket-connection-details:local-directory -- "$@")
  eval set -- "$PARSED_ARGUMENTS"
  while :; do
    case $1 in 
     -h|--help)
        help
        exit
        ;;
     -s|--mysql-server)        
        SERVER=$2        
        argument_log "server"
        shift 2
        ;;
     -u|--mysql-user)
        USER=$2
        argument_log "user"
        shift 2
        ;;
     -p|--mysql-password)
        PASSWD=$2
        shift 2
        ;;
     -b|--s3bucket)
        BUCKET=$2
        argument_log "s3 bucket"
        shift 2
        ;;
     -d|--s3bucket-connection-details)
        DETAILS=$2
        argument_log "s3 bucket connection details"
        shift 2
        ;;
     -l|--local-directory)
        DIRECTORY=$2
        shift 2
        ;;
     --)
        break;;
    esac
  done
}

function restore(){
  echo "*******************RESTORE SELECTED*******************"
  echo
  restore_check
  echo "restore process should have started here"
}

function backup(){
  echo "*******************BACKUP SELECTED*******************"
  echo
  backup_check
    echo "backup process should have started here"
}

function restore_check(){
  echo "restore checks running"

  if ! which rsync >> /dev/null; then
    echo "Percona backup tool missing. Please install rsync before running the script"
    exit 1
  fi

  echo "restore checks over"
}

# check that all n
function backup_check(){
  echo "backup checks running"

  if ! which xtrabackup >> /dev/null; then
    echo "Percona backup tool missing. Please install xtrabackup before running the script"
    exit 1
  fi

  echo "backup checks over"
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
  echo "  -s|--mysql-server                         specify the URL of mysql server"
  echo "  -u|--mysql-user                           specify the user of mysql server"
  echo "  -p|--mysql-password                       specify the password of the user"
  echo "  -b|--s3bucket                             specify the address of s3 bucket"
  echo "  -d|--s3bucket-connection_details          specify the path to details file for your s3 bucket"
  echo
}
###################################################################################################
main "$@"