WITH fact_non_bracket_pricing AS
(
    SELECT 
      tube_assembly_id, 
      supplier, 
      quote_date AS date, 
      SUM(cost) AS unit_cost,
      SUM(min_order_quantity) AS min_order,
      SUM(annual_usage) AS annual_usage,
      SUM(quantity) AS qty_purchased,
      SUM(quantity) * SUM(cost) AS total_cost
    FROM `<schema_aqui>.raw.price_quote`
    WHERE  bracket_pricing = "No"
    GROUP BY tube_assembly_id, supplier, quote_date, bracket_pricing
),
calendar AS 
(
    SELECT
      date,
      EXTRACT(YEAR FROM date) AS year,
      EXTRACT(MONTH FROM date) AS month,
      FORMAT_DATE('%B', date) AS month_name
    FROM UNNEST(GENERATE_DATE_ARRAY('2000-01-01', current_date())) AS date
)
SELECT f.*, c.year, c.month, c.month_name,
      CASE WHEN qty_purchased < min_order THEN 'No' ELSE 'Yes' END AS non_bracket_pricing_rule_satisfied, 
FROM fact_non_bracket_pricing f
JOIN calendar c ON f.date = c.date
ORDER BY tube_assembly_id