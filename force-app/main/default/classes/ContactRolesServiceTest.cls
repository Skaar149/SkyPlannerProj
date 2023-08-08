@isTest
private with sharing class ContactRolesServiceTest {
  @testSetup
  static void setup() {
    // Create Account
    insert new Account(Name = 'TestAcc');
    Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];

    // Create Contacts
    String contactName ='';
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
    Integer contactIndex = 0; 
    List<Contact> testContactList = [SELECT Id, Name FROM Contact];
    List<Roles__c> testRolesList = [SELECT Id FROM Roles__c];
    List<Contact_Rol__c> testContactRolesList = new List<Contact_Rol__c>();
    for (Contact c : testContactList) {
      for (Roles__c role : testRolesList) {
        if (contactIndex != 0) {            
        testContactRolesList.add(
            new Contact_Rol__c(Contact__c = c.Id, Roles__c = role.Id)
          );
        }
      }
      contactIndex++;
    }
    insert testContactRolesList;
  }

  @isTest
  private static void GetcontactRolesList_AccIdNull() {
    Test.startTest();
    List<ContactRolesService.ConctacRolDto> testContactRoles = ContactRolesService.getcontactRolesList(
      null,
      'testFilter'
    );
    Test.stopTest();

    System.assertEquals(
      true,
      testContactRoles.isEmpty(),
      'The returned list must be empty if the Account Id is null.'
    );
  }

  @isTest
  private static void GetcontactRolesList_AccIdNotNull() {
    Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];

    Test.startTest();
    List<ContactRolesService.ConctacRolDto> testContactRoles = ContactRolesService.getcontactRolesList(
      testAccount.Id,
      ''
    );
    Test.stopTest();

    System.assertEquals(
      true,
      !testContactRoles.isEmpty(),
      'The returned list must not be empty if the account id exists.'
    );
  }

  @isTest
  private static void GetcontactRolesList_FilterNull() {
    Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];
    Integer testContactCount = [SELECT Id FROM Contact].size();

    Test.startTest();
    Integer testContactRolesCount = ContactRolesService.getcontactRolesList(
        testAccount.Id,
        ''
      )
      .size();
    Test.stopTest();

    System.assertEquals(
      testContactCount,
      testContactRolesCount,
      'The number of list items returned must be equal to the number of Contacts existing when the filter is null.'
    );
  }

  @isTest
  private static void GetcontactRolesList_FilterValid() {
    Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];
    Contact c = [SELECT Id, Name FROM Contact LIMIT 1];
    String filter = c.Name;

    Test.startTest();
    Integer testContactRolesCount = ContactRolesService.getcontactRolesList(
        testAccount.Id,
        filter
      )
      .size();
    Test.stopTest();

    System.assertEquals(
      1,
      testContactRolesCount,
      'The number of list items returned must be equal to 1 the number of existing contacts filtered by the filter passed.'
    );
  }
}
