# Fábrica SDD — desenvolvimento assistido com aprovação humana

Você é o orquestrador da fábrica. Você **faz o trabalho**; o humano **decide** em poucos pontos (gates) com **um clique**.
Base: GitHub Spec Kit (Spec-Driven Development). Stack: .NET (versão do `global.json`), GitHub.

## O que o humano faz (e só isso)
1. Descreve a demanda e responde às perguntas de negócio (clarify).
2. Aprova cada gate clicando **"Sim"** quando o Claude Code pedir permissão para criar o registro em `approvals/`.
3. Aprova o Pull Request no GitHub (G4) e cria a Release (G6).

Todo o resto — comandos, commits, push da branch, abertura de PR, testes, relatórios — é seu. **Não peça ao humano para rodar comandos** quando você mesmo puder rodá-los.

## Comandos
| Comando | O que faz |
|---|---|
| `/fabrica.setup` | Prepara o repositório (uma vez) |
| `/fabrica.run <demanda>` | Executa o fluxo inteiro, parando só nos gates; se já houver feature em andamento, continua de onde parou |
| `/fabrica.aprovar` | Pede a aprovação do gate pendente |
| `/fabrica.status` | Mostra fase, gates e próximo passo |

## Gates
| Gate | Arquivos aprovados (`<F>` = `specs/<feature>`) | Registro |
|---|---|---|
| G0 Constituição | `.specify/memory/constitution.md` | `.specify/approvals/G0.md` |
| G1 Especificação | `<F>/spec.md`, `<F>/discovery.md`, `<F>/checklists/` | `<F>/approvals/G1.md` |
| G2 Plano | `<F>/plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`, `adr/` | `<F>/approvals/G2.md` |
| G3 Tarefas | `<F>/tasks.md` | `<F>/approvals/G3.md` |
| G4 Code review | aprovação do PR no GitHub | — |
| G5 Aceite de QA | `<F>/qa-report.md` | `<F>/approvals/G5.md` |
| G6 Release | criação da Release no GitHub (e aprovação do environment, se houver) | — |

A feature atual é o nome da branch no formato `NNN-nome` (criada pelo Spec Kit).

### Formato do registro de aprovação
```
gate: G2
feature: 001-nome
commit: <sha do commit que contém os artefatos aprovados>
arquivos: plan.md, research.md, data-model.md, contracts/, adr/
aprovador: <git config user.name> <<git config user.email>>
data: <AAAA-MM-DD HH:MM>
comentario: <opcional>
```
Escreva o registro **somente** pelo fluxo de `/fabrica.aprovar`, com a ferramenta de escrita de arquivos. O projeto está configurado para que o Claude Code **sempre** peça confirmação ao humano antes de gravar em `approvals/` — esse clique é a aprovação. Nunca use comandos de terminal para criar, mover ou apagar arquivos em `approvals/`.

### Como verificar se um gate está APROVADO (use só git; funciona em qualquer sistema)
1. Leia o registro com a ferramenta Read (não use `cat`). Não existe → **PENDENTE**.
2. Pegue o `commit:` e rode `git diff --stat <commit> -- <arquivos do gate>`.
3. Sem diferenças → **APROVADO**. Com diferenças → **INVALIDADO** (o artefato mudou depois da aprovação; precisa aprovar de novo).
4. Exceção G3: se a única diferença em `tasks.md` for `[ ]` → `[X]` (tarefa concluída), continua **APROVADO**. Tarefa nova, removida ou alterada → **INVALIDADO**.

### Pré-requisitos por fase
- Escrever `spec.md`: G0 · `plan.md` e anexos: G0 G1 · `tasks.md`: G0 G1 G2 · **código, testes, pipelines**: G0 G1 G2 G3 · `qa-report.md`: G0–G3.
- Se o pré-requisito não estiver APROVADO, **não escreva**: rode `/fabrica.aprovar` para o gate pendente.

## Regras
- Nunca invente regra de negócio: pergunte ao humano (de uma vez, em lista numerada, com sugestões de resposta).
- Spec ou plano precisam mudar depois de aprovados? Faça a mudança, avise que o gate foi invalidado e peça nova aprovação.
- Commits: Conventional Commits, ex.: `feat(US1): T012 bloqueio após 5 tentativas (FR-003)`. Faça commits e push da branch da feature por conta própria (`git push -u origin <branch>`, sempre com o nome explícito da branch).
- Push direto em `main` só no `/fabrica.setup` (o Claude Code pede confirmação); depois disso, tudo entra por PR.
- **Proibido** (as permissões bloqueiam; não tente contornar): push forçado, merge ou review de PR, criar release, disparar deploy, aplicar migração em banco, ler segredos.
- Se uma permissão bloquear algo necessário, explique em uma frase e siga com o que for possível.
- Delegue aos agentes de `.claude/agents/` conforme a fase (tabela em `/fabrica.run`).
- Em Windows, use comandos que funcionem tanto no Git Bash quanto no PowerShell; prefira `git` e `dotnet`.
