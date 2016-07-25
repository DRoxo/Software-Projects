import os
import xml.etree.cElementTree as ET
import datetime
import sys
from shutil import copyfile

##********************SFDCObject Constructor*************************##
##*******************************************************************##


class SFDCObject:
    listSFDCObjects = []
    listFoldersToCreate = []
    
    #FIXME include missing mappings between Salesforce folders and Metadata Types on  SFDCObjectMap, SFDCObjectMapExtensions
    SFDCObjectMap = dict({
        'ApprovalProcess'       :   'approvalProcesses'     ,
        'AuraDefinitionBundle'  :   'aura'                  ,
        'ApexClass'             :   'classes'               ,
        'ApexComponent'         :   'components'            ,
        'HomePageComponent'     :   'homePageComponents'    ,
        'Layout'                :   'layouts'               ,
        'CustomObject'          :   'objects'               ,
        'ApexPage'              :   'pages'                 ,
        'Profile'               :   'profiles'              ,
        'StaticResource'        :   'staticresources'       ,
        'CustomTab'             :   'tabs'                  ,
        'ApexTrigger'           :   'triggers'              ,
        'PermissionSet'         :   'permissionsets'        ,
        'Flow'                  :   'flows'                 ,
        'Workflow'              :   'workflows'             ,
        'CustomApplication'     :   'applications'          ,
        'Translations'          :   'translations'          ,
        'Queue'                 :   'queues'                ,
        'CustomLabels'           :   'labels'                
    });

    SFDCObjectMapExtensions = dict({
        'approvalProcesses'    : '.approvalProcess'  ,
        'aura'                 : ''  ,
        'classes'              : '.cls'  ,
        'components'           : '.component'  ,
        'homePageComponents'   : '.homePageComponent'  ,
        'layouts'              : '.layout'  ,
        'objects'              : '.object'  ,
        'pages'                : '.page'  ,
        'profiles'             : '.profile'  ,
        'staticresources'      : '.resource'  ,
        'tabs'                 : '.tab'  ,
        'triggers'             : '.trigger'  ,
        'permissionsets'       : '.permissionset'  ,
        'flows'                : '.flows'  ,
        'workflows'            : '.workflow'  ,
        'applications'         : '.app'  ,
        'translations'         : '.translation'  ,
        'queues'               : '.queue'  ,
        'labels'               : '.labels' ,
	'remoteSiteSettings'   : '.remoteSite',
        'email'                : '.email'
        });

    ## List of elements that require -meta.xml file
    SFDCObjectListMetaXML = [
		'ApexClass',	
		'ApexComponent',	
		'ApexPage',	
		'ApexTrigger',	
		'DashboardFolder',	
		'Document',
		'DocumentFolder',
		'EmailFolder',
		'EmailTemplate',
		'ReportFolder',
		'StaticResource'
                ];
    
    SFDCObjectCount = 0

    def __init__(self, sfdcType,sfdcMember):
            self.sfdcType = SFDCObject.SFDCObjectMap.get(sfdcType)
            self.sfdcMember = sfdcMember
            SFDCObject.listSFDCObjects.append(self)
            SFDCObject.SFDCObjectCount += 1
            if self.sfdcType not in SFDCObject.listFoldersToCreate:
                SFDCObject.listFoldersToCreate.append(self.sfdcType)
            
    def getMemberValue():
        return "members"

    def getTypeValue():
        return "name"
    
    def displayCount(self):
        print ("Total SFDC Objects %d" % SFDCObject.SFDCObjectCount)

    def displaySFDCObject(self):
        print ("sfdcType: ", self.sfdcType,"sfdcMember: ", self.sfdcMember)

    def getSFDCObjectPath(self):
        return "src/" + self.sfdcType + "/" + self.sfdcMember + SFDCObject.SFDCObjectMapExtensions.get(self.sfdcType)
    
    def displaySFDCObjectList(self):
        print ("SFDC Ojects list size: " , len(SFDCObject.listSFDCObjects))

    


def processTagValue(tagValue):
    return tagValue[tagValue.index('}')+1:]

def createSFDCObjects(listElem , typeValue):
    for elem in listElem:
         SFDCObject(typeValue,elem)



##*******************************************************************##
##*******************************************************************##



#curPath =  os.getcwd()

sFDCpackageXML = 'package.xml'
sFDCdesctructiveChangesXML = 'destructiveChanges.xml'


tree = ET.parse(sys.argv[1]+'/' + sFDCpackageXML)

root = tree.getroot()


listElem = []
for child in root:
    for child2 in child:
        if processTagValue(child2.tag) == SFDCObject.getMemberValue():
            listElem.append(child2.text)
        elif processTagValue(child2.tag) == SFDCObject.getTypeValue():
            createSFDCObjects(listElem,child2.text)
            listElem = []


    
tempPath = 'Output/tmp'
deployPath = 'Deploy'

if not os.path.exists(tempPath+ '/' + deployPath):
            os.makedirs(tempPath+ '/' + deployPath)

filePaths =  'filePaths.txt'


target = open(filePaths, 'w')

for obj in SFDCObject.listSFDCObjects:
    print(SFDCObject.getSFDCObjectPath(obj))
    target.write(SFDCObject.getSFDCObjectPath(obj))
    target.write('\n')
    if list(SFDCObject.SFDCObjectMap.keys())[list(SFDCObject.SFDCObjectMap.values()).index(obj.sfdcType)] in SFDCObject.SFDCObjectListMetaXML :
        target.write(SFDCObject.getSFDCObjectPath(obj) + '-meta.xml')
        target.write('\n')


target.close()

for folderToCreate in SFDCObject.listFoldersToCreate:
    print(folderToCreate)
    os.makedirs(tempPath+ '/' + deployPath + '/src/' + folderToCreate)
      
os.rename(filePaths, tempPath+ '/' + filePaths)

copyfile(sys.argv[1]+'/' + sFDCpackageXML,tempPath+ '/' + deployPath + '/src/' + sFDCpackageXML)

if sys.argv[2] == "Y":
    copyfile(sys.argv[1]+'/' + sFDCdesctructiveChangesXML,tempPath+ '/' + deployPath + '/src/' + sFDCdesctructiveChangesXML)

