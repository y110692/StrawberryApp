public class StrawberryBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> statesList = new List<String>{'Processed', 'Removed'};
        
        String query = 'SELECT Id, Name, Height__c,CreatedDate,Variety__c,WateringDate__c, PlantingDate__c,VarietyPicture__c,Line__c, Line__r.Name, VarietyRipening__c, State__c, Harvest__c FROM Plant__c WHERE State__c NOT in: statesList';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Plant__c> plantList) {
        
		List<Plant__c> plantsToUpdate = new List<Plant__c>();

        for(Plant__c plant : plantList) {

            System.debug('Plant is ' + plant.Id);
            if (plant.PlantingDate__c != null) {
                Datetime plantingDate = plant.PlantingDate__c;
				Datetime nowDateTime = Datetime.now();
				Decimal plantAge = (nowDateTime.getTime()- plantingDate.getTime())/ 86400000;
				System.debug('Plant age = ' + plantAge);

				if (plantAge > 14 && plantAge < plant.VarietyRipening__c && plant.State__c != 'Bloomed') {
					plant.State__c = 'Bloomed';
					System.debug('Plant ' + plant.Id + ' age (' + plantAge + ') is more than 14 and less than ' + plant.VarietyRipening__c+ '. New status is Bloomed');
					plantsToUpdate.add(plant);
				}
				else if (plantAge >= plant.VarietyRipening__c && plant.State__c != 'Ripe') {
					plant.State__c = 'Ripe';
					System.debug('Plant' + plant.Id + 'age (' + plantAge + ') is more than ' + plant.VarietyRipening__c + '. New status is Ripe');

					plantsToUpdate.add(plant);
				}
				else {
					System.debug('Skipped: ' + plant.Id + ' / ' + plantAge + ' / ' + plant.State__c);
				}
            }
			else {
				System.debug('Plant ' + plant.Id + ' date is null.');

			}
            
        }

		if (Plant__c.sObjectType.getDescribe().isUpdateable()){
			System.debug('updatable');
            update plantsToUpdate;
          }
		  else {
			System.debug('Not updateable');
		  }
        
        
    }   
    
    public void finish(Database.BatchableContext bc) {
        System.debug('finish');
  }
}