/**
 * Created by Ivan on 05.03.2018.
 */
public without sharing class MAS_PlanOfStudyController {

    @AuraEnabled
    public static String getContactName(String contactId) {
        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id = :contactId];
        if(contacts.size() == 1) {
            return contacts.get(0).Name;
        }
        return null;
    }

    @AuraEnabled
    public static MAS_Plan_of_Study__c getPlanOfStudy(String studentId) {
        MAS_UserUtils.Level l = MAS_UserUtils.getLevel();
        if((l != MAS_UserUtils.Level.Advisor) && (l != MAS_UserUtils.Level.Student)) {
            return null;
        }
        if(studentId == null || studentId == '' || l == MAS_UserUtils.Level.Student) {
            studentId = MAS_UserUtils.currentUser().Contact.Id;
        }
        MAS_QueryBuilder queryBuilder = new MAS_QueryBuilder();
        queryBuilder.tableName = 'MAS_Plan_of_Study__c';
        queryBuilder.fieldsTable = 'Id, MAS_Student__r.Name, MAS_Advisor__r.Name, MAS_1_2_Subject__c, MAS_1_2_Title__c, MAS_1_Alt_Subject__c, MAS_1_Alt_Title__c, MAS_2_1_Subject__c, MAS_2_1_Title__c, MAS_2_2_Subject__c, MAS_2_2_Title__c, MAS_2_Alt_Subject__c, MAS_2_Alt_Title__c, MAS_3_1_Subject__c, MAS_3_1_Title__c, MAS_3_2_Subject__c, MAS_3_2_Title__c, MAS_3_Alt_Subject__c, MAS_3_Alt_Title__c, MAS_Status__c, MAS_Name__c, MAS_Date_Submitted__c, MAS_Question_1__c, MAS_Question_2__c, MAS_1_1_Subject__c, MAS_1_1_Title__c';
        queryBuilder.whereExpression = 'MAS_Student__c = \'' + studentId + '\'';
        String queryString = queryBuilder.buildQuery();
        List<MAS_Plan_of_Study__c> plansOfStudy = Database.query(queryString);
        MAS_Plan_of_Study__c planOfStudy = null;
        if(plansOfStudy.size() == 1) planOfStudy = plansOfStudy.get(0);
        return planOfStudy;
    }

    @AuraEnabled
    public static void updatePlanOfStudy(MAS_Plan_of_Study__c plan) {
        if(plan.MAS_Date_Submitted__c == null && plan.MAS_Status__c == 'Student Submitted') plan.MAS_Date_Submitted__c = Date.today();
        update plan;
    }

}