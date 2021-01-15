WITH fact_bracket_pricing AS
(
    SELECT 
      tube_assembly_id, 
      supplier, 
      quote_date AS date, 
      SUM(cost) AS unit_cost,
      SUM(quantity) AS qty_purchased,
      SUM(quantity) * SUM(cost) AS total_cost
    FROM `gcp-boavista-737.raw.price_quote`
    WHERE  bracket_pricing = "Yes"
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
SELECT f.*, c.year, c.month, c.month_name
FROM fact_bracket_pricing f
JOIN calendar c ON f.date = c.date