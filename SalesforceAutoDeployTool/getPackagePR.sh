#!/bin/bash
#title           :runDeployFromPullRequest.sh
#description     :This will run a python script to generate a package.xml and destructiveChanges.xml and preform a deploy in a Salesforce Org
#date            :20160727
#version         :0.1     
#usage		 :bash getPullRequest.sh (read comments below)
#notes           :Install Python 3.5 to use this script.
#bash_version    :4.1.5(1)-release
#==============================================================================


mkdir -p Input
mkdir -p Output

#Define your login in the login.properties
. Config/build.properties


#################################################################
#################### Get Pull Request Diff ######################
#################################################################



#curl -u DiogoRoxo:BlueInfinity2016 https://bitbucket.org/api/2.0/repositories/iatasfdc/amsdev/pullrequests/128/diff -L -o Input/pullRequest_128.diff

curl -u $VAR_USER:$VAR_PASS $VAR_URL/api/2.0/repositories/$VAR_REPOSITORY/$VAR_PROJECT/pullrequests/$PULLREQUESTID/diff -L -o Input/pullRequest_$PULLREQUESTID.diff

results=$(grep '^+++\|^---' Input/pullRequest_$PULLREQUESTID.diff | grep 'src/' | grep -v '.xml' | uniq)

rm Input/pullRequest_$PULLREQUESTID.diff

var_file="gitLog_PullRequest_${PULLREQUESTID}_$(date +%Y%m%d%H%M%S)"


export IFS="
"
for line in $results; do
    echo $line  
done >> Input/$var_file

python xmlConstructor.py "$var_file" "$VAR_VERSION"

echo "Output/$var_file"


#Clean tmp folder from previous failed Deploys

if [ -d "Output/tmp" ]; then
	cd Output/tmp
	rm -rf *
	cd ../..
fi



################## Use Desctructive Changes? #####################


useDestructiveChanges=N


#################################################################
################# Get Files from BitBucket ######################
#################################################################



python xmlDecoder.py "Output/$var_file" "$useDestructiveChanges"

	
list=$(dos2unix < Output/tmp/filePaths.txt)

while read -r line; do

   	lineURL=$(python -c "import urllib.parse as ps, sys; print (ps.quote(sys.argv[1]))" "$line")

	echo "URL: $VAR_URL_API/1.0/repositories/$VAR_REPOSITORY/$VAR_PROJECT/raw/$VAR_BRANCH_REMOTE/$lineURL"

	curl -u $VAR_USER:$VAR_PASS  $VAR_URL_API/1.0/repositories/$VAR_REPOSITORY/$VAR_PROJECT/raw/$VAR_BRANCH_REMOTE/$lineURL  -L -o Output/tmp/Deploy/$line
	
done <<< "$list"

##Example
#curl -u DiogoRoxo:BlueInfinity2016 https://api.bitbucket.org/1.0/repositories/iatasfdc/amsdev/raw/amsdevsprint15diogo/src/layouts/Case-Application%20Change%20Request%20%2528AIMS%2529.layout  -L -o AMS_Console.app
