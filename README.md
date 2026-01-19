# Grupo 8 - Sistemas de Banco de Dados 2

## 📊 Projeto: Análise de Investimentos em Filmes (TMDB)

Este projeto implementa um pipeline ETL completo para análise de dados de filmes, utilizando a arquitetura de Data Lake com camadas Raw, Silver e Gold.

### 🎯 Persona: Diretor de Estratégia de Investimentos

**Objetivo:** Identificar o próximo filme de sucesso com o menor orçamento possível, maximizando o ROI (Return on Investment).

---

## 🚀 Como Executar

### Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado e rodando
- [Python 3.10+](https://www.python.org/downloads/)
- [VS Code](https://code.visualstudio.com/) com extensão Jupyter
- [pgAdmin 4](https://www.pgadmin.org/download/) (opcional, para visualização)

### 1. Clonar o Repositório

Este repositório utiliza Git Large File Storage (Git LFS) para que seja possível realizar o upload do arquivo .csv.
Para garantir que todos os arquivos sejam baixados corretamente, siga os passos abaixo:

> **Atenção:**  
> - No **Windows**, é necessário realizar o [download e instalação do Git LFS](https://git-lfs.com/) antes de prosseguir.  
> - No **Linux**, instale o Git LFS utilizando o gerenciador de pacotes da sua distribuição (ex.: `sudo apt install git-lfs`).

```bash
git lfs install

git clone https://github.com/kauaneiras/Grupo-8-SBD2.git # Pode levar alguns minutos devido ao uso do Git LFS

cd Grupo-8-SBD2

git lfs pull
```

Para verificar se os arquivos foram devidamente baixados rode o seguinte comando:
```bash
git lfs ls-files
```

Saída esperada:
```bash
c8f3e0de0f * Data Layer/raw/dados_brutos.csv
```

### 2. Iniciar o Banco de Dados

```bash
# Na raiz do projeto, execute:
docker-compose up -d
```

Aguarde o container iniciar. Você pode verificar o status com:
```bash
docker ps
```

O banco estará disponível quando o status mostrar `(healthy)`.

**Configurações do banco:**
| Parâmetro | Valor |
|-----------|-------|
| Host | `localhost` |
| Porta | `5433` |
| Database | `grupo08` |
| Usuário | `postgres` |
| Senha | `postgres` |

### 3. Conectar no pgAdmin 4

1. Abra o **pgAdmin 4**
2. Clique com botão direito em **Servers** → **Register** → **Server...**
3. Na aba **General**:
   - Name: `Grupo08-SBD2`
4. Na aba **Connection**:
   - Host: `localhost`
   - Port: `5433`
   - Maintenance database: `grupo08`
   - Username: `postgres`
   - Password: `postgres`
5. Clique em **Save**

### 4. Executar o ETL Raw → Silver

1. Abra o VS Code na pasta do projeto
2. Navegue até `Transformer/etl_raw_to_silver.ipynb`
3. Execute todas as células do notebook (Run All)
4. Aguarde a conclusão do processo (~3-5 minutos)

**O que o ETL faz:**
- Carrega 1.3M de registros do arquivo CSV bruto
- Filtra filmes (apenas Released, remove adulto)
- Converte e limpa tipos de dados
- Cria métricas financeiras (profit, ROI, budget_tier)
- Carrega os dados no PostgreSQL (schema `silver`)

### 5. Verificar os Dados no pgAdmin

Após o ETL, você pode visualizar os dados:

1. No pgAdmin, navegue até: `Grupo08-SBD2` → `Databases` → `grupo08` → `Schemas` → `silver` → `Tables` → `filmes`
2. Clique com botão direito → **View/Edit Data** → **First 100 Rows**

Ou execute a query:
```sql
SELECT id, title, release_year, primary_genre, budget, revenue, roi
FROM silver.filmes
ORDER BY popularity DESC
LIMIT 10;
```

---

## 📁 Estrutura do Projeto

```
Grupo-8-SBD2/
├── docker-compose.yml          # Configuração do PostgreSQL
├── README.md                   # Este arquivo
├── Data Layer/
│   ├── raw/
│   │   ├── dados_brutos.csv    # Dados originais (TMDB)
│   │   └── analytics.ipynb     # Análise exploratória (Raw)
│   ├── silver/
│   │   ├── dados_silver.csv    # Backup dos dados tratados
│   │   ├── ddl.sql             # Script de criação da tabela
│   │   ├── analytics.ipynb     # Análise exploratória (Silver)
│   │   └── MER_DER_DLD.md      # Documentação do modelo de dados
│   └── gold/
│       ├── ddl.sql             # Scripts de criação do DW
│       └── consultas.sql       # Queries analíticas
└── Transformer/
    ├── etl_raw_to_silver.ipynb # ETL Raw → Silver
    └── etl_silver_to_gold.ipynb # ETL Silver → Gold
```

---

## 📈 Estatísticas do Dataset

| Métrica | Valor |
|---------|-------|
| Total de Filmes | 1.174.587 |
| Gêneros Únicos | 19 |
| Produtoras Únicas | 130.706 |
| Países Únicos | 245 |
| Período | 1800 - 2061 |
| Filmes com ROI calculável | 15.979 |
| Taxa de Sucesso (lucrativos) | 59.1% |

---

## 🛠️ Comandos Úteis

```bash
# Iniciar o banco
docker-compose up -d

# Parar o banco
docker-compose down

# Ver logs do banco
docker logs grupo08-db

# Reiniciar o banco (limpa os dados)
docker-compose down -v
docker-compose up -d
```

---

## 👥 Equipe - Grupo 8

A equipe é composta pelos seguintes membros:
<center>
<table style="margin-left: auto; margin-right: auto;">
    <tr> <td align="center">
            <a href="https://github.com/kauaneiras">
                <img style="border-radius: 50%;" src="https://github.com/kauaneiras.png" width="150px;"/>
                <h5 class="text-center">Kauan Eiras</h5>
            </a>
        </td>
         <td align="center">
            <a href="https://github.com/kalipassos">
                <img style="border-radius: 50%;" src="https://github.com/kalipassos.png" width="150px;"/>
                <h5 class="text-center">Kallyne Passos</h5>
            </a>
        </td>
         <td align="center">
            <a href="https://github.com/klmurussi">
                <img style="border-radius: 50%;" src="https://github.com/klmurussi.png" width="150px;"/>
                <h5 class="text-center">Kathlyn Lara</h5>
            </a>
        </td>
     <td align="center">
            <a href="https://github.com/Ninja-Haiyai">
                <img style="border-radius: 50%;" src="https://github.com/Ninja-Haiyai.png" width="150px;"/>
                <h5 class="text-center">Matheus Barros</h5>
            </a>
        </td>
        <td align="center">
            <a href="https://github.com/leanars">
                <img style="border-radius: 50%;" src="https://github.com/leanars.png" width="150px;"/>
                <h5 class="text-center">Leandro Almeida</h5>
            </a>
        </td>
</table>

---

## 📝 Licença

Este projeto é parte da disciplina de Sistemas de Banco de Dados 2 - UnB.
