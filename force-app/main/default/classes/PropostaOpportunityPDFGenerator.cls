public with sharing class PropostaOpportunityPDFGenerator {

    public PropostaOpportunityPDFGenerator() {

        Id oppId = ApexPages.currentPage().getParameters().get('id');
        if (oppId == null) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity não informada')
            );
            return;
        }

        // Renderiza o PDF da Visualforce
        PageReference pdfPage = Page.Proposta_Oportunidade;
        pdfPage.getParameters().put('id', oppId);

        Blob pdfBlob;
        try {
            pdfBlob = pdfPage.getContentAsPDF();
        } catch (Exception e) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, 'Erro ao gerar PDF')
            );
            return;
        }

        // Cria o File (ContentVersion)
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Proposta - ' + oppId;
        cv.PathOnClient = 'Proposta.pdf';
        cv.VersionData = pdfBlob;
        insert cv;

        // Recupera ContentDocumentId
        Id contentDocumentId = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ].ContentDocumentId;

        // Relaciona o arquivo à Opportunity
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDocumentId;
        cdl.LinkedEntityId = oppId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;

        // Volta para a Opportunity
        ApexPages.currentPage().setRedirect(true);
        ApexPages.currentPage().getParameters().put('id', oppId);
    }
}