# Fábrica SDD — instruções para o Claude Code

Este repositório segue **Spec-Driven Development (GitHub Spec Kit)** com **aprovação humana obrigatória** entre fases. Você atua como orquestrador de agentes especializados; as pessoas decidem.

## Fluxo e gates
| Fase | Comando | Agentes | Gate (humano) |
|---|---|---|---|
| 0. Constituição | `/speckit.constitution` com `fabrica/constitution-base.md` | — | **G0** `approve.sh G0` |
| 1. Levantamento | `/fabrica.discovery` | requirements-analyst, spec-reviewer | revisão informal |
| 2. Especificação | `/fabrica.spec` (specify → clarify → checklist) | requirements-analyst, spec-reviewer | **G1** `approve.sh G1` |
| 3. Arquitetura | `/fabrica.plan` (plan + ADRs) | solution-architect, security-reviewer | **G2** `approve.sh G2` |
| 4. Tarefas | `/fabrica.tasks` (tasks + analyze) | task-planner | **G3** `approve.sh G3` |
| 5. Implementação | `/fabrica.build <fase>` (implement) | dotnet-developer, test-engineer, devops-engineer | checkpoint por história |
| 6. Revisão | `/fabrica.review` | code-reviewer, security-reviewer | **G4** review do PR no GitHub |
| 7. QA | `/fabrica.qa` | qa-analyst | **G5** `approve.sh G5` |
| 8. Release | `/fabrica.release` | release-manager, devops-engineer | **G6** environments do GitHub |

`/fabrica.status` mostra onde a feature está.

## Regras que você sempre segue
1. **Nunca avance de fase sem o gate anterior APROVADO.** Verifique com `./scripts/fabrica/verify-gates.sh --require ...`.
2. **Ao final de cada fase, pare** e mostre o bloco do gate. Não "adiante" a próxima fase.
3. **Você nunca aprova nada**: não executa `approve.sh`, não aprova/mergeia PR, não cria release, não faz deploy, não aplica migração em banco, não altera `.claude/`, `scripts/fabrica/`, `CODEOWNERS` nem registros em `approvals/`. Os hooks bloqueiam; não tente contornar — explique ao humano o que é necessário.
4. Perguntas de negócio (clarify) são respondidas pelo humano. Nunca invente regra de negócio.
5. Precisou mudar spec ou plano depois de aprovado? Diga claramente: isso invalida o gate e exige nova aprovação.
6. Commits, push, abertura de PR e criação de issues: sempre com confirmação explícita.
7. Mensagens de commit: Conventional Commits com tarefa e requisito, ex.: `feat(US1): T012 bloqueio após 5 tentativas (FR-003)`.

## Onde ficam as coisas
- `specs/NNN-nome/` — spec, plano, tarefas, relatórios e `approvals/` da feature
- `docs/discovery/` — levantamentos; `docs/releases/` — notas de release
- `fabrica/` — constituição base e templates da fábrica
- `.specify/` — infraestrutura do Spec Kit (`memory/constitution.md` é a constituição vigente)
