/**
 * Created by Ivan on 06.04.2018.
 */
public without sharing class MAS_SummerPlanController {

    public class SPList {
        public String studentId;
        public String studentName;
        public String sp1Id;
        public String sp1Status;
        public String sp1Title;
        public String sp2Id;
        public String sp2Status;
        public String sp2Title;
    }

    public class DataResult
    {
        public List<SPList> sObjectRecords {get; set;}
        public Integer total {get; set;}
    }

    public static String createSummerPlanList(List<MAS_Summer_Plan__c> spList) {
        DataResult dataReturn = new DataResult();
        dataReturn.sObjectRecords = new List<MAS_SummerPlanController.SPList>();
        if(Math.mod(spList.size(), 2) == 0) {
            List<SPList> spListRet = new List<SPList>();
            Integer total = spList.size() / 2;


            Integer s1 = 0;
            Integer e1 = total;
            Integer s2 = total;
            Integer e2 = total * 2;
            if(spList.get(0).MAS_Title__c.contains('2')) {
                s1 = total;
                e1 = total * 2;
                s2 = 0;
                e2 = total;
            }
            for (Integer i = s1; i < e1; i++) {
                SPList sp = new SPList();
                sp.studentId = spList[i].MAS_Student__r.Id;
                sp.studentName = spList[i].MAS_Student__r.Name;
                sp.sp1Id = spList[i].Id;
                sp.sp1Status = spList[i].MAS_Status__c;
                sp.sp1Title = spList[i].MAS_Title__c;
                for(Integer j = s2; j < e2; j++) {
                    if(spList[i].MAS_Student__r.Id == spList[j].MAS_Student__r.Id) {
                        sp.sp2Id = spList[j].Id;
                        sp.sp2Status = spList[j].MAS_Status__c;
                        sp.sp2Title = spList[j].MAS_Title__c;
                        break;
                    }
                }
                dataReturn.sObjectRecords.add(sp);
            }
            dataReturn.total = total;
        } else {
            dataReturn.total = 0;
        }
        return JSON.serialize(dataReturn);
    }


    public static String getSummerPlanList(String advisorId) {
        List<Contact> contactList = [SELECT Id, Name, (SELECT Id, MAS_Status__c, MAS_Title__c FROM Summer_Plans_Student__r ORDER BY MAS_Status__c) FROM Contact WHERE MAS_Advisor__c = :advisorId];
        List<SPList> spList = new List<SPList>();
        for (Integer i = 0; i < contactList.size(); i++) {
            SPList sp = new SPList();
            sp.studentId = contactList[i].Id;
            sp.studentName = contactList[i].Name;
            for (Integer j = 0; j < contactList[i].Summer_Plans_Student__r.size(); j++) {
                if(contactList[i].Summer_Plans_Student__r[j].MAS_Title__c == 'Summer 1') {
                    sp.sp1Id = contactList[i].Summer_Plans_Student__r[j].Id;
                    sp.sp1Status = contactList[i].Summer_Plans_Student__r[j].MAS_Status__c;
                    sp.sp1Title = contactList[i].Summer_Plans_Student__r[j].MAS_Title__c;
                } else {
                    sp.sp2Id = contactList[i].Summer_Plans_Student__r[j].Id;
                    sp.sp2Status = contactList[i].Summer_Plans_Student__r[j].MAS_Status__c;
                    sp.sp2Title = contactList[i].Summer_Plans_Student__r[j].MAS_Title__c;
                }
            }
            spList.add(sp);
        }
        System.debug(spList);

        spList.sort();

        DataResult dr = new DataResult();
        dr.sObjectRecords = spList;
        dr.total = spList.size();

        String resultJson = JSON.serialize(dr);
        return resultJson;
    }

    @AuraEnabled
    public static MAS_Summer_Plan__c getSummerPlan(String studentId, String summerNumS) {
        Integer summerNum = 0;
        try {
            summerNum = Integer.valueOf(summerNumS);
        } catch (Exception e) {
            System.debug('MAS_SummerPlanController.getSummerPlan error convert summerNumS to Integer');
        }

        MAS_UserUtils.Level l = MAS_UserUtils.getLevel();
        if((l != MAS_UserUtils.Level.Advisor) && (l != MAS_UserUtils.Level.Student)) {
            return null;
        }
        if(studentId == null || studentId == '' || l == MAS_UserUtils.Level.Student) {
            studentId = MAS_UserUtils.currentUser().Contact.Id;
        }
        if(summerNum == null || (summerNum < 1 && summerNum > 2)) {
            return null;
        }
        String summerPlanTitle = summerNum == 1 ? 'Summer 1' : 'Summer 2';
        MAS_QueryBuilder queryBuilder = new MAS_QueryBuilder();
        queryBuilder.tableName = 'MAS_Summer_Plan__c';
        queryBuilder.fieldsTable = 'Id, MAS_Student__r.MAS_Citizenship_Status__c, MAS_Student__r.Name, MAS_Advisor__r.Name, MAS_Plan__c, MAS_Status__c, MAS_Title__c, MAS_1_Staying_at_MIT__c, MAS_2_Leaving_MIT__c, MAS_3_Complicated__c, MAS_4_Graduating__c, MAS_5_Plans__c, MAS_6_Fellowship_Info__c, MAS_7_Getting_CPTOPT__c, MAS_8_Received_CPTOPT__c, MAS_9_NotStarted_CPTOPT__c, MAS_10_Thesis_Situation__c';
        queryBuilder.whereExpression = 'MAS_Student__c = \'' + studentId + '\' AND MAS_Title__c = \'' + summerPlanTitle + '\'';
        String queryString = queryBuilder.buildQuery();
        List<MAS_Summer_Plan__c> summerPlanList = Database.query(queryString);
        MAS_Summer_Plan__c summerPlanObj = null;
        if(summerPlanList.size() == 1) {
            summerPlanObj = summerPlanList.get(0);
        }
        return summerPlanObj;
    }

    @AuraEnabled
    public static void updateSummerPlan(MAS_Summer_Plan__c plan) {
        update plan;
    }
}