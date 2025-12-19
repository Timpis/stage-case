import { LightningElement, api, wire } from 'lwc';
import listarDocumentos from '@salesforce/apex/DocumentosController.listar';
import marcarAssinado from '@salesforce/apex/DocumentosController.marcarAssinado';
import deletarDocumento from '@salesforce/apex/DocumentosController.deletarDocumento';
import enviarEmail from '@salesforce/apex/EnvioEmailPropostaController.enviarEmail';
import { refreshApex } from '@salesforce/apex';

export default class Documentos_oportunidade extends LightningElement {
    @api recordId;

    documentos = [];
    documentosAssinados = [];
    wiredResult;

    emailStatus = 'E-mail não enviado';
    emailStatusClass = 'slds-text-color_error';

    columns = [
        { label: 'Nome do Arquivo', fieldName: 'title' },
        {
            type: 'button-icon',
            initialWidth: 40,
            typeAttributes: {
                iconName: 'utility:delete',
                title: 'Excluir',
                variant: 'border-filled'
            }
        }
    ];

    @wire(listarDocumentos, { recordId: '$recordId' })
    wiredDocs(result) {
        this.wiredResult = result;
        if (result.data) {
            this.documentos = result.data.normais;
            this.documentosAssinados = result.data.assinados;
        }
    }

    handleUploadFinished() {
        refreshApex(this.wiredResult);
    }

    handleUploadAssinadoFinished() {
        marcarAssinado({ opportunityId: this.recordId })
            .then(() => refreshApex(this.wiredResult));
    }

    handleRowAction(event) {
        const row = event.detail.row;
        this.handleDelete(row.id);
    }

    handleDelete(documentId) {
        deletarDocumento({ documentId })
            .then(() => refreshApex(this.wiredResult));
    }

    enviarEmail() {
        enviarEmail({ opportunityId: this.recordId })
            .then(() => {
                this.emailStatus = 'E-mail enviado com sucesso';
                this.emailStatusClass = 'slds-text-color_success';
            });
    }

    gerarNda() {}
    gerarProposta() {}
}
