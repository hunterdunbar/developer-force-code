/**
 * Created by Ivan on 20.04.2018.
 */

public with sharing class MAS_ContactHelper {

    public static List<Contact> getListOfContacts() {
        List<Contact> listContacts = [SELECT Id, Name, RecordType.Name FROM Contact WHERE RecordType.Name in ('Faculty', 'Reader')];
        return listContacts;
    }

    public static void addCritDayAvailability() {
        List<Contact> listContacts = getListOfContacts();
        afterInsert(listContacts);
    }

    public static void afterInsert(List<Contact> items) {
        List<MAS_Crit_Day_Availability__c> crit_Day = new List<MAS_Crit_Day_Availability__c>();
        for (Contact c: items) {
            List<Contact> selectedContacts = [SELECT Id, RecordType.Name FROM Contact WHERE Id = :c.Id LIMIT 1];
            Contact selectedContact = (selectedContacts.size() == 1) ? selectedContacts.get(0) : null;
            if(selectedContact != null && (selectedContact.RecordType.Name == 'Faculty' || selectedContact.RecordType.Name == 'Reader')) {
                List<Crit_Day_Slot__mdt> selectedCritDaySlots = [SELECT Id, Crit_Day_Time_Slot__c, Crit_Day_Time_Slot_Text__c, Is_Break__c, Label FROM Crit_Day_Slot__mdt];
                for(Crit_Day_Slot__mdt cds : selectedCritDaySlots) {
                    MAS_Crit_Day_Availability__c cd = new MAS_Crit_Day_Availability__c();
                    cd.MAS_Related_Contact__c = c.Id;
                    cd.MAS_Start_Time__c = cds.Crit_Day_Time_Slot__c;
                    cd.MAS_Start_Time_Text__c = cds.Crit_Day_Time_Slot_Text__c;
                    cd.MAS_IsAvailable__c = !cds.Is_Break__c;
                    cd.MAS_Is_Break__c = cds.Is_Break__c;
                    crit_Day.add(cd);
                }
            }
        }
        if(crit_Day.size() > 0) {
            insert crit_Day;
        }
    }
}