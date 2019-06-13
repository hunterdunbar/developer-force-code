/**
 * Created by Ivan on 18.04.2018.
 */

public with sharing class MAS_ProposalController {

    @AuraEnabled
    public static MAS_Proposal__c getProposal(String studentId) {
        MAS_UserUtils.Level l = MAS_UserUtils.getLevel();
        if((l != MAS_UserUtils.Level.Advisor) && (l != MAS_UserUtils.Level.Student)) {
            return null;
        }
        if(studentId == null || studentId == '' || l == MAS_UserUtils.Level.Student) {
            studentId = MAS_UserUtils.currentUser().Contact.Id;
        }
        MAS_QueryBuilder queryBuilder = new MAS_QueryBuilder();
        queryBuilder.tableName = 'MAS_Proposal__c';
        queryBuilder.fieldsTable = 'Id, MAS_Student__c, MAS_Advisor__c, MAS_Reader_One__c, MAS_Reader_One__r.Name, MAS_Reader_Two__c, MAS_Reader_Two__r.Name, MAS_Reader_Three__c, MAS_Reader_Three__r.Name, MAS_Abstract__c, MAS_Advisor_Status__c, MAS_Reader_One_Status__c, MAS_Reader_Two_Status__c';
        queryBuilder.whereExpression = 'MAS_Student__c = \'' + studentId + '\'';
        String queryString = queryBuilder.buildQuery();
        List<MAS_Proposal__c> proposalList = Database.query(queryString);
        MAS_Proposal__c proposalObj = null;
        if(proposalList.size() == 1) proposalObj = proposalList.get(0);
        return proposalObj;
    }

    @AuraEnabled
    public static void updateProposal(MAS_Proposal__c proposalObj) {
        update proposalObj;
    }
}