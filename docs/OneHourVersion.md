# 🚀 Legacy to Cloud-Native

### Migrando sistemas monolíticos para arquiteturas cloud-native

---

## ⏱️ Agenda (60 minutos)

1. Contexto e objetivo da sessão (5 min)
2. Racional da migração: por que, quando e como (10 min)
3. Fases críticas da transformação (15 min)
4. Boas práticas de arquitetura cloud-native (15 min)
5. Armadilhas comuns e como evitá-las (10 min)
6. Encerramento + Q&A (5 min)

---

## 1️⃣ Contexto e objetivo da sessão (5 min)

### O problema real

* A maioria das empresas **não pode desligar o legacy**
* Ao mesmo tempo, precisa:

  * escalar
  * reduzir lead time
  * integrar serviços cloud
  * aumentar resiliência

👉 O desafio não é *cloud*, é **evolução arquitetural com continuidade de negócio**.

---

### Objetivo do webinar

* Mostrar **como modernizar sem big-bang**
* Ajudar a decidir:

  * **se** migrar
  * **quando** migrar
  * **como** migrar
* Evitar:

  * reescritas desnecessárias
  * over-engineering
  * “microserviços por moda”

---

## 2️⃣ Racional da migração (10 min)

### Drivers técnicos e de negócio

**Técnicos**

* Escalabilidade limitada
* Deploys arriscados
* Acoplamento excessivo
* Baixa testabilidade
* Infra manual / frágil

**Negócio**

* Time-to-market
* Custo operacional
* Integração com serviços cloud (AI, messaging, analytics)
* Disponibilidade e SLAs

👉 **Sem driver claro, não existe migração bem-sucedida.**

---

### Estratégias de modernização – os 6Rs

| Estratégia | Quando usar               | Exemplo prático | Riscos comuns |
| ---------- | ------------------------- | ---------------- | ------------- |
| Rehost     | Ganho rápido de infra     | Migrar um monólito on-prem para VMs na cloud sem alterar o código, apenas automatizando provisionamento e backups. | Levar problemas do on-prem para a cloud, custo maior que o esperado, falsa sensação de modernização. |
| Replatform | Pequenos ajustes técnicos | Mover a aplicação para a cloud usando banco gerenciado e storage cloud, com mínimas alterações de código. | Dependência excessiva de serviços cloud sem preparo, ganho limitado se o código continuar altamente acoplado. |
| Refactor   | Melhorar arquitetura      | Modularizar o monólito, introduzir containers, CI/CD e separação clara de domínios. | Subestimar esforço, refatoração sem entendimento do domínio, impacto em prazos e estabilidade. |
| Rebuild    | Último recurso            | Reescrever completamente o sistema usando nova stack e arquitetura cloud-native. | Big-bang, atraso elevado, perda de conhecimento de negócio, risco alto de não entrega. |
| Retire     | Sistema sem valor         | Desativar aplicação obsoleta substituída por SaaS ou outra solução interna. | Quebra de dependências ocultas, impacto em processos não mapeados, resistência organizacional. |
| Retain     | Ainda não é prioridade    | Manter sistema estável sem mudanças enquanto o time foca em iniciativas mais estratégicas. | Aumento do débito técnico, risco futuro maior, dificuldade de evolução quando virar prioridade. |

>NOTA: Os 6Rs não são um ranking técnico — são uma decisão de negócio com impacto arquitetural.


💡 **Rebuild quase nunca é o primeiro passo.**

---

### Decisão prática

Pergunta-chave:

> “Qual problema real eu quero resolver com essa migração?”

Se a resposta for vaga → **pare aqui**.

---

## 3️⃣ Fases críticas da transformação (15 min)

### Fase 1 — Entender o legacy

Antes de migrar, é preciso **mapear**:

* Dependências técnicas
* Dependências de domínio
* Acoplamento com dados
* Integrações externas
* Fluxos críticos de negócio

Checklist rápido:

* Onde está o estado?
* O que escala junto?
* O que quebra junto?

---

### Fase 2 — Roadmap de decomposição

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20240405152350/Monolithic-Architecture.webp)

![Image](https://substackcdn.com/image/fetch/f_auto%2Cq_auto%3Agood%2Cfl_progressive%3Asteep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fc2a0e8e9-9f9b-43de-b067-bad366303919_1994x1010.png)

![Image](https://assets.bytebytego.com/diagrams/0396-typical-microservice-architecture.png)

```
Monólito
 → Modular Monolith
   → Micro-serviços
```

#### Por que **Modular Monolith**?

* Reduz risco
* Mantém deploy único
* Força limites de domínio
* Prepara o código para extração futura

👉 Modular Monolith é **estratégia**, não fracasso.

---

### Fase 3 — Critérios de sucesso por etapa

Não avance se não houver ganho real:

* Deploy ficou mais seguro?
* Escala ficou mais granular?
* Testes ficaram mais fáceis?
* Lead time diminuiu?

---

## 4️⃣ Boas práticas de arquitetura cloud-native (15 min)

### Princípios fundamentais

* Configuração externa
* Stateless sempre que possível
* Logs como streams
* Build ≠ Release ≠ Run

---

### Containerização e orquestração

* Containers como unidade de deploy
* Orquestração com **Kubernetes**
* Infra efêmera
* Auto-healing

💬 Frase-chave:

> “Kubernetes não resolve arquitetura ruim.”

---

### CI/CD e Infraestrutura como Código

* Pipeline como contrato
* Nada manual em produção
* Infra versionada
* Ambientes reproduzíveis

Exemplo de pipeline:

```
Commit → Build → Test → Scan → Deploy
```

---

### Observabilidade desde o início

* Logs estruturados
* Métricas de negócio + técnicas
* Tracing distribuído

👉 **Sem observabilidade, microserviços viram caos distribuído.**

---

## 5️⃣ Armadilhas comuns (10 min)

### 🚨 Over-engineering: solução é mais complexa do que o problema real

Sinais clássicos:

* Microserviços demais cedo demais
* Kubernetes usado como VM cara
* Complexidade sem necessidade

Pergunta honesta:

> “Isso resolve um problema real hoje?”

---

### 🚨 Perda de conhecimento de domínio

* Refactor sem entender o negócio
* Extração de serviços errados
* Times organizados por tecnologia, não por domínio

👉 Código novo ≠ entendimento novo.

---

### 🚨 Continuidade de negócio

Big-bang é quase sempre erro.

Solução: **Strangler Fig Pattern**

![Image](https://learn.microsoft.com/en-us/azure/architecture/patterns/_images/strangler.png)

![Image](https://microservices.io/i/decompose-your-monolith-devnexus-feb-2020.001.jpeg)

* Coexistência
* Migração incremental
* Risco controlado

---

## 6️⃣ Encerramento e Q&A (5 min)

### Checklist final — Cloud-native readiness

* Drivers claros?
* Roadmap incremental?
* Pipeline confiável?
* Observabilidade presente?
* Ganho real por etapa?

---

### Mensagem final

> Cloud-native não é sobre microserviços, containers ou Kubernetes.
> É sobre **reduzir risco enquanto aumenta velocidade**.

---

### Próximos passos (pós-sessão)

* Revisar o repositório
* Explorar os exemplos de pipeline
* Avaliar o legacy com critérios claros
* Evoluir **um passo de cada vez**

---

## 📚 Leituras recomendadas

* AWS Cloud Adoption Framework
* ThoughtWorks Technology Radar
* Google Cloud Architecture Center