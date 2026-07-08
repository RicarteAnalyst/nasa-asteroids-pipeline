WITH source_data AS(
    SELECT 
        nome, 
        diametro_max_km,
        is_perigoso,
        data_observacao
    FROM {{ source('public', 'raw_nasa_asteroides') }}
)

SELECT
    nome AS asteroide_nome,
    ROUND(diametro_max_km::numeric, 2) AS diametro_km,
    CASE 
        WHEN is_perigoso AND diametro_max_km > 0.5 THEN 'Crítico'
        WHEN is_perigoso THEN 'Monitorar'
        ELSE 'Seguro'
    END AS nivel_alerta,
    is_perigoso,
    data_observacao,
    NOW() AS processado_em
FROM source_data
WHERE nome IS NOT NULL