# Feature Specification: Análise e monitoramento de pools de liquidez

**Feature Branch**: `001-pool-liquidity-analysis`

**Created**: 2026-11-02

**Status**: Draft

**Input**: User description: "Criar uma ferramenta de análise de criptomoedas, para implementarmos um bot trader utilizando IA, análise de pools de liquidez nas principais blockchains (Ethereum, Solana, Polygon). Esta feature entrega apenas a base de análise e monitoramento; não executa ordens. Fonte: discovery.md."

> **Aviso obrigatório do produto:** as informações geradas por esta ferramenta **não são recomendação de investimento**.

## Clarifications

### Session 2026-11-02

- Q: Como a pontuação classifica um sinal isolado? → A: 25 pontos por sinal; "liquidez baixa" e "queda brusca de TVL" ativos, sozinhos, forçam a faixa "alto" (nota mínima 67); "concentração" e "token recém-criado" só elevam a nota.
- Q: Base da queda de TVL? → A: TVL de exatamente 24 h atrás; sem 24 h de histórico o sinal fica "não avaliado".
- Q: Como o consumidor escolhe alertas? → A: cada webhook escolhe as condições no cadastro; novo alerta só depois que a condição deixar de valer em uma coleta e voltar; só HTTPS; mensagem assinada.
- Q: Como identificar o token? → A: pelo endereço do contrato; o símbolo é filtro auxiliar com aviso de ambiguidade.
- Q: Granularidade do histórico? → A: pontos de 1 minuto por 7 dias e agregação por hora até 90 dias.
- Q: Dados pessoais? → A: endereços de carteira não são guardados (apenas o percentual de concentração); dos consumidores, apenas nome do responsável e URL do webhook.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consultar dados atualizados de pools de liquidez (Priority: P1)

Como analista de mercado cripto (ou sistema consumidor), quero consultar em um único lugar, em formato padronizado, os dados atuais dos pools de liquidez dos protocolos suportados nas três blockchains, para comparar pools entre redes sem depender de vários agregadores.

**Why this priority**: sem a base de dados consolidada nada mais (risco, ranking, alertas, histórico) existe; é o MVP e o insumo do futuro bot.

**Independent Test**: com a coleta ativa, consultar um pool conhecido de cada combinação protocolo/blockchain e comparar os valores com a fonte pública de origem.

**Acceptance Scenarios**:

1. **Given** a coleta ativa, **When** consulto a lista de pools, **Then** recebo pools de Ethereum, Solana e Polygon dos protocolos Uniswap v2/v3, Raydium, Orca e QuickSwap, cada um identificando blockchain e protocolo.
2. **Given** um pool monitorado, **When** consulto seus detalhes, **Then** recebo os campos definidos em FR-005 e a data/hora da última atualização.
3. **Given** um pool coletado, **When** passa 1 minuto, **Then** uma nova coleta é feita e a data/hora da coleta muda.
4. **Given** uma fonte indisponível, **When** consulto um pool que depende dela, **Then** recebo os últimos dados válidos marcados como desatualizados e desde quando.
5. **Given** um protocolo que não fornece algum dado (ex.: liquidez por faixa em pool sem liquidez concentrada), **When** consulto o pool, **Then** o campo aparece como "não aplicável/indisponível", nunca como zero.
6. **Given** qualquer resposta de consulta, **When** retornada, **Then** contém o aviso "não é recomendação de investimento".
7. **Given** um pool com TVL ≤ US$ 50 mil **e** volume 24h ≤ US$ 10 mil, **When** consulto a lista, **Then** ele não é monitorado nem aparece.

---

### User Story 2 - Pontuação de risco por pool (Priority: P1)

Como analista de mercado cripto (ou sistema consumidor), quero ver uma pontuação de risco de 0 a 100 para cada pool, com os sinais que a compõem, para evitar pools com indícios de golpe ou baixa segurança.

**Why this priority**: evitar pools perigosos (ex.: *rug pull*) é o principal valor de decisão da base de dados.

**Independent Test**: observar pools com características conhecidas (TVL baixo, token recente, etc.) e verificar se pontuação, faixa e sinais correspondem às regras.

**Acceptance Scenarios**:

1. **Given** um pool monitorado, **When** consulto seus detalhes, **Then** recebo a pontuação (0 = menor risco, 100 = maior risco), a faixa (baixo 0–33, médio 34–66, alto 67–100) e o estado de cada sinal (ativo, inativo ou não avaliado).
2. **Given** um pool com TVL < US$ 100 mil e nenhum outro sinal, **When** a pontuação é calculada, **Then** "liquidez baixa" fica ativo e a faixa é "alto" (nota 67).
3. **Given** um pool cujo TVL caiu 30% ou mais em relação ao TVL de 24 h atrás e nenhum outro sinal, **When** calculada, **Then** "queda brusca de TVL" fica ativo e a faixa é "alto" (nota 67).
4. **Given** um pool em que 10 carteiras ou menos detêm mais de 50% da liquidez e nenhum outro sinal, **When** calculada, **Then** "concentração" fica ativo, soma 25 pontos e a faixa é "baixo".
5. **Given** um pool com token criado há menos de 7 dias e nenhum outro sinal, **When** calculada, **Then** "token recém-criado" fica ativo, soma 25 pontos e a faixa é "baixo".
6. **Given** os sinais "concentração" e "token recém-criado" ativos, **When** calculada, **Then** a nota é 50 e a faixa é "médio".
7. **Given** os quatro sinais ativos, **When** calculada, **Then** a nota é 100.
8. **Given** um sinal sem dado disponível (incluindo pool com menos de 24 h de histórico para a queda de TVL), **When** calculada, **Then** o sinal fica "não avaliado" (0 pontos), o pool recebe o selo "risco parcial" e a resposta lista os sinais não avaliados.

---

### User Story 3 - Filtrar e ranquear pools (Priority: P2)

Como analista (ou sistema consumidor), quero filtrar e ordenar pools por blockchain, protocolo, token, TVL, volume, APR/APY e risco, para encontrar rapidamente os mais relevantes.

**Why this priority**: torna a base utilizável em escala, mas depende das histórias P1.

**Independent Test**: com um conjunto conhecido de pools, aplicar filtros/ordenações e verificar resultado e ordem.

**Acceptance Scenarios**:

1. **Given** a lista de pools, **When** filtro por blockchain e/ou protocolo, **Then** recebo só pools dessa blockchain/protocolo.
2. **Given** a lista, **When** filtro por endereço de token, **Then** recebo só pools que contêm esse token; **When** filtro por símbolo, **Then** recebo os pools correspondentes com aviso de que o símbolo pode ser ambíguo e o endereço de cada token.
3. **Given** a lista, **When** filtro por faixas de TVL, volume 24h, APR/APY ou pontuação de risco, **Then** recebo só pools dentro das faixas.
4. **Given** a lista, **When** ordeno por TVL, volume 24h, APR/APY ou pontuação de risco (crescente ou decrescente), **Then** os pools vêm nessa ordem, com desempate pelo identificador do pool e valores indisponíveis sempre no fim.
5. **Given** filtros sem correspondência, **When** consulto, **Then** recebo lista vazia, sem erro.
6. **Given** mais resultados que o tamanho da página, **When** consulto, **Then** recebo a página pedida (padrão 50, máximo 200 itens) e a indicação de como obter a próxima.

---

### User Story 4 - Alertas por webhook (Priority: P2)

Como sistema consumidor (futuro bot trader), quero receber alertas por webhook quando um pool atingir condições relevantes, para reagir sem consultar o tempo todo.

**Why this priority**: habilita reação automática, mas depende de pontuação de risco e dados atuais.

**Independent Test**: cadastrar um webhook de teste, provocar uma condição de alerta e verificar a notificação recebida e sua assinatura.

**Acceptance Scenarios**:

1. **Given** um webhook cadastrado com a condição "risco alto", **When** um pool passa à faixa "alto", **Then** o endereço recebe notificação com pool, blockchain, protocolo, condição, valores, data/hora e o aviso de não recomendação.
2. **Given** um webhook cadastrado com a condição "queda brusca de TVL", **When** o sinal fica ativo, **Then** ele recebe o alerta e webhooks que não escolheram essa condição não recebem.
3. **Given** um alerta enviado, **When** o receptor valida a assinatura com o segredo do webhook, **Then** a mensagem é reconhecida como autêntica; uma mensagem alterada ou forjada não é.
4. **Given** um webhook que não responde, **When** o envio falha, **Then** o sistema reenvia até 5 vezes com intervalos crescentes e registra a falha.
5. **Given** a condição continuando ativa, **When** novas coletas ocorrem, **Then** não há novo alerta; ele só é reenviado se a condição deixar de valer em uma coleta e voltar a valer depois.
6. **Given** um pool que entra no monitoramento já na faixa "alto", **When** a primeira coleta é concluída, **Then** é gerado um alerta de "risco alto".
7. **Given** uma URL de webhook que não seja HTTPS ou aponte para endereço interno/privado, **When** tento cadastrá-la, **Then** o cadastro é recusado com mensagem clara.
8. **Given** um webhook cadastrado, **When** peço para listar, alterar condições ou remover, **Then** a operação vale só para os webhooks da minha chave de API.

---

### User Story 5 - Histórico de pools (Priority: P3)

Como analista (ou sistema consumidor), quero consultar o histórico de um pool nos últimos 90 dias, para analisar tendências e, no futuro, alimentar a IA do bot.

**Why this priority**: valioso para análise e IA futura, mas não bloqueia o uso imediato.

**Independent Test**: após um período de coleta, consultar o histórico num intervalo e conferir os pontos com as coletas feitas.

**Acceptance Scenarios**:

1. **Given** um pool monitorado, **When** consulto os últimos 7 dias, **Then** recebo pontos de 1 minuto; **When** consulto entre 7 e 90 dias atrás, **Then** recebo pontos agregados por hora.
2. **Given** um intervalo que inclui datas com mais de 90 dias, **When** consulto, **Then** recebo só os últimos 90 dias e a indicação de que o restante não está disponível.
3. **Given** dados com mais de 90 dias, **When** a rotina de retenção roda (ao menos uma vez por dia), **Then** deixam de estar disponíveis.
4. **Given** um período sem coleta (fonte indisponível ou pool fora do monitoramento), **When** consulto o histórico, **Then** a lacuna aparece como "sem dados", sem valores inventados.
5. **Given** um pedido com muitos pontos, **When** consulto, **Then** recebo os dados paginados; cada consulta cobre no máximo 31 dias.

---

### User Story 6 - Acompanhamento da saúde da coleta (Priority: P3)

Como operador da plataforma, quero saber se cada fonte de dados e cada protocolo estão sendo coletados no prazo, para agir quando os dados ficarem desatualizados.

**Why this priority**: apoio operacional; a plataforma já funciona sem ele.

**Independent Test**: simular a indisponibilidade de uma fonte e verificar se o estado de saúde reflete o problema.

**Acceptance Scenarios**:

1. **Given** a coleta funcionando, **When** consulto o estado da coleta (com chave de API válida), **Then** vejo, por fonte e por protocolo, a data/hora da última coleta bem-sucedida.
2. **Given** uma fonte que deixou de responder, **When** consulto o estado, **Then** vejo a fonte como indisponível/atrasada e desde quando.

---

### Edge Cases

- Fonte de dados indisponível ou lenta: usar o último dado válido, sinalizado como desatualizado (US1/US6).
- Fontes divergentes para o mesmo pool: uma fonte prioritária por dado, informada na resposta (FR-005).
- Pool que cruza o limite de monitoramento: entra ou sai na coleta seguinte; o histórico já gravado é mantido até expirar.
- Pool removido do protocolo: deixa de ser coletado; o histórico segue até expirar.
- Dado de concentração ou de criação do token indisponível: sinal "não avaliado" e selo "risco parcial" (US2).
- Tentativa de acesso sem credencial válida: acesso negado, sem revelar dados.
- Webhook lento ou inválido: falha registrada sem travar a coleta.
- Dado desatualizado: a pontuação continua visível, marcada como calculada sobre dado desatualizado, e não gera novos alertas.
- Pool com mais de 2 tokens: fora de escopo (não monitorado).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O sistema MUST coletar dados de pools de 7 combinações protocolo/blockchain: Uniswap v2 e v3 em Ethereum e em Polygon, QuickSwap em Polygon, Raydium e Orca em Solana.
- **FR-002**: O sistema MUST obter os dados de agregadores públicos de dados (DefiLlama, DexScreener, The Graph) nesta versão.
- **FR-003**: O sistema MUST monitorar somente pools de 2 tokens com TVL acima de US$ 50 mil **ou** volume 24h acima de US$ 10 mil.
- **FR-004**: O sistema MUST coletar cada pool monitorado a cada 1 minuto. Se uma fonte publicar dados menos frequentemente, vale o dado mais recente da fonte.
- **FR-005**: O sistema MUST disponibilizar, por pool: identificador (blockchain + protocolo + endereço do pool), blockchain, protocolo, tokens (símbolo e endereço), TVL (USD), volume 24h (USD), taxa cobrada por troca (%), taxas arrecadadas em 24 h (USD), APR e APY estimados (% ao ano), variação de preço do token em 24 h (%), liquidez por faixa de preço (quando aplicável), fonte usada, data/hora da coleta e data/hora do dado na fonte.
- **FR-006**: O sistema MUST apresentar APR/APY sempre como valor estimado.
- **FR-007**: O sistema MUST mostrar campos sem dado como "não aplicável/indisponível", nunca como zero.
- **FR-008**: Um dado MUST ser considerado desatualizado quando o dado da fonte tiver mais de 2 minutos de idade ou a fonte estiver sem resposta; nesse caso o sistema MUST manter o último dado válido, marcá-lo como desatualizado e informar desde quando; MUST NOT gerar novos alertas com base em dado desatualizado.
- **FR-009**: O sistema MUST calcular, para cada pool monitorado, a pontuação de risco de 0 (menor) a 100 (maior) como soma de 25 pontos por sinal ativo, com faixas baixo (0–33), médio (34–66) e alto (67–100); se "liquidez baixa" ou "queda brusca de TVL" estiver ativo, a nota MUST ser no mínimo 67.
- **FR-010**: O sinal "liquidez baixa" MUST ativar quando o TVL for menor que US$ 100 mil.
- **FR-011**: O sinal "concentração" MUST ativar quando 10 carteiras ou menos detiverem mais de 50% da liquidez do pool (carteiras provedoras de liquidez).
- **FR-012**: O sinal "token recém-criado" MUST ativar quando qualquer token do pool tiver menos de 7 dias desde a criação do seu contrato.
- **FR-013**: O sinal "queda brusca de TVL" MUST ativar quando o TVL for 30% ou mais menor que o TVL de exatamente 24 h antes; sem 24 h de histórico o sinal fica "não avaliado".
- **FR-014**: Quando o dado de um sinal não estiver disponível, o sistema MUST marcá-lo "não avaliado" (0 pontos), atribuir ao pool o selo "risco parcial" e listar os sinais não avaliados.
- **FR-015**: O sistema MUST permitir consultar lista e detalhe de pools por API, com lista paginada (padrão 50, máximo 200 itens por página).
- **FR-016**: O sistema MUST permitir filtrar por blockchain, protocolo, token (endereço do contrato; símbolo como filtro auxiliar com aviso de ambiguidade), faixa de TVL, volume 24h, APR/APY e pontuação de risco.
- **FR-017**: O sistema MUST permitir ordenar por TVL, volume 24h, APR/APY e pontuação de risco, crescente ou decrescente; a ordenação padrão é TVL decrescente; empates são desfeitos pelo identificador do pool e valores indisponíveis ficam no fim.
- **FR-018**: O sistema MUST permitir cadastrar, listar, alterar e remover webhooks; cada webhook escolhe as condições que quer receber entre "risco alto" e "queda brusca de TVL".
- **FR-019**: O cadastro de webhook MUST aceitar somente URLs HTTPS e MUST recusar endereços internos ou privados.
- **FR-020**: Cada alerta MUST conter pool, blockchain, protocolo, condição disparada, valores relevantes, data/hora e o aviso de não recomendação, e MUST ser assinado com um segredo por webhook para que o receptor verifique a autenticidade.
- **FR-021**: Em falha de envio, o sistema MUST reenviar até 5 vezes com intervalos crescentes e registrar a falha.
- **FR-022**: Uma ocorrência de alerta começa quando a condição passa a valer (inclusive na primeira coleta de um pool já em risco alto) e termina quando deixa de valer em uma coleta; o sistema MUST enviar um único alerta por ocorrência.
- **FR-023**: O sistema MUST guardar o histórico de cada pool por 90 dias: pontos de 1 minuto nos primeiros 7 dias e agregados por hora de 7 a 90 dias; MUST descartar dados mais antigos ao menos uma vez por dia.
- **FR-024**: O sistema MUST permitir consultar o histórico por intervalo de datas (máximo 31 dias por consulta), paginado, identificando lacunas como "sem dados".
- **FR-025**: O sistema MUST expor o estado da coleta por fonte e por protocolo (última coleta bem-sucedida e situação).
- **FR-026**: Todo acesso à API (inclusive estado da coleta) e à gestão de webhooks MUST exigir chave de API; o acesso é somente interno, todas as chaves têm as mesmas permissões, e cada chave só gerencia os próprios webhooks. As chaves são emitidas, revogadas e trocadas por um administrador da plataforma.
- **FR-027**: O sistema MUST registrar trilha de auditoria (quem, o quê, quando) de cadastro, alteração e remoção de webhooks e de emissão e revogação de chaves.
- **FR-028**: Todo resultado de consulta e todo alerta MUST conter o aviso "não é recomendação de investimento".
- **FR-029**: O sistema MUST ser somente leitura de dados públicos: MUST NOT executar ordens, movimentar recursos, ter custódia de ativos, nem solicitar ou armazenar chaves privadas ou frases de recuperação.
- **FR-030**: O sistema MUST NOT armazenar endereços de carteira (guardar apenas o percentual de concentração calculado); dos consumidores MUST guardar apenas nome do responsável e URL do webhook; nenhum desses dados MUST aparecer em logs.
- **FR-031**: O sistema MUST registrar logs estruturados, traces e métricas da coleta, oferecer verificação de saúde do serviço e responder a erros de API em formato padronizado.

### Dados pessoais (LGPD)

| Dado | Finalidade | Onde é guardado | Retenção |
|---|---|---|---|
| Nome do responsável pela chave de API | Identificar o consumidor e auditar | Cadastro de chaves/webhooks | Enquanto a chave existir |
| URL do webhook | Entregar alertas | Cadastro de webhooks | Até a remoção do webhook |
| Endereço de carteira | Calcular concentração | **Não é guardado**; só o percentual resultante | — |

### Key Entities

- **Pool de liquidez**: reserva de 2 tokens em um protocolo e blockchain; identificado por blockchain + protocolo + endereço do pool; atributos conforme FR-005.
- **Token**: identificado por blockchain + endereço do contrato; símbolo, data de criação (quando disponível).
- **Pontuação de risco**: nota 0–100 de um pool em um instante; faixa, estado de cada sinal e selo "risco parcial".
- **Sinal de risco**: liquidez baixa, concentração, token recém-criado, queda brusca de TVL; ativo, inativo ou não avaliado.
- **Registro histórico**: fotografia de um pool em um instante (valores e pontuação), retida por 90 dias.
- **Webhook**: URL HTTPS, condições escolhidas, segredo de assinatura, chave de API dona.
- **Alerta / ocorrência**: notificação gerada por uma condição de um pool, com tentativas e estado de entrega.
- **Fonte de dados**: agregador consultado; situação e última coleta bem-sucedida.
- **Chave de API**: credencial interna, com responsável, situação (ativa/revogada) e histórico de auditoria.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: As 7 combinações protocolo/blockchain têm pools monitorados e consultáveis.
- **SC-002**: Em operação normal (todas as fontes respondendo), 95% dos pools monitorados têm dado com no máximo 2 minutos de idade.
- **SC-003**: 100% dos pools monitorados têm pontuação de risco calculada, com o selo "risco parcial" quando houver sinal não avaliado.
- **SC-004**: Uma única consulta, filtrada por blockchain e ordenada por risco, devolve os 10 pools de menor risco.
- **SC-005**: Em operação normal, 95% dos alertas chegam ao webhook em até 60 segundos após a detecção da condição.
- **SC-006**: Nenhum dado com mais de 90 dias é retornado em consultas de histórico.
- **SC-007**: 0 chaves privadas ou frases de recuperação solicitadas ou armazenadas, 0 endereços de carteira armazenados e 0 dados pessoais em logs.
- **SC-008**: 100% dos resultados de consulta e dos alertas exibem o aviso de não recomendação de investimento.
- **SC-009**: Em operação normal, 95% das consultas de pools, filtros e ranking respondem em até 500 ms, as de histórico em até 2 s, e a API fica disponível 99,5% do mês (metas sugeridas, a confirmar no plano — Q-12).

## Assumptions

- Uso inicial exclusivamente interno; acesso externo exige nova especificação.
- Valores monetários em dólar americano (USD).
- APR/APY usa o valor estimado fornecido pelo agregador; o método é detalhado no plano (Q-06).
- Fontes divergentes: o plano define a fonte prioritária por dado; a fonte usada é informada.
- Fontes adicionais para concentração de carteiras e criação do token são definidas no plano.
- Viabilidade da coleta a cada 1 minuto depende dos limites e termos das fontes (Q-16); é risco a tratar no plano, que deve estimar o número de pools monitorados.
- Conformidade regulatória por país (Q-15) e base legal LGPD (Q-17) seguem em aberto e não bloqueiam esta especificação; devem ser tratadas antes de qualquer acesso externo.
- Restrição do cliente: a API será em ASP.NET Core (registrada para o arquiteto no plano).
- Fora de escopo: bot trader, execução de ordens, IA, custódia, interface web, nós RPC próprios, outras blockchains/protocolos, pools com mais de 2 tokens, valores em BRL, limites de alerta configuráveis pelo consumidor, acesso de terceiros, limite de requisições por consumidor, redistribuição dos dados, histórico além de 90 dias e qualquer recomendação de investimento.
