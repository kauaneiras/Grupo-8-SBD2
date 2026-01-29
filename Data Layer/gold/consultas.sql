-- Consulta 1: Listar os 20 filmes com maior receita, incluindo título, data de lançamento, orçamento, lucro e ROI
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

-- Consulta 2: Listar os 50 filmes mais recentes com suas receitas
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