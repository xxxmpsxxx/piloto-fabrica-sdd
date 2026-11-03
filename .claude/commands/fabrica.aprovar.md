---
description: "Pede a aprovação humana do gate pendente (um clique)"
argument-hint: "[G0|G1|G2|G3|G5] [comentário]"
---

# /fabrica.aprovar

Gate solicitado (opcional): $ARGUMENTS

1. Descubra a feature (branch `NNN-nome`; para G0 não precisa) e qual gate aprovar: o informado acima ou o **primeiro gate não APROVADO** na ordem G0, G1, G2, G3, G5, considerando só os que já têm artefato (verificação conforme o CLAUDE.md).
2. Confira se os gates anteriores estão APROVADOS. Se não, aprove-os primeiro, em ordem.
3. Grave no repositório os artefatos do gate: `git add` dos arquivos/pastas do gate (nunca da pasta `approvals/`) e `git commit -m "docs(<feature>): artefatos para <gate>"`. Se não houver mudanças, use o commit atual. Pegue o sha com `git rev-parse HEAD`.
4. Mostre ao humano, em até 12 linhas, **o que ele está aprovando**: os arquivos, os pontos principais (decisões, regras, riscos, nº de tarefas ou recomendação de QA) e o que ainda está em aberto. Termine com:

   > Para aprovar, clique em **Sim** no pedido de permissão que vai aparecer agora. Para recusar, clique em **Não** e diga o que mudar.
   > Clique só em "Sim" (não em "Sim, não perguntar de novo").

5. Crie o registro com a ferramenta de escrita, no caminho e formato do CLAUDE.md (`aprovador` = `git config user.name` e `user.email`). O Claude Code vai pedir permissão — **essa resposta é a decisão do humano**.
   - **Sim** → `git add -A specs .specify` e `git commit -m "docs(<feature>): aprova <gate>"`; se houver branch de feature, `git push -u origin <branch>`. Confirme em uma linha.
   - **Não** → não tente de novo. Pergunte o que precisa mudar, faça as mudanças e repita este fluxo.
6. Se foi chamado de dentro de `/fabrica.run`, volte ao fluxo e **continue automaticamente** para a próxima fase.
