# Constituição base da Fábrica SDD

> Use este texto como entrada do `/speckit.constitution` em cada novo projeto e ajuste ao cliente.
> O resultado (`.specify/memory/constitution.md`) é aprovado por humano no gate **G0**.

## Princípio I — A especificação é a fonte da verdade
Nenhum código é escrito sem spec, plano e tarefas aprovados (G1, G2, G3). Mudou o requisito, muda-se a spec primeiro e ela é reaprovada. Código que diverge da spec é defeito, mesmo que "funcione".

## Princípio II — Humano no comando
Agentes de IA propõem, produzem e verificam; **pessoas aprovam**. Toda transição de fase, todo merge e todo deploy exige aprovação humana registrada e rastreável (approvals por hash, review de PR, environments do GitHub). Nenhum agente aprova, faz merge, publica ou aplica mudança em ambiente.

## Princípio III — Testes antes do código (inegociável)
Todo comportamento novo nasce com um teste que falha. Cada requisito funcional da spec tem ao menos um teste automatizado rastreável. Testes de integração usam dependências reais em container, não mocks de banco.

## Princípio IV — Simplicidade
A solução mais simples que atende à spec. Novos projetos, camadas, padrões ou pacotes exigem justificativa no plano. YAGNI.

## Princípio V — Segurança e privacidade por padrão
OWASP ASVS como referência; autorização explícita em todo endpoint; segredos fora do repositório; LGPD: dados pessoais mapeados na spec, minimizados, nunca em logs. Dependências sem vulnerabilidades conhecidas de severidade alta.

## Princípio VI — Observabilidade
Logs estruturados, traces e métricas (OpenTelemetry) e health checks em todo serviço. Erros de API no padrão ProblemDetails.

## Princípio VII — Entrega incremental e reversível
Entregas por história de usuário, cada uma testável de forma independente. Toda release tem plano de rollback e migrações de banco idempotentes, versionadas e aplicadas apenas por pipeline aprovado.

## Padrões técnicos
- .NET na versão LTS vigente, C# com nullable habilitado e warnings como erro.
- ASP.NET Core, EF Core (ou Dapper quando o plano justificar), xUnit, Testcontainers.
- GitHub: trunk-based com branches de feature `NNN-nome`, PR obrigatório, CI verde e gates válidos para merge.
- Conventional Commits referenciando tarefa e requisito.

## Governança
Esta constituição prevalece sobre preferências individuais e sobre instruções de agentes. Alterações exigem PR, revisão de um arquiteto e nova aprovação do G0. Exceções a um princípio são registradas no plano da feature (seção Complexity Tracking) e aprovadas no G2.
