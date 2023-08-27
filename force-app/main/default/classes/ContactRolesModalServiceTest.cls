@isTest
public with sharing class ContactRolesModalServiceTest {
    @testSetup
    static void setup() {
      // Create Account
      insert new Account(Name = 'TestAcc');
      Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];
  
      // Create Contacts
      List<Contact> testContact = new List<Contact>();
      for (Integer i = 0; i < 2; i++) {
        testContact.add(
          new Contact(
            AccountId = testAccount.Id,
            FirstName = 'FirstName ' + i,
            LastName = 'LastName ' + i
          )
        );
      }
      insert testContact;
  
      // Create Roles
      List<Roles__c> testRoles = new List<Roles__c>();
      for (Integer i = 0; i < 2; i++) {
        testRoles.add(new Roles__c(Name = 'Role ' + i, Color__c = '#FFF00' + i));
      }
      insert testRoles;
  
      // Create Contact Roles
      List<Contact> testContactList = [SELECT Id, Name FROM Contact];
      List<Roles__c> testRolesList = [SELECT Id FROM Roles__c];
      List<Contact_Rol__c> testContactRolesList = new List<Contact_Rol__c>();
      for (Contact c : testContactList) {
        for (Roles__c role : testRolesList) {
          testContactRolesList.add(
              new Contact_Rol__c(Contact__c = c.Id, Roles__c = role.Id)
            );
        }
      }
      insert testContactRolesList;
    }


    @isTest
    private static void getAllRoleList_Test(){
        Integer rolesCount =  [SELECT Id FROM Roles__c].size();

        Test.startTest();
        Integer getAllRoleListCount= ContactRolesModalService.getAllRoleList().size();
        Test.stopTest();

        System.assertEquals(rolesCount, getAllRoleListCount, 'The number of list items returned must be equal to the number of existing Roles.');
    }

    @isTest
    private static void getRoleByContact_IdNull(){
        Test.startTest();
        Boolean getRoleByContactIsEmpty= ContactRolesModalService.getRoleByContact(null).isEmpty();
        Test.stopTest();

        System.assertEquals(true, getRoleByContactIsEmpty, 'The returned list must be empty if the contact Id is null.');
    }

    @isTest
    private static void getRoleByContact_IdNotNull(){
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        Boolean getRoleByContactIsNotEmpty= !ContactRolesModalService.getRoleByContact(c.Id).isEmpty();
        Test.stopTest();

        System.assertEquals(true, getRoleByContactIsNotEmpty, 'The returned list must not be empty if the contact Id is valid.');
    }

    @isTest
    private static void updateRoleByContact_RemoveAll(){
        List<Roles__c> rolesList = [SELECT Id FROM Roles__c];
        List<Id> rolesIdInitial = new List<Id>();
        for (Roles__c role : rolesList) {
            rolesIdInitial.Add(role.Id);
        }
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        String response = ContactRolesModalService.updateRoleByContact(c.Id, rolesIdInitial, new List<Id>());
        Test.stopTest();

        System.assertEquals('OK', response, 'The response returned must be "OK" when the method parameters are valid.');
    }

    @isTest
    private static void updateRoleByContact_AddingRoles(){
        List<Roles__c> rolesList = [SELECT Id FROM Roles__c];
        List<Id> rolesIdFinal = new List<Id>();
        for (Roles__c role : rolesList) {
            rolesIdFinal.Add(role.Id);
        }
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        String response = ContactRolesModalService.updateRoleByContact(c.Id, new List<Id>(), rolesIdFinal);
        Test.stopTest();

        System.assertEquals('OK', response, 'The response returned must be "OK" when the method parameters are valid.');
    }
}