/**
 * Created by Ivan on 24.04.2018.
 */

public with sharing class MAS_ThesisController {

    @AuraEnabled
    public static String getThesises() {
        String advisorId = MAS_UserUtils.currentUser().Contact.Id;
        MAS_UserUtils.Level l = MAS_UserUtils.getLevel();
        if(l == MAS_UserUtils.Level.Advisor) {
            List<Contact> thesisSubmitted = [SELECT Id, MAS_Thesis_Submitted__c FROM Contact WHERE MAS_Advisor__c = :advisorId];
        } else {
            return null;
        }
        return null;
    }
}