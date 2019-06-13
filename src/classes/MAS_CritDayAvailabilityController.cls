/**
 * Created by Ivan on 25.04.2018.
 */

public with sharing class MAS_CritDayAvailabilityController {

    @AuraEnabled
    public static List<MAS_Crit_Day_Availability__c> getCritDayAvailabilityObj(String contactId) {
        MAS_UserUtils.Level l = MAS_UserUtils.getLevel();
        if((l != MAS_UserUtils.Level.Advisor) && (l != MAS_UserUtils.Level.Reader)) {
            return null;
        }
        if(contactId == null || contactId == '') {
            contactId = MAS_UserUtils.currentUser().Contact.Id;
        }
        List<MAS_Crit_Day_Availability__c> cdList =
        [SELECT Id, MAS_Start_Time__c, MAS_Start_Time_Text__c, MAS_Is_Break__c, MAS_IsAvailable__c, MAS_ReaderSubmitted__c
        FROM MAS_Crit_Day_Availability__c WHERE MAS_Related_Contact__c = :contactId
        ORDER BY MAS_Start_Time__c];

        List<MAS_Crit_Day_Availability__c> cdListRet = new List<MAS_Crit_Day_Availability__c>();
        for(Integer i = 0; i < cdList.size(); i++) {
            if(((cdList[i].MAS_Start_Time__c).minute() == 0) || ((cdList[i].MAS_Start_Time__c).minute() == 30)) {
                cdListRet.add(cdList[i]);
            }
        }
        return cdListRet;
    }

    @AuraEnabled
    public static Boolean setCritDayAvailabilityObj(List<SObject> critDayAvailabilitiesList) {
        List<MAS_Crit_Day_Availability__c> cdList = (List<MAS_Crit_Day_Availability__c>) critDayAvailabilitiesList;
        MAS_UserUtils.Level l = MAS_UserUtils.getLevel();
        if((l != MAS_UserUtils.Level.Advisor) && (l != MAS_UserUtils.Level.Reader)) {
            return false;
        }
        if(cdList.size() > 0) {
            String contactId = MAS_UserUtils.currentUser().Contact.Id;

            List<MAS_Crit_Day_Availability__c> cdListFrom =
            [SELECT Id, MAS_Related_Contact__c, MAS_Start_Time__c, MAS_Is_Break__c, MAS_IsAvailable__c
            FROM MAS_Crit_Day_Availability__c WHERE MAS_Related_Contact__c = :contactId
            ORDER BY MAS_Start_Time__c];

            Map<Id, MAS_Crit_Day_Availability__c> idList = new Map<Id, MAS_Crit_Day_Availability__c>(cdListFrom);
            Map<Datetime, MAS_Crit_Day_Availability__c> timeList = new Map<Datetime, MAS_Crit_Day_Availability__c>();
            for (MAS_Crit_Day_Availability__c val : cdListFrom) {
                timeList.put(val.MAS_Start_Time__c, val);
            }

            List<MAS_Crit_Day_Availability__c> cdListOut = new List<MAS_Crit_Day_Availability__c>();
            for (Integer i = 0; i < cdList.size(); i++) {
                //check if recived id is not equals current contact id
                if(idList.get(cdList[i].Id) == null || !idList.get(cdList[i].Id).MAS_Related_Contact__c.equals(contactId)) {
                    return false;
                }
                cdListOut.add(cdList[i]);
                MAS_Crit_Day_Availability__c cCD = idList.get(cdList[i].Id);
                MAS_Crit_Day_Availability__c temp = timeList.get(cCD.MAS_Start_Time__c.addMinutes(15));
                if(temp == null) return false;
                if(temp.MAS_Is_Break__c) {
                    temp.MAS_IsAvailable__c = false;
                } else {
                    temp.MAS_IsAvailable__c = cdList[i].MAS_IsAvailable__c;
                }
                cdListOut.add(temp);
            }

            update cdListOut;
        } else {
            return false;
        }
        return true;
    }

}