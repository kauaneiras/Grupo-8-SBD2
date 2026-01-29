-- =============================================================================
-- DDL - Camada Gold - TMDB Movies Dataset
-- Projeto: Grupo-8-SBD2
-- =============================================================================


-- 1. Criação do Schema
CREATE SCHEMA IF NOT EXISTS dw;

-- =============================================================================
-- TABELAS DE DIMENSÃO
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tabela: dw.dim_rel (Release / Calendário)
-- -----------------------------------------------------------------------------
CREATE TABLE dw.dim_rel (
    srk_rel     INTEGER NOT NULL,          -- Surrogate Key
    rel_dat     DATE,                      -- release_date
    rel_yer     INTEGER,                   -- release_year
    rel_mon     INTEGER,                   -- release_month
    rel_mon_nam VARCHAR(20),               -- release_month_name
    rel_day_wek INTEGER,                   -- release_day_of_week
    rel_day_nam VARCHAR(20),               -- release_day_name
    rel_dec     INTEGER,                   -- release_decade
    CONSTRAINT pk_dim_rel PRIMARY KEY (srk_rel)
);

COMMENT ON TABLE dw.dim_rel IS 'Dimensão Calendário (Release)';
COMMENT ON COLUMN dw.dim_rel.rel_dat IS 'Data de lançamento';
COMMENT ON COLUMN dw.dim_rel.rel_yer IS 'Ano';

-- -----------------------------------------------------------------------------
-- Tabela: dw.dim_pft (Profit / Financeiro)
-- -----------------------------------------------------------------------------
CREATE TABLE dw.dim_pft (
    srk_pft     INTEGER NOT NULL,          -- Surrogate Key
    bdg         NUMERIC,                   -- budget
    rev         NUMERIC,                   -- revenue
    pft         NUMERIC,                   -- profit
    ret_inv     NUMERIC,                   -- roi (Return on Investment)
    pfe         BOOLEAN,                   -- is_profitable
    bdg_tir     VARCHAR(50),               -- budget_tier
    CONSTRAINT pk_dim_pft PRIMARY KEY (srk_pft)
);

COMMENT ON TABLE dw.dim_pft IS 'Dimensão Financeira (Profit)';
COMMENT ON COLUMN dw.dim_pft.bdg IS 'Orçamento (Budget)';
COMMENT ON COLUMN dw.dim_pft.rev IS 'Receita (Revenue)';

-- -----------------------------------------------------------------------------
-- Tabela: dw.dim_eng (Engagement)
-- -----------------------------------------------------------------------------
CREATE TABLE dw.dim_eng (
    srk_eng     INTEGER NOT NULL,          -- Surrogate Key
    vot_avg     NUMERIC(4, 2),             -- vote_average
    vot_cnt     INTEGER,                   -- vote_count
    pop         NUMERIC,                   -- popularity
    CONSTRAINT pk_dim_eng PRIMARY KEY (srk_eng)
);

COMMENT ON TABLE dw.dim_eng IS 'Dimensão de Engajamento (Engagement)';
COMMENT ON COLUMN dw.dim_eng.vot_avg IS 'Média de votos';
COMMENT ON COLUMN dw.dim_eng.pop IS 'Popularidade';

-- -----------------------------------------------------------------------------
-- Tabela: dw.dim_lng (Language)
-- -----------------------------------------------------------------------------
CREATE TABLE dw.dim_lng (
    srk_lng     INTEGER NOT NULL,          -- Surrogate Key
    lng         VARCHAR(10),               -- original_language
    CONSTRAINT pk_dim_lng PRIMARY KEY (srk_lng)
);

COMMENT ON TABLE dw.dim_lng IS 'Dimensão de Idiomas (Language)';

-- -----------------------------------------------------------------------------
-- Tabela: dw.dim_cmp (Company)
-- -----------------------------------------------------------------------------
CREATE TABLE dw.dim_cmp (
    srk_cmp     INTEGER NOT NULL,          -- Surrogate Key
    prd_cmp     VARCHAR(255),              -- production_company / primary_company
    CONSTRAINT pk_dim_cmp PRIMARY KEY (srk_cmp)
);

COMMENT ON TABLE dw.dim_cmp IS 'Dimensão de Produtoras (Company)';

-- -----------------------------------------------------------------------------
-- Tabela: dw.dim_ctr (Country)
-- -----------------------------------------------------------------------------
CREATE TABLE dw.dim_ctr (
    srk_ctr     INTEGER NOT NULL,          -- Surrogate Key
    prd_ctr     VARCHAR(100),              -- production_country / primary_country
    CONSTRAINT pk_dim_ctr PRIMARY KEY (srk_ctr)
);

COMMENT ON TABLE dw.dim_ctr IS 'Dimensão de Países (Country)';

-- -----------------------------------------------------------------------------
-- Tabela: dw.dim_rte (Runtime)
-- -----------------------------------------------------------------------------
CREATE TABLE dw.dim_rte (
    srk_rte     INTEGER NOT NULL,          -- Surrogate Key
    rte         NUMERIC,                   -- runtime
    CONSTRAINT pk_dim_rte PRIMARY KEY (srk_rte)
);

COMMENT ON TABLE dw.dim_rte IS 'Dimensão de Duração (Runtime)';

-- -----------------------------------------------------------------------------
-- Tabela: dw.dim_gen (Genres)
-- -----------------------------------------------------------------------------
CREATE TABLE dw.dim_gen (
    srk_gen     INTEGER NOT NULL,          -- Surrogate Key
    gen         VARCHAR(100),              -- genre
    CONSTRAINT pk_dim_gen PRIMARY KEY (srk_gen)
);

COMMENT ON TABLE dw.dim_gen IS 'Dimensão de Gêneros (Genres)';

-- -----------------------------------------------------------------------------
-- Tabela: dw.dim_prd_cmp (Production Companies)

-- -----------------------------------------------------------------------------
CREATE TABLE dw.dim_prd_cmp (
    srk_pco     INTEGER NOT NULL,          -- Surrogate Key
    pco         VARCHAR(255),              -- company
    CONSTRAINT pk_dim_prd_cmp PRIMARY KEY (srk_pco)
);

COMMENT ON TABLE dw.dim_prd_cmp IS 'Dimensão de todas as produtoras';


-- =============================================================================
-- TABELA FATO: dw.fat_mov (Fato Filme)
-- =============================================================================

CREATE TABLE dw.fat_mov (
    srk_ttl     INTEGER NOT NULL,          -- Surrogate Key (Baseada no ID)
    ttl         VARCHAR(500),              -- title
    org_ttl     VARCHAR(500),              -- original_title
    crt         TIMESTAMP,                 -- created_at
    
    -- Chaves Estrangeiras (Foreign Keys)
    srk_rel     INTEGER,                   -- FK para dim_rel
    srk_gen     INTEGER,                   -- FK para dim_gen
    srk_pft     INTEGER,                   -- FK para dim_pft
    srk_eng     INTEGER,                   -- FK para dim_eng
    srk_lng     INTEGER,                   -- FK para dim_lng
    srk_cmp     INTEGER,                   -- FK para dim_cmp
    srk_ctr     INTEGER,                   -- FK para dim_ctr
    srk_rte     INTEGER,                   -- FK para dim_rte
    
    CONSTRAINT pk_fat_mov PRIMARY KEY (srk_ttl)
);

-- Definição das Constraints de Chave Estrangeira
ALTER TABLE dw.fat_mov ADD CONSTRAINT frk_rel 
    FOREIGN KEY (srk_rel) REFERENCES dw.dim_rel(srk_rel);

ALTER TABLE dw.fat_mov ADD CONSTRAINT frk_gen 
    FOREIGN KEY (srk_gen) REFERENCES dw.dim_gen(srk_gen);

ALTER TABLE dw.fat_mov ADD CONSTRAINT frk_pft 
    FOREIGN KEY (srk_pft) REFERENCES dw.dim_pft(srk_pft);

ALTER TABLE dw.fat_mov ADD CONSTRAINT frk_eng 
    FOREIGN KEY (srk_eng) REFERENCES dw.dim_eng(srk_eng);

ALTER TABLE dw.fat_mov ADD CONSTRAINT frk_lng 
    FOREIGN KEY (srk_lng) REFERENCES dw.dim_lng(srk_lng);

ALTER TABLE dw.fat_mov ADD CONSTRAINT frk_cmp 
    FOREIGN KEY (srk_cmp) REFERENCES dw.dim_cmp(srk_cmp);

ALTER TABLE dw.fat_mov ADD CONSTRAINT frk_ctr 
    FOREIGN KEY (srk_ctr) REFERENCES dw.dim_ctr(srk_ctr);

ALTER TABLE dw.fat_mov ADD CONSTRAINT frk_rte 
    FOREIGN KEY (srk_rte) REFERENCES dw.dim_rte(srk_rte);

-- =============================================================================
-- ÍNDICES
-- =============================================================================

CREATE INDEX idx_fat_mov_srk_rel ON dw.fat_mov(srk_rel);
CREATE INDEX idx_fat_mov_srk_gen ON dw.fat_mov(srk_gen);
CREATE INDEX idx_fat_mov_srk_pft ON dw.fat_mov(srk_pft);
CREATE INDEX idx_fat_mov_srk_eng ON dw.fat_mov(srk_eng);
CREATE INDEX idx_fat_mov_srk_lng ON dw.fat_mov(srk_lng);
CREATE INDEX idx_fat_mov_srk_cmp ON dw.fat_mov(srk_cmp);
CREATE INDEX idx_fat_mov_srk_ctr ON dw.fat_mov(srk_ctr);
CREATE INDEX idx_fat_mov_srk_rte ON dw.fat_mov(srk_rte);

-- =============================================================================
-- COMENTÁRIOS
-- =============================================================================

COMMENT ON TABLE dw.fat_mov IS 'Tabela fato de filmes (Movies) com nomenclatura mnemônica';
COMMENT ON COLUMN dw.fat_mov.srk_ttl IS 'Chave substituta do filme';
COMMENT ON COLUMN dw.fat_mov.ttl IS 'Título do filme';
COMMENT ON COLUMN dw.fat_mov.srk_rel IS 'Chave para dimensão Release (Calendário)';
COMMENT ON COLUMN dw.fat_mov.srk_gen IS 'Chave para dimensão Genres (Gêneros)';
COMMENT ON COLUMN dw.fat_mov.srk_pft IS 'Chave para dimensão Profit (Financeiro)';
COMMENT ON COLUMN dw.fat_mov.srk_eng IS 'Chave para dimensão Engagement (Engajamento)';
COMMENT ON COLUMN dw.fat_mov.srk_lng IS 'Chave para dimensão Language (Idioma)';
COMMENT ON COLUMN dw.fat_mov.srk_cmp IS 'Chave para dimensão Company (Produtora)';
COMMENT ON COLUMN dw.fat_mov.srk_ctr IS 'Chave para dimensão Country (País)';
COMMENT ON COLUMN dw.fat_mov.srk_rte IS 'Chave para dimensão Runtime (Duração)';