-- =============================================================================
-- CONSULTAS SQL OTIMIZADAS PARA POWER BI - Camada Gold
-- Projeto: Grupo-8-SBD2
-- =============================================================================

-- =============================================================================
-- Consulta 1: Listar os 20 filmes com maior receita, incluindo título, data de lançamento, orçamento, lucro e ROI
-- =============================================================================
SELECT
  f.srk_ttl,
  f.ttl AS titulo,
  d.rel_dat AS data_lancamento,
  p.rev AS receita,
  p.bdg AS orcamento,
  p.pft AS lucro,
  p.ret_inv AS roi
FROM gold.fat_mov f
JOIN gold.dim_pft p ON p.srk_pft = f.srk_pft
LEFT JOIN gold.dim_rel d ON d.srk_rel = f.srk_rel
ORDER BY p.rev DESC NULLS LAST
LIMIT 20;

-- =============================================================================
-- Consulta 2: Listar os 50 filmes mais recentes com suas receitas
-- =============================================================================
SELECT
  f.srk_ttl,
  f.ttl AS titulo,
  f.crt AS created_at,
  d.rel_dat AS data_lancamento,
  p.rev AS receita
FROM gold.fat_mov f
LEFT JOIN gold.dim_rel d ON d.srk_rel = f.srk_rel
LEFT JOIN gold.dim_pft p ON p.srk_pft = f.srk_pft
ORDER BY f.crt DESC NULLS LAST
LIMIT 50;

-- =============================================================================
-- Consulta 3: KPIs Executivos
-- =============================================================================
SELECT 
    COUNT(DISTINCT f.srk_ttl) AS total_filmes,
    ROUND(SUM(p.rev) / 1e12, 2) AS receita_total_trilhoes,
    ROUND(SUM(p.pft) / 1e12, 2) AS lucro_total_trilhoes,
    ROUND(AVG(e.vot_avg)::NUMERIC, 2) AS nota_media_geral,
    ROUND(SUM(e.vot_cnt) / 1e6, 1) AS total_votos_milhoes,
    ROUND(AVG(CASE WHEN p.bdg > 0 THEN p.ret_inv END)::NUMERIC, 0) AS roi_medio_percentual,
    ROUND(
        (COUNT(CASE WHEN p.pfe = TRUE THEN 1 END)::NUMERIC / 
         NULLIF(COUNT(CASE WHEN p.bdg > 0 THEN 1 END), 0)) * 100, 1
    ) AS taxa_sucesso_percentual,
    MAX(r.rel_yer) - MIN(r.rel_yer) AS anos_de_historia,
    MIN(r.rel_yer) AS primeiro_ano,
    MAX(r.rel_yer) AS ultimo_ano
FROM dw.fat_mov f
LEFT JOIN dw.dim_pft p ON f.srk_pft = p.srk_pft
LEFT JOIN dw.dim_eng e ON f.srk_eng = e.srk_eng
LEFT JOIN dw.dim_rel r ON f.srk_rel = r.srk_rel;

-- =============================================================================
-- Consulta 4 (CTE): Comparativo de Performance por País
-- =============================================================================

WITH metricas_por_pais AS (
    -- Calcula métricas agregadas por país de produção
    SELECT 
        ct.prd_ctr AS pais,
        COUNT(f.srk_ttl) AS total_filmes,
        SUM(p.rev) AS receita_total,
        SUM(p.pft) AS lucro_total,
        ROUND(AVG(e.vot_avg)::NUMERIC, 2) AS nota_media,
        ROUND(AVG(p.ret_inv)::NUMERIC, 2) AS roi_medio
    FROM dw.fat_mov f
    INNER JOIN dw.dim_ctr ct ON f.srk_ctr = ct.srk_ctr
    INNER JOIN dw.dim_pft p ON f.srk_pft = p.srk_pft
    LEFT JOIN dw.dim_eng e ON f.srk_eng = e.srk_eng
    WHERE ct.prd_ctr IS NOT NULL
      AND p.rev > 0
    GROUP BY ct.prd_ctr
    HAVING COUNT(f.srk_ttl) >= 50
)
SELECT 
    pais,
    total_filmes,
    ROUND(receita_total / 1e9, 2) AS receita_bilhoes,
    ROUND(lucro_total / 1e9, 2) AS lucro_bilhoes,
    nota_media,
    roi_medio,
    ROUND((receita_total::NUMERIC / SUM(receita_total) OVER ()) * 100, 2) AS market_share_pct,
    RANK() OVER (ORDER BY receita_total DESC) AS ranking_receita
FROM metricas_por_pais
ORDER BY receita_total DESC
LIMIT 15;

-- =============================================================================
-- Consulta 5 (CTE): Top 5 Gêneros Mais Lucrativos por Década
-- =============================================================================
WITH lucro_por_genero_decada AS (
    -- Agrupa métricas financeiras por gênero e década
    SELECT 
        r.rel_dec AS decada,
        g.gen AS genero,
        COUNT(f.srk_ttl) AS total_filmes,
        SUM(p.pft) AS lucro_total,
        SUM(p.rev) AS receita_total,
        ROUND(AVG(e.vot_avg)::NUMERIC, 2) AS nota_media,
        ROUND(AVG(p.ret_inv)::NUMERIC, 2) AS roi_medio
    FROM dw.fat_mov f
    INNER JOIN dw.dim_rel r ON f.srk_rel = r.srk_rel
    INNER JOIN dw.dim_gen g ON f.srk_gen = g.srk_gen
    INNER JOIN dw.dim_pft p ON f.srk_pft = p.srk_pft
    LEFT JOIN dw.dim_eng e ON f.srk_eng = e.srk_eng
    WHERE r.rel_dec >= 1980
      AND g.gen IS NOT NULL
      AND p.pft > 0
    GROUP BY r.rel_dec, g.gen
),
ranking_generos AS (
    -- Aplica ranking dos gêneros mais lucrativos por década
    SELECT 
        decada,
        genero,
        total_filmes,
        ROUND(lucro_total / 1e9, 2) AS lucro_bilhoes,
        ROUND(receita_total / 1e9, 2) AS receita_bilhoes,
        nota_media,
        roi_medio,
        RANK() OVER (PARTITION BY decada ORDER BY lucro_total DESC) AS ranking_decada
    FROM lucro_por_genero_decada
)
SELECT 
    decada,
    genero,
    total_filmes,
    lucro_bilhoes,
    receita_bilhoes,
    nota_media,
    roi_medio,
    ranking_decada
FROM ranking_generos
WHERE ranking_decada <= 5
ORDER BY decada DESC, ranking_decada;