WITH dados_limpos AS (
    SELECT * FROM {{ ref('stg_nasa_asteroides') }} -- Referenciando a tabela de asteroides críticos!
)

SELECT
    DATE_TRUNC('month', data_observacao)::date AS mes,
    COUNT(*) AS quantidade_asteroides_criticos
FROM dados_limpos
WHERE nivel_alerta IN ('Crítico', 'Monitorar')
GROUP BY 1
ORDER BY 1