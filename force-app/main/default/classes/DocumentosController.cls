public with sharing class DocumentosController {


    @AuraEnabled(cacheable=true)
    public static Map<String, List<DocumentoDTO>> listar(Id recordId) {

        List<DocumentoDTO> normais = new List<DocumentoDTO>();
        List<DocumentoDTO> assinados = new List<DocumentoDTO>();

        for (ContentVersion cv : [
            SELECT ContentDocumentId, Title
            FROM ContentVersion
            WHERE FirstPublishLocationId = :recordId
            ORDER BY CreatedDate DESC
        ]) {
            DocumentoDTO dto =
                new DocumentoDTO(cv.ContentDocumentId, cv.Title);

            // Regra simples e defensável
            if (cv.Title != null &&
                cv.Title.toLowerCase().contains('assinado')) {

                assinados.add(dto);
            } else {
                normais.add(dto);
            }
        }

        return new Map<String, List<DocumentoDTO>>{
            'normais'  => normais,
            'assinados'=> assinados
        };
    }

    @AuraEnabled
    public static void deletarDocumento(Id documentId) {

        if (documentId == null) {
            throw new AuraHandledException('Documento não informado');
        }

        delete [
            SELECT Id
            FROM ContentDocument
            WHERE Id = :documentId
        ];
    }

    @AuraEnabled
    public static void marcarAssinado(Id opportunityId) {

        if (opportunityId == null) {
            throw new AuraHandledException('Oportunidade não informada');
        }

        update new Opportunity(
            Id = opportunityId,
            Documentos_Anexados__c = true
        );
    }


    public class DocumentoDTO {
        @AuraEnabled public String id;
        @AuraEnabled public String title;

        public DocumentoDTO(String id, String title) {
            this.id = id;
            this.title = title;
        }
    }
}
