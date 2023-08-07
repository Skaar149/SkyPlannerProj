public with sharing class ContactRolesService {
  
  public class ConctacRolDto {
    @AuraEnabled
    public Id contactId;
    @AuraEnabled
    public String contactName;
    @AuraEnabled
    public String contactPhone;
    @AuraEnabled
    public String contactEmail;
    @AuraEnabled
    public List<RoleDto> contactRoles;
  }

  public class RoleDto {
    @AuraEnabled
    public Id contactId;
    @AuraEnabled
    public String Role;
    @AuraEnabled
    public String Color;
  }


  @AuraEnabled(cacheable=false)
  public static List<ConctacRolDto> getcontactRolesList(Id AccId, String Filter) {
    Filter = '%' + Filter + '%';
    Map<Id, ConctacRolDto> contactRoles = new Map<Id, ConctacRolDto>();
    for (Contact_Rol__c cr : [
      SELECT
        Contact__r.Id,
        Contact__r.Name,
        Contact__r.Phone,
        Contact__r.Email,
        Contact__r.AccountId,
        Roles__r.Name,
        Roles__r.Color__c
      FROM Contact_Rol__c
      WHERE
        Contact__r.AccountId = :AccId
        AND (Contact__r.Name LIKE :Filter
        OR Contact__r.Email LIKE :Filter
        OR Contact__r.Phone LIKE :Filter)
        ORDER BY Roles__r.Name
    ]) {
      if (contactRoles.containsKey(cr.Contact__r.Id)) {
        ConctacRolDto dto = contactRoles.get(cr.Contact__r.Id);
        //create role dto
        RoleDto roleDto = new RoleDto();
        roleDto.contactId = cr.Contact__r.Id;
        roleDto.Role = cr.Roles__r.Name;
        roleDto.Color = 'background-color: ' + cr.Roles__r.Color__c;
        dto.contactRoles.add(roleDto);
      } else {
        ConctacRolDto dto = new ConctacRolDto();
        dto.contactId = cr.Contact__r.Id;
        dto.contactName = cr.Contact__r.Name;
        dto.contactPhone = cr.Contact__r.Phone;
        dto.contactEmail = cr.Contact__r.Email;
        //create role dto
        RoleDto roleDto = new RoleDto();
        roleDto.contactId = cr.Contact__r.Id;
        roleDto.Role = cr.Roles__r.Name;
        roleDto.Color = 'background-color: ' + cr.Roles__r.Color__c;
        dto.contactRoles = new List<RoleDto>{ roleDto };
        contactRoles.put(cr.Contact__r.Id, dto);
      }
    }
    //La lista de todos los contactos para agregar al resultado los contactos que no tengas Roles
    List<Contact> contactList = getContactbyAccount(AccId, Filter);
    for (Contact c : contactList) {
      if (!contactRoles.containsKey(c.Id)) {
        ConctacRolDto dto = new ConctacRolDto();
        dto.contactId = c.Id;
        dto.contactName = c.Name;
        dto.contactPhone = c.Phone;
        dto.contactEmail = c.Email;
        dto.contactRoles = new List<RoleDto>();
        contactRoles.put(c.Id, dto);
      }
    }
    List<ConctacRolDto> resultList= contactRoles.values();
    return resultList;
  }

  public static List<Contact> getContactbyAccount(Id AccId, String Filter) {
    return [
      SELECT Id, Name, Phone, Email, AccountId
      FROM Contact
      WHERE
        AccountId = :AccId
        AND (Name LIKE :Filter
        OR Email LIKE :Filter
        OR Phone LIKE :Filter)
    ];
  }
}
