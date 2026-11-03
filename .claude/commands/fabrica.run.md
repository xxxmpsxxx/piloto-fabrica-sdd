---
description: "Executa o fluxo SDD completo de uma demanda, parando só nos gates humanos; retoma de onde parou"
argument-hint: "<descrição da demanda> (vazio = continuar a feature atual)"
---

# /fabrica.run — desenvolvimento assistido de ponta a ponta

Demanda: $ARGUMENTS

Você conduz tudo. O humano só responde perguntas de negócio e clica em "Sim" nas aprovações.
Avance sozinho de uma fase para a seguinte assim que o gate dela for aprovado. Entre as fases, informe o progresso em **uma linha** (ex.: "✅ G2 aprovado — gerando tarefas…").

## 0. Onde estamos
- Rode as verificações do `/fabrica.status` (sem mostrar o relatório completo).
- G0 não aprovado → diga "Rode /fabrica.setup primeiro" e pare.
- Branch `NNN-nome` com trabalho em andamento → **continue na primeira fase não concluída** abaixo (ignore a demanda, a menos que seja outra feature; nesse caso pergunte).
- Na `main` sem feature → comece pela fase 1 com a demanda. Sem demanda → pergunte qual é.

## 1. Levantamento → Especificação (gate G1)
1. **requirements-analyst**: monte o discovery a partir da demanda (template `fabrica/templates/discovery-template.md`).
2. Faça ao humano, **de uma vez**, as perguntas de negócio que bloqueiam a spec (no máximo 8, numeradas, cada uma com sugestão de resposta: "responda só os números que quiser mudar; o resto eu sigo com a sugestão"). Aguarde a resposta.
3. Rode o **/speckit.specify** com o conteúdo do discovery (comando ou skill do Spec Kit instalado em `.claude/`). Isso cria a branch e `specs/NNN-nome/spec.md`. Salve o discovery em `specs/NNN-nome/discovery.md`.
4. **spec-reviewer** revisa; rode o **/speckit.clarify** e responda você mesmo o que já foi respondido pelo humano; só pergunte o que for realmente novo (de novo, de uma vez). Rode **/speckit.checklist**. Corrija a spec até não restarem achados críticos.
5. Commit + push da branch. → `/fabrica.aprovar G1`.

## 2. Arquitetura (gate G2)
1. **solution-architect** roda o **/speckit.plan** com a stack do repositório (.NET do `global.json`, ASP.NET Core, EF Core, xUnit, Testcontainers): `plan.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`, `adr/`.
2. **security-reviewer** analisa o plano (ameaças, LGPD); incorpore o que for relevante.
3. Commit + push. → `/fabrica.aprovar G2`.

## 3. Tarefas (gate G3)
1. **task-planner** roda **/speckit.tasks** e **/speckit.analyze**. Corrija inconsistências em `tasks.md`. Problema na spec ou no plano → corrija, avise que invalida G1/G2 e reaprove na ordem.
2. Commit + push. → `/fabrica.aprovar G3`.

## 4. Implementação (sem gate formal; checkpoint por história)
1. Rode **/speckit.implement** fase por fase (Setup → Fundação → US1 → US2 …):
   - código → **dotnet-developer** (TDD); testes → **test-engineer**; pipeline/Docker → **devops-engineer**;
   - marque `[X]` em cada tarefa; commit por tarefa ou por grupo pequeno; push da branch ao fim de cada fase.
2. Ao fim de cada fase: `dotnet build`, `dotnet test`. Falhou → corrija antes de seguir.
3. **Checkpoint**: ao concluir cada história (US), mostre em até 6 linhas o que foi entregue e como testar, e pergunte: "Sigo para a próxima história? (sim / ajustar)". Se o humano disse antes "pode seguir direto", não pergunte mais.
4. Se precisar de tarefa nova → adicione ao `tasks.md` e reaprove G3 (`/fabrica.aprovar G3`) antes de implementá-la.

## 5. Revisão e Pull Request (gate G4)
1. **code-reviewer** e **security-reviewer** em paralelo sobre `git diff main...HEAD`. Consolide em `specs/NNN-nome/review-report.md`.
2. Corrija você mesmo (via **dotnet-developer**) todo achado bloqueante, crítico ou alto e revise de novo.
3. Push e abra o PR com `gh pr create` usando `.github/pull_request_template.md` preenchido.
4. Diga: "⛔ G4 — aprove o PR no GitHub: <link>. Enquanto isso, sigo com o QA." e **continue** para a fase 6.

## 6. QA (gate G5)
1. **qa-analyst**: matriz de rastreabilidade, testes de aceite dos cenários Given/When/Then em `tests/Acceptance/`, execução completa, `qa-report.md` pelo template.
2. NÃO APTO → volte à fase 4 para corrigir os defeitos (sem perguntar, se forem defeitos claros) e repita o QA.
3. Commit + push. → `/fabrica.aprovar G5`.
4. Diga: "Tudo aprovado do meu lado. Faça o merge do PR no GitHub quando o review (G4) e os checks estiverem verdes." Verifique com `gh pr checks` e reporte o estado.

## 7. Release (gate G6) — depois do merge
Quando o humano disser que fez o merge (ou num próximo `/fabrica.run` com o PR já mergeado):
1. `git switch main` e `git pull`.
2. **release-manager**: versão, `CHANGELOG.md`, `docs/releases/<versão>.md`, checklist de deploy e rollback. Como `main` é protegida, crie a branch `release/v<versão>`, commit, push e abra PR.
3. Diga: "⛔ G6 — após o merge desse PR, crie a Release `v<versão>` no GitHub (Releases → Draft a new release)." Fim do fluxo.
