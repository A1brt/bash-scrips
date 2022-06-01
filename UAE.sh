#!/bin/bash

if [[ $1 == "-unzip" ]]; then
   echo "unzip"
   if [[ $3 ]]; then
      tar -xvf $2 -C $3
   else
      echo hello
      tar -xvf $2
   fi
elif [[ $1 == "-zip" ]]; then
   echo "zip"
   case $2 in
        "-gzip")
          tar -czvf "${3}.gz" $4
          ;;
        "-bzip2")    
          tar -cjvf "${3}.bz2" $4
          ;;
        "-xz")    
          tar -cJvf "${3}.xz" $4
          ;; 
    esac
else 
   exit 1
fi

