public with sharing class StrawberryController {

    public class WrapperFilters {
        @AuraEnabled
        public Integer filterMinHeight{get;set;}

        @AuraEnabled
        public Integer filterMaxHeight{get;set;}

        @AuraEnabled
        public List<String> filterVarieties { get; set; }

        @AuraEnabled
        public List<String> filterState { get; set; }

    }
    @AuraEnabled(cacheable=true)
        public static List<Plant__c> getPlants(WrapperFilters filtersToApex){ 

        System.debug('filters = ' + String.valueOf(filtersToApex));

        Integer filterMinHeight = filtersToApex.filterMinHeight;
        Integer filterMaxHeight = filtersToApex.filterMaxHeight;
        List<String> filterVarieties = filtersToApex.filterVarieties == null? getVarietyList() : filtersToApex.filterVarieties;
        List<String> filterState = filtersToApex.filterState == null ? getStateList() : filtersToApex.filterState;

        List<Plant__c> plants = [SELECT Id, Name, Height__c,CreatedDate,Variety__c,WateringDate__c, PlantingDate__c,VarietyPicture__c,Line__c, Line__r.Name, VarietyRipening__c, State__c, Harvest__c
        FROM Plant__c
        WHERE Height__c >=:filterMinHeight AND Height__c <=:filterMaxHeight
        AND Variety__c IN:filterVarieties
        AND State__c IN:filterState
        WITH SECURITY_ENFORCED
        ORDER BY Line__c, Name];

        System.Debug(plants);
        return plants;
    }

    @AuraEnabled(cacheable=true)
    public static void deletePlant(String recordId){
        Plant__c item = [SELECT Id from Plant__c  WHERE Id=:recordId WITH SECURITY_ENFORCED][0] ;
        if (Plant__c.sObjectType.getDescribe().isDeletable()){
            delete item;
        }
    }

    @AuraEnabled(cacheable=false)
    public static void clonePlant(String recordId){
        Plant__c item = [SELECT Id, Line__c, State__c, Variety__c, Height__c FROM Plant__c  WHERE Id=:recordId WITH SECURITY_ENFORCED][0] ;
        Plant__c cloneItem = new Plant__c(State__c = item.State__c, Line__c = item.Line__c, Variety__c = item.Variety__c, Height__c = item.Height__c);
        if (Plant__c.sObjectType.getDescribe().isCreateable()){
            insert cloneItem;
          }
    }

    @AuraEnabled
    public static void harvestPlant(Id recordId){
        System.debug(recordId);
        Plant__c plant = [SELECT Id, Name, Height__c,CreatedDate,Variety__c,WateringDate__c, PlantingDate__c,VarietyPicture__c,Line__c, Line__r.Name, VarietyRipening__c, State__c, Harvest__c FROM Plant__c WHERE Id=:recordId WITH SECURITY_ENFORCED];

        plant.State__c = 'Processed';
        if (Plant__c.sObjectType.getDescribe().isUpdateable()){
            update plant;
          }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getVarietyList(){
        Schema.DescribeFieldResult fieldDetail = Plant__c.Variety__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldDetail.getPicklistValues();

        List<String> varietyList = new List<String>();
        for (Schema.PicklistEntry entry: values) {
            varietyList.add(entry.getLabel());
        }

        return varietyList;
    }


    @AuraEnabled(cacheable=true)
    public static List<String> getStateList(){
        Schema.DescribeFieldResult fieldDetail = Plant__c.State__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldDetail.getPicklistValues();

        List<String> stateList = new List<String>();
        for (Schema.PicklistEntry entry: values) {
            stateList.add(entry.getLabel());
        }

        return stateList;
    }

    @AuraEnabled
    public static Plant__c waterThePlant(Id recordId){
        Plant__c plant = [SELECT Id, Name, Height__c,CreatedDate,Variety__c,WateringDate__c, PlantingDate__c,VarietyPicture__c,Line__c, Line__r.Name, VarietyRipening__c, State__c, Harvest__c FROM PLant__c WHERE Id=:recordId WITH SECURITY_ENFORCED];
        
        System.debug(' watering date = ' + plant.WateringDate__c);
        plant.WateringDate__c = Datetime.now();
        System.debug('new watering date = ' + plant.WateringDate__c);
        if (Plant__c.sObjectType.getDescribe().isUpdateable()){
            update plant;
        }

        return plant;
    }
}