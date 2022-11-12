@isTest
public with sharing class StrawberryController_TEST {
    @isTest
    static void test1(){

        Line__c line1 = new Line__c();
        insert line1;

        Datetime bloomedDate = Datetime.now().adddays(-15);
        Datetime ripeDate = Datetime.now().adddays(-90);
        Plant__c  plant1 = new Plant__c (Line__c = line1.Id, Height__c = 5, PlantingDate__c = bloomedDate, State__c = 'Planted', Variety__c = 'Albion');
        Plant__c  plant2 = new Plant__c (Line__c = line1.Id, Height__c = 5,  PlantingDate__c = ripeDate, State__c = 'Planted', Variety__c = 'Albion');
        insert plant1;
        insert plant2;
        System.debug(plant1);
        System.debug(plant2);

        StrawberryBatch b = new StrawberryBatch();

        Test.startTest();
        
         StrawberryController.WrapperFilters wrapper = new StrawberryController.WrapperFilters();
         wrapper.filterMinHeight = 0;
         wrapper.filterMinHeight = 30;
         wrapper.filterState = null;
         wrapper.filterVarieties = null;

        StrawberryController.getPlants(wrapper);
        StrawberryController.getStateList();
        StrawberryController.getVarietyList();
        StrawberryController.clonePlant(plant2.Id);
        StrawberryController.waterThePlant(plant1.Id);
        StrawberryController.harvestPlant(plant1.Id);
        StrawberryController.deletePlant(plant1.Id);

        Test.stopTest();

        List<Plant__c> plantList = [SELECT Id from Plant__c ];
        System.assertEquals(2, plantList.size());


    }
}
