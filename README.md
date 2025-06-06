## Índice

- [Objetivo](#objetivo)
- [Escopo](#escopo)
- [Contexto](#contexto)
- [Restrições](#restrições)
- [Trade Offs](#trade-offs)
- [Diagramas](#diagramas)
- [Requisitos de Software](#requisitos-de-software)
- [Modelagem](#modelagem)
- [Observabilidade](#observabilidade)
- [Stacks](#stacks)
- [Testes](#testes)
- [Modelo de Rede Neural Convolucional](#modelo-de-rede-neural-convolucional)
- [Instruções de uso](#instruções-de-uso)
- [Apresentação](#apresentação)

---

## Objetivo

O projeto consiste no desenvolvimento de um aplicativo móvel de workflow de documentos para assinatura digital. Nele, cada usuário cadastrado (proprietário do documento) pode fazer upload de arquivos nos formatos PDF ou DOCX, definir uma lista sequencial de signatários (com nome, CPF/CNPJ e e-mail) e iniciar um fluxo onde o sistema encaminha automaticamente o documento, por ordem, a cada pessoa para assinatura. A cada etapa, o signatário recebe um e-mail com o link de assinatura, assina eletronicamente e, então, o documento avança para o próximo; quando todos assinarem, o PDF final é armazenado e pode ser baixado pelo proprietário. Além disso, o app mantém um histórico dos “Últimos Documentos” enviados, exibindo estado (Em andamento, Concluído ou Cancelado) e detalhes de cada signatário (pendente, assinado ou ignorado). Usuários não autenticados são direcionados à tela de login, garantindo que apenas o dono acesse seus documentos e seu fluxo de assinaturas.

---

## Escopo

**1. Coleta de Dados**

- **Dados do Usuário:** Nome, e-mail, senha, e imagens carregadas pelo usuário para análise de possíveis problemas de pele. O processo de autenticação usa JWT o que garante uma alta segurança para o usuários.
- **Interações:** Salvo os registros das imagens enviadas, além de que o usuário tem 20 análises de limite por mês.
- **Armazenamento de Imagens:** As imagens enviadas são salvas no banco de dados (MongoDB) em formato **Base64** para processamento e histórico.

**2. Pré-processamento**

- O backend, implementado em **Node.js**, processa os dados recebidos e interage com o modelo de machine learning para prever possíveis condições de pele. Para realizar essas predições, utilizei um **algoritmo de CNN (Convolutional Neural Network)**.

  **Por que utilizei uma CNN?**  
  Redes Neurais Convolucionais (CNNs) são uma classe de algoritmos de aprendizado profundo projetados especificamente para tarefas relacionadas a imagens. Elas se destacam em tarefas de **reconhecimento e classificação de padrões visuais**, sendo amplamente utilizadas para identificar objetos, texturas e outros elementos em imagens.

**3. Design de Interface**

- O frontend, desenvolvido em **Flutter/Dart**, oferece uma interface responsiva e intuitiva, de fácil entendimento.

**4. Desenvolvimento**

- **Frontend:** Flutter/Dart para a criação do aplicativo móvel.
- **Backend:** Implementado em Node.js para processar solicitações, gerenciar autenticação e comunicar-se com o modelo de IA.
- **Modelo de IA:** Convolutional Neural Network (CNN), treinado em Python/TensorFlow, foi adaptado para uso em **JavaScript** após conversão.
- **Observabilidade:**: Utilização do próprio dashboard do atlas para a observabilidade do sistema, além dos sistema prometheus e grafana

**5. Escolha do DB**

A escolha do banco de dados para o sistema foi guiada pelas necessidades específicas do projeto e pelos princípios do **Teorema CAP (Consistência, Disponibilidade e Tolerância à Partição).**

**6. Arquitetura do Sistema**

### **Frontend**

No desenvolvimento do frontend, segui os **princípios do Clean Architecture**, uma abordagem que promove a separação de responsabilidades e a modularidade do sistema. O código foi estruturado em módulos distintos, garantindo organização e facilidade de manutenção. Cada módulo contém três camadas principais: Data, Domain e Presentation.

### **Backend**

Para o backend, segui a **arquitetura padrão MVC (Model-View-Controller)**, uma escolha consolidada no desenvolvimento com **Node.js**, por sua simplicidade e eficácia em organizar o fluxo de dados. Os principais componentes são: Controller, Router, Models, Services.

**7. Qualidade**

- O código passa por testes unitários para garantir sua funcionalidade.
- Testes específicos do modelo de IA garantem precisão na predição de mais de 20 condições de pele, que foi treinado em cerca de 15 épocas.

**8. CI**

- A integração contínua é realizada com GitHub Actions e armazenamento local para versões de desenvolvimento, além disso garante que nenhum novo código irá quebrar os testes aumentando a segurança do desenvolvedor sobre o app já desenvolvido.

**9. Observabilidade**

- Utilizei **Grafana** e **Prometheus** para monitorar métricas e eventos do sistema, como uso do banco de dados e desempenho das solicitações, além de utilizar o dashboard da OpenAI e o dashboard do MongoDB Atlas.

---

## Contexto

O aplicativo é voltado para o apoio a profissionais médicos e pacientes no diagnóstico inicial de condições dermatológicas. Ele não substitui o diagnóstico médico, mas oferece uma análise prévia que pode agilizar a consulta médica ou reduzir a ansiedade de pacientes.

---

## Restrições

1. **Recursos financeiros limitados:** O app ainda não foi publicado na Play Store devido a restrições orçamentárias.
2. **Processamento no backend:** Imagens de alta resolução podem consumir mais recursos computacionais.
3. **Limitação de doenças detectáveis:** O sistema é capaz de identificar apenas 20 tipos de problemas de pele:

   **Acne**, **carcinoma actínico**, **dermatite atópica**, **doenças bolhosas**, **celulite**, **eczema**, **erupções cutâneas por medicamentos**, **herpes e HPV**, **doenças relacionadas à luz**, **lúpus**, **melanoma**, **erupções de heras venenosas**, **psoríase**, **tumores benignos**, **doenças sistêmicas**, **tinha (infecção fúngica)**, **urticária**, **tumores vasculares**, **vasculite** e **infecções virais**.

4. **Qualidade da imagem:** Para garantir a precisão da análise, as fotos enviadas devem ser de boa qualidade, nítidas, bem iluminadas e com foco claro na área afetada.

---

## Trade Offs

- **Cobertura x Precisão:**

O modelo diagnostica apenas doenças presentes no dataset, sacrificando abrangência para maior precisão.

- **Simplicidade do Dataset x Generalização:**

Dados padronizados limitam a adaptação a casos reais, embora facilitem o desenvolvimento inicial.

- **Tamanho do Modelo x Eficiência Computacional:**

Modelos menores são mais rápidos, mas podem perder detalhes críticos.

- **Detecção Automática x Grau de Confiança:**

Faltam dados para diagnosticar graus avançados de algumas condições.

---

## Diagramas

**Diagrama de caso de uso:**

Representa as interações do usuário com o sistema, incluindo cadastro, login, e envio de imagens para análise.

<img width="700" src="https://github.com/user-attachments/assets/81500ad6-5dcc-4dc3-a702-cf3b0e0643ff">

**Diagrama de Container:**

Descreve a arquitetura do sistema dividida em containers, como frontend, backend e banco de dados

<img width="700" src="https://github.com/user-attachments/assets/9b253990-3b73-49d6-958b-a8c711a92fce">

**Diagrama de classe:**

O diagrama de classes mostra duas classes principais: User, que representa o usuário do sistema (contendo informações de identificação, credenciais e limite de análises mensais), e Analysis, que representa cada análise de imagem realizada (armazenando referência ao usuário, imagem analisada, classificação prevista, confiança e data). A relação entre elas indica que um usuário pode ter várias análises associadas, refletindo o fluxo de uso do sistema.

<img width="500" src="https://github.com/user-attachments/assets/2dbba672-d4f2-4e8f-8a4e-e9a3e29ecef8">

---

## Requisitos de Software

### Requisitos Funcionais:

**RF01**   Autenticação de usuários (login e logout via Firebase Auth).

**RF02**   Upload de documentos nos formatos PDF e DOCX.

**RF03**   Cadastro de signatários com nome, CPF/CNPJ, e-mail e definição de ordem de assinatura.

**RF04**   Início do fluxo de assinatura: criação de envelope no serviço externo (Autentique).

**RF05**   Envio automático de e-mail ao signatário ativo com link de assinatura.

**RF06**   Recebimento de webhook para confirmação de assinatura e avanço ao próximo signatário.

**RF07**   Exibição do status de cada signatário (pendente, assinado, ignorado) em tempo real.

**RF08**   Download do documento final assinado (PDF) após todos os signatários concluírem.

**RF09**   Histórico de “Últimos Documentos” para cada usuário (10 itens), com título, data de envio e status geral.

**RF10**   Reenvio de convite ao signatário atual e cancelamento de fluxo antes da conclusão (apenas pelo proprietário).

**RF11**   Registro de logs de auditoria para cada ação relevante (upload, envio, assinatura, download, cancelamento).

**RF12**   Perfil de usuário com informações básicas e lista de documentos enviados (acessível apenas após login).

### Requisitos Não Funcionais:

**RF01**   O aplicativo deve suportar Android 8.0+ e iOS 12+, adaptando-se a diferentes tamanhos de tela.

**RF02**   Tempo de carregamento da lista de “Últimos Documentos” inferior a 1 segundo.

**RF03**   Tempo para iniciar upload de arquivo de até 20 MB não deve exceder 3 segundos em conexão móvel.

**RF04**   Todas as comunicações (Flutter → backend e backend → API externa) devem usar HTTPS (TLS 1.2+).

**RF05**   Chaves de API e segredos devem ficar em arquivo .env (não comitados) e carregados via flutter_dotenv.

**RF06**   Backend stateless em contêiner Docker, escalável horizontalmente; banco PostgreSQL com réplica de leitura.

**RF07**   Documentos em repouso (AWS S3) devem estar criptografados e acessíveis por URLs pré-assinadas com expiração.

**RF08**   O código deve seguir práticas de “clean code” e estar coberto por testes unitários (≥ 80 %).

**RF09**   O aplicativo deve apresentar feedback visual (spinners, snackbars) em operações que demorem mais de 1 segundo.

**RF10**   Funcionalidade offline para exibir o calendário de assinaturas já baixado, sincronizando quando reconectar.

**RF11**   Monitoramento de métricas (Prometheus/Grafana) e captura de crashes via Firebase Crashlytics.

---

## Modelagem

As atividades e avaliações do projeto foram organizadas no **Trello**, seguindo o **método Kanban** para gerenciamento de tarefas.

No início, o foco foi em **estruturar a arquitetura do app**, garantindo que cada módulo tivesse suas responsabilidades bem definidas. Paralelamente, foi feito o planejamento sobre como desenvolver o modelo de IA, desde a coleta de dados até a integração ao sistema.

Uma decisão estratégica foi a **conversão do modelo de Python para Node.js**, utilizando TensorFlow.js. Essa escolha foi baseada na experiência prévia em desenvolvimento com Node.js, que facilitou a integração do modelo ao backend e otimizou o fluxo de desenvolvimento.

---

## Observabilidade

O sistema de monitoramento utiliza **Prometheus** e **Grafana** para coletar e visualizar métricas, como latência, uso de CPU e memória, enquanto o **MongoDB Atlas** fornece insights detalhados do banco de dados, incluindo desempenho de queries e uso de recursos.

Além disso, o projeto utiliza **SonarLint** no backend para garantir a qualidade do código e **Flutter Analysis Options** no frontend para padronizar e validar as melhores práticas durante o desenvolvimento mobile.

<img width="700" alt="Captura de Tela 2024-11-23 às 14 03 57" src="https://github.com/user-attachments/assets/5dd60585-ebf8-411a-85d7-6c0e68927ff6">

<img width="700" alt="Captura de Tela 2024-11-23 às 14 04 12" src="https://github.com/user-attachments/assets/5234c178-b983-4c97-af78-7f7d74047df2">

<img width="700" alt="Captura de Tela 2024-12-08 às 22 46 15" src="https://github.com/user-attachments/assets/051ea976-2bc6-40f6-bf74-56b423e6ebc1">

---

## Stacks

- **Frontend:** Flutter/Dart
- **Backend:** Node.js + Express.js
- **Banco de Dados:** PostgreSQL
- **Autenticação:** Keycloak / Gov.br / OAuth2

---

## Testes

Foi utilizado de testes unitários para a realização do aplicativo, tanto no front-end tanto no backend, além disso, estou rodando uma pipeline de integração continua em cada commit efetuado na develop, para rodar todos os testes e ver se nenhuma alteração compremeteu outro módulo do sistema

1. **Testes Unitários:**

   - **Backend:** Jest
   - **Frontend:** Flutter Test

2. **Testes do Modelo de IA:**  
   **Métricas principais monitoradas:**
   - **Acurácia:** Percentual de diagnósticos corretos.
   - **Recall:** Capacidade do modelo de identificar todas as condições relevantes.

---

## **Modelo de Rede Neural Convolucional**

Foi utilizado um dataset do kaggle para fazer a rede neural convolucional, que contém mais de 20 doenças de pele.

**Dataset**: https://www.kaggle.com/datasets/haroonalam16/20-skin-diseases-dataset

2. **Pré-Processamento e Aumento de Dados (Augmentation):**

   - As imagens são redimensionadas para 192x192 pixels e normalizadas (valores entre 0 e 1).
   - Técnicas de aumento de dados, como rotações, zoom e inversão horizontal, foram aplicadas para aumentar a variedade do conjunto de treino e evitar que o modelo sofra overfitting em um padrão específico.

3. **Codificação dos Rótulos (Labels):**
   - Os nomes das classes são convertidos em números.
   - Depois disso, usa-se uma representação "one-hot", onde cada classe é representada por um vetor com 1 na posição da classe e 0 nas demais.

### **Estrutura do Modelo**

O modelo é uma CNN projetada para classificação de imagens, composta por:

- **Camadas Convolucionais:** Responsáveis por extrair características visuais, como texturas, cores e bordas das imagens.
- **Max Pooling:** Reduz gradualmente a resolução, resumindo as informações mais relevantes e diminuindo a complexidade computacional.
- **Camadas Densas:** Integram as características extraídas pelas convoluções para realizar a classificação final.
- **Função de Ativação Softmax:** Na última camada, converte as saídas em probabilidades, associando cada imagem a uma das 20 classes.

A última camada usa a função de ativação _softmax_, produzindo uma probabilidade para cada uma das 20 classes.

## Treinamento

- **Função de Perda:** `categorical_crossentropy`, adequada para problemas de classificação com múltiplas classes.
- **Otimizador:** `Adamax` (variação do Adam), com ajustes para maior estabilidade.
- **Métrica:** `accuracy` (acurácia), indicando o percentual de acertos.
- **Número de Épocas:** 18.

No processo de treinamento, também foi usado um conjunto de validação para monitorar se o modelo estava aprendendo de forma adequada e não apenas decorando os dados de treino.

O modelo desenvolvido está disponível no repositório neste [Link](./model/modelo_derma_check_v3.ipynb).

## Resultados

<table style="border:1px solid #ccc; border-collapse: collapse; text-align: center;">
  <tr style="border:1px solid #ccc;">
    <td style="border:1px solid #ccc; padding:10px;">
     <img width="517" alt="Acuracia" src="https://github.com/user-attachments/assets/d014cc50-b646-4372-8848-f368bc67a0bd">
    </td>
  </tr>
  <tr style="border:1px solid #ccc;">
    <td style="border:1px solid #ccc; padding:10px;">
     <img width="460" alt="Captura de Tela 2024-12-08 às 22 14 58" src="https://github.com/user-attachments/assets/3d45a435-88bc-40e5-968f-484433d4307f">
    </td>
  </tr>
  <tr style="border:1px solid #ccc;">
    <td style="border:1px solid #ccc; padding:10px;">
     <img width="460" alt="Captura de Tela 2024-12-08 às 22 15 38" src="https://github.com/user-attachments/assets/4a62785a-bd5b-4c59-8fb2-a830fca1185e">
    </td>
  </tr>
 
</table>

---

## **Instruções de Uso**

## **Backend**

Para rodar o backend, siga os passos abaixo:

1. Certifique-se de ter o **Docker** e o **Docker Compose** instalados na sua máquina.

2. Crie um arquivo `.env` na raiz do projeto backend com o seguinte conteúdo:

   ```env
   NODE_ENV=development
   PORT=5001
   JWT_SECRET=_sua_chave
   OPENAI_API_KEY=_sua_chave
   MONGO_PASSWORD=_sua_chave
   MONGO_URI=_sua_chave
   ```

Certifique-se de que as portas necessárias (como 5001) estão livres na sua máquina.

No diretório do backend, execute o seguinte comando para iniciar o servidor:

```bash
docker-compose up
```

### Mobile

Para rodar o aplicativo, siga os passos abaixo:

Certifique-se de ter o Flutter instalado na sua máquina. Caso ainda não tenha, consulte a documentação oficial do Flutter.

Certifique-se de que um emulador ou dispositivo físico está configurado e disponível.

Instale as dependências do projeto principal:

```bash
flutter pub get
```

Instale as dependências do design system:

```bash
cd packages/design_system
flutter pub get
```

Retorne ao diretório raiz do projeto e inicie o aplicativo com o comando

```bash
flutter run
```
