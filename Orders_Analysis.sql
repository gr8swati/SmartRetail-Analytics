use master;
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(50),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_id VARCHAR(50),
    quantity INT,
    discount FLOAT,
    sale_price FLOAT,
    profit FLOAT
);


select *
from orders;


--find top 10 highest reveue generating products 
SELECT TOP 10 
    product_id,
    SUM(sale_price) AS sales
FROM 
    orders
GROUP BY 
    product_id
ORDER BY 
    sales DESC;

--find top 5 highest selling products in each region
WITH cte AS (
    SELECT 
        region,
        product_id,
        SUM(sale_price) AS sales
    FROM 
        orders
    GROUP BY 
        region,
        product_id
)
SELECT 
    region,
    product_id,
    sales,
	rn
FROM (
    SELECT 
        region,
        product_id,
        sales,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
    FROM 
        cte
) AS A
WHERE rn <= 5
ORDER BY region, rn;


--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023 
WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM 
        orders
    GROUP BY 
        YEAR(order_date),
        MONTH(order_date)
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM 
    cte 
WHERE 
    order_year IN (2022, 2023)
GROUP BY 
    order_month
ORDER BY 
    order_month;

--for each category which month had highest sales 
WITH cte AS (
    SELECT 
        category,
        FORMAT(order_date, 'yyyyMM') AS order_year_month,
        SUM(sale_price) AS sales 
    FROM 
        orders
    GROUP BY 
        category,
        FORMAT(order_date, 'yyyyMM')
)
SELECT 
    category,
    order_year_month,
    sales
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
    FROM 
        cte
) AS a
WHERE rn = 1
ORDER BY category;


-- 234245

WITH cte AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM 
        orders
    GROUP BY 
        sub_category,
        YEAR(order_date)
),
cte2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM 
        cte 
    GROUP BY 
        sub_category
)
SELECT TOP 1 
    *,
    (sales_2023 - sales_2022) AS profit_growth
FROM  
    cte2
ORDER BY 
    profit_growth DESC;
