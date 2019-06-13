/**
 * Created by Ivan on 12.04.2018.
 */

public with sharing class MASCO_FilterUtils {

    private static Map<String, Filter> filters { get; set; }
    static {
        filters = new Map<String, Filter>();
        filters.put('PlanOfStudy', new PlanOfStudy());
        filters.put('SummerPlan', new SummerPlan());
        filters.put('AbstractList' , new AbstractList());
        filters.put('ProposalList' , new ProposalList());
        filters.put('ProposalFileList', new ProposalFileList());
    }

    public static Filter getFilterByCode(String code) {
        return filters.get(code);
    }

    public abstract class Filter {
        public abstract String buildCondition(Map<String, String> filterParams);
    }

    /* Get PlanOfStudy list for current Advisor
    MASCO_DataTableController.DataDescriptor d = new MASCO_DataTableController.DataDescriptor();
    d.objectName = 'MAS_Plan_of_Study__c';
    d.fieldSet = 'Id';
    d.filterCode = 'PlanOfStudy';
     */
    public class PlanOfStudy extends Filter {
        public override String buildCondition(Map<String, String> filterParams) {
            User u = MAS_UserUtils.currentUser();
            MAS_UserUtils.Level l = MAS_UserUtils.getLevel();
            String soqlCondition;
            if(l == MAS_UserUtils.Level.Advisor) {
                soqlCondition = 'MAS_Advisor__c =\'' + u.Contact.Id + '\'';
            } else {
                soqlCondition = 'MAS_Student__c =\'005000000000000\'';
            }
            return soqlCondition;
        }
    }

    /* Get SummerPlan list for current Advisor
    MASCO_DataTableController.DataDescriptor d = new MASCO_DataTableController.DataDescriptor();
    d.objectName = 'MAS_Summer_Plan__c';
    d.fieldSet = 'Id';
    d.filterCode = 'SummerPlan';
     */
    public class SummerPlan extends Filter {
        public override String buildCondition(Map<String, String> filterParams) {
            User u = MAS_UserUtils.currentUser();
            MAS_UserUtils.Level l = MAS_UserUtils.getLevel();
            String soqlCondition;
            if(l == MAS_UserUtils.Level.Advisor) {
                soqlCondition = 'MAS_Advisor__c =\'' + u.Contact.Id + '\'';
            } else {
                soqlCondition = 'MAS_Student__c =\'005000000000000\'';
            }
            return soqlCondition;
        }
    }

    /* Get Abstract list for current Advisor
    MASCO_DataTableController.DataDescriptor d = new MASCO_DataTableController.DataDescriptor();
    d.objectName = 'MAS_Abstract__c';
    d.fieldSet = 'Id';
    d.filterCode = 'AbstractList';
    */
    public class AbstractList extends Filter {
        public override String buildCondition(Map<String, String> filterParams) {
            User u = MAS_UserUtils.currentUser();
            MAS_UserUtils.Level l = MAS_UserUtils.getLevel();
            String soqlCondition;
            if(l == MAS_UserUtils.Level.Advisor) {
                soqlCondition = 'MAS_Advisor__c =\'' + u.Contact.Id + '\'';
            } else {
                soqlCondition = 'MAS_Student__c =\'005000000000000\'';
            }
            return soqlCondition;
        }
    }

    /* Get Proposal list for current Advisor
    MASCO_DataTableController.DataDescriptor d = new MASCO_DataTableController.DataDescriptor();
    d.objectName = 'MAS_Proposal__c';
    d.fieldSet = 'Id';
    d.filterCode = 'ProposalList';
    */
    public class ProposalList extends Filter {
        public override String buildCondition(Map<String, String> filterParams) {
            User u = MAS_UserUtils.currentUser();
            MAS_UserUtils.Level l = MAS_UserUtils.getLevel();
            String soqlCondition;
            if(l == MAS_UserUtils.Level.Advisor) {
                soqlCondition = 'MAS_Advisor__c =\'' + u.Contact.Id + '\'';
            } else {
                soqlCondition = 'MAS_Student__c =\'005000000000000\'';
            }
            return soqlCondition;
        }
    }

    public class ProposalFileList extends Filter {
        public override String buildCondition(Map<String, String> filterParams) {
            User u = MAS_UserUtils.currentUser();
            MAS_UserUtils.Level l = MAS_UserUtils.getLevel();
            String soqlCondition = '';
            if(l == MAS_UserUtils.Level.Advisor || l == MAS_UserUtils.Level.Student) {

                if (filterParams != null) {
                    for (String key : filterParams.keySet()) {
                        if (String.isNotBlank(filterParams.get(key))) {
                            if (key == 'LinkedEntityId') {
                                soqlCondition += 'LinkedEntityId = \'' + String.escapeSingleQuotes(filterParams.get(key)) + '\'';
                            }
                        }
                    }
                }
            } else {
                soqlCondition = 'LinkedEntityId = NULL';
            }
            return soqlCondition;
        }
    }
}