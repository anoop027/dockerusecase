#!/bin/bash

ndays=1
npath=1

function usage()
{
  echo "Usage: $0 [-d <path to directory>] [-n <number of days>] "
}

function checkdir()
{
  if [ -d "$fpath" ]
  then
      echo "Directory $fpath is a valid directory." >> /dev/null 2>&1
  else
      echo "Error: "$fpath" does not exist, Invalid directory"
      exit 1
  fi
}

function  checkdays()
{
  if ! [[ $days =~ ^[0-9]+$ ]]
      then
          echo " -n --> accepts only positive integers"
          usage
          exit 1
  else
          echo "number of days is valid" >> /dev/null 2>&1
  fi
}


while getopts ":d:n:" opt; do
  case ${opt} in
    d )
      fpath=$OPTARG
      npath=2
      checkdir
      ;;
    n )
      days=$OPTARG
      ndays=2
      checkdays
      ;;
    \? )
       usage
      ;;
  esac
done
if [ $OPTIND -eq 1 ];
then
  echo "No options were passed"
  usage
  exit 1
fi
if [ $ndays -eq 1 ];
then
  echo "no argument passed for number of days"
  usage
  exit 1
fi
if [ $npath -eq 1 ];
then
  echo "no argument passed for directory"
  usage
  exit 1
fi
shift $((OPTIND -1))


find $fpath -mtime -$days -print > /tmp/test.sh


IFS=$'\n' read -d '' -r -a lines < /tmp/test.sh

#printf '%s\n' "${lines[@]}"

echo "+-------------------------------------------------------------+"
echo "Below are the list of files modified within $days days and their file sizes "
echo "+-------------------------------------------------------------+"


for i in ${lines[@]}
do
        fspec=$i
        fname=`basename $fspec`
        FILE="$fpath/$fname"
        if test -f "$FILE"; then
           echo File name: $fname ,  Size : $(find $fpath/$fname -printf "%s") bytes ,  modified on : $(date -r $fname)
           printf '\n'
        else
           echo "$FILE not exists." >> /dev/null
        fi
done

