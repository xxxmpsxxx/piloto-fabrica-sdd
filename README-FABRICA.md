# Fábrica SDD v2 — desenvolvimento assistido

## Instalar (uma vez por repositório)
1. Extraia o conteúdo deste zip **na pasta raiz do repositório**, substituindo os arquivos existentes. Confira que as pastas `.claude` e `.github` foram extraídas: elas são ocultas no macOS e no Linux.
2. Abra o Claude Code **na pasta raiz do repositório**. No Claude Desktop, escolha essa pasta, não a pasta de cima. Se a sessão já estava aberta, abra uma nova.
3. Digite `/fabrica.setup`. Ele faz o restante: confere as ferramentas, remove a versão anterior do kit, instala o Spec Kit, gera a constituição, configura o GitHub e pede o único push direto na main.

## Usar
```
/fabrica.run Cadastro de clientes com consulta e histórico de alterações
```
O Claude conduz o fluxo inteiro: levantamento, especificação, arquitetura, tarefas, implementação, revisão, PR e QA. Você só:
- responde às perguntas de negócio;
- clica em **Sim** quando ele pedir permissão para gravar em `approvals/`; esse clique é a aprovação do gate;
- aprova e faz o merge do PR no GitHub e cria a Release.

`/fabrica.status` mostra onde a feature está. `/fabrica.run` sem texto continua de onde parou.

## Como as aprovações são garantidas
- No Claude Code, o projeto obriga a pedir permissão antes de gravar em `approvals/`, em qualquer modo, inclusive no de aceitar edições automaticamente. Merge, push forçado, deploy, migração em banco e leitura de segredos ficam bloqueados.
- Cada registro de aprovação guarda o commit aprovado. Se o artefato mudar depois, o gate fica inválido.
- No GitHub, o check `fabrica-gates` impede o merge de código sem G0, G1, G2, G3 e G5 válidos. Isso só vale em repositório público ou com plano pago.
- Não há scripts locais nem hooks: só `git`, `gh`, `dotnet` e `uv`. Funciona igual no Windows, no macOS e no Linux.

## Opcionais
Em `fabrica/opcional/` estão o deploy com aprovação (`cd.yml`) e a revisão de PR por IA (`ai-review.yml`). Para usar, copie para `.github/workflows/` e ajuste.
