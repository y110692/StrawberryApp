global with sharing class StrawberryBatchScheduled implements Schedulable {
    
    //  String cronExp = '0 0 13 * * ?';
    global void execute(SchedulableContext ctx) {
        StrawberryBatch b=new StrawberryBatch();
        database.executebatch(b, 200);
    }
    
}

