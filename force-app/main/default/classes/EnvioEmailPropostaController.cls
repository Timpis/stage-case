public with sharing class EnvioEmailPropostaController {

    @AuraEnabled
    public static void enviarEmail(Id opportunityId) {

        Opportunity opp = [
            SELECT Id, Name, Email_Proposta_Enviado__c
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1
        ];

        OpportunityContactRole ocr = [
            SELECT Contact.Email
            FROM OpportunityContactRole
            WHERE OpportunityId = :opportunityId
            AND Contact.Email != null
            ORDER BY IsPrimary DESC
            LIMIT 1
        ];

        ContentVersion cv = [
            SELECT Title, VersionData
            FROM ContentVersion
            WHERE FirstPublishLocationId = :opportunityId
            AND FileType = 'PDF'
            ORDER BY CreatedDate DESC
            LIMIT 2
        ];

        Messaging.EmailFileAttachment anexo = new Messaging.EmailFileAttachment();
        anexo.setFileName(cv.Title + '.pdf');
        anexo.setBody(cv.VersionData);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { ocr.Contact.Email });
        email.setSubject('Proposta Comercial - ' + opp.Name);
        email.setPlainTextBody('Segue em anexo a proposta comercial.');
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { anexo });

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

        opp.Email_Proposta_Enviado__c = true;
        update opp;
    }
}
