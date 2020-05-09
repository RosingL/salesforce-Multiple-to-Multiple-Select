global with sharing class Commonutils {
    

    //获取对象下某字段的选项列表值
    //Get The field PickList Value
    public static Map<String,String>  getPickListValues(String objName,String fieldName) {
        //根据对象名获取对象。
        //Accord To Object Name And Get The Object Infomation
        Schema.SObjectType objType= Schema.getGlobalDescribe().get(objName);
        if ( objType == null ) return null;
        //获取对象下所有字段。
        //Get All Field Of This Object
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        //得到对应的字段选项列表值
        //Get The PickList Value Of The Field
        List<Schema.PicklistEntry> pleList = objFieldMap.get(fieldName).getDescribe().getPicklistValues();
        Map<String,String> resultMap=new Map<String,String>();
        for(Schema.PicklistEntry option:pleList){
            resultMap.put(option.getValue(),option.getLabel());
        }
        return resultMap;
    }

   
}