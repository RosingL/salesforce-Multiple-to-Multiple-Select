({
    showMessage:function(title, Msg){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":Msg,
            type:"success"
        });
        toastEvent.fire();
    },

    showError:function(errors){
    	var message='';
    	//解析错误信息，返回正确的文字
    	//Return correct error Description 
    	if (errors) {
            for(var i=0; i < errors.length; i++) {
                for(var j=0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                    message += (message.length > 0 ? '\n' : '') + errors[i].pageErrors[j].message;
                }
                if(errors[i].fieldErrors) {
                    for(var fieldError in errors[i].fieldErrors) {
                        var thisFieldError = errors[i].fieldErrors[fieldError];
                        for(var j=0; j < thisFieldError.length; j++) {
                            message += (message.length > 0 ? '\n' : '') + thisFieldError[j].message;
                        }
                    }
                }
                if(errors[i].message) {
                    message += (message.length > 0 ? '\n' : '') + errors[i].message;
                }
            }
        } else {
            message += (message.length > 0 ? '\n' : '') + 'Unknown error';
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            title: '错误',
            type: 'error',
            "message":message
        });
        toastEvent.fire();
    },

    refreshView:function(recordId){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
        
        $A.get("e.force:refreshView").fire();
    },

    Cancel : function(component, event, helper) { 
        // Close the action panel 
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 
    } 
 
})