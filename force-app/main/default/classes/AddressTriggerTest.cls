@isTest
public class AddressTriggerTest {
    
    @testSetup
    static void setup() {
                List<Schema.PicklistEntry> options = Schema.Address__c.SObjectType.getDescribe().fields.getMap().get('Address_Type__c').getDescribe().getPicklistValues();
		Account acc = new Account(Name = 'Test Account');
       	insert acc;
        Address__c add = new Address__c();
            add.Address_Type__c = options[0].getValue();
            add.City__c = 'Jaipur';
            add.Country__c = 'India';
            add.State__c = 'Rajasthan';
            add.Street__c = '243 Shanti Path';
            add.Zip_Postal_Code__c = '302004';
            add.Primary__c = true;
            add.Related_To__c = acc.Id;
            insert add;
    }
    
	@isTest
    public static void insertAddressTest(){
        List<Schema.PicklistEntry> options = Schema.Address__c.SObjectType.getDescribe().fields.getMap().get('Address_Type__c').getDescribe().getPicklistValues();
        if(options.size() > 0){
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Address__c add1 = new Address__c();
            add1.Address_Type__c = options[0].getValue();
            add1.City__c = 'Jaipur';
            add1.Country__c = 'India';
            add1.State__c = 'Rajasthan';
            add1.Street__c = '243 Shanti Path';
            add1.Zip_Postal_Code__c = '302004';
            add1.Primary__c = true;
            add1.Related_To__c = acc.Id;
            insert add1;
            
            
        }
        
    }
    
    @isTest
    public static void updateAddressTest(){
        List<Schema.PicklistEntry> options = Schema.Address__c.SObjectType.getDescribe().fields.getMap().get('Address_Type__c').getDescribe().getPicklistValues();
        if(options.size() > 0){
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Address__c add1 = new Address__c();
            add1.Address_Type__c = options[0].getValue();
            add1.City__c = 'Jaipur';
            add1.Country__c = 'India';
            add1.State__c = 'Rajasthan';
            add1.Street__c = '243 Shanti Path';
            add1.Zip_Postal_Code__c = '302004';
            add1.Primary__c = false;
            add1.Related_To__c = acc.Id;
            insert add1;
            
            if(options.size() >= 0){
                add1.Primary__c = true;
                update add1;
            }
        }
    }
}