public with sharing class ValidacaoCnpjController {

    @AuraEnabled
    public static ValidacaoCnpjService.Resultado validarLead(Id leadId) {

        if (leadId == null) {
            throw new AuraHandledException('Lead não informado');
        }

        Lead l = [
            SELECT Id, CNPJ__c
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];

        if (String.isBlank(l.CNPJ__c)) {
            throw new AuraHandledException('CNPJ do Lead não informado');
        }

        ValidacaoCnpjService.Resultado r =
            ValidacaoCnpjService.validarCnpj(l.CNPJ__c);

        l.Razao_Social__c = r.razaoSocial;
        l.Nome_Fantasia__c = r.nomeFantasia;
        l.Lead_Validado__c = true;

        update l;

        return r;
    }
}