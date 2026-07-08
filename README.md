# ☄️ NASA Asteroids Data Pipeline (Projeto-Degelo Supplement)

Este projeto implementa um pipeline de dados robusto, escalável e orquestrado para a ingestão, transformação e governança de dados operacionais sobre asteroides monitorados pela NASA (Near Earth Object Web Service API). 

O foco principal do repositório é aplicar boas práticas de **Engenharia de Dados**, garantindo a integridade, teste e documentação das tabelas desde a camada de dados brutos até a modelagem dimensional final.

## 🛠️ Arquitetura e Tecnologias

O fluxo do pipeline segue a arquitetura de um Data Warehouse local moderno estruturado em containers:

- **Orquestração:** **Apache Airflow (Astronomer)** gerenciando as tasks de extração incremental da API e carga no banco de dados.
- **Ingestão e Carga (EL):** Scripts Python otimizados integrados aos Hooks do Airflow para persistência.
- **Armazenamento:** **PostgreSQL** rodando em ambiente isolado via **Docker**.
- **Transformação de Dados (T):** **dbt (Data Build Tool)** modularizando as queries em camadas (Staging e Marts).
- **Data Quality:** Testes automatizados de integridade via dbt para validação de chaves e nulos.

## 📐 Linhagem de Dados (Lineage DAG)

O pipeline foi estruturado seguindo o conceito de separação de conceitos em camadas dentro do Data Warehouse:

1. `source.public.raw_nasa_asteroides`: Camada onde o dado pousa em seu estado bruto.
2. `stg_nasa_asteroides`: Camada de staging responsável pela limpeza inicial, padronização de tipos de dados e renomeação de campos.
3. `marts`: Tabelas facto prontas para o consumo analítico (`fct_analise_mensal_asteroides`, `fct_asteroides_criticos`, `fct_frequencia_observacoes`, `fct_maiores_asteroides`).

*(Dica: Adicione aqui o print da DAG de linhagem que o dbt docs gerou para você na porta 8001)*

## 🧪 Governança e Qualidade de Dados (Data Quality)

Para blindar o repositório contra dados corrompidos ou inconsistências da API, foram implementados **13 testes de dados automatizados** gerenciados pelo dbt, garantindo que regras críticas de negócio nunca sejam quebradas:

- **Testes de Unicidade (`unique`):** Aplicados em chaves primárias das tabelas fato (como `asteroide_nome` agrupados) para mitigar duplicações.
- **Testes de Não-Nulidade (`not_null`):** Aplicados em métricas severas e campos de identificação essenciais da NASA.

Para rodar os testes localmente:
```bash
dbt test
