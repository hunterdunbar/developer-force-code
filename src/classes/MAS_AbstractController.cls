/**
 * Created by Ivan on 10.04.2018.
 */
public without sharing class MAS_AbstractController {

    @AuraEnabled
    public static List<Contact> findReaderObj(String searchString) {
        searchString = searchString.remove('\'');
        searchString = '%' + searchString + '%';
        return [SELECT Id, Name FROM Contact WHERE RecordType.Name = 'Reader' AND Name LIKE :searchString];
    }

    @AuraEnabled
    public static String findReaderJSON(String searchString) {
        searchString = searchString.remove('\'');
        searchString = '%' + searchString + '%';
        return JSON.serialize([SELECT Id, Name FROM Contact WHERE RecordType.Name = 'Reader' AND Name LIKE :searchString]);
    }

    @AuraEnabled
    public static MAS_Abstract__c getAbstract(String studentId) {
        MAS_UserUtils.Level l = MAS_UserUtils.getLevel();
        if((l != MAS_UserUtils.Level.Advisor) && (l != MAS_UserUtils.Level.Student)) {
            return null;
        }
        if(studentId == null || studentId == '' || l == MAS_UserUtils.Level.Student) {
            studentId = MAS_UserUtils.currentUser().Contact.Id;
        }
        MAS_QueryBuilder queryBuilder = new MAS_QueryBuilder();
        queryBuilder.tableName = 'MAS_Abstract__c';
        queryBuilder.fieldsTable = 'Id, MAS_Student__c, MAS_Student__r.Name, MAS_Advisor__c, MAS_Advisor__r.Name, MAS_Reader_One__c, MAS_Reader_One__r.Name, MAS_Reader_Two__c, MAS_Reader_Two__r.Name, MAS_Reader_Three__c, MAS_Reader_Three__r.Name, MAS_Abstract__c, MAS_Status__c, MAS_Title__c, MAS_Advisor_CDA__c, MAS_Reader_1_CDA__c, MAS_Reader_2_CDA__c, MAS_Reader_3_CDA__c, MAS_1st_Choice_Area_of_Concentration__c, MAS_2nd_Choice_Area_of_Concentration__c';
        queryBuilder.whereExpression = 'MAS_Student__c = \'' + studentId + '\'';
        String queryString = queryBuilder.buildQuery();
        List<MAS_Abstract__c> abstractList = Database.query(queryString);
        MAS_Abstract__c abstractObj = null;
        if(abstractList.size() == 1) abstractObj = abstractList.get(0);
        return abstractObj;
    }

    @AuraEnabled
    public static void updateAbstract(MAS_Abstract__c abstractObj) {
        update abstractObj;
    }

    public class Responce {
        public String status;
        public Contact contact;
    }

    @AuraEnabled
    public static String createReaderContact(Contact contact) {
        Responce resp = new Responce();
        try {
            contact.RecordTypeId = '012f1000001168hAAA';
            insert contact;
        } catch (DmlException dmle) {
            resp.status = dmle.getMessage();
            return JSON.serialize(resp);
        } catch (Exception e) {
            resp.status = e.getMessage();
            return JSON.serialize(resp);
        }
        List<Contact> cResps = [SELECT Id, Name FROM Contact WHERE Id = :contact.Id LIMIT 1];
        Contact cResp = (cResps.size() == 1) ? cResps.get(0) : null;
        resp.status = 'Ok';
        resp.contact = cResp;
        return JSON.serialize(resp);
    }

}