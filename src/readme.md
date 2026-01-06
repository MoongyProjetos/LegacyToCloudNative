# Arquitetura de Exemplo — Legacy to Cloud-Native

Este documento descreve a evolução arquitetural de uma aplicação Web ao longo do processo de modernização,
partindo de um cenário **on-premises tradicional** até uma arquitetura **cloud-native**, com foco em
**continuidade de negócio**, **redução de risco** e **incrementalidade**.

---

## 🏠 On-Premises (Legacy)

Arquitetura tradicional, comum em muitas organizações.

### Componentes
- Windows Server com IIS
- SQL Server Database
- Logs locais (ex: Log4Net)
- Deploy manual
- Escalabilidade vertical

### Características
- Forte acoplamento entre aplicação e infraestrutura
- Escala limitada
- Observabilidade restrita
- Alto risco em mudanças

---

## ☁️ Cloud Native v1 — Lift and Shift (conceitual)

> ⚠️ **Importante:** esta fase é apresentada apenas como conceito.
> Não foi implementada nos exemplos de Bicep, Terraform ou Docker.

### Objetivo
Mover a carga de trabalho para a cloud **sem alterar a aplicação**, focando apenas em infraestrutura.

### Componentes típicos
- VM com Windows
- SQL Server em VM
- Backup e rede gerenciados pela cloud

### Limitações
- Pouco ou nenhum ganho arquitetural
- Custos semelhantes ou maiores
- Problemas do on-prem levados para a cloud

---

## ☁️ Cloud Native v2 — Introdução ao PaaS (Azure)

> ✅ **Implementado em Bicep e Terraform**

Esta fase representa a **primeira modernização real**, com adoção de serviços PaaS e automação.

### Componentes
- **Azure App Service (Web App)** — `MoongyWebApp`
- **Azure SQL Database**
- **Application Insights (workspace-based)**
- **Log Analytics Workspace**

### Características
- Infraestrutura como Código (Bicep / Terraform)
- Deploy automatizado
- Escalabilidade gerenciada pelo Azure
- Observabilidade centralizada
- Menor esforço operacional

### Benefícios
- Redução de risco operacional
- Menor custo de manutenção
- Melhor time-to-market
- Base sólida para evolução cloud-native

---

## 🐳 Cloud Native v3 — Containers (Ambiente Local / Dev)

> ✅ **Implementado via Docker Compose**

Esta fase replica localmente os principais conceitos cloud-native,
permitindo desenvolvimento e testes consistentes.

### Componentes
- **Web App containerizada** (`MoongyWebApp`)
- **SQL Server em container** (Developer Edition)
- **OpenTelemetry Collector**
- **Jaeger** (visualização local de traces)
- Exportação opcional para **Azure Application Insights**

### Características
- Paridade entre ambientes (dev ↔ cloud)
- Observabilidade desde o início
- Arquitetura orientada a serviços
- Base para futura orquestração (ex: Kubernetes)

### Observabilidade
- OpenTelemetry como padrão
- Traces visíveis localmente via Jaeger
- Possibilidade de envio direto para Application Insights

---
## ☸️ Cloud Native v4 — Kubernetes (Escala e Maturidade Operacional)

> 🚧 **Fase avançada / opcional**  
> Deve ser adotada **apenas quando houver necessidade real de escala, isolamento e autonomia entre serviços**.


::contentReference[oaicite:0]{index=0}


Esta fase representa a consolidação do modelo cloud-native, quando a aplicação
já está **containerizada**, **observável** e **automatizada**, e passa a exigir
**escala mais sofisticada** e **resiliência operacional**.

---

### Componentes
- **Cluster Kubernetes** (AKS, EKS, GKE ou on-prem)
- **Deployments e Services**
- **Ingress Controller**
- **ConfigMaps e Secrets**
- **Horizontal Pod Autoscaler (HPA)**
- **OpenTelemetry**
- **Application Insights / Azure Monitor**
- (Opcional) Service Mesh

---

### Características
- Orquestração completa de containers
- Escalabilidade automática
- Auto-healing
- Deploys progressivos (rolling / blue-green)
- Separação clara entre aplicação e infraestrutura
- Observabilidade distribuída

---

### O que o Kubernetes resolve
- Escalar partes específicas da aplicação
- Isolar falhas
- Padronizar deploy entre times
- Reduzir dependência de infraestrutura específica

---

### O que o Kubernetes **não** resolve
- Arquitetura ruim
- Domínios mal definidos
- Falta de CI/CD
- Ausência de observabilidade
- Over-engineering

> 💬 **Frase importante para o webinar:**  
> “Kubernetes amplifica boas práticas — não corrige más decisões.”

---

### Quando faz sentido adotar Kubernetes?
Checklist honesto:

- Tenho múltiplos serviços independentes?
- Tenho múltiplos times deployando em paralelo?
- Preciso escalar partes diferentes da aplicação?
- Já tenho CI/CD maduro?
- Já tenho observabilidade funcionando?

Se a maioria das respostas for **não**:
➡️ Kubernetes **não é prioridade agora**.

---

### Relação com as fases anteriores
- **Cloud Native v2 (PaaS)** → simplicidade e ganho rápido
- **Cloud Native v3 (Containers)** → paridade e portabilidade
- **Cloud Native v4 (Kubernetes)** → escala, autonomia e resiliência

---

## 📌 Visão Geral da Evolução 

| Fase | Infraestrutura | Deploy | Observabilidade | Complexidade |
|----|----|----|----|----|
| On-Prem | Manual | Manual | Local | Baixa |
| Cloud v1 | VM | Semi-manual | Limitada | Média |
| Cloud v2 | PaaS | Automatizado | Centralizada | Baixa |
| Cloud v3 | Containers | Automatizado | Distribuída | Média |
| Cloud v4 | Kubernetes | Declarativo | Distribuída | Alta |

---

## 🎯 Mensagem-chave

> Cloud-native não é um salto tecnológico.  
> É uma **evolução arquitetural incremental**, guiada por risco,
> maturidade do time e necessidades reais do negócio.
