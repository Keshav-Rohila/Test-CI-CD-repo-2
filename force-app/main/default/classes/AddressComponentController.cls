public class AddressComponentController {

    /**
     * To get all the address type options
     */
    @AuraEnabled(cacheable=true)
    public static List<AddressTypeWrapper> getAddressTypeOptions(){
        try {
            List<AddressTypeWrapper> types = new List<AddressTypeWrapper>();
            List<Schema.PicklistEntry> options = Schema.Address__c.SObjectType.getDescribe().fields.getMap().get('Address_Type__c').getDescribe().getPicklistValues();
            for(Schema.PicklistEntry op: options){
                System.debug('option -> ' + op);
                AddressTypeWrapper type = new AddressTypeWrapper(op.getLabel(),op.getValue());
                types.add(type);
            }
            System.debug('tyepes -> ' + types);
            return types;
            
        } catch (Exception e) {
            System.debug('error -> ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
 * Save the address information stored on the LWC UI
 * @param {String} relatedRecId - Id of the record the address is related to
 * @param {string} addressString - Serialized address data
 */
    @AuraEnabled
    public static void saveAddress(String relatedRecId, String addressString){
        try {
            System.debug('addressString ->' + addressString);
            AddressDataWrapper addressDetails = (AddressDataWrapper) JSON.deserialize(addressString, AddressDataWrapper.class);
            System.debug('addressDetails ->' + addressDetails);
            Address__c add = new Address__c();
            add.Street__c = addressDetails.street;
            add.City__c = addressDetails.city;
            add.State__c = addressDetails.state;
            add.Country__c = addressDetails.country;
            add.Zip_Postal_Code__c = addressDetails.postalCode;
            if(addressDetails.latitude  != null){
                add.Latitude__c = Decimal.valueOf(addressDetails.latitude);
            }
            if(addressDetails.longitude != null){
                add.Longitude__c = Decimal.valueOf(addressDetails.longitude);
            }
            add.Primary__c = addressDetails.primary;
            add.Address_Type__c = String.join(addressDetails.type,';');
            add.Related_To__c = relatedRecId;
            System.debug('address -> ' + add);
            insert add;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // To get the google places API key from the custom setting
    public static String getApiKey(){
        Credentials__c cred = Credentials__c.getOrgDefaults();   // Custom setting to store the API key
        String key = cred.Google_API_Key__c;
        return key;
    }

    /**
 * Gives the search suggestions using the Google API
 * @param {String} key -Search key to autocomplete
 */
    @AuraEnabled
    public static String getSearchSuggestions(String key){
        try {
            String apiKey = AddressComponentController.getApiKey();
            String apiUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=' + EncodingUtil.urlEncode(key, 'UTF-8') + '&key=' + apiKey;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(apiUrl);
            request.setMethod('GET');
            
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                return response.getBody();
            } else {
                return 'Error: ' + response.getStatusCode() + ' - ' + response.getStatus();
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


     /**
     * Gives the data of the searched address
     * @param {String} searchKey - Search key for API to get address components
     */
    @AuraEnabled    
    public static String selectLocation(String searchKey){
        try {
            String apiKey = AddressComponentController.getApiKey();
            String apiUrl = 'https://maps.googleapis.com/maps/api/geocode/json?address=' + EncodingUtil.urlEncode(searchKey, 'UTF-8') + '&key=' + apiKey;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(apiUrl);
            request.setMethod('GET');
            
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                return response.getBody();
            } else {
                return 'Error: ' + response.getStatusCode() + ' - ' + response.getStatus();
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Wrapper for the address type
    public class AddressTypeWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public AddressTypeWrapper(){

        }

        public AddressTypeWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    // Address data wrapper
    public class AddressDataWrapper{
        @AuraEnabled public String street;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String country;
        @AuraEnabled public String postalCode;
        @AuraEnabled public String latitude;
        @AuraEnabled public String longitude;
        @AuraEnabled public Boolean primary;
        @AuraEnabled public List<String> type;
    }

    @AuraEnabled
    public static string getData(String accId){
        try {
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

}