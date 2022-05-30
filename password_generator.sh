#!/bin/bash
echo "Enter the length of the passowrd: "
read length

password=`cat /dev/urandom | tr -cd 'a-zA-Z0-9' | fold -w $length | head -n 1`

echo $password


