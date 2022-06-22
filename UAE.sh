#!/bin/bash

LOCATOIN=`which tar`
if [[ $? -ne 0 ]]; then
	echo "tar not installed on this system, please install tar before running this command"
	exit 1
fi

# decomressing a tar archive if option -d is selected
# input format: bash UAE.sh -d <file> for current working directory or bash UAE.sh -d <file> <new-location> for decompressing into another directory

if [[ $1 == "-d" ]]; then
   if [[ $3 ]]; then
      tar -xvf $2 -C $3
   else
      tar -xvf $2
   fi
   exit 0
fi

# compressing a tar archive if option -d was not selected
case $1 in
       "-gzip")
          tar -czvf "${2}.gz" $3
          ;;
       "-bzip2")    
          tar -cjvf "${2}.bz2" $3
          ;;
       "-xz")    
          tar -cJvf "${2}.xz" $3
          ;; 
esac
exit 0
