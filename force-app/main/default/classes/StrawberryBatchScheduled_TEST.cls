@isTest
private class StrawberryBatchScheduled_TEST {
    @isTest
    static void test1(){

        Test.StartTest();
        StrawberryBatchScheduled sh1 = new StrawberryBatchScheduled();
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Schedule Plant', sch, sh1); 
        Test.stopTest(); 

        List<CronTrigger> cronTriggerList = [SELECT ID, CronExpression, CronJobDetail.Name, CronJobDetailId, EndTime, NextFireTime, PreviousFireTime, StartTime, State, TimesTriggered FROM CronTrigger WHERE CronJobDetail.Name=:'Test Schedule Plant' ];

        System.assertEquals( 1, cronTriggerList.size() );
    }
}
