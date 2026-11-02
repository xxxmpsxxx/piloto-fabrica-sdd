---
description: "Fase 4 — Quebra em tarefas (/speckit.tasks + /speckit.analyze) e pedido do gate G3"
---

# /fabrica.tasks — Tarefas (gate G3)

1. Pré-requisito: `./scripts/fabrica/verify-gates.sh --require G0 G1 G2`.
2. Delegue ao **task-planner** a execução de **/speckit.tasks** e, em seguida, **/speckit.analyze**.
3. Se o analyze apontar problema em `spec.md` ou `plan.md`, **não corrija esses arquivos**: apresente ao humano, pois corrigir invalida G1/G2 e exige nova aprovação.
4. Pergunte ao humano se deseja converter as tarefas em issues do GitHub (**/speckit.taskstoissues**). Só execute com um "sim" explícito.
5. Resumo: tarefas por história, paralelizáveis, caminho crítico, estimativa relativa.

Termine com:

> ⛔ **GATE G3 — Tarefas.** Revise `tasks.md` (é o contrato do que os agentes vão implementar).
> Para aprovar: `./scripts/fabrica/approve.sh G3 <feature>`
> Depois: `/fabrica.build US1` (uma história por vez).

**Pare aqui.**
