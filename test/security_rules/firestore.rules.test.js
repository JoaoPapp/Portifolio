const assert = require('assert');
const {
    initializeTestEnvironment,
    assertSucceeds,
    assertFails,
} = require('@firebase/rules-unit-testing');
const fs = require('fs');

// Configuração do ambiente de teste
let testEnv;

before(async () => {
    // Inicializa o ambiente de teste, apontando para as nossas regras
    testEnv = await initializeTestEnvironment({
        projectId: 'flowsign-80719', // Use o ID do seu projeto real
        firestore: {
            rules: fs.readFileSync('firestore.rules', 'utf8'),
        },
    });
});

after(async () => {
    // Limpa o ambiente após os testes
    await testEnv.cleanup();
});

beforeEach(async () => {
    // Limpa os dados do emulador antes de cada teste
    await testEnv.clearFirestore();
});

describe('Regras de Segurança da Coleção "documents"', () => {
    it('Deve PERMITIR que um utilizador leia os seus próprios documentos', async () => {
        const myUserId = 'user_A';
        const myDocId = 'doc_of_user_A';

        // 1. Simula um utilizador autenticado
        const context = testEnv.authenticatedContext(myUserId);

        // 2. Cria um documento no emulador que pertence a este utilizador
        await testEnv.withSecurityRulesDisabled(async (context) => {
            await context.firestore().collection('documents').doc(myDocId).set({
                name: 'My Personal Doc',
                ownerId: myUserId, // O dono é o próprio utilizador
            });
        });

        // 3. Tenta ler o documento como este utilizador
        const readAttempt = context.firestore().collection('documents').doc(myDocId).get();

        // 4. Verificação: A leitura deve ser bem-sucedida
        await assertSucceeds(readAttempt);
    });

    it('Deve NEGAR que um utilizador leia os documentos de outros', async () => {
        const myUserId = 'user_A';
        const otherUserId = 'user_B';
        const docOfOtherUser = 'doc_of_user_B';

        // 1. Simula o "utilizador A" autenticado
        const context = testEnv.authenticatedContext(myUserId);

        // 2. Cria um documento no emulador que pertence ao "utilizador B"
        await testEnv.withSecurityRulesDisabled(async (context) => {
            await context.firestore().collection('documents').doc(docOfOtherUser).set({
                name: "Other User's Doc",
                ownerId: otherUserId, // O dono é outra pessoa
            });
        });

        // 3. Tenta ler o documento do outro utilizador
        const readAttempt = context.firestore().collection('documents').doc(docOfOtherUser).get();

        // 4. Verificação: A leitura deve falhar
        await assertFails(readAttempt);
    });
});