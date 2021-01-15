WITH CTE AS 
(
    SELECT DISTINCT tube_assembly_id, component_id, CAST(quantity AS NUMERIC) AS quantity
    FROM `gcp-boavista-737.raw.bill_of_materials`, 
    UNNEST
    ([
        NULLIF(quantity_1, 'NA'),
        NULLIF(quantity_2, 'NA'),
        NULLIF(quantity_3, 'NA'),
        NULLIF(quantity_4, 'NA'),
        NULLIF(quantity_5, 'NA'),
        NULLIF(quantity_6, 'NA'),
        NULLIF(quantity_7, 'NA'),
        NULLIF(quantity_8, 'NA')
    ]) AS quantity, 
    UNNEST
    ([
        NULLIF(component_id_1, 'NA'),
        NULLIF(component_id_2, 'NA'),
        NULLIF(component_id_3, 'NA'),
        NULLIF(component_id_4, 'NA'),
        NULLIF(component_id_5, 'NA'),
        NULLIF(component_id_6, 'NA'),
        NULLIF(component_id_7, 'NA'),
        NULLIF(component_id_8, 'NA')
    ]) AS component_id
    WHERE component_id IS NOT NULL AND quantity IS NOT NULL
)
SELECT tube_assembly_id, component_id, SUM(quantity) AS quantity
FROM CTE 
GROUP BY tube_assembly_id, component_id
HAVING quantity > 0
ORDER BY quantity DESC