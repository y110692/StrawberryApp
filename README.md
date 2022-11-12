# Strawberry Planting 
### Salesforce LWC application

Demo GIF is below. **App features**:

- Custom objects - Plant and Line.
- Wired getPlants Apex method to retrieve data.
- Child component 'Plant Item' to render records.
- Parent component 'Plant list' with filters, list of plants and selected record information.
- Filter plants (records) by min/max height, variety, state.
- Reset filters.
- New plant (record) creation.
- Plant (record) selection.
- **Scheduled Apex Batch** to update State field depending of plant age (PlantingDate__c field).
- Watering the plant indicator if it is dry (depending on *last watering date* - WateringDate__c).
- Harvesting button if *plant age > Variety Ripening period*.
- Remove record action button.
- Clone record action button.
- Edit record action button.

![Demo](https://user-images.githubusercontent.com/116291167/201484523-83c1ee5a-0199-4f35-bf77-d5db857e854f.mp4)
