@isTest
public with sharing class StrawberryBatch_TEST {
    @isTest
    static void test1(){

        Line__c line1 = new Line__c();
        insert line1;

        Datetime bloomedDate = Datetime.now().adddays(-15);
        Datetime ripeDate = Datetime.now().adddays(-90);
        Plant__c  plant1 = new Plant__c (Line__c = line1.Id, PlantingDate__c = bloomedDate, State__c = 'Planted', Variety__c = 'Albion');
        Plant__c  plant2 = new Plant__c (Line__c = line1.Id, PlantingDate__c = ripeDate, State__c = 'Planted', Variety__c = 'Albion');
        insert plant1;
        insert plant2;
        System.debug(plant1);
        System.debug(plant2);

        StrawberryBatch b = new StrawberryBatch();

        Test.startTest();

        ID batchprocessid = Database.executeBatch(b,200);
        
        Test.stopTest();

        Plant__c plant1upd = [SELECT Id, State__c from Plant__c WHERE Id=:plant1.Id];
        Plant__c plant2upd = [SELECT Id, State__c from Plant__c WHERE Id=:plant2.Id];

        System.assertEquals('Bloomed', plant1upd.State__c );
        System.assertEquals('Ripe', plant2upd.State__c );


    }
}
