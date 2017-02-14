#!/bin/bash
#title           :runDeployFromGitLog.sh
#description     :This will run a python script to generate a package.xml and destructiveChanges.xml and preform a deploy in a Salesforce Org
#author			 :Roxo, Diogo
#date            :20160727
#version         :1.0    
#usage			 :bash runDeployFromGitLog.sh (read comments below)
#notes           :Install Python 3.5 to use this script.
#bash_version    :4.1.5(1)-release
#==============================================================================


mkdir -p Input
mkdir -p Output

#Define your personal configuration
. Config/build.properties



#################################################################
######################### Get Git Log ###########################
#################################################################


  
echo $VAR_PATH
echo $VAR_BRANCH_REMOTE


results=$(git -C $VAR_PATH diff --name-status  $(git  -C $VAR_PATH rev-list -n1 --before="$BEFORE" origin/$VAR_BRANCH_REMOTE)  | grep 'src/' | grep -v '.xml' | uniq) 

var_file="gitLog_${VAR_BRANCH_REMOTE}_${BEFORE// /}_$(date +%Y%m%d%H%M%S)"


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

echo "
Use Destructive Changes?  !CAREFUL! the listed components will be removed. For manual add/remove components go to: Output/tmp/ folder.
" 
read -p 'Response(Y/N , Default: N): ' useDestructiveChanges

echo "Your answer: " $useDestructiveChanges


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




#################################################################
######################## Ant Deploy #############################
#################################################################



cd Config
ant deployPackageToSB
antReturnCode=$?
cd ..


echo "ANT: Return code is: \""$antReturnCode"\""
 
if [ $antReturnCode -ne 0 ];then
 
    echo "BUILD ERROR:
		  Analyse the generated files in the tmp/Deploy folder.
		  In order to rerun this process: ./rerunLastDeployFromGitLog.sh
		  Sugested actions:
			1. Analyse the detected errors in the build.
			2. Remove the files in error from the package.xml and from the src/ directory."
	echo Output/tmp
	
	echo Output/$var_file | tee Output/tmp/outputFolder.txt
	
    exit 1;
	
else
 
    echo "GREAT SUCCESS: Niiice - I liiike!"
	mv Output/tmp/* Output/$var_file/
    echo Output/$var_file
	exit 0;
fi

