@isTest
public with sharing class RolesServiceTest {
    @testSetup
    static void setup() {
        //insert Roles
        insert new Roles__C(Name = 'White', Color__c = '#FFFFFF');
        insert new Roles__C(Name = 'Black', Color__c = '#000000');
    }

    @isTest
    private static void CreateRole_InvalidName(){
        Roles__c role = [SELECT Name FROM Roles__c LIMIT 1];

        Test.startTest();
        String response = RolesService.createRole(role.Name, 'color', 'style');
        Test.stopTest();

        System.assertEquals('Invalid Name', response, 'The response returned must be "Invalid Name".');
    }

    @isTest
    private static void CreateRole_InvalidColor(){
        Roles__c role = [SELECT Color__c FROM Roles__c LIMIT 1];

        Test.startTest();
        String response = RolesService.createRole('name', role.Color__c, 'style');
        Test.stopTest();

        System.assertEquals('Invalid Color', response, 'The response returned must be "Invalid Color".');
    }

    @isTest
    private static void CreateRole_Succefully(){
        Test.startTest();
        String response = RolesService.createRole('Red', '#FF0000', 'style');
        Test.stopTest();

        System.assertEquals('OK', response, 'The response returned must be "OK".');
    }

}