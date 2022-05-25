#! /bin/bash
echo "Enter your expression: "
read -ra inputs
arg1=${inputs[0]}
arg2=${inputs[1]}
arg3=${inputs[2]}

case $arg2 in

   "+")
    res=$((arg1+arg3))
    ;;
   "-")
    res=$((arg1-arg3))
    ;;
   '*')
    res=$((arg1*arg3))
    ;;
   "/")
    res=$((arg1/arg3))
    ;;
    *)
     echo "Incrorrect format"
    ;;
esac

echo $res
