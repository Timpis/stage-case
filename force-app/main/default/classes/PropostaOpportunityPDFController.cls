public with sharing class PropostaOpportunityPDFController {

    public Opportunity opp { get; set; }

    public PropostaOpportunityPDFController() {

        Id oppId = ApexPages.currentPage().getParameters().get('id');

        if (oppId == null) {
            return;
        }

        opp = [
            SELECT
                Id,
                Name,
                Account.Name,
                Tecnologia_do_Projeto__c,
                Tempo_Estimado__c,
                Data_Inicio__c,
                Data_Fim__c,
                Custo_Estimado__c,
                Valor_da_proposta__c
            FROM Opportunity
            WHERE Id = :oppId
        ];
    }
}
