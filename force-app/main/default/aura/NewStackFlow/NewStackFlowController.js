({
    init : function (component) {
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        component.set("v.recordTypeId", recordTypeId);
        var actionGetRecordTypeName = component.get("c.getRecordTypeName");
        actionGetRecordTypeName.setParams({
            recordTypeId: recordTypeId
        });
        actionGetRecordTypeName.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var recordTypeName = response.getReturnValue();
                var header = component.find("header").set("v.value", "New Stack: " + recordTypeName);
            }
        });
        $A.enqueueAction(actionGetRecordTypeName);
        //***********************************
        var actionGetLayoutFieldNames = component.get("c.getLayoutFieldNames");
        actionGetLayoutFieldNames.setParams({
            recordTypeId: recordTypeId
        });
        actionGetLayoutFieldNames.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var fieldNames = response.getReturnValue();
                component.set("v.fieldNames", fieldNames);
            }
        });
        $A.enqueueAction(actionGetLayoutFieldNames);
        //***********************************
        var actionGetSection = component.get("c.getLayoutSections");
        actionGetSection.setParams({
            recordTypeId: recordTypeId
        });
        actionGetSection.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var sections = response.getReturnValue();
                component.set("v.sections", sections);
            }
        });
        $A.enqueueAction(actionGetSection);
        //***********************************
        var actionGetLayoutFields = component.get("c.getLayoutFields");
        actionGetLayoutFields.setParams({
            recordTypeId: recordTypeId
        });
        actionGetLayoutFields.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var fields = response.getReturnValue();
                console.log(JSON.stringify(fields));
                component.set("v.fieldSet", fields);
            }
        });
        $A.enqueueAction(actionGetLayoutFields);
        //***********************************
        /*
        Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        var inputVariables = [
            {
                name: "recordTypeId",
                type: "String",
                value: recordTypeId
            }
        ];
        flow.startFlow("New_Stack_Screen_Flow", inputVariables);
        */
    },
     
    handleCloseModal: function(component, event, helper) {
        window.history.back();
    },
    
    handleSave: function(component, event, helper) {
        component.find("recordEditForm").submit();
    },
    
    handleSuccess: function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Stack has been created successfully.",
            "type": "success"
        });
        toastEvent.fire();
        
        var params = event.getParams();
        var recordId = params.response.id;
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
          "recordId": recordId
        });
        navEvent.fire();
    }
})