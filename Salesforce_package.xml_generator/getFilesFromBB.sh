#!/bin/bash
#title           :getFilesFromBB.sh
#description     :This will process a package xml and retrieve the files corresponding files from a bitbucket branch
#author		     :Roxo, Diogo
#date            :20160628
#version         :0.1     
#usage		     :bash getFilesFromBB.sh (read comments below)
#notes           :Install Python 3.5 to use this script.
#bash_version    :4.1.5(1)-release
#==============================================================================

#py xmlDecoder.py

#Define your login in the login.properties
. Config/build.properties

list=$(dos2unix < Output/tmp/filePaths.txt)

while read -r line; do
    echo "Path: $VAR_URL_API/1.0/repositories/$VAR_REPOSITORY/$VAR_PROJECT/raw/$VAR_BRANCH_REMOTE/$line"

   	lineURL=$(python -c "import urllib.parse as ps, sys; print (ps.quote(sys.argv[1]))" "$line")

	echo "URL: $VAR_URL_API/1.0/repositories/$VAR_REPOSITORY/$VAR_PROJECT/raw/$VAR_BRANCH_REMOTE/$lineURL"

	curl -u $VAR_USER:$VAR_PASS  $VAR_URL_API/1.0/repositories/$VAR_REPOSITORY/$VAR_PROJECT/raw/$VAR_BRANCH_REMOTE/$lineURL  -L -o Output/tmp/$line
	
done <<< "$list"

#curl -u DiogoRoxo:BlueInfinity2016 https://api.bitbucket.org/1.0/repositories/iatasfdc/amsdev/raw/amsdevsprint15diogo/src/layouts/Case-Application%20Change%20Request%20%2528AIMS%2529.layout  -L -o AMS_Console.app


