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
                var header = component.find("header").set("v.value", "New Stack (" + recordTypeName + ")");
            }
        });
        $A.enqueueAction(actionGetRecordTypeName);
        //***********************************
        var actionGetLayoutFieldNames = component.get("c.getLayoutFieldNames");
        actionGetLayoutFieldNames.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var fieldNames = response.getReturnValue();
                component.set("v.fieldNames", fieldNames);
            }
        });
        $A.enqueueAction(actionGetLayoutFieldNames);
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
    }
})