public with sharing class ValidacaoCnpjService {

    // DTO
    public class Resultado {
        @AuraEnabled public Boolean valido;
        @AuraEnabled public String razaoSocial;
        @AuraEnabled public String nomeFantasia;
        @AuraEnabled public String mensagem;
    }

    public static Resultado validarCnpj(String cnpj) {

        if (String.isBlank(cnpj)) {
            throw new AuraHandledException('CNPJ não informado');
        }

        cnpj = cnpj.replaceAll('[^0-9]', '');

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://brasilapi.com.br/api/cnpj/v1/' + cnpj);
        req.setMethod('GET');
        req.setHeader('User-Agent', 'Salesforce');

        Http http = new Http();
        HttpResponse res;

        try {
            res = http.send(req);
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao conectar na BrasilAPI');
        }

        Integer status = res.getStatusCode();

        if (status == 400) {
            throw new AuraHandledException('CNPJ inválido ou mal formatado');
        }
        if (status == 404) {
            throw new AuraHandledException('CNPJ não encontrado na Receita Federal');
        }
        if (status != 200) {
            throw new AuraHandledException('Erro inesperado ao validar CNPJ');
        }

        Map<String, Object> body =
            (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        String situacao =
            (String) body.get('descricao_situacao_cadastral');

        if (situacao != 'ATIVA') {
            throw new AuraHandledException('CNPJ não está ativo na Receita Federal');
        }

        Resultado r = new Resultado();
        r.valido = true;
        r.razaoSocial = (String) body.get('razao_social');
        r.nomeFantasia = (String) body.get('nome_fantasia');
        r.mensagem = 'CNPJ válido';

        return r;
    }
}