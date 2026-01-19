-- =============================================================================
-- DDL - Camada Silver - TMDB Movies Dataset
-- Projeto: Grupo-8-SBD2
-- =============================================================================

-- Criação do schema
CREATE SCHEMA IF NOT EXISTS silver;

-- Drop da tabela se existir (para recriação)
-- DROP TABLE IF EXISTS silver.filmes;

-- Criação da tabela principal
CREATE TABLE IF NOT EXISTS silver.filmes (
    -- Identificação
    id                   INTEGER PRIMARY KEY,
    
    -- Informações Básicas
    title                TEXT,
    original_title       TEXT,
    original_language    VARCHAR(10),
    runtime              INTEGER,
    status               VARCHAR(50),
    
    -- Informações Temporais
    release_date         DATE,
    release_year         INTEGER,
    release_month        INTEGER,
    release_month_name   VARCHAR(20),
    release_day_of_week  INTEGER,
    release_day_name     VARCHAR(20),
    release_decade       INTEGER,
    
    -- Categorização
    genres               TEXT,
    primary_genre        VARCHAR(50),
    
    -- Produção
    production_companies TEXT,
    primary_company      TEXT,
    production_countries TEXT,
    primary_country      VARCHAR(100),
    
    -- Avaliação e Popularidade
    vote_average         NUMERIC(4,2),
    vote_count           INTEGER,
    popularity           DOUBLE PRECISION,
    
    -- Informações Financeiras
    budget               BIGINT,
    revenue              BIGINT,
    profit               BIGINT,
    roi                  DOUBLE PRECISION,
    is_profitable        BOOLEAN,
    budget_tier          VARCHAR(20),
    
    -- Metadados
    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- ÍNDICES
-- =============================================================================

-- Índice para consultas por ano de lançamento
CREATE INDEX IF NOT EXISTS idx_filmes_release_year 
    ON silver.filmes(release_year);

-- Índice para filtragem por gênero principal
CREATE INDEX IF NOT EXISTS idx_filmes_primary_genre 
    ON silver.filmes(primary_genre);

-- Índice para ordenação por avaliação
CREATE INDEX IF NOT EXISTS idx_filmes_vote_average 
    ON silver.filmes(vote_average);

-- Índice para ordenação por popularidade
CREATE INDEX IF NOT EXISTS idx_filmes_popularity 
    ON silver.filmes(popularity);

-- Índice para análise por faixa orçamentária
CREATE INDEX IF NOT EXISTS idx_filmes_budget_tier 
    ON silver.filmes(budget_tier);

-- Índice para consultas por década
CREATE INDEX IF NOT EXISTS idx_filmes_release_decade 
    ON silver.filmes(release_decade);

-- Índice para consultas por país principal
CREATE INDEX IF NOT EXISTS idx_filmes_primary_country 
    ON silver.filmes(primary_country);

-- =============================================================================
-- COMENTÁRIOS
-- =============================================================================

COMMENT ON TABLE silver.filmes IS 'Tabela de filmes da camada Silver - dados limpos e transformados do TMDB';

COMMENT ON COLUMN silver.filmes.id IS 'Identificador único do filme no TMDB (PK)';
COMMENT ON COLUMN silver.filmes.title IS 'Título do filme';
COMMENT ON COLUMN silver.filmes.original_title IS 'Título no idioma original';
COMMENT ON COLUMN silver.filmes.original_language IS 'Código ISO 639-1 do idioma original';
COMMENT ON COLUMN silver.filmes.runtime IS 'Duração do filme em minutos';
COMMENT ON COLUMN silver.filmes.status IS 'Status de lançamento (Released, Post Production, etc.)';

COMMENT ON COLUMN silver.filmes.release_date IS 'Data de lançamento do filme';
COMMENT ON COLUMN silver.filmes.release_year IS 'Ano de lançamento extraído da data';
COMMENT ON COLUMN silver.filmes.release_month IS 'Mês de lançamento (1-12)';
COMMENT ON COLUMN silver.filmes.release_month_name IS 'Nome do mês de lançamento';
COMMENT ON COLUMN silver.filmes.release_day_of_week IS 'Dia da semana (0=Segunda a 6=Domingo)';
COMMENT ON COLUMN silver.filmes.release_day_name IS 'Nome do dia da semana';
COMMENT ON COLUMN silver.filmes.release_decade IS 'Década de lançamento (ex: 1990, 2000, 2010)';

COMMENT ON COLUMN silver.filmes.genres IS 'Lista de gêneros em formato JSON';
COMMENT ON COLUMN silver.filmes.primary_genre IS 'Gênero principal (primeiro da lista)';

COMMENT ON COLUMN silver.filmes.production_companies IS 'Lista de produtoras em formato JSON';
COMMENT ON COLUMN silver.filmes.primary_company IS 'Produtora principal (primeira da lista)';
COMMENT ON COLUMN silver.filmes.production_countries IS 'Lista de países de produção em formato JSON';
COMMENT ON COLUMN silver.filmes.primary_country IS 'País principal de produção';

COMMENT ON COLUMN silver.filmes.vote_average IS 'Média de avaliações dos usuários (0 a 10)';
COMMENT ON COLUMN silver.filmes.vote_count IS 'Quantidade total de votos recebidos';
COMMENT ON COLUMN silver.filmes.popularity IS 'Índice de popularidade calculado pelo TMDB';

COMMENT ON COLUMN silver.filmes.budget IS 'Orçamento do filme em USD';
COMMENT ON COLUMN silver.filmes.revenue IS 'Receita total do filme em USD';
COMMENT ON COLUMN silver.filmes.profit IS 'Lucro calculado (revenue - budget)';
COMMENT ON COLUMN silver.filmes.roi IS 'Retorno sobre investimento em percentual';
COMMENT ON COLUMN silver.filmes.is_profitable IS 'Indicador booleano de lucratividade';
COMMENT ON COLUMN silver.filmes.budget_tier IS 'Faixa de orçamento (Micro, Low, Medium, High, Blockbuster)';

COMMENT ON COLUMN silver.filmes.created_at IS 'Timestamp de criação do registro no banco';
