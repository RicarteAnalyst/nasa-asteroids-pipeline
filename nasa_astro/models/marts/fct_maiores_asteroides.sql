WITH dados_limpos AS (
    SELECT * FROM {{ ref('stg_nasa_asteroides') }}
),

ranking_por_alerta AS (
    SELECT
        asteroide_nome,
        nivel_alerta,
        diametro_km,
        data_observacao,
        ROW_NUMBER() OVER (PARTITION BY nivel_alerta ORDER BY diametro_km DESC) as posicao_no_ranking
    FROM dados_limpos
    WHERE diametro_km IS NOT NULL
)

SELECT * FROM ranking_por_alerta
WHERE posicao_no_ranking <= 5 -- Traz os 5 maiores de cada nível de alerta
ORDER BY nivel_alerta, posicao_no_ranking