# 🚚 CargaClick – Plataforma Inteligente de Fretes

Plataforma moderna de gerenciamento de fretes que conecta **clientes** e **transportadores** de forma ágil e transparente.  
Com cálculo de rotas em tempo real, plano de fidelização, comissão dinâmica e dashboards intuitivos, o **CargaClick** traz eficiência para o mercado de logística.

---

## 📦 Principais Funcionalidades

- **Cadastro completo** de clientes e transportadores
- **Bolsão de solicitações** (marketplace de fretes em aberto)
- **Simulação de frete com mapa interativo** (OpenRouteService + Leaflet.js)
- **Negociação direta** entre clientes e transportadores
- **Encerramento com fidelização** (ClickPoints, ranking VIP e bônus)
- **Dashboard visual** com cards de acesso rápido
- **Plano de pontos e comissão reduzida** para usuários fiéis
- **Layout responsivo** com [Tailwind CSS](https://tailwindcss.com/)
- **Banco de dados PostgreSQL** robusto e escalável

---

## 🛠️ Stack Tecnológica

- **Backend:** Ruby on Rails 7.1.x (Ruby 3.2.4)
- **Frontend:** TailwindCSS + Turbo + Stimulus
- **Banco de Dados:** PostgreSQL
- **Infraestrutura:** Render (deploy em Docker)
- **Maps/Rotas:** OpenRouteService + Leaflet.js
- **CI/CD:** GitHub Actions
- **Servidor:** Puma

---

## 🚀 Como rodar localmente

### Pré-requisitos

- Ruby >= 3.2.4  
- Rails >= 7.1.x  
- Node.js + Yarn  
- PostgreSQL 15+  

### Passos

1. Clone o projeto:
   ```bash
   git clone git@github.com:harleyjosesoncim/cargaclick.git
   cd cargaclick
