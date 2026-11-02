---
description: "Fase 5 — Implementação de uma fase/história do tasks.md com TDD (/speckit.implement)"
argument-hint: "<Setup | Fundacao | US1 | US2 | ... | IDs de tarefas>"
---

# /fabrica.build — Implementação

Escopo desta execução: $ARGUMENTS (se vazio, a próxima fase com tarefas pendentes).

1. Pré-requisito: `./scripts/fabrica/verify-gates.sh --require G0 G1 G2 G3`. Os hooks também bloqueiam escrita de código sem esses gates.
2. Confirme com `git status` que a árvore está limpa e que você está na branch da feature.
3. Execute o fluxo **/speckit.implement restrito ao escopo acima**:
   - tarefas de código → **dotnet-developer** (TDD, uma tarefa por vez, marcando `[X]`);
   - tarefas de testes → **test-engineer**;
   - tarefas de pipeline/Docker/IaC → **devops-engineer**;
   - tarefas marcadas `[P]` podem ser delegadas em paralelo se tocarem arquivos diferentes.
4. Ao final do escopo: `dotnet build -warnaserror`, `dotnet test`, `dotnet format --verify-no-changes`.
5. Delegue ao **test-engineer** uma passada de reforço de testes na história concluída.
6. Se alguma tarefa se mostrar errada/insuficiente, **pare** e proponha `/speckit.converge` — tarefas novas invalidam G3 e exigem reaprovação.
7. Proponha os commits (mensagem por tarefa ou agrupada por história). Commits e push só com confirmação do humano.

Termine com:

> ⏸️ **Checkpoint <escopo>.** O que foi feito, testes executados, como validar manualmente (do quickstart).
> Próximo: `/fabrica.build <próxima fase>` ou, se tudo concluído, `/fabrica.review`.

**Pare aqui.**
