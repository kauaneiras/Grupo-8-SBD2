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
FROM dw.fat_mov f
JOIN dw.dim_pft p ON p.srk_pft = f.srk_pft
LEFT JOIN dw.dim_rel d ON d.srk_rel = f.srk_rel
ORDER BY p.rev DESC NULLS LAST
LIMIT 20;

-- =============================================================================
-- Consulta 2: Listar os 50 filmes populares
-- =============================================================================
SELECT
    f.srk_ttl AS id_filme,
    f.ttl AS titulo,
    f.org_ttl AS titulo_original,
    f.crt AS criado_em,
    e.vot_avg  AS nota_media,
    e.vot_cnt  AS qtd_votos,
    e.pop      AS popularidade
FROM dw.fat_mov AS f
LEFT JOIN dw.dim_eng AS e
       ON f.srk_eng = e.srk_eng
ORDER BY e.pop DESC NULLS LAST
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

-- =============================================================================
-- Consulta 6: Filme mais lucrativo por gênero
-- =============================================================================
WITH filmes_rankeados_por_genero AS (
    SELECT 
        g.gen AS genero,
        f.ttl AS titulo_filme,
        p.pft AS lucro,
        ROW_NUMBER() OVER(
            PARTITION BY g.gen
            ORDER BY p.pft DESC
        ) AS ranking
    FROM dw.fat_mov f
    JOIN dw.dim_gen g ON f.srk_gen = g.srk_gen
    JOIN dw.dim_pft p ON f.srk_pft = p.srk_pft
    WHERE p.pft IS NOT NULL AND p.pft > 0
)
SELECT 
    genero,
    titulo_filme,
    lucro
FROM filmes_rankeados_por_genero
WHERE ranking = 1
ORDER BY lucro DESC;

-- =============================================================================
-- Consulta 7 (CTE): Produtora com maior lucro médio por gênero
-- =============================================================================

WITH metricas_por_produtora AS (
    -- Calcular a média por Gênero e Produtora
    SELECT 
        g.gen AS genero,
        c.prd_cmp AS produtora,
        AVG(p.pft) AS lucro_medio,
        COUNT(f.srk_ttl) AS qtd_filmes
    FROM dw.fat_mov f
    JOIN dw.dim_gen g ON f.srk_gen = g.srk_gen
    JOIN dw.dim_cmp c ON f.srk_cmp = c.srk_cmp
    JOIN dw.dim_pft p ON f.srk_pft = p.srk_pft
    WHERE p.pft IS NOT NULL 
    GROUP BY g.gen, c.prd_cmp
    HAVING COUNT(f.srk_ttl) >= 3 -- Ao menos 3 filmes para ignorar casos a parte
),
ranking_dominancia AS (
    -- Rankear quem tem a melhor média dentro de cada gênero
    SELECT 
        genero,
        produtora,
        lucro_medio,
        qtd_filmes,
        ROW_NUMBER() OVER(
            PARTITION BY genero 
            ORDER BY lucro_medio DESC
        ) AS ranking
    FROM metricas_por_produtora
)
SELECT 
    genero,
    produtora,
    ROUND(lucro_medio, 2) AS media_lucro,
    qtd_filmes
FROM ranking_dominancia
WHERE ranking = 1
ORDER BY lucro_medio DESC;

-- =============================================================================
-- Consulta 8: Nota média por gênero
-- =============================================================================

SELECT 
    g.gen AS genero,
    ROUND(AVG(e.vot_avg)::NUMERIC, 2) AS nota_media,
    COUNT(f.srk_ttl) AS qtd_filmes
FROM dw.dim_gen g
LEFT JOIN dw.fat_mov f ON g.srk_gen = f.srk_gen
LEFT JOIN dw.dim_eng e ON f.srk_eng = e.srk_eng
WHERE e.vot_avg IS NOT NULL
GROUP BY g.gen
ORDER BY nota_media DESC;

-- =============================================================================
-- Consulta 9: Contagem de filmes por gênero
-- =============================================================================

SELECT 
    g.gen AS genero,
    COUNT(f.srk_ttl) AS total_filmes
FROM dw.dim_gen g
LEFT JOIN dw.fat_mov f ON g.srk_gen = f.srk_gen
GROUP BY g.gen
ORDER BY total_filmes DESC;

-- =============================================================================
-- Consulta 10: Análise de Duração x Popularidade (Engajamento)
-- =============================================================================
SELECT 
    CASE 
        WHEN rt.rte < 90 THEN '1. Curto (< 90 min)'
        WHEN rt.rte BETWEEN 90 AND 120 THEN '2. Padrão (90-120 min)'
        WHEN rt.rte BETWEEN 121 AND 150 THEN '3. Longo (121-150 min)'
        WHEN rt.rte > 150 THEN '4. Épico (> 150 min)'
        ELSE 'Desconhecido'
    END AS faixa_duracao,
    
    COUNT(f.srk_ttl) AS qtd_filmes_amostra,
    ROUND(AVG(e.pop)::NUMERIC, 2) AS popularidade_media,
    ROUND(AVG(e.vot_avg)::NUMERIC, 2) AS nota_media,
   
FROM dw.fat_mov f
INNER JOIN dw.dim_rte rt ON f.srk_rte = rt.srk_rte
INNER JOIN dw.dim_eng e ON f.srk_eng = e.srk_eng
LEFT JOIN dw.dim_pft p ON f.srk_pft = p.srk_pft
WHERE rt.rte > 0
GROUP BY 1
ORDER BY popularidade_media DESC;


-- =============================================================================
-- Consulta 11: Risco e Retorno por Faixa Orçamentária (Budget Tier)
-- =============================================================================
SELECT 
    p.bdg_tir AS faixa_orcamento,
    COUNT(f.srk_ttl) AS qtd_filmes_analisados,
    
    -- Retorno Médio sobre Investimento 
    ROUND(AVG(p.ret_inv)::NUMERIC, 2) AS roi_medio_percentual,
    ROUND(AVG(p.pft) / 1e6, 2) AS lucro_liquido_medio_milhoes,
    ROUND(
        (COUNT(CASE WHEN p.pfe = TRUE THEN 1 END)::NUMERIC / COUNT(*)) * 100, 
    2) AS probabilidade_sucesso_pct,
    ROUND(AVG(p.bdg) / 1e6, 2) AS custo_medio_milhoes
FROM dw.fat_mov f
INNER JOIN dw.dim_pft p ON f.srk_pft = p.srk_pft
WHERE p.bdg > 0 
GROUP BY p.bdg_tir
HAVING COUNT(f.srk_ttl) > 50 
ORDER BY roi_medio_percentual DESC;

-- =============================================================================
-- Consulta 12 (CTE): Sazonalidade de Retorno (Melhor mês para lançar)
-- =============================================================================
WITH performance_mensal AS (
    -- Calcular métricas agregadas por mês
    SELECT 
        r.rel_mon AS numero_mes,
        r.rel_mon_nam AS mes_lancamento,
        COUNT(f.srk_ttl) AS volume_lancamentos,
        AVG(p.rev) AS receita_media_raw,
        AVG(p.ret_inv) AS roi_medio_raw
    FROM dw.fat_mov f
    INNER JOIN dw.dim_rel r ON f.srk_rel = r.srk_rel
    INNER JOIN dw.dim_pft p ON f.srk_pft = p.srk_pft
    WHERE p.bdg > 1000000 
    GROUP BY r.rel_mon, r.rel_mon_nam
),
ranking_sazonalidade AS (
    SELECT 
        numero_mes,
        mes_lancamento,
        volume_lancamentos,
        ROUND(receita_media_raw / 1e6, 2) AS receita_media_milhoes,
        ROUND(roi_medio_raw::NUMERIC, 2) AS roi_medio,
        -- Ranking baseado no ROI (1 = Melhor mês)
        RANK() OVER (ORDER BY roi_medio_raw DESC) AS rank_atratividade
    FROM performance_mensal
)
SELECT 
    numero_mes,
    mes_lancamento,
    volume_lancamentos,
    receita_media_milhoes,
    roi_medio,
    rank_atratividade
FROM ranking_sazonalidade
ORDER BY rank_atratividade;