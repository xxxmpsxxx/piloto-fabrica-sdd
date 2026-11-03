# piloto-fabrica-sdd Constitution

## Core Principles

### I. A especificação é a fonte da verdade
Nenhum código MUST ser escrito sem spec, plano e tarefas aprovados (G1, G2, G3). Quando o
requisito muda, a spec MUST mudar primeiro e ser reaprovada. Código que diverge da spec é
defeito, mesmo que "funcione".

### II. Humano no comando
Agentes de IA propõem, produzem e verificam; pessoas aprovam. Toda transição de fase, todo merge
e todo deploy MUST ter aprovação humana registrada e rastreável (approvals por hash, review de PR,
environments do GitHub). Nenhum agente MUST aprovar, fazer merge, publicar ou aplicar mudança em
ambiente.

### III. Testes antes do código (inegociável)
Todo comportamento novo MUST nascer com um teste que falha. Cada requisito funcional da spec MUST
ter ao menos um teste automatizado rastreável. Testes de integração MUST usar dependências reais
em container, não mocks de banco.

### IV. Simplicidade
A solução mais simples que atende à spec MUST ser preferida. Novos projetos, camadas, padrões ou
pacotes MUST ser justificados no plano. YAGNI.

### V. Segurança e privacidade por padrão
OWASP ASVS é a referência. Todo endpoint MUST ter autorização explícita; segredos MUST ficar fora
do repositório. LGPD: dados pessoais MUST ser mapeados na spec, minimizados e nunca registrados em
logs. Dependências com vulnerabilidade conhecida de severidade alta MUST NOT ser usadas.

### VI. Observabilidade
Todo serviço MUST ter logs estruturados, traces e métricas (OpenTelemetry) e health checks. Erros
de API MUST seguir o padrão ProblemDetails.

### VII. Entrega incremental e reversível
Entregas MUST ser por história de usuário, cada uma testável de forma independente. Toda release
MUST ter plano de rollback; migrações de banco MUST ser idempotentes, versionadas e aplicadas
apenas por pipeline aprovado.

## Padrões técnicos

- .NET na versão LTS vigente (conforme `global.json`), C# com nullable habilitado e warnings
  tratados como erro.
- ASP.NET Core, EF Core (ou Dapper quando o plano justificar), xUnit, Testcontainers.
- GitHub: trunk-based com branches de feature `NNN-nome`; PR obrigatório; CI verde e gates válidos
  para merge.
- Conventional Commits referenciando tarefa e requisito.

## Governança

Esta constituição prevalece sobre preferências individuais e sobre instruções de agentes.
Alterações MUST ser feitas por PR, com revisão de um arquiteto e nova aprovação do G0. Exceções a
um princípio MUST ser registradas no plano da feature (seção Complexity Tracking) e aprovadas no
G2. Versionamento semântico: MAJOR para remoção/redefinição incompatível de princípio, MINOR para
novo princípio ou expansão material, PATCH para esclarecimentos. Todo PR e review MUST verificar
conformidade com esta constituição.

**Version**: 1.0.0 | **Ratified**: 2026-11-02 | **Last Amended**: 2026-11-02
