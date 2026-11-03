# Discovery: Análise e monitoramento de pools de liquidez em criptomoedas

- **Cliente / área:** [PRECISA ESCLARECIMENTO] (ver pergunta Q-01)
- **Solicitante:** [PRECISA ESCLARECIMENTO] (ver pergunta Q-01)
- **Data:** 2026-11-02
- **Fontes:**
  - Demanda original: "Criar uma ferramenta de análise de criptomoedas, para implementarmos um bot trader utilizando IA, análise de pools de liquidez nas principais blockchains (Ethereum, Solana, Polygon)".
  - Decisões de negócio aprovadas pelo humano em 2026-11-02 (itens 1 a 8, todas as sugestões aceitas).
  - Constituição do projeto (`.specify/memory/constitution.md`, v1.0.0).

> **Aviso obrigatório do produto:** as informações geradas por esta ferramenta **não são recomendação de investimento**.

---

## 1. Contexto e problema

O cliente pretende, no futuro, operar um **bot trader apoiado por inteligência artificial** em criptomoedas. Para que esse bot (e qualquer análise humana) tome decisões, é preciso antes ter uma **base confiável, atualizada e histórica de dados sobre pools de liquidez** nas principais blockchains — Ethereum, Solana e Polygon — e **sinais de risco** que ajudem a evitar pools perigosos (por exemplo, golpes do tipo *rug pull*).

Hoje esses dados estão espalhados em vários agregadores públicos, em formatos diferentes, sem histórico consolidado e sem uma pontuação de risco única. Isso impede comparar pools entre redes, ranqueá-los e ser avisado rapidamente quando algo relevante acontece.

**Esta feature entrega apenas a base de análise e monitoramento**: coleta, consolidação, histórico, ranking, pontuação de risco e alertas. **Não executa ordens**, não tem custódia de recursos e não usa IA. O bot trader e a IA serão features futuras que consumirão os dados e sinais produzidos aqui.

## 2. Objetivos e métricas de sucesso

| Objetivo | Métrica | Meta |
|---|---|---|
| Cobrir os protocolos acordados | Protocolos com coleta ativa entre: Uniswap v2/v3 (Ethereum e Polygon), Raydium e Orca (Solana), QuickSwap (Polygon) | 100% dos protocolos listados |
| Manter dados atualizados | Intervalo entre coletas de cada pool monitorado | 1 minuto (decisão 5) |
| Manter histórico para análise e para o futuro bot | Período de histórico consultável por pool | 90 dias (decisão 5) |
| Identificar pools de risco | Pools monitorados com pontuação de risco (0–100) calculada | 100% dos pools monitorados |
| Avisar rapidamente sobre eventos relevantes | Tempo entre a detecção de uma condição de alerta e o envio do webhook | [PRECISA ESCLARECIMENTO] — sugestão: até 1 minuto (Q-12) |
| Permitir consumo por sistemas | Consultas de pools, filtros e ranking disponíveis via API | Todas as histórias P1 e P2 acessíveis via API |
| Medida de sucesso de negócio | Indicador que o cliente usará para considerar a ferramenta bem-sucedida | [PRECISA ESCLARECIMENTO] (Q-02) |

## 3. Stakeholders e perfis de usuário

**Stakeholders**
| Stakeholder | Interesse |
|---|---|
| Cliente / patrocinador (a confirmar — Q-01) | Base de dados e sinais para viabilizar o futuro bot trader com IA |
| Product Owner | Priorização das histórias e aceite das entregas |
| Time das features futuras (bot trader e IA) | Consumir dados, histórico e sinais de forma estável |
| Jurídico / conformidade (a confirmar — Q-15) | Aviso de "não é recomendação de investimento", LGPD e regulação por país |

**Personas**
| Persona | Descrição | O que precisa |
|---|---|---|
| **Analista de mercado cripto** | Pessoa que estuda pools para identificar oportunidades e riscos | Consultar pools, filtrar, ranquear, ver histórico e risco |
| **Sistema consumidor (futuro bot trader / IA)** | Sistema automatizado que consumirá os dados | Dados padronizados entre redes, histórico, pontuação de risco e alertas por webhook |
| **Operador da plataforma** | Pessoa que acompanha se a coleta está funcionando | Saber se as fontes estão respondendo e se os dados estão atualizados |

> Quem pode acessar a API (só uso interno ou também terceiros/clientes externos) está em aberto (Q-03).

## 4. Histórias de usuário priorizadas

### P1 — Consultar dados atualizados de pools de liquidez

Como **analista de mercado cripto (ou sistema consumidor)**, quero **consultar, em um único lugar e em formato padronizado, os dados atuais dos pools de liquidez dos protocolos suportados nas três blockchains**, para **comparar pools entre redes sem depender de vários agregadores**.

Dados por pool (decisão 2): TVL, volume 24h, taxas, APR/APY estimado, composição dos tokens, variação de preço e liquidez por faixa.

**Teste independente:** com a coleta ativa, consultar um pool conhecido de cada protocolo e comparar os valores com a fonte pública de origem.

**Critérios de aceite**
- **Dado** que a coleta está ativa para os protocolos suportados, **quando** consulto a lista de pools, **então** recebo pools de Ethereum, Solana e Polygon dos protocolos Uniswap v2/v3, Raydium, Orca e QuickSwap, cada um identificando blockchain e protocolo.
- **Dado** um pool monitorado, **quando** consulto seus detalhes, **então** recebo TVL, volume 24h, taxas, APR/APY estimado, composição dos tokens, variação de preço e liquidez por faixa, além da data/hora da última atualização.
- **Dado** que um pool foi coletado, **quando** se passa 1 minuto, **então** uma nova coleta para esse pool é realizada e a data/hora da última atualização muda.
- **Dado** que uma fonte de dados está indisponível, **quando** consulto um pool que depende dela, **então** recebo os últimos dados válidos indicando claramente que estão desatualizados e desde quando (forma de sinalização a confirmar — Q-10).
- **Dado** um protocolo que não fornece algum dos dados (ex.: liquidez por faixa só existe em pools de liquidez concentrada), **quando** consulto o pool, **então** o campo aparece como "não aplicável/indisponível", nunca como zero.
- **Dado** qualquer resposta de consulta, **quando** ela é retornada, **então** contém o aviso "não é recomendação de investimento".

### P1 — Pontuação de risco por pool

Como **analista de mercado cripto (ou sistema consumidor)**, quero **ver uma pontuação de risco de 0 a 100 para cada pool, com os sinais que a compõem**, para **evitar pools com indícios de golpe ou de baixa segurança**.

Sinais de risco (decisão 7): liquidez baixa, concentração da liquidez/tokens em poucas carteiras, token recém-criado e queda brusca de TVL (indício de *rug pull*).

**Teste independente:** cadastrar/observar pools com características conhecidas (ex.: TVL baixo, token criado recentemente) e verificar se a pontuação e os sinais exibidos correspondem às regras.

**Critérios de aceite**
- **Dado** um pool monitorado, **quando** consulto seus detalhes, **então** recebo a pontuação de risco entre 0 e 100 e a lista de sinais de risco ativos.
- **Dado** um pool com liquidez abaixo do limite definido (Q-05), **quando** a pontuação é calculada, **então** o sinal "liquidez baixa" aparece ativo e o pool é classificado como risco alto.
- **Dado** um pool cuja liquidez/tokens está concentrada em poucas carteiras acima do limite definido (Q-05), **quando** a pontuação é calculada, **então** o sinal "concentração em poucas carteiras" aparece ativo e o pool é classificado como risco alto.
- **Dado** um pool com token criado há menos do que o prazo definido (Q-05), **quando** a pontuação é calculada, **então** o sinal "token recém-criado" aparece ativo e o pool é classificado como risco alto.
- **Dado** um pool cujo TVL caiu mais do que o percentual definido dentro da janela definida (Q-05), **quando** a pontuação é calculada, **então** o sinal "queda brusca de TVL (possível rug pull)" aparece ativo e o pool é classificado como risco alto.
- **Dado** que um dado necessário a um sinal não está disponível, **quando** a pontuação é calculada, **então** o sistema informa qual sinal não pôde ser avaliado (tratamento na pontuação a confirmar — Q-07).

### P2 — Filtrar e ranquear pools

Como **analista de mercado cripto (ou sistema consumidor)**, quero **filtrar e ordenar pools por blockchain, protocolo, token, TVL, volume, APR/APY e risco**, para **encontrar rapidamente os pools mais relevantes para minha análise**.

**Teste independente:** com um conjunto conhecido de pools, aplicar filtros e ordenações e verificar se o resultado contém somente os pools esperados na ordem esperada.

**Critérios de aceite**
- **Dado** a lista de pools monitorados, **quando** filtro por blockchain e/ou protocolo, **então** recebo somente pools daquela blockchain/protocolo.
- **Dado** a lista de pools monitorados, **quando** filtro por um token, **então** recebo somente pools que contêm aquele token.
- **Dado** a lista de pools monitorados, **quando** filtro por faixas de TVL, volume 24h, APR/APY ou pontuação de risco, **então** recebo somente pools dentro das faixas informadas.
- **Dado** a lista de pools monitorados, **quando** peço o ranking por um critério, **então** recebo os pools ordenados por esse critério (critérios e ranking padrão a confirmar — Q-08).
- **Dado** que nenhum pool atende aos filtros, **quando** consulto, **então** recebo uma lista vazia, sem erro.

### P2 — Alertas por webhook

Como **sistema consumidor (futuro bot trader)**, quero **receber alertas por webhook quando um pool atingir condições relevantes**, para **reagir sem precisar consultar a API o tempo todo**.

**Teste independente:** cadastrar um webhook de teste, provocar/observar uma condição de alerta e verificar o recebimento da notificação com os dados do pool.

**Critérios de aceite**
- **Dado** que cadastrei um endereço de webhook e as condições de interesse, **quando** um pool atinge uma dessas condições, **então** recebo uma notificação no endereço cadastrado contendo pool, blockchain, protocolo, condição disparada, valores relevantes, data/hora e o aviso "não é recomendação de investimento".
- **Dado** um pool que passa a ter pontuação de risco alto ou sinal de queda brusca de TVL, **quando** a condição é detectada, **então** o alerta é enviado aos webhooks interessados nessa condição (condições disponíveis a confirmar — Q-11).
- **Dado** que o endereço do webhook não responde, **quando** o envio falha, **então** o sistema tenta reenviar conforme a política definida (Q-13) e registra a falha.
- **Dado** que a mesma condição continua ativa para o mesmo pool, **quando** novas coletas acontecem, **então** o sistema não envia alertas repetidos além do definido (Q-13).

### P3 — Histórico de pools

Como **analista de mercado cripto (ou sistema consumidor)**, quero **consultar o histórico dos dados de um pool nos últimos 90 dias**, para **analisar tendências e, no futuro, treinar/alimentar a IA do bot trader**.

**Teste independente:** após um período de coleta, consultar o histórico de um pool em um intervalo de datas e verificar se os pontos retornados correspondem às coletas realizadas.

**Critérios de aceite**
- **Dado** um pool monitorado, **quando** consulto o histórico em um intervalo de datas dentro dos últimos 90 dias, **então** recebo a série de valores (TVL, volume, taxas, APR/APY, preço, composição, liquidez por faixa e pontuação de risco) com data/hora de cada ponto.
- **Dado** um intervalo que inclui datas com mais de 90 dias, **quando** consulto o histórico, **então** recebo apenas os dados dentro dos 90 dias e uma indicação de que o restante não está disponível.
- **Dado** dados com mais de 90 dias, **quando** a rotina de retenção é executada, **então** esses dados deixam de estar disponíveis.
- **Dado** um período em que a fonte de dados esteve indisponível, **quando** consulto o histórico, **então** a lacuna aparece identificada como "sem dados", e não preenchida com valores inventados.
- **Dado** um pedido de histórico com muitos pontos, **quando** consulto, **então** recebo os dados de forma paginada ou agregada (granularidade a confirmar — Q-09).

### P3 — Acompanhamento da saúde da coleta

Como **operador da plataforma**, quero **saber se cada fonte de dados e cada protocolo estão sendo coletados no prazo**, para **agir rapidamente quando os dados ficarem desatualizados**.

**Teste independente:** simular a indisponibilidade de uma fonte e verificar se o estado de saúde reflete o problema.

**Critérios de aceite**
- **Dado** que a coleta está funcionando, **quando** consulto o estado da coleta, **então** vejo, por fonte e por protocolo, a data/hora da última coleta bem-sucedida.
- **Dado** que uma fonte deixou de responder, **quando** consulto o estado da coleta, **então** vejo a fonte como indisponível/atrasada e desde quando.

## 5. Regras de negócio

- **RN-001:** O sistema é **somente leitura de dados públicos**. Não executa ordens, não negocia, não movimenta recursos. (decisões 1 e 8)
- **RN-002:** O sistema **não tem custódia** de ativos e **não armazena nem solicita chaves privadas** ou frases de recuperação. (decisão 8)
- **RN-003:** Toda informação exibida/entregue (respostas da API e alertas) deve conter o aviso **"não é recomendação de investimento"**. (decisão 8)
- **RN-004:** Blockchains suportadas nesta feature: **Ethereum, Solana e Polygon**. (demanda e decisão 3)
- **RN-005:** Protocolos suportados: **Uniswap v2 e v3 (Ethereum e Polygon), Raydium e Orca (Solana), QuickSwap (Polygon)**. (decisão 3)
- **RN-006:** Dados obrigatórios por pool: **TVL, volume 24h, taxas, APR/APY estimado, composição dos tokens, variação de preço, liquidez por faixa e histórico**. (decisão 2)
- **RN-007:** O APR/APY é sempre apresentado como **estimado**. (decisão 2) — método de cálculo a confirmar (Q-06).
- **RN-008:** Na v1, os dados vêm de **APIs públicas de agregadores (DefiLlama, DexScreener, The Graph)**; nós RPC próprios ficam para versão futura. (decisão 4)
- **RN-009:** Cada pool monitorado é coletado a **cada 1 minuto**. (decisão 5)
- **RN-010:** O histórico é retido por **90 dias**; dados mais antigos são descartados. (decisão 5)
- **RN-011:** Cada pool tem uma **pontuação de risco de 0 a 100**. (decisão 7) — se 0 é menor ou maior risco e faixas (baixo/médio/alto) a confirmar (Q-04).
- **RN-012:** São sinais de **risco alto**: liquidez baixa; concentração em poucas carteiras; token recém-criado; queda brusca de TVL (indício de *rug pull*). (decisão 7) — limites numéricos a confirmar (Q-05).
- **RN-013:** O consumo é feito por **API com filtros e ranking** e por **alertas via webhook**; **não há interface web** nesta feature. (decisão 6)
- **RN-014:** O bot trader e a IA **não fazem parte** desta feature; ela entrega a base de dados e sinais que eles consumirão. (decisão 1)

## 6. Requisitos não funcionais

> Valores marcados com [PRECISA ESCLARECIMENTO] são **sugestões** do analista para validação; não estão aprovados.

| Categoria | Requisito | Valor mensurável |
|---|---|---|
| Desempenho | Frequência de coleta por pool | A cada 1 minuto (RN-009) |
| Desempenho | Atraso máximo aceitável do dado ("frescor") em condições normais | [PRECISA ESCLARECIMENTO] — sugestão: dado com no máximo 2 minutos de idade (Q-12) |
| Desempenho | Tempo de resposta de consultas de pools, filtros e ranking | [PRECISA ESCLARECIMENTO] — sugestão: p95 ≤ 500 ms (Q-12) |
| Desempenho | Tempo de resposta de consulta de histórico (até 90 dias de um pool) | [PRECISA ESCLARECIMENTO] — sugestão: p95 ≤ 2 s (Q-12) |
| Desempenho | Tempo entre detecção da condição e envio do webhook | [PRECISA ESCLARECIMENTO] — sugestão: ≤ 60 s (Q-12) |
| Capacidade | Quantidade de pools monitorados simultaneamente | [PRECISA ESCLARECIMENTO] — todos os pools dos protocolos ou apenas os acima de um TVL mínimo? (Q-14) |
| Capacidade | Respeito aos limites de uso das APIs públicas | 0 bloqueios por excesso de requisições nas fontes em operação normal; limites e eventuais custos de planos a confirmar (Q-16) |
| Retenção | Período de histórico | 90 dias (RN-010) |
| Segurança | Sistema somente leitura, sem custódia e sem chaves privadas | 0 chaves privadas/frases de recuperação armazenadas ou solicitadas (RN-001, RN-002) |
| Segurança | Acesso à API e cadastro de webhooks | Todo acesso com autorização explícita (constituição, princípio V); quem acessa e como a confirmar (Q-03) |
| Segurança | Autenticidade dos alertas | O receptor deve conseguir verificar que o webhook veio da plataforma — [PRECISA ESCLARECIMENTO] (Q-13) |
| Segurança | Vulnerabilidades | 0 dependências com vulnerabilidade conhecida de severidade alta (constituição) |
| LGPD / dados pessoais | Endereços de carteiras (usados no sinal de concentração) são dados públicos pseudônimos que podem ser considerados dado pessoal se vinculáveis a pessoas | Mapeados na spec, minimizados e nunca registrados em logs; base legal provável: **legítimo interesse** — [PRECISA ESCLARECIMENTO] (Q-17) |
| LGPD / dados pessoais | Dados dos consumidores da API (nome/e-mail de contato, URL de webhook, credenciais de acesso) | Mapeados, minimizados, fora dos logs; base legal provável: **execução de contrato** — [PRECISA ESCLARECIMENTO] (Q-17) |
| Disponibilidade | Disponibilidade da API de consulta | [PRECISA ESCLARECIMENTO] — sugestão: 99,5% ao mês (Q-12) |
| Disponibilidade | Comportamento com fonte indisponível | Continua respondendo com o último dado válido, sinalizado como desatualizado (P1) |
| Observabilidade | Saúde da coleta por fonte/protocolo | Data/hora da última coleta bem-sucedida visível por fonte e protocolo (P3); logs, traces, métricas e health checks (constituição, princípio VI) |
| Acessibilidade | Não há interface web nesta feature | Não aplicável nesta entrega; mensagens de erro da API em formato padronizado e legível (constituição, princípio VI) |

## 7. Integrações e dependências externas

| Integração | Uso | Observação |
|---|---|---|
| DefiLlama (API pública) | Dados de TVL, volume, rendimento de pools | Termos de uso, limites e licença de dados a confirmar (Q-16) |
| DexScreener (API pública) | Dados de pares/pools, preço, volume, liquidez | Termos de uso, limites e licença de dados a confirmar (Q-16) |
| The Graph (subgraphs públicos) | Dados detalhados dos protocolos (ex.: liquidez por faixa no Uniswap v3) | Pode exigir chave e cobrança por consulta — a confirmar (Q-16) |
| Endpoints de webhook dos consumidores | Envio de alertas | Cadastrados pelos consumidores (P2) |
| Futuro bot trader / IA | Consumidor dos dados e sinais | Fora de escopo; contrato de consumo deve ser estável |
| Restrição informada pelo cliente | A API REST será em ASP.NET Core (decisão 6) | Registrada como restrição para o arquiteto de solução; demais decisões técnicas não fazem parte deste discovery |

**Dependência de dados para sinais de risco:** a concentração em poucas carteiras e a data de criação do token podem não estar disponíveis nos agregadores escolhidos para a v1 — viabilidade a confirmar (Q-07).

## 8. Fora de escopo

- Bot trader e execução de ordens de compra/venda (feature futura).
- Inteligência artificial / modelos preditivos (feature futura).
- Custódia de ativos, carteiras, chaves privadas ou qualquer movimentação de recursos.
- Interface web, painéis ou aplicativo móvel.
- Nós RPC próprios e leitura direta das blockchains (versão futura).
- Blockchains além de Ethereum, Solana e Polygon.
- Protocolos além de Uniswap v2/v3, Raydium, Orca e QuickSwap.
- Histórico além de 90 dias.
- Recomendação de investimento de qualquer tipo.
- Adequação regulatória específica por país (ex.: Banco Central / CVM no Brasil) — tratada como pergunta em aberto não bloqueante (Q-15).

## 9. Glossário

| Termo | Definição |
|---|---|
| **Blockchain** | Rede pública e distribuída onde as transações são registradas (aqui: Ethereum, Solana, Polygon). |
| **DEX** | Corretora descentralizada; negociação feita diretamente por contratos na blockchain. |
| **Protocolo** | Sistema DEX específico (Uniswap, Raydium, Orca, QuickSwap). |
| **Pool de liquidez** | Reserva de dois (ou mais) tokens depositados por provedores, usada para trocas na DEX. |
| **Provedor de liquidez (LP)** | Quem deposita tokens no pool e recebe parte das taxas. |
| **TVL (Total Value Locked)** | Valor total, em moeda de referência, dos tokens depositados no pool. |
| **Volume 24h** | Valor total negociado no pool nas últimas 24 horas. |
| **Taxas** | Percentual cobrado por troca e/ou valor total de taxas geradas pelo pool. |
| **APR** | Rendimento anual estimado, sem considerar reinvestimento. |
| **APY** | Rendimento anual estimado, considerando reinvestimento (juros compostos). |
| **Composição dos tokens** | Quais tokens formam o pool e a proporção de cada um. |
| **Liquidez por faixa** | Distribuição da liquidez em faixas de preço (relevante em pools de liquidez concentrada, como Uniswap v3 e Orca). |
| **Liquidez concentrada** | Modelo em que o provedor escolhe a faixa de preço em que sua liquidez atua. |
| **Rug pull** | Golpe em que criadores/maiores detentores retiram a liquidez de forma repentina, derrubando o valor do token. |
| **Pontuação de risco** | Nota de 0 a 100 atribuída a cada pool com base nos sinais de risco. |
| **Sinal de risco** | Condição observada que indica perigo (liquidez baixa, concentração, token recém-criado, queda brusca de TVL). |
| **Agregador** | Serviço que consolida dados de várias DEX/blockchains (DefiLlama, DexScreener, The Graph). |
| **Nó RPC** | Servidor que permite ler dados diretamente da blockchain (fora de escopo na v1). |
| **Webhook** | Notificação enviada automaticamente pela plataforma para um endereço cadastrado pelo consumidor. |
| **Custódia** | Guarda de ativos ou chaves de terceiros (não praticada por este sistema). |

## 10. Perguntas em aberto

| # | Pergunta | Para quem | Impacto se não respondida | Bloqueia spec? |
|---|---|---|---|---|
| Q-01 | Quem é o cliente/área patrocinadora e o solicitante formal? | Patrocinador | Sem dono para aceitar entregas e priorizar | Não |
| Q-02 | Qual indicador de negócio define o sucesso da ferramenta (ex.: nº de pools cobertos, % de rug pulls detectados antes da queda, uso pelo bot)? | Patrocinador / PO | Não há como avaliar se a entrega gerou valor | Não |
| Q-03 | Quem acessa a API e os webhooks: só uso interno (time e futuro bot) ou também clientes/terceiros? Haverá cadastro de usuários e planos de acesso? | Patrocinador / PO | Muda autenticação, limites de uso, dados pessoais tratados e escopo de P2 | **Sim** |
| Q-04 | Na pontuação 0–100, 0 é menor ou maior risco? Quais as faixas de "baixo", "médio" e "alto"? Qual o peso de cada sinal? | PO / especialista de mercado | Pontuação não pode ser especificada nem testada | **Sim** |
| Q-05 | Quais os limites de cada sinal de risco: (a) liquidez baixa = TVL abaixo de quanto? (b) concentração = quantas carteiras detendo qual % ? (c) token recém-criado = menos de quantos dias/horas? (d) queda brusca de TVL = queda de quantos % em qual janela de tempo? | PO / especialista de mercado | Sinais de risco e critérios de aceite não são testáveis | **Sim** |
| Q-06 | Como o APR/APY estimado deve ser calculado (com base em taxas de 24h, 7 dias, inclui recompensas de incentivo)? Usar o valor do agregador é aceitável? | PO / especialista de mercado | Valores divergentes entre fontes e entre redes; perda de confiança no dado | Não |
| Q-07 | Se um sinal não puder ser avaliado (ex.: dado de concentração de carteiras ou data de criação do token indisponível nos agregadores), como tratar na pontuação: ignorar, considerar risco alto ou marcar "risco indeterminado"? É aceitável que esses sinais dependam de fonte adicional? | PO | Pontuação inconsistente; possível inviabilidade de 2 dos 4 sinais na v1 | **Sim** |
| Q-08 | Quais critérios de ranking são necessários e qual o ranking padrão (ex.: maior TVL, maior APR/APY, menor risco, combinação)? | PO | Ranking da P2 indefinido | Não (bloqueia P2) |
| Q-09 | Qual a granularidade do histórico: manter todos os pontos de 1 minuto pelos 90 dias ou agregar (ex.: por hora) após algum prazo? | PO / time da IA futura | Volume de dados e utilidade do histórico para a IA | Não (bloqueia P3) |
| Q-10 | A partir de quanto tempo sem atualização um dado deve ser considerado "desatualizado" e como isso deve ser sinalizado? | PO | Consumidores (e o futuro bot) podem agir sobre dados velhos | Não |
| Q-11 | Quais condições podem disparar alertas por webhook (ex.: mudança de faixa de risco, queda de TVL, variação de preço acima de X%, APR acima de X%)? O consumidor configura os limites? | PO / time do bot futuro | Alertas da P2 indefinidos | Não (bloqueia P2) |
| Q-12 | Confirmar ou ajustar as metas de desempenho e disponibilidade sugeridas (frescor ≤ 2 min, consulta p95 ≤ 500 ms, histórico p95 ≤ 2 s, webhook ≤ 60 s, disponibilidade 99,5%/mês). | PO / patrocinador | Requisitos não funcionais sem meta aprovada | Não |
| Q-13 | Política de webhooks: quantas tentativas de reenvio e em que intervalo, como evitar alertas repetidos, e se o receptor precisa validar a autenticidade da mensagem. | PO / time do bot futuro | Alertas perdidos ou duplicados; risco de mensagens falsificadas | Não |
| Q-14 | Quais pools monitorar: todos os pools dos protocolos listados ou apenas os que passam de um TVL/volume mínimo, ou uma lista escolhida? | PO | Define volume de coleta, custos e viabilidade da coleta a cada 1 minuto | **Sim** |
| Q-15 | Há exigências regulatórias por país a observar (ex.: Brasil — Banco Central/CVM) para disponibilizar análises de criptoativos, principalmente se houver acesso de terceiros? O texto do aviso "não é recomendação de investimento" deve seguir redação jurídica específica? | Jurídico / conformidade | Risco regulatório e reputacional | Não |
| Q-16 | Os termos de uso e limites das APIs públicas (DefiLlama, DexScreener, The Graph) permitem coleta a cada 1 minuto e uso comercial/redistribuição dos dados? Há orçamento para planos pagos ou chaves (ex.: The Graph)? | Patrocinador / jurídico | Bloqueio pelas fontes, descumprimento de termos ou custo não previsto | Não |
| Q-17 | LGPD: confirmar se endereços de carteira serão tratados como dado pessoal e qual a base legal (sugestão: legítimo interesse); confirmar dados dos consumidores da API (contato, URL de webhook) e base legal (sugestão: execução de contrato). Quem é o encarregado (DPO)? | Jurídico / DPO | Não conformidade com LGPD; mapeamento de dados pessoais incompleto na spec | Não |
| Q-18 | Em qual moeda de referência os valores (TVL, volume, taxas) devem ser expressos: dólar (USD), real (BRL) ou ambos? | PO | Inconsistência de valores e comparações | Não |

## 11. Decisões complementares do humano (respostas às perguntas bloqueantes)
- **Q-03 (resolvida):** acesso somente interno (time e futuro bot), autenticação por chave de API; sem cadastro de usuários nem planos.
- **Q-04 (resolvida):** 0 = menor risco, 100 = maior risco. Faixas: 0–33 baixo, 34–66 médio, 67–100 alto. Quatro sinais com peso igual (25 pontos cada).
- **Q-05 (resolvida):** liquidez baixa = TVL < US$ 100 mil; concentração = 10 carteiras ou menos detêm > 50% da liquidez; token recém-criado = < 7 dias; queda brusca de TVL = queda ≥ 30% em 24 h.
- **Q-07 (resolvida):** sinal sem dado disponível fica "não avaliado" (não soma pontos); o pool recebe o selo "risco parcial" listando os sinais não avaliados. Fonte adicional para concentração e criação do token será definida no plano.
- **Q-14 (resolvida):** monitorar pools com TVL > US$ 50 mil OU volume 24h > US$ 10 mil, nas 3 redes e nos protocolos listados.

## 12. Decisões da etapa de clarificação (2026-11-02, aceitas pelo humano)
- **Pontuação:** 25 pontos por sinal; "liquidez baixa" e "queda brusca de TVL" ativos, **sozinhos**, forçam a faixa "alto" (nota mínima 67). "Concentração" e "token recém-criado" só elevam a nota. Esta decisão **substitui** a leitura do RN-012 de que qualquer sinal é risco alto.
- **Queda de TVL:** comparada ao TVL de exatamente 24 h atrás; sem 24 h de histórico o sinal fica "não avaliado".
- **Webhooks:** cada webhook escolhe as condições (risco alto, queda brusca de TVL); novo alerta só após a condição deixar de valer em uma coleta e voltar; só HTTPS; mensagem assinada.
- **Token:** identificado pelo endereço do contrato; símbolo é filtro auxiliar com aviso de ambiguidade.
- **Histórico:** pontos de 1 minuto por 7 dias, agregação por hora até 90 dias.
- **Dados pessoais:** endereços de carteira NÃO são guardados (só o percentual de concentração); dos consumidores, apenas nome do responsável e URL do webhook.
