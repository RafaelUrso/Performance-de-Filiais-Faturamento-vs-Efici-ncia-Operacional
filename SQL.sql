SELECT
    filial, *seleciona a coluna filial*
    TO_CHAR(dt_ref, 'YYYY-MM') AS mes_ano, *altera todos os números para char e ano/mes*
    SUM(valor) AS faturamento_total, *soma o faturamneto*
    SUM(comissao_bruta) AS comissao_total, *soma a comissao*
    ROUND((SUM(comissao_bruta)::NUMERIC / NULLIF(SUM(valor), 0)) * 100, 2) AS margem_pct *converte para o tipo numerico. NULLiF evita que dê erro caso a divisão seja por 0.*
FROM producao *entra na tabela producao*
GROUP BY filial, TO_CHAR(dt_ref, 'YYYY-MM') *junta as linhas que pertencem a mesma filial e ano.*
ORDER BY filial, mes_ano; *Define a ordem dos resultados.*

WITH faturamento_mensal AS ( *cria uma tabela temporária dentro da consulta.*
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
    LAG(faturamento) OVER (PARTITION BY filial ORDER BY mes_ano) AS faturamento_mes_anterior, *LAG pega o valor da linha anterior. PARTITION BY filial isso faz o lag funcionar separadamente para cada filial. ORDER BY significa o que significa o anterior, no caso mes_ano*
    ROUND(
        ((faturamento - LAG(faturamento) OVER (PARTITION BY filial ORDER BY mes_ano))::NUMERIC
        / NULLIF(LAG(faturamento) OVER (PARTITION BY filial ORDER BY mes_ano), 0)) * 100,
        2 *aqui temos uma conta básica (faturamento atual − faturamento anterior) ÷ faturamento anterior × 100*
    ) AS crescimento_mom_pct
FROM faturamento_mensal
ORDER BY filial, mes_ano;

*"Para cada filial, mês a mês, quanto foi o faturamento, quanto foi o faturamento do mês anterior e qual foi o percentual de crescimento ou queda em relação ao mês anterior?"*

SELECT
    filial, +seleciona a coluna filial*
    SUM(comissao_bruta) AS comissao_total,
    SUM(custo) AS custo_total,
    SUM(comissao_bruta - custo) AS lucro_bruto, *somas e somas...*
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
        ROW_NUMBER() OVER (PARTITION BY filial ORDER BY SUM(valor) DESC) AS ranking *ROW_NUMBER adiciona um número a cada assesor. ORDER BY ordena o faturamento de forma descrescente. PARTITIO
        BY filial, Faça esse ranking separadamente para cada filial.*
    FROM producao
    GROUP BY filial, assessor *agrupa por filial mais acessor*
),
faturamento_total_filial AS (
    SELECT
        filial,
        SUM(valor) AS faturamento_filial
    FROM producao
    GROUP BY filial *todo essse with basicamente pergunta quanto essa filial faturou.*
)
SELECT
    a.filial, *basicamente aqui até o t estamos criando uma tabela de A a T.*
    a.assessor AS top_1_assessor,
    a.faturamento_assessor,
    t.faturamento_filial,
    ROUND((a.faturamento_assessor::NUMERIC / t.faturamento_filial) * 100, 2) AS concentracao_top1_pct *faturamento do maior acessor dividido pela maior filial * 100
FROM faturamento_assessor a
JOIN faturamento_total_filial t ON a.filial = t.filial *aqui ele junta as informações e o ON diz onde será feita a ligação.*
WHERE a.ranking = 1; *Isso elimina todos os assessores que não são o primeiro colocado.*
