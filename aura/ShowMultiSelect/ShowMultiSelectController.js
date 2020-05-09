({
    doInit : function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        if(!recordId){
            component.set("v.title", "New");
        }else{
            component.set("v.title", "Edit");
        }
        var getPickVal = component.get("c.getPickValues");
        getPickVal.setParams({
                objname : 'Test_Obj__c',
                parentFieldName : 'Parent_Multi_Select__c',
                childFieldName : 'Child_Multi_Select__c',
        });


        var existData = component.get("c.GetExistData");
        existData.setParams({
                recordId : recordId,
        });

        //读取父级选项列表和子级选项列表值， 形成依赖关系的List

        getPickVal.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultMap = response.getReturnValue();
                component.set("v.listMapPick", resultMap);
                component.set('v.loaded', !component.get('v.loaded'));
                console.log(component.get("v.listMapPick"));
            } else {
                helper.showError(response.getError());
            }
        });

        //读取当前记录的 父级选项列表 和 子级选项列表的值， 在页面展示已经选中的值
        // Edit  Record . show The Record alredy checked Choices.
        existData.setCallback(this, function (response,errorMessage) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                var parentList=resultData.parentList;
                var childList=resultData.childList;
                if(!!parentList){
                    component.set('v.activeParents',resultData.parentList);
                    component.set('v.activeParentsMessage', "Parent Choices: " + parentList.join(';'));
                    if(childList){
                    component.set('v.activeChilds',resultData.childList);
                    component.set('v.activeChildsMessage', "Child Choices: " + childList.join(';'));   
                    }    
                }
                component.set('v.Dataloaded', !component.get('v.Dataloaded'));
            } else {
                helper.Cancel();
                helper.showError(response.getError());
            }
        });
        
        
        $A.enqueueAction(getPickVal);
        $A.enqueueAction(existData);

    },


    

    waiting: function(component, event, helper) {
        component.set('v.loaded', false);
    },
 
    doneWaiting: function(component, event, helper) {
        component.set('v.loaded', true);
        
    },

    Save : function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));
        //标准更新记录方法
        // component.find("edit").get("e.recordSave").fire();
        //提示信息

        //保存方法 Save Action
        var saveAction = component.get("c.SaveData");

        var showParentVal=component.get("v.activeParents");
        var showChildVal=component.get("v.activeChilds");

        var parentLabels=component.get("v.activeParentsLabel");
        var childLabels=component.get("v.activeChildsLabel");

        if(showParentVal.length==0){
            alert("At Least Choose One Parent ")
            component.set('v.loaded', !component.get('v.loaded'));
            return;
        }
        if(showChildVal.length==0){
            alert("At Least Choose One Child")
            component.set('v.loaded', !component.get('v.loaded'));
            return;
        }
        var key1=false;
        showParentVal.forEach(function(v){
            var key=false;
            //each active parent need at least one child had checked.
            //选择了父值 至少需要选择一个子值
            $("input[type='checkbox']:checked").each(function(j) {
                if($(this).attr("name")==v){
                    key=true;
                }
            });  

            if(!key){
                key1=true;
            }
        })

        if(key1){
            alert("At Least choose One Child Value");
            component.set('v.loaded', !component.get('v.loaded'));
            return;
        }
        
        


        saveAction.setParams({
                recordId : component.get("v.recordId"),
                showChildVal: showChildVal.join(';'),
                showParentVal: showParentVal.join(';'),
                childLabels: childLabels,
                parentLabels: parentLabels,
        });

        //调用方法
        saveAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var message = response.getReturnValue();
                if(message.isSuccess){
                    //提示信息
                    helper.showMessage("Success","Save Success")
                    //跳转到记录页面
                    //
                    helper.refreshView(component.get("v.recordId"));
                    //setTimeout(window.location.reload(),1000);
                    
                }else{
                    helper.showMessage("Save Error",message.saveMsg);
                }
                component.set('v.loaded', !component.get('v.loaded'));
            } else {
                helper.showError(response.getError());
            }
        });

        $A.enqueueAction(saveAction);

        
    },

    handleSectionToggle: function (cmp, event) {
        var strgetSelectValue=new Array();
        var strgetSelectLabel=new Array();


        var openSections = event.getParam('openSections');
        var openSectionsLabel = new Array();

        var activeBus=cmp.get('v.activeChilds');
        if(activeBus!=null&&activeBus!=''){
            //先全部取消勾选
            // uncheck All .
            var getSelectValueMenbers =$("input[type='checkbox']:checked").each(function(j) {
                $(this).prop("checked",false);
                
            });
            //勾选选中的。
            //check The User 
            activeBus.forEach(function(ele,Index){
                openSections.forEach(function(ele2,Index2){
                    if($("#"+ele+"").attr("name")==ele2){
                        $("#"+ele+"").prop("checked",true);  
                        var val=$("#"+ele+"").val();
                        var label=$("#"+ele+"").attr("data-label");
                        strgetSelectValue.push(val);
                        strgetSelectLabel.push(label);  
                    }
                });
                
            });  

            cmp.set('v.activeChilds', strgetSelectValue);
            cmp.set('v.activeChildsMessage', strgetSelectLabel.join(';'));
            cmp.set('v.activeChildsMessage', "Child Choices:"+strgetSelectLabel.join(';'));
        }
        


        cmp.set('v.activeParents',openSections);
        if (openSections.length === 0) {
            cmp.set('v.activeParentsMessage', "Nothing Parent Have Choiced!");
        } else {
            var listBus=cmp.get("v.listMapPick");
            listBus.forEach(function(obj){
                openSections.forEach(function(ele){
                    if(obj.parentPick.value==ele){
                        openSectionsLabel.push(obj.parentPick.label);
                    }
                });
            });
            cmp.set('v.activeParentsLabel', openSectionsLabel.join(';'));
            cmp.set('v.activeParentsMessage', "Parent Choices: " + openSectionsLabel.join(';'));
        }
    },

    handleSectionBus: function(component, event){
        var strgetSelectValue=new Array();
        var strgetSelectLabel=new Array();
        var getSelectValueMenbers =$("input[type='checkbox']:checked").each(function(j) {
            if (j >= 0) {
                var val=$(this).val();
                var label=$(this).attr("data-label");
                strgetSelectValue.push(val);
                strgetSelectLabel.push(label);
                
            }
        });

        component.set('v.activeChilds', strgetSelectValue);
        component.set('v.activeChildsLabel', strgetSelectLabel.join(';'));
        component.set('v.activeChildsMessage', "Child Chocies:"+strgetSelectLabel.join(';'));
    },

    Cancel : function(component, event, helper) { 
        // Close the action panel 
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 
    } 
    


})