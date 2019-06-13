/**
 * Created by Ivan on 05.04.2018.
 */
public with sharing class MAS_UserHelper {

    //Test to create POS when user created

    public static List<User> getListOfStudentAdvisorUsers() {
        List<User> listUsers = [SELECT Id, Name, ContactId FROM User WHERE Profile.Name = 'Student Community Login User' OR Profile.Name = 'Faculty Community User'];
        return listUsers;
    }

    public static void addPOS() {
        List<User> listUsers = getListOfStudentAdvisorUsers();
        afterInsert(listUsers);
    }


    public static void afterInsert(List<User> items) {
        List<MAS_Plan_of_Study__c> planOfStudyList = new List<MAS_Plan_of_Study__c>();
        List<MAS_Summer_Plan__c> summerPlanList = new List<MAS_Summer_Plan__c>();
        List<MAS_Abstract__c> abstractList = new List<MAS_Abstract__c>();
        List<MAS_Proposal__c> proposalList = new List<MAS_Proposal__c>();

        for(User u : items) {
            List<User> selectedUsers = [SELECT Id, Profile.Name FROM User WHERE Id = :u.Id LIMIT 1];
            User selectedUser = (selectedUsers.size() == 1) ? selectedUsers.get(0) : null;
            if(selectedUser != null && selectedUser.Profile.Name == 'Student Community Login User') {
                List<Contact> contactList = [SELECT Id, MAS_Advisor__c FROM Contact WHERE Id = :u.ContactId LIMIT 1];
                Contact selectedContact = (contactList.size() == 1) ? contactList.get(0) : null;

                MAS_Plan_of_Study__c planOfStudyRecord = new MAS_Plan_of_Study__c();
                MAS_Summer_Plan__c summerPlanRecord1 = new MAS_Summer_Plan__c();
                MAS_Summer_Plan__c summerPlanRecord2 = new MAS_Summer_Plan__c();
                MAS_Abstract__c abstractRecord = new MAS_Abstract__c();
                MAS_Proposal__c proposalRecord = new MAS_Proposal__c();

                planOfStudyRecord.MAS_Student__c = u.ContactId;
                summerPlanRecord1.MAS_Student__c  = u.ContactId;
                summerPlanRecord2.MAS_Student__c  = u.ContactId;
                abstractRecord.MAS_Student__c    = u.ContactId;
                proposalRecord.MAS_Student__c    = u.ContactId;

                planOfStudyRecord.MAS_Status__c = 'Unreviewed';
                summerPlanRecord1.MAS_Status__c = 'Unreviewed';
                summerPlanRecord2.MAS_Status__c = 'Unreviewed';

                planOfStudyRecord.MAS_Advisor__c = selectedContact.MAS_Advisor__c;
                summerPlanRecord1.MAS_Advisor__c  = selectedContact.MAS_Advisor__c;
                summerPlanRecord2.MAS_Advisor__c  = selectedContact.MAS_Advisor__c;
                abstractRecord.MAS_Advisor__c    = selectedContact.MAS_Advisor__c;
                abstractRecord.MAS_Reader_One__c = selectedContact.MAS_Advisor__c;
                proposalRecord.MAS_Advisor__c    = selectedContact.MAS_Advisor__c;

                summerPlanRecord1.MAS_Title__c = 'Summer 1';
                summerPlanRecord2.MAS_Title__c = 'Summer 2';

                planOfStudyList.add(planOfStudyRecord);
                summerPlanList.add(summerPlanRecord1);
                summerPlanList.add(summerPlanRecord2);
                abstractList.add(abstractRecord);
                proposalList.add(proposalRecord);
            }
        }
        if(planOfStudyList.size() > 0) {
            insert planOfStudyList;
        }
        if(summerPlanList.size()  > 0) {
            insert summerPlanList;
        }
        if(abstractList.size()    > 0) {
            insert abstractList;
        }
        if(proposalList.size()    > 0) {
            insert proposalList;
        }
    }

}