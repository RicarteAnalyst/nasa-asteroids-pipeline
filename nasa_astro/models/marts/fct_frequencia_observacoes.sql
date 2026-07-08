-- models/marts/fct_frequencia_observacoes.sql

WITH dados_brutos AS (
    -- Puxa direto da fonte do banco, antes de qualquer remoção de duplicadas
    SELECT 
        nome,
        data_observacao
    FROM {{ source('public', 'raw_nasa_asteroides') }}
    WHERE nome IS NOT NULL
)

SELECT
    nome AS asteroide_nome,
    COUNT(*) AS total_observacoes,                     -- Quantas vezes ele apareceu
    MIN(data_observacao)::date AS primeira_observacao, -- A primeira vez que a NASA o viu
    MAX(data_observacao)::date AS ultima_observacao    -- A última aparição registrada
FROM dados_brutos
GROUP BY 1
ORDER BY total_observacoes DESC -- O topo da lista será o asteroide mais "frequentador"