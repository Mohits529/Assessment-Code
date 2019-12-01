public class BusinessClass {
    
    @auraEnabled
    public static List <String> getPicklistValues(sObject ObjectName, string picklistField) {
        List <String> allOpts = new list <String> ();
        try{
            Schema.sObjectType objType = ObjectName.getSObjectType();
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            list<Schema.PicklistEntry> values = fieldMap.get(picklistField).getDescribe().getPickListValues();
            for (Schema.PicklistEntry a: values) {
                allOpts.add(a.getValue());
            }        
            allOpts.sort();
            
        }catch(Exception e){
            System.debug('-->'+e.getMessage());
        }
        return allOpts;
    }
    
    @auraEnabled
    Public static list<Wrapperclass> getBusinessSales(String city1,String city2){
        list<Wrapperclass> listOfWrapper=new List<WrapperClass>();
        try{
            
            string combinedCity=city1+';'+city2;
            List<Business__c> businessRecords=[select Id,Name,Sales__c,Operating_Region__c from Business__c where Operating_Region__c=:city1 OR Operating_Region__c=:city2 OR Operating_Region__c =:combinedCity];        
            
            if(!businessRecords.isEmpty()){
            Map<string,List<Business__c>> mapBusinessRecbyOperatingReg=New Map<string,List<Business__c>>();
            
            for(Business__c business:businessRecords){
                
                business.Operating_Region__c=business.Operating_Region__c.replace(';', ',');
                
                List<Business__c> bussinessList = mapBusinessRecbyOperatingReg.get(business.Operating_Region__c);
                
                if(bussinessList== Null){
                    bussinessList =new list<Business__c>();
                    mapBusinessRecbyOperatingReg.put(business.Operating_Region__c,bussinessList);
                }
                bussinessList.add(business);
                
                
                
                
            }
            for(String region:mapBusinessRecbyOperatingReg.keyset()){
                list<Business__c> businessRec=mapBusinessRecbyOperatingReg.get(region);
                
                
                Decimal sumofsalebyregion=0;
                for(Business__c business:businessRec){
                    business.Operating_Region__c=business.Operating_Region__c.replace(';', ',');
                    sumofsalebyregion= sumofsalebyregion + business.Sales__c;
                    
                }
                Wrapperclass wr=new Wrapperclass(region,businessRec,sumofsalebyregion);
                
                listOfWrapper.add(wr);
                
            }
            }else if(businessRecords.isEmpty()){
                listOfWrapper=null;
                }
        }catch(Exception e){
            system.debug('-->'+e.getLineNumber()+e.getMessage());
        }
        
        return listOfWrapper;
    }
    public class Wrapperclass {
        @auraEnabled Public String Region {get;set;}
        @auraEnabled public List<Business__c> busunessRecList {get;set;}
        @auraEnabled Public Decimal sumofSale {get;set;}
        Public Wrapperclass(String Region,List<Business__c> busunessRecList,Decimal sumofSale){
            this.Region =Region;
            this.busunessRecList=busunessRecList;
            this.sumofSale=sumofSale;
            
        }
        
    }
    Public class ownerBasedWrapperClass{
        @auraEnabled Public Id ownerId {get;set;}
        @auraEnabled public String OwnerName {get;set;}
        @auraEnabled Public Integer TotalLeads {get;set;}
        @auraEnabled Public Integer TotalOpportunities {get;set;}
        @auraEnabled Public Date LatestCreatedopp {get;set;}
        @auraEnabled Public Decimal TotalOppVal {get;set;}
        
        
        public ownerBasedWrapperClass(Id ownerId,String OwnerName,Integer TotalLeads,Integer TotalOpportunities,Date LatestCreatedopp,Decimal TotalOppVal){
            this.ownerId=ownerId;
            this.OwnerName=OwnerName;
            this.TotalLeads=TotalLeads;
            this.TotalOpportunities=TotalOpportunities;
            this.LatestCreatedopp=LatestCreatedopp;
            this.TotalOppVal=TotalOppVal;
        }
    }
    @auraEnabled
    Public static list<ownerBasedWrapperClass> getRecordsByOwner(){
        List<ownerBasedWrapperClass> listWrapperClass=New List<ownerBasedWrapperClass>();
        try{
            Map<Id,Integer> totalLeadsByOwnerId=New Map<Id,Integer>();
            Map<Id,Integer> totalOppsByOwnerId=New Map<Id,Integer>();
            Map<Id,Decimal> totalOppsSumByOwnerId=New Map<Id,Decimal>();
            Map<Id,Date> lastOppcreatedDateByOwnerId=New Map<Id,Date>();
            
            List<sObject> leadRec=[SELECT count(Id),OwnerId FROM Lead group by ownerId];
            
            for(sObject l:leadRec){
                
                totalLeadsByOwnerId.put((Id)l.get('OwnerId'),(Integer)l.get('expr0'));
                
            }
            
            List<sObject> opportunityRecs=[select count(Id),Sum(Amount),Max(createdDate),OwnerId from opportunity group by ownerId ];
            for(sObject opprec:opportunityRecs){
                
                totalOppsByOwnerId.put((Id)opprec.get('OwnerId'),(Integer)opprec.get('expr0'));
                totalOppsSumByOwnerId.put((Id)opprec.get('OwnerId'),(Decimal)opprec.get('expr1'));
                DateTime dT=(DateTime)opprec.get('expr2');
                Date createdDate=date.newinstance(dT.year(), dT.month(), dT.day());
                lastOppcreatedDateByOwnerId.put((Id)opprec.get('OwnerId'),createdDate);
            }
            
            list<User> users=[Select Id,Name from User ];
            for(User usr : users){
                ownerBasedWrapperClass ownWrpClass;
                if(totalLeadsByOwnerId.containsKey(usr.Id) && totalOppsByOwnerId.containsKey(usr.Id)){
                    
                    ownWrpClass=New ownerBasedWrapperClass(usr.Id,usr.Name,totalLeadsByOwnerId.get(usr.Id),totalOppsByOwnerId.get(usr.Id),lastOppcreatedDateByOwnerId.get(usr.Id),totalOppsSumByOwnerId.get(usr.Id));
                    
                }
                else if(!totalLeadsByOwnerId.containsKey(usr.Id) && totalOppsByOwnerId.containsKey(usr.Id) ){
                    
                    ownWrpClass=New ownerBasedWrapperClass(usr.Id,usr.Name,null,totalOppsByOwnerId.get(usr.Id),lastOppcreatedDateByOwnerId.get(usr.Id),totalOppsSumByOwnerId.get(usr.Id));
                }
                else if(totalLeadsByOwnerId.containsKey(usr.Id) && !totalOppsByOwnerId.containsKey(usr.Id)){
                    
                    ownWrpClass=New ownerBasedWrapperClass(usr.Id,usr.Name,totalLeadsByOwnerId.get(usr.Id),null,null,null);
                }
                listWrapperClass.add(ownWrpClass);
            }
        }catch(Exception e){
            system.debug('-->'+e.getMessage()+e.getLineNumber());
        }
        
        return listWrapperClass;
    }
}