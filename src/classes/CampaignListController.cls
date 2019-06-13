public class CampaignListController {

    @AuraEnabled
    public static List<Campaign> findAll() {
        return [SELECT id, name, status FROM Campaign LIMIT 50];
    }

    @AuraEnabled
    public static List<Campaign> findByName(String searchKey) {
        String name = '%' + searchKey + '%';
        return [SELECT id, name, status FROM Campaign WHERE name LIKE :name LIMIT 50];
    }

    @AuraEnabled
    public static Campaign findById(String campaignId) {
        return [SELECT id, name, status
                    FROM Campaign WHERE Id = :campaignId];
    }

}