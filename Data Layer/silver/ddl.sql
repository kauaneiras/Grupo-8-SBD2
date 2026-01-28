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
