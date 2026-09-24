SELECT
    filial,
    TO_CHAR(dt_ref, 'YYYY-MM') AS mes_ano,
    SUM(valor) AS faturamento_total,
    SUM(comissao_bruta) AS comissao_total,
    ROUND((SUM(comissao_bruta)::NUMERIC / NULLIF(SUM(valor), 0)) * 100, 2) AS margem_pct
FROM producao
GROUP BY filial, TO_CHAR(dt_ref, 'YYYY-MM')
ORDER BY filial, mes_ano;

WITH faturamento_mensal AS (
    SELECT
        filial,
        TO_CHAR(dt_ref, 'YYYY-MM') AS mes_ano,
        SUM(valor) AS faturamento
    FROM producao
    GROUP BY filial, TO_CHAR(dt_ref, 'YYYY-MM')
)
SELECT
    filial,
    mes_ano,
    faturamento,
    LAG(faturamento) OVER (PARTITION BY filial ORDER BY mes_ano) AS faturamento_mes_anterior,
    ROUND(
        ((faturamento - LAG(faturamento) OVER (PARTITION BY filial ORDER BY mes_ano))::NUMERIC
        / NULLIF(LAG(faturamento) OVER (PARTITION BY filial ORDER BY mes_ano), 0)) * 100,
        2
    ) AS crescimento_mom_pct
FROM faturamento_mensal
ORDER BY filial, mes_ano;

SELECT
    filial,
    SUM(comissao_bruta) AS comissao_total,
    SUM(custo) AS custo_total,
    SUM(comissao_bruta - custo) AS lucro_bruto,
    ROUND(
        (SUM(comissao_bruta - custo)::NUMERIC / NULLIF(SUM(comissao_bruta), 0)) * 100,
        2
    ) AS margem_liquida_pct
FROM producao
GROUP BY filial
ORDER BY lucro_bruto DESC;

WITH faturamento_assessor AS (
    SELECT
        filial,
        assessor,
        SUM(valor) AS faturamento_assessor,
        ROW_NUMBER() OVER (PARTITION BY filial ORDER BY SUM(valor) DESC) AS ranking
    FROM producao
    GROUP BY filial, assessor
),
faturamento_total_filial AS (
    SELECT
        filial,
        SUM(valor) AS faturamento_filial
    FROM producao
    GROUP BY filial
)
SELECT
    a.filial,
    a.assessor AS top_1_assessor,
    a.faturamento_assessor,
    t.faturamento_filial,
    ROUND((a.faturamento_assessor::NUMERIC / t.faturamento_filial) * 100, 2) AS concentracao_top1_pct
FROM faturamento_assessor a
JOIN faturamento_total_filial t ON a.filial = t.filial
WHERE a.ranking = 1;
