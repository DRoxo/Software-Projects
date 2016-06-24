#!/bin/bash
#title           :getPullRequest.sh
#description     :This will run a python script to generate a package.xml and destructiveChanges.xml
#author		 :Roxo, Diogo
#date            :20160620
#version         :0.1     
#usage		 :bash getPullRequest.sh (read comments below)
#notes           :Install Python 3.5 to use this script.
#bash_version    :4.1.5(1)-release
#==============================================================================

#Define your login in the login.properties
. loginInfo.properties

echo -n "Enter Pull Request Index Number: "
read num

curl -u $VAR_USER:$VAR_PASS $VAR_URL/$num/patch -L -o Input/pullRequest_$num.txt

results=$(grep '^+++\|delete mode' Input/pullRequest_$num.txt | grep 'src/' | grep -v '.xml' | uniq)

py xmlConstructor.py "$results" "pullRequest_$num" "$VAR_VERSION"

