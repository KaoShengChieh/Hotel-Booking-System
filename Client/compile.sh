#!/bin/bash

set +e

rm bin/*.class

set -e

required_jdk_version="11"

check_jdk_version() {
  local result
  local java_cmd
  if [[ -n $(type -p java) ]]
  then
    java_cmd=java
  elif [[ (-n "$JAVA_HOME") && (-x "$JAVA_HOME/bin/java") ]]
  then
    java_cmd="$JAVA_HOME/bin/java"
  fi
  local IFS=$'\n'
  # remove \r for Cygwin
  local lines=$("$java_cmd" -Xms32M -Xmx32M -version 2>&1 | tr '\r' '\n')
  if [[ -z $java_cmd ]]
  then
    echo "Require jdk $required_jdk_version but it's not installed."
    exit 1
  else
    for line in $lines; do
      if [[ (-z $result) && ($line = *"version \""*) ]]
      then
        local ver=$(echo $line | sed -e 's/.*version "\(.*\)"\(.*\)/\1/; 1q')
        # on macOS, sed doesn't support '?'
        if [[ $ver = "1."* ]]
        then
          result=$(echo $ver | sed -e 's/1\.\([0-9]*\)\(.*\)/\1/; 1q')
        else
          result=$(echo $ver | sed -e 's/\([0-9]*\)\(.*\)/\1/; 1q')
        fi
      fi
    done
  fi
  if [[ $result != $required_jdk_version ]]
  then
	echo "Require jdk $required_jdk_version but jdk $result installed."
	exit 1
  fi
}

check_jdk_version

CC=javac
DEBUG=-Xlint
CP=bin
SRC=src/*.java
FACADE=src/facade/*.java
GUI=src/GUI/*.java
DEST=bin

$CC $DEBUG -cp $CP $SRC $FACADE $GUI -d $DEST

