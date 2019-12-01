({
    doInit : function(component, event, helper) {
        var fieldName = 'Operating_Region__c';
        var action = component.get("c.getPicklistValues");
        var opts = [];
        action.setParams({
            "ObjectName": component.get("v.objInfoCase"),
            "picklistField": fieldName
        });
        action.setCallback(this, function(response){ 
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {                
                var allValues = response.getReturnValue(); 
                
                if (allValues == undefined && allValues.length <= 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                    
                }
                else
                {
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push({
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }
                    
                }
                component.set("v.picklistValues", opts);
            }                    
        });
        $A.enqueueAction(action);
        
    },
    getReport:function(component, event, helper) {
        
        var selectedCities= component.get("v.selectedOptions");
        var action=component.get("c.getBusinessSales")
        console.log(selectedCities);
        action.setParams({
            "city1" : selectedCities[0],
            "city2" : selectedCities[1],
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state === 'SUCCESS'){         
                var StoreResponse = a.getReturnValue();
                component.set("v.wrapperList",StoreResponse);            
                
            }else if (state === "ERROR") {
                var errors = a.getError();
                console.log('@@Errors');
                
            }
        });
        
        $A.enqueueAction(action);
    },
    
    selectoption:function(component, event, helper) {
        var selectedOptions=component.get("v.selectedOptions");
        
        if(selectedOptions.length>2){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "error!",
                "message": "Maximum 2 cities can be selected."
            });
            toastEvent.fire();
        }
        if(selectedOptions.length===2){
            component.set("v.Likedisable",false);
        }else{
            component.set("v.Likedisable",true);
        }
        
    }
})