({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Owner Id', fieldName: 'ownerId', type: 'Id'},
            {label: 'Owner Name', fieldName: 'OwnerName', type: 'Text'},
            {label: 'Total Leads', fieldName: 'TotalLeads', type: 'number'},
            {label: 'Total Opportunities', fieldName: 'TotalOpportunities', type: 'number',default:'0'},
            {label: 'Latest Created Date(Opp)', fieldName: 'LatestCreatedopp', type: 'Date'},
            {label: 'Total Val(Opp)', fieldName: 'TotalOppVal', type: 'currency',typeAttributes: { currencyCode: 'USD' }}
            
        ]);
        
        var action = component.get("c.getRecordsByOwner");
        
        
        action.setCallback(this, function(response){ 
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {                
                var allValues = response.getReturnValue(); 
                component.set("v.wrapperList",allValues);
                
            }                    
        });
        $A.enqueueAction(action);
        
        
    }
    
})