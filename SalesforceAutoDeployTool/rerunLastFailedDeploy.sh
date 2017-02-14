#!/bin/bash
#title           :runAntForTmpFolder.sh
#description     :This will preform a deploy in a Salesforce Org
#author		 :Roxo, Diogo
#date            :20160727
#version         :0.1     
#usage		 :bash runDeployFromGitLog.sh (read comments below)
#notes           :Install Python 3f.5 to use this script.
#bash_version    :4.1.5(1)-release
#==============================================================================


#################################################################
######################## Ant Deploy #############################
#################################################################

var_file_folder=$(head -n 1 Output/tmp/outputFolder.txt)

echo $var_file_folder
 
cd Config
ant deployPackageToSB
antReturnCode=$?
cd ..


echo "ANT: Return code is: \""$antReturnCode"\""
 
if [ $antReturnCode -ne 0 ];then
 
    echo "BUILD ERROR:
		  Analyze the generated files in the tmp/Deploy folder.
		  In order to rerun this process: ./runAntForTmpFolder.sh
		  Sugested actions:
			1. Analyze the detected errors in the build.
			2. Remove the files in error from the package.xml and from the src/ directory."
			
	echo Output/tmp
	
    exit 1;
else
 
    echo "GREAT SUCCESS: Niiice - I liiike!"
	mv Output/tmp/* $var_file_folder/
    echo $var_file_folder
	exit 0;
fi

