public with sharing class MultiSelectController {
    
    @AuraEnabled
    public static List<PickList> getPickValues(String objname,String parentFieldName,String childFieldName) {
    	Map<String,List<PickClass>> resultMap=new Map<String,List<PickClass>>();
        Map<String,String> parentMap=new Map<String,String>();
    	List<PickList> resultList=new List<PickList>();
    	//Get The Object Chilid Picklist Value,Includes label、value、controllerValue. 
    	//获取对象子选项列表的基础属性,  包括label  value ,控制值等
    	Map<String,String> childPickValMap=CommonUtils.getPickListValues(objname,childFieldName);
    	for(String childVal:childPickValMap.keySet()){
    		//Find The Child Val Get The Mapping Controller Value
    		//根据当前子选项列表值，获取对应控制字段的值
    		PickClass controllValue=getControllingValue(objname,parentFieldName,childFieldName,childVal);
    		//Init The Inner Class. 
    		//构造内部类
            PickClass newPick=new PickClass();
            newPick.value=childVal;
            newPick.label=childPickValMap.get(childVal);

    		if(controllValue!=null){
    			if(resultMap.containsKey(controllValue.value)){
                    parentMap.put(controllValue.value,controllValue.label);
    				resultMap.get(controllValue.value).add(newPick);
    			}else{
                    parentMap.put(controllValue.value,controllValue.label);
    				resultMap.put(controllValue.value,new List<PickClass>{newPick});
    			}
    		}
    	}
    	
    	for(String contrlval:resultMap.keySet()){
    		PickList newObj=new PickList();

            PickClass newPick=new PickClass();
            newPick.label=parentMap.get(contrlval);
            newPick.value=contrlval;
            // Finally We Return A Parent Obj Mapping to LIst ChildObj.
            // 最终形成一个 父对象 下面挂一个List子对象
    		newObj.parentPick=newPick;
    		newObj.listValues=resultMap.get(contrlval);
    		resultList.add(newObj);
    	}

    	return resultList;
    }

    @AuraEnabled
    public static ReturnClass GetExistData(String recordId) {
        ReturnClass newClass=new returnClass();
        Test_Obj__c tstObj=[SELECT ID,Show_Child_Multi_Select__c,Show_Parent_Multi_Select__c FROM Test_Obj__c WHERE ID=:recordId];
        //Cause We Need Get List<String>, So We Spilt The Data
        if(!String.isBlank(tstObj.Show_Child_Multi_Select__c)){
            newClass.childList=tstObj.Show_Child_Multi_Select__c.split(';');    
        }
        if(!String.isBlank(tstObj.Show_Parent_Multi_Select__c)){
            newClass.parentList=tstObj.Show_Parent_Multi_Select__c.split(';');    
        }
        return newClass;
    }

    
    @AuraEnabled
    public static SaveMessage SaveData(String recordId,String showChildVal,String showParentVal,String childLabels,String parentLabels) {
        Test_Obj__c saveObj=new Test_Obj__c(Id=recordId);
        saveObj.Show_Child_Multi_Select__c=showChildVal;
        saveObj.Show_Parent_Multi_Select__c=showParentVal;
        // saveObj.ServiceType__c=serviceLabel;
        // saveObj.BusienessType__c=businessLabel;
        SaveMessage saveMsg=new SaveMessage();
        SavePoint sp=DataBase.setSavepoint();
        try{
            update saveObj;
            saveMsg.isSuccess = true;
            saveMsg.returnId = recordId;
            saveMsg.canSave = false;
            saveMsg.saveMsg = 'Save Success';
        }catch(Exception e){
            Database.rollback(sp);
            saveMsg.isSuccess=false;
            saveMsg.saveMsg=e.getMessage();
        }
        return saveMsg;
    }



    /*通过依赖字段找到控制字段*//*Accord Child Value Find the Controller Value*/
    public static PickClass getControllingValue(String pObjName, String pControllingFieldName, String pDependentFieldName, String pDependentValue)
    {
        PickClass controllingValue = new PickClass();
        //verify/get object schema
        Schema.SObjectType pType = Schema.getGlobalDescribe().get(pObjName);
        if ( pType == null ) return controllingValue;
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();

        //verify field names
        if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)) return controllingValue;     

        //get the control & dependent values   
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();

        //clear heap
        objFieldMap = null;

        //serialize dep entries        
        List<TPicklistEntry> objDS_Entries = new List<TPicklistEntry>();
        objDS_Entries = (List<TPicklistEntry>)JSON.deserialize(JSON.serialize(dep_ple), List<TPicklistEntry>.class);

        List<Integer> validIndexes;
        for (TPicklistEntry objDepPLE : objDS_Entries){

          
              if (objDepPLE.label == pDependentValue)
              {
                  validIndexes = cnvBits(objDepPLE.validFor);
                  // System.debug('validIndexes:::' + validIndexes);
                  if (validIndexes.size()>0) {
                      controllingValue.label=ctrl_ple[validIndexes.get(0) - 1].getLabel();
                      controllingValue.value=ctrl_ple[validIndexes.get(0) - 1].getValue();
                  }
              }

              if (objDepPLE.value == pDependentValue)
              {
                  validIndexes = cnvBits(objDepPLE.validFor);
                  // System.debug('validIndexes:::' + validIndexes);
                  if (validIndexes.size()>0) {
                      controllingValue.label=ctrl_ple[validIndexes.get(0) - 1].getLabel();
                      controllingValue.value=ctrl_ple[validIndexes.get(0) - 1].getValue();
                  }
              }

        }

        //clear heap
        objDS_Entries = null;


        return controllingValue;
    }


    // Converts a base64 string into a list of integers indicating at which position the bits are on
    public static List<Integer> cnvBits (String b64Str) {
        List<Integer> lstOut = new List<Integer>();
        if ( b64Str == null || b64Str == '' ) return lstOut;

        List<Integer> lstBytes = B64ToBytes(b64Str);

        Integer i, b, v;
        for ( i = 0; i < lstBytes.size(); i++ ) {
            v = lstBytes[i];
            //System.debug ( 'i['+i+'] v['+v+']' );
            for ( b = 1; b <= 8; b++ ) {
                //System.debug ( 'i['+i+'] b['+b+'] v['+v+'] = ['+(v & 128)+']' );
                if ( ( v & 128 ) == 128 ) lstOut.add( (i*8) + b );
                v <<= 1;
            }
        }

        //System.Debug('cnvBits: [' + b64Str + '] = ' + lstOut);
        return lstOut;
    }//cnvBits

    public static List<Integer> B64ToBytes (String sIn) {
        Map<Integer,Integer> base64 = new Map<Integer,Integer>{65=>0,66=>1,67=>2,68=>3,69=>4,70=>5,71=>6,72=>7,73=>8,74=>9,75=>10,76=>11,77=>12,78=>13,79=>14,80=>15,81=>16,82=>17,83=>18,84=>19,85=>20,86=>21,87=>22,88=>23,89=>24,90=>25
                                                               ,97=>26,98=>27,99=>28,100=>29,101=>30,102=>31,103=>32,104=>33,105=>34,106=>35,107=>36,108=>37,109=>38,110=>39,111=>40,112=>41,113=>42,114=>43,115=>44,116=>45,117=>46,118=>47,119=>48,120=>49,121=>50,122=>51
                                                               ,48=>52,49=>53,50=>54,51=>55,52=>56,53=>57,54=>58,55=>59,56=>60,57=>61,43=>62,47=>63};

        List<Integer> lstOut = new List<Integer>();
        if ( sIn == null || sIn == '' ) return lstOut;
        
        sIn += '='.repeat( 4 - Math.mod( sIn.length(), 4) );

        for ( Integer idx=0; idx < sIn.length(); idx += 4 ) {
            if ( base64.get(sIn.charAt(idx+1)) != null ) lstOut.add( (base64.get(sIn.charAt(idx)) << 2) | (base64.get(sIn.charAt(idx+1)) >>> 4) );
            if ( base64.get(sIn.charAt(idx+2)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+1)) & 15)<<4) | (base64.get(sIn.charAt(idx+2)) >>> 2) );
            if ( base64.get(sIn.charAt(idx+3)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+2)) & 3)<<6) | base64.get(sIn.charAt(idx+3)) );
        }

        //System.Debug('B64ToBytes: [' + sIn + '] = ' + lstOut);
        return lstOut;
    }//B64ToBytes

    public class TPicklistEntry{
        public string active {get;set;}
        public string defaultValue {get;set;}
        public string label {get;set;}
        public string value {get;set;}
        public string validFor {get;set;}
        public TPicklistEntry(){
        }
    }


    public Class PickList{
        @AuraEnabled
        public PickClass parentPick { GET; SET; }
        @AuraEnabled
        public List<PickClass> listValues { GET; SET; }
    }

    public Class PickClass{
        @AuraEnabled
        public String label { GET; SET; }
        @AuraEnabled
        public String value{GET;SET;}
    }


    public class SaveMessage{
        @AuraEnabled
        public Boolean canSave {GET; SET;}
        @AuraEnabled
        public Id returnId {GET; SET;}
        @AuraEnabled
        public String saveMsg {GET; SET;}
        @AuraEnabled
        public Boolean isSuccess  {GET; SET;}
    }

    public class ReturnClass{
        @AuraEnabled
        public List<String> parentList {GET; SET;}
        @AuraEnabled
        public List<String> childList {GET; SET;}
    }
}