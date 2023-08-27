public with sharing class RolesService {
  @AuraEnabled
  public static string createRole(String name, String color, String style) {
    if (invalidName(String.escapeSingleQuotes(name))) {
      return 'Invalid Name';
    } else if (invalidColor(String.escapeSingleQuotes(color))) {
      return 'Invalid Color';
    } else {
      Roles__c newRole = new Roles__c();
      newRole.Name = name;
      newRole.Color__c = color;
      newRole.Style__c = style;
      insert newRole;
      return 'OK';
    }
  }

  private static Boolean invalidName(String name) {
    List<Roles__c> roles = [SELECT Name FROM Roles__c WITH SECURITY_ENFORCED];
    for (Roles__c role : roles) {
      if (role.Name.toLowerCase() == name.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  private static Boolean invalidColor(String color) {
    List<Roles__c> roles = [
      SELECT Color__c
      FROM Roles__c
      WITH SECURITY_ENFORCED
    ];
    for (Roles__c role : roles) {
      if (role.Color__c.toLowerCase() == color.toLowerCase()) {
        return true;
      }
    }
    return false;
  }
}
