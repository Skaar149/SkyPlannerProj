public with sharing class contactRoleService {
  public class ConctacRolDto {
    public Id contactId;
    public String contactName;
    public String contactPhone;
    public String contactEmail;
    public List<String> contactRoles;
  }


  @AuraEnabled(cacheable=true)
  public static List<String> getcontactRoleListString(Id AccId, String Filter) {
    System.debug('AccId > ' + AccId);
    System.debug('Filter > ' + Filter);
    Filter = '%' + Filter + '%';
    Map<Id, ConctacRolDto> contactRoles = new Map<Id, ConctacRolDto>();
    for (Contact_Rol__c cr : [
      SELECT
        Contact__r.Id,
        Contact__r.Name,
        Contact__r.Phone,
        Contact__r.Email,
        Contact__r.AccountId,
        Roles__r.Name
      FROM Contact_Rol__c
      WHERE
        Contact__r.AccountId = :AccId
        AND (Contact__r.Name LIKE :Filter
        OR Contact__r.Email LIKE :Filter
        OR Contact__r.Phone LIKE :Filter)
    ]) {
      if (contactRoles.containsKey(cr.Contact__r.Id)) {
        ConctacRolDto dto = contactRoles.get(cr.Contact__r.Id);
        dto.contactRoles.add(cr.Roles__r.Name);
      } else {
        ConctacRolDto dto = new ConctacRolDto();
        dto.contactId = cr.Contact__r.Id;
        dto.contactName = cr.Contact__r.Name;
        dto.contactPhone = cr.Contact__r.Phone;
        dto.contactEmail = cr.Contact__r.Email;
        dto.contactRoles = new List<String>{ cr.Roles__r.Name };
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
        dto.contactRoles = new List<String>();
        contactRoles.put(c.Id, dto);
      }
    }
    List<String> resultStringList = new List<String>();
    for (String contactId : contactRoles.keySet()) {
      String contacIdJson = JSON.serialize(contactRoles.get(contactId));
      resultStringList.add(contacIdJson);
    }
    System.debug('resultStringList' + ' - ' + resultStringList);

    return resultStringList;
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
