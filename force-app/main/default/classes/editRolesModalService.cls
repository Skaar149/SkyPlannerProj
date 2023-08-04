public with sharing class editRolesModalService {
  public class dualListElementDto {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
    public dualListElementDto(String label, String value) {
      this.label = label;
      this.value = value;
    }
  }
  @AuraEnabled
  public static List<dualListElementDto> getAllRoleList() {
    System.debug('getAllRoleList edit Modal');
    List<dualListElementDto> result = new List<dualListElementDto>();
    for (Roles__c role : [
      SELECT Id, Name
      FROM Roles__c
    ]) {
      result.add(new dualListElementDto(role.Name, role.Id));
    }
    System.debug('getAllRoleList edit Modal result ' + result);
    return result;
  }

  @AuraEnabled
  public static List<String> getRoleByContact(Id contactId) {
    System.debug('getRoleByContact edit Modal');
    List<String> result = new List<String>();
    for (Contact_Rol__c cr : [
      SELECT Contact__r.Id, Roles__r.Name, Roles__r.Id
      FROM Contact_Rol__c
      WHERE Contact__r.Id = :contactId
    ]) {
      result.add(cr.Roles__r.Id);
    }
    System.debug('getRoleByContact edit Modal result ' + result);
    return result;
  }

  @AuraEnabled
  public static String updateRoleByContact(
    Id contactId,
    List<Id> initialRoles,
    List<Id> finalRoles
  ) {
    System.debug('getRoleByContact edit Modal');
    System.debug('getRoleByContact contactId '+contactId);
    System.debug('getRoleByContact initialRoles '+initialRoles);
    System.debug('getRoleByContact finalRoles '+finalRoles);
    List<String> result = new List<String>();
    List<Id> toRemoveRoles = new List<Id>();
    List<Contact_Rol__c> toInsertRoles = new List<Contact_Rol__c>();
    try {
      for (Id role : initialRoles) {
        if (finalRoles.isEmpty() || !finalRoles.contains(role)) {
          toRemoveRoles.add(role);
        }
      }

      for (Id role : finalRoles) {
        if (initialRoles.isEmpty() || !initialRoles.contains(role)) {
          Contact_Rol__c toAddRole = new Contact_Rol__c();
          toAddRole.Contact__c = contactId;
          toAddRole.Roles__c = role;
          toInsertRoles.add(toAddRole);
        }
      }
      List<Contact_Rol__c> rolesToRemove = [
        SELECT Id, Contact__r.Id, Roles__r.Id
        FROM Contact_Rol__c
        WHERE Contact__r.Id = :contactId AND Roles__r.Id IN :toRemoveRoles
      ];

      System.debug('getRoleByContact toInsertRoles '+ toInsertRoles);
      System.debug('getRoleByContact toRemoveRoles '+ rolesToRemove);
      delete rolesToRemove;
      upsert toInsertRoles;
      return 'OK';
    } catch (Exception e) {
      return e.getMessage();
    }
  }
}
