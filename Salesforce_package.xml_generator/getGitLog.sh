#!/bin/bash
#title           :getGitLog.sh
#description     :This will run a python script to generate a package.xml and destructiveChanges.xml
#author		 :Roxo, Diogo
#date            :20160620
#version         :0.1     
#usage		 :bash getGitLog.sh (read comments below)
#notes           :Install Python 3f.5 to use this script.
#bash_version    :4.1.5(1)-release
#==============================================================================

#Define your login in the login.properties
. loginInfo.properties

echo -n "From (dd-mm-YYYY HH:MM:SS) : "
read fromDate

echo -n "To (dd-mm-YYYY HH:MM:SS) : "
read toDate


echo $VAR_PATH
echo $VAR_BRANCH


results=$(git -C $VAR_PATH diff "$VAR_BRANCH@{$fromDate}" "$VAR_BRANCH@{$toDate}" | grep '^+++\|delete mode' | grep 'src/' | grep -v '.xml' | uniq)

#results=$(git -C $VAR_PATH log --before=$toDate --after=$fromDate --name-status | grep 'src/' | grep -v '.xml' |  grep '^A\|^M\|^D\|     M ')

echo gitLog_$fromDate$toDate

py xmlConstructor.py "$results" "gitLog_$fromDate$toDate" "$VAR_VERSION"