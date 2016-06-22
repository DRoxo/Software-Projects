import os
import xml.etree.cElementTree as ET

import sys

##********************SFDCObject Constructor*************************##
##*******************************************************************##


class SFDCObject:

    	#API version
    version = "31.0"
	
	#FIXME include missing mappings between Salesforce folders and Metadata Types
    SFDCObjectMap = dict({
    'approvalProcesses':'ApprovalProcess',
    'aura':'AuraDefinitionBundle',
    'classes':'ApexClass',
    'components':'ApexComponent',
    'homePageComponents':'HomePageComponent',
    'layouts':'Layout',
    'objects':'CustomObject',
    'pages':'ApexPage',
    'profiles':'Profile',
    'staticresources':'StaticResource',
    'tabs':'CustomTab',
    'triggers':'ApexTrigger',
    'tabs':'CustomTab',
    'permissionsets':'PermissionSet',
    'flows':'Flow',
    'customlabels':'CustomLabel',
    'workflows':'Workflow',
    'applications':'CustomApplication',
    'translations':'Translations',
    'queues':'Queue',
    'labels':'CustomLabel'
    });

    SFDCObjectCount = 0
    listSFDCObjectsAdd = []
    listSFDCObjectsDelete = []
    
    def __init__(self, sfdcType,sfdcMember,sfdcAction):
        self.sfdcType = SFDCObject.SFDCObjectMap.get(sfdcType)
        self.sfdcMember = sfdcMember
        self.sfdcAction = sfdcAction

        if(sfdcAction == 'add'):
            SFDCObject.listSFDCObjectsAdd.append(self)
        elif(sfdcAction == 'delete'):
            SFDCObject.listSFDCObjectsDelete.append(self)

        SFDCObject.SFDCObjectCount += 1
	
    def displayCount(self):
        print ("Total SFDC Objects %d" % SFDCObject.SFDCObjectCount)

    def displaySFDCObject(self):
        print ("sfdcType: ", self.sfdcType,"sfdcMember: ", self.sfdcMember,"sfdcAction: ", self.sfdcAction)

    def displaySFDCObjectList(self):
        print ("SFDC Ojects list size: " , len(SFDCObject.listSFDCObjects))


##*******************************************************************##
##*******************************************************************##


      
curPath =  os.getcwd()

lines = sorted(sys.argv[1].split('\n'))


##### only for testing
#file = open('examples/testFile.txt', 'r')
#lines = file.readlines()
#####




for modFile in lines:
    
    action = "add"
    if "delete" in modFile:
        action = "delete"

    modFileIndex = modFile.index('src/') + len('src/')

    modFile = modFile[modFileIndex:]

    #Type
        
    modFileIndexType =modFile.index('/') + len('/')

    modFileType = modFile[:modFileIndexType-1]
        

    #Member

    modFileMember = modFile[modFileIndexType:modFile.index('.')]

	
	
    sfcdObj  = SFDCObject(modFileType,modFileMember,action)

    #sfcdObj.displayCount()
    #sfcdObj.displaySFDCObject()


xmlFileNames = dict({'add':'package.xml','delete':'destructiveChanges.xml'});



pairSFDCObjects = [sfcdObj.listSFDCObjectsAdd,sfcdObj.listSFDCObjectsDelete];

for listSFDCObjects in pairSFDCObjects:


    ET.register_namespace('',"http://soap.sforce.com/2006/04/metadata")

    package = ET.Element("{http://soap.sforce.com/2006/04/metadata}Package")

    types = ET.SubElement(package, "types")

    for index,obj in enumerate(listSFDCObjects):
        if index > 0 and listSFDCObjects[index - 1].sfdcType is not obj.sfdcType:
            ET.SubElement(types, "name").text = listSFDCObjects[index - 1].sfdcType
            types = ET.SubElement(package, "types")

        ET.SubElement(types, "members").text = obj.sfdcMember

        if (index == len(listSFDCObjects)-1):
            ET.SubElement(types, "name").text = obj.sfdcType

    if obj.sfdcAction == "add":
        ET.SubElement(package, "version").text = sfcdObj.version

    tree = ET.ElementTree(package)

    if listSFDCObjects:
        if not os.path.exists("Output/" + sys.argv[2]):
            os.makedirs("Output/" + sys.argv[2])
        tree.write("Output/" + sys.argv[2] + "/"+ xmlFileNames.get(obj.sfdcAction),xml_declaration=True,encoding="UTF-8",method="xml")
        print("file created: " + "Output/" + sys.argv[2] + "/"+ xmlFileNames.get(obj.sfdcAction))
