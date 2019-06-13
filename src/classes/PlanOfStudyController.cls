public class PlanOfStudyController {

    @AuraEnabled
    public static String getAllPos() {
        MAS_QueryBuilder queryBuilder = new MAS_QueryBuilder();
        queryBuilder.tableName = 'Plan_of_Study__c';
        List<sObject> ret = Database.query(queryBuilder.buildQuery());
        return JSON.serialize(ret);
    }

    @AuraEnabled
    public static String getPosListAdvisor() {
        MAS_QueryBuilder queryBuilder = new MAS_QueryBuilder();
        queryBuilder.tableName = 'User';
        String query = queryBuilder.buildQuery();
        query += ' WHERE Id = \'005f100000Gdsv6AAB\'';
        List<sObject> ret = Database.query(query);
        return JSON.serialize(ret);//[SELECT Id, Name FROM Profile WHERE Id=:profileId][0].Name;
    }

    //Get POS object. If current user Student -> get his POS, if current user Advisor -> get POS by Id
    @AuraEnabled
    public static String getPosById(String idS) {
        MAS_QueryBuilder queryBuilder = new MAS_QueryBuilder();
        queryBuilder.tableName = 'Plan_of_Study__c';
        queryBuilder.fieldsTable = 'MAS_Student__c, MAS_Advisor__c, MAS_1_2_Subject__c, MAS_1_2_Title__c, MAS_1_Alt_Subject__c, MAS_1_Alt_Title__c, MAS_2_1_Subject__c, MAS_2_1_Title__c, MAS_2_2_Subject__c, MAS_2_2_Title__c, MAS_2_Alt_Subject__c, MAS_2_Alt_Title__c, MAS_3_1_Subject__c, MAS_3_1_Title__c, MAS_3_2_Subject__c, MAS_3_2_Title__c, MAS_3_Alt_Subject__c, MAS_3_Alt_Title__c, MAS_Status__c';
        if(MAS_UserUtils.getLevel() == MAS_UserUtils.Level.Student) {
            queryBuilder.whereExpression = 'MAS_Student__c = :UserInfo.getUserId()'; //\'003f100001yydX0AAI\'
            List<sObject> ret = Database.query(queryBuilder.buildQuery());
            return JSON.serialize(ret);
        } else if(MAS_UserUtils.getLevel() == MAS_UserUtils.Level.Advisor) {
            if(idS != null) {
                queryBuilder.whereExpression = 'MAS_Student__c = :idS';
                List<sObject> ret = Database.query(queryBuilder.buildQuery());
                return JSON.serialize(ret);
            }
        }
        return JSON.serialize('');
    }

    @AuraEnabled
    public static String updatePosStudent(String idS) {
        return '';
    }

}