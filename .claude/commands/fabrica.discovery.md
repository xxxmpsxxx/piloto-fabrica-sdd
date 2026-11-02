---
description: "Fase 1 — Levantamento de requisitos de uma nova demanda (gera docs/discovery/<slug>.md)"
argument-hint: "<descrição da demanda ou caminho de atas/documentos>"
---

# /fabrica.discovery — Levantamento de requisitos

Entrada do humano: $ARGUMENTS

1. Verifique a constituição: rode `./scripts/fabrica/verify-gates.sh`. Se G0 não estiver APROVADO, pare e oriente o humano a rodar `/speckit.constitution` com `fabrica/constitution-base.md` e aprovar G0.
2. Defina um `slug` curto (kebab-case) para a demanda e confirme com o humano.
3. Delegue ao subagente **requirements-analyst** a produção de `docs/discovery/<slug>.md` a partir das fontes informadas, usando `fabrica/templates/discovery-template.md`.
4. Delegue ao **spec-reviewer** uma leitura crítica do discovery (lacunas e perguntas).
5. Apresente ao humano, de forma curta:
   - resumo do escopo em 5 linhas;
   - as perguntas em aberto priorizadas (marque as que bloqueiam a especificação).

Não existe gate formal aqui, mas **não avance sozinho**. Termine com:

> ⏸️ Discovery pronto para revisão. Responda às perguntas em aberto (ou peça ajustes). Quando estiver de acordo, rode `/fabrica.spec <slug>`.
