WITH staging_data AS (
    SELECT 
        asteroide_nome,
        diametro_km,
        nivel_alerta,
        data_observacao
    FROM {{ ref('stg_nasa_asteroides') }} -- Aqui está o segredo: referenciando a sua staging!
)

SELECT
    asteroide_nome,
    diametro_km,
    nivel_alerta,
    data_observacao
FROM staging_data
WHERE nivel_alerta IN ('Crítico', 'Monitorar')