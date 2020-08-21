#!/usr/bin/env bash

count=0
out=''
err=''

echo "The arguments is $@ and pwd is $(pwd)"

while [[ $? -eq 0 ]]; do
	count=$((count+1))
	#./ex3_fail.sh > out 2>err
	"$(pwd)/$1" > out 2>err
	#./ex3_fail.sh > out 2>err
done

echo "Until $count times success, $1 went error"
echo "The $1's STDOUT is \"$(cat out)\""
echo "THe $1's STDERR is \"$(cat err)\""
