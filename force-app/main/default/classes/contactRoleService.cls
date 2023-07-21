public with sharing class contactRoleService {
    @AuraEnabled(cacheable = true)
    public static List<Contact> getcontactRole(Id RecordId , String Filter) {
        Filter = '%' + Filter + '%';
        return [
            SELECT Name, Email , Phone, AccountId
            FROM Contact
            WHERE 
                  AccountId = :RecordId AND
                  (Name LIKE :Filter OR
                  Email LIKE :Filter OR
                  Phone LIKE :Filter)
        ];
    }
}