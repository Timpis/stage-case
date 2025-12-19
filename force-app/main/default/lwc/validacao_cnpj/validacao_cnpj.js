import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import validarLead from '@salesforce/apex/ValidacaoCnpjController.validarLead';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Validacao_cnpj extends LightningElement {

    recordId;

    @wire(CurrentPageReference)
    getPageRef(pageRef) {
        if (pageRef && pageRef.attributes && pageRef.attributes.recordId) {
            this.recordId = pageRef.attributes.recordId;
            console.log('RECORD ID OK =>', this.recordId);
        }
    }

    status = 'CNPJ não validado';
    statusEmoji = '❌';
    statusClass = 'status status-error';

    handleValidar() {
        console.log('CLIQUE COM RECORD ID =>', this.recordId);

        if (!this.recordId) {
            this.showToast(
                'Erro',
                'Lead não identificado na página',
                'error'
            );
            return;
        }

        validarLead({ leadId: this.recordId })
            .then(result => {
                this.status = 'Validado';
                this.statusEmoji = '✅';
                this.statusClass = 'status status-success';

                this.showToast(
                    'Sucesso',
                    result.mensagem,
                    'success'
                );
            })
            .catch(error => {
                this.showToast(
                    'Erro na validação',
                    error.body?.message || 'Erro inesperado',
                    'error'
                );
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}