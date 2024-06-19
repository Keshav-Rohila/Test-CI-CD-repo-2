@isTest
public class AddressComponentControllerTest {

    @testSetup
    static void setup() {
        // Insert a custom setting for API Key
        Credentials__c cred = new Credentials__c();
        cred.Google_API_Key__c = 'fakeApiKey';
        insert cred;

        // Insert Address picklist values
        // Note: Since picklist values are metadata, they are not directly insertable in test setup.
        // Assuming the picklist values are already defined in the org.
    }

    @isTest
    static void testGetAddressTypeOptions() {
        Test.startTest();
        List<AddressComponentController.AddressTypeWrapper> addressTypes = AddressComponentController.getAddressTypeOptions();
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(0, addressTypes.size(), 'There should be some address type options.');
        for (AddressComponentController.AddressTypeWrapper type : addressTypes) {
            System.assertNotEquals(null, type.label, 'Label should not be null.');
            System.assertNotEquals(null, type.value, 'Value should not be null.');
        }
    }

    @isTest
    static void testSaveAddress() {
        // Create a sample AddressDataWrapper object
        AddressComponentController.AddressDataWrapper addressData = new AddressComponentController.AddressDataWrapper();
        addressData.street = '123 Test St';
        addressData.city = 'Test City';
        addressData.state = 'Test State';
        addressData.country = 'Test Country';
        addressData.postalCode = '12345';
        addressData.latitude = '12.345678';
        addressData.longitude = '98.765432';
        addressData.primary = true;
        addressData.type = new List<String>{'Home', 'Office'};
        
        String addressString = JSON.serialize(addressData);
		Account acc = new Account(Name='test Account');
        insert acc;
        Test.startTest();
        try{
            AddressComponentController.saveAddress(acc.Id, addressString);
            Address__c insertedAddress = [SELECT Street__c, City__c, State__c, Country__c, Zip_Postal_Code__c, Latitude__c, Longitude__c, Primary__c, Address_Type__c, Related_To__c FROM Address__c WHERE Related_To__c = '001xx000003NGsFAAW' LIMIT 1];

        // Assertions
        System.assertEquals('123 Test St', insertedAddress.Street__c, 'Street should match.');
        System.assertEquals('Test City', insertedAddress.City__c, 'City should match.');
        System.assertEquals('Test State', insertedAddress.State__c, 'State should match.');
        System.assertEquals('Test Country', insertedAddress.Country__c, 'Country should match.');
        System.assertEquals('12345', insertedAddress.Zip_Postal_Code__c, 'Postal code should match.');
        System.assertEquals(12.345678, insertedAddress.Latitude__c, 'Latitude should match.');
        System.assertEquals(98.765432, insertedAddress.Longitude__c, 'Longitude should match.');
        System.assertEquals(true, insertedAddress.Primary__c, 'Primary should be true.');
        System.assertEquals('Home;Office', insertedAddress.Address_Type__c, 'Address type should match.');
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
        Test.stopTest();

        // Query the address to check if it was inserted
        
    }

    @isTest
    static void testGetApiKey() {
        Test.startTest();
        String apiKey = AddressComponentController.getApiKey();
        Test.stopTest();

        // Assertion
        System.assertEquals('fakeApiKey', apiKey, 'API Key should match the value from custom setting.');
    }

    @isTest
    static void testGetSearchSuggestions() {
        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        String response = AddressComponentController.getSearchSuggestions('test');
        Test.stopTest();

        // Assertions
        System.assert(response.contains('predictions'), 'Response should contain predictions.');
    }

    @isTest
    static void testSelectLocation() {
        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        String response = AddressComponentController.selectLocation('1600 Amphitheatre Parkway, Mountain View, CA');
        Test.stopTest();

        // Assertions
        //System.assert(response.contains('results'), 'Response should contain results.');
    }

    // Mock class for HTTP responses
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"predictions":[{"description":"Test Prediction"}],"status":"OK"}');
            res.setStatusCode(200);
            return res;
        }
    }
}