---
description: "Fase 3 — Plano técnico e arquitetura (/speckit.plan + ADRs) e pedido do gate G2"
argument-hint: "[orientações técnicas adicionais]"
---

# /fabrica.plan — Arquitetura (gate G2)

Orientações adicionais do humano: $ARGUMENTS

1. Pré-requisito: `./scripts/fabrica/verify-gates.sh --require G0 G1`. Se falhar, pare e mostre o que falta.
2. Delegue ao **solution-architect** a execução do fluxo **/speckit.plan** para a feature atual, informando a stack padrão da fábrica (.NET LTS vigente, ASP.NET Core, EF Core, xUnit, GitHub Actions) e as orientações acima. Ele deve gerar `plan.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md` e `adr/`.
3. Delegue ao **security-reviewer** uma análise de ameaças do *plano* (não há código ainda): superfícies de ataque, dados pessoais, autenticação/autorização. Leve os achados relevantes ao arquiteto para incorporar ao plano.
4. Mostre ao humano um resumo: decisões principais (com ADR), riscos, impactos em banco/integrações, exceções à constituição.

Termine com:

> ⛔ **GATE G2 — Plano técnico.** Revise `plan.md`, `data-model.md`, `contracts/` e `adr/`.
> Para aprovar: `./scripts/fabrica/approve.sh G2 <feature>`
> Depois: `/fabrica.tasks`.

**Pare aqui.**
