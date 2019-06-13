/**
 * Created by Ivan on 23.04.2018.
 */

public with sharing class MAS_FileController {

    /**
     * Method create new Content Document Link to connect File and Work Order
     */
    @AuraEnabled
    public static void addFile(Id contentVersionId, Id proposalId) {
        if (contentVersionId == null || proposalId == null) {
            return;
        }
        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];
        ContentVersion contentVersion = (contentVersions.size() == 1) ? contentVersions.get(0) : null;
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
        contentDocumentLink.LinkedEntityId = proposalId;
        contentDocumentLink.ShareType = 'V';
        contentDocumentLink.Visibility = 'AllUsers';
        MASCO_SoqlUtils.tryPerformDmlOperation(MASCO_SoqlUtils.DmlOperation.Inserting, new List<sObject> {contentDocumentLink});
    }

    /**
     * Method removes File by Content Document Link
     */
    @AuraEnabled
    public static String deleteFile(Id id) {
        if (id == null) {
            return null;
        }
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.Id = id;
        return JSON.serialize(MASCO_SoqlUtils.performDmlOperation(MASCO_SoqlUtils.DmlOperation.Deleting, contentDocumentLink));
    }
}