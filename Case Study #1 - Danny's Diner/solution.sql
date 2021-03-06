/* --------------------
   Case Study Questions
   --------------------*/

-- Question #1
-- What is the total amount each customer spent at the restaurant?
SELECT
    a.customer_id
    , sum(b.price)
FROM dannys_diner.sales a
    JOIN dannys_diner.menu b ON a.product_id = b.product_id
GROUP BY
    a.customer_id
ORDER BY
    a.customer_id

-- 2. How many days has each customer visited the restaurant?
SELECT
    a.customer_id
    , count(distinct a.order_date)
FROM dannys_diner.sales a
GROUP BY
    a.customer_id
ORDER BY
    a.customer_id

-- 3. What was the first item from the menu purchased by each customer?

-- **** SOLUTION **** #1
SELECT *
FROM (
    SELECT
        a.customer_id
        , b.product_name
        , DENSE_RANK ( ) OVER (
            PARTITION BY a.customer_id 
            ORDER BY a.order_date ASC) AS date_rank
    FROM dannys_diner.sales a
        JOIN dannys_diner.menu b ON a.product_id = b.product_id
    GROUP BY
        a.customer_id
        , b.product_name
        , a.order_date
    ) temp
WHERE temp.date_rank = 1


-- **** SOLUTION **** #2 with CTE
WITH temp AS (
    SELECT
        a.customer_id
        , b.product_name
        , DENSE_RANK ( ) OVER (
            PARTITION BY a.customer_id 
            ORDER BY a.order_date ASC
            ) AS date_rank
    FROM dannys_diner.sales a
        JOIN dannys_diner.menu b ON a.product_id = b.product_id
    GROUP BY
        a.customer_id
        , b.product_name
        , a.order_date
    )
SELECT *
FROM temp
WHERE temp.date_rank = 1

-- 4. What is the most purchased item on the menu and how many times was it 
-- purchased by all customers?

-- **** SOLUTION **** #1
WITH orders AS (
    SELECT
        b.product_name
        , count(a.order_date) order_count
    FROM dannys_diner.sales a
        JOIN dannys_diner.menu b ON a.product_id = b.product_id
    GROUP BY
        b.product_name
    ),

    ranks AS (
    SELECT
        product_name
        , order_count
    , DENSE_RANK () OVER (ORDER BY order_count DESC) AS order_rank
    FROM orders
    )

SELECT
    product_name
    , order_count
FROM ranks
WHERE order_rank = 1

-- Soluton #2 - simplified
SELECT
    b.product_name
    , count(*)      AS count
FROM dannys_diner.sales a
    JOIN dannys_diner.menu b ON a.product_id = b.product_id
GROUP BY
    b.product_name
ORDER BY count(*) DESC
limit 1

-- 5. Which item was the most popular for each customer?

-- **** SOLUTION ****
WITH ranks AS(
    SELECT
        a.customer_id
        , b.product_name
        , DENSE_RANK () OVER (
            PARTITION BY a.customer_id 
            ORDER BY count(*) DESC)    AS order_rank
    FROM dannys_diner.sales a
        JOIN dannys_diner.menu b ON a.product_id = b.product_id
    GROUP BY
        a.customer_id
        , b.product_name
    )
SELECT 
    customer_id
    , product_name
FROM ranks
WHERE order_rank = 1

-- 6. Which item was purchased first by the customer after they became a 
-- member?

-- **** SOLUTION ****
-- Asumption - Considering the order occured on the day they became a member 
-- (a.order_date >= c.join_date)
WITH ranks AS (
    SELECT
        a.customer_id
        , b.product_name
        , a.order_date
        , c.join_date
        , DENSE_RANK ( ) OVER (
                PARTITION BY a.customer_id 
                ORDER BY a.order_date ASC
                ) AS date_rank
    FROM dannys_diner.sales a
        JOIN dannys_diner.menu b ON a.product_id = b.product_id
        JOIN dannys_diner.members c ON a.customer_id = c.customer_id
    WHERE a.order_date >= c.join_date
    GROUP BY
        a.customer_id
        , b.product_name
        , a.order_date
        , c.join_date
    ORDER BY
        a.customer_id
   )
SELECT
    customer_id
    , product_name
    , order_date
    , join_date
FROM ranks
WHERE date_rank = 1

-- 7. Which item was purchased just before the customer became a member?

-- **** SOLUTION ****
-- Asumption - Not considering the order occured on the day they became a 
-- member (a.order_date < c.join_date)
WITH ranks AS (
    SELECT
        a.customer_id
        , b.product_name
        , a.order_date
        , c.join_date
        , DENSE_RANK ( ) OVER (
                PARTITION BY a.customer_id 
                ORDER BY a.order_date DESC
                ) AS date_rank
    FROM dannys_diner.sales a
        JOIN dannys_diner.menu b ON a.product_id = b.product_id
        JOIN dannys_diner.members c ON a.customer_id = c.customer_id
    WHERE a.order_date < c.join_date
    GROUP BY
        a.customer_id
        , b.product_name
        , a.order_date
        , c.join_date
    ORDER BY
        a.customer_id
   )
SELECT
    customer_id
    , product_name
    , order_date
    , join_date
FROM ranks
WHERE date_rank = 1

-- 8. What is the total items and amount spent for each member before they 
-- became a member?

-- **** SOLUTION ****
-- Asumption - Not considering the order occured on the day they became a 
-- member (a.order_date < c.join_date)
SELECT
    a.customer_id
    , c.join_date
    , count(*)      AS orders
    , sum(price)    AS expenses
FROM dannys_diner.sales a
    JOIN dannys_diner.menu b ON a.product_id = b.product_id
    JOIN dannys_diner.members c ON a.customer_id = c.customer_id
WHERE a.order_date < c.join_date
GROUP BY
    a.customer_id
    , c.join_date
ORDER BY
    a.customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points 
-- multiplier - how many points would each customer have?

-- **** SOLUTION ****
-- Assumption - that the membership applies to the order occured on the day 
-- they became a member (a.order_date >= c.join_date)
SELECT
    a.customer_id
    , sum(b.points)  AS points
FROM dannys_diner.sales a

    JOIN (
        SELECT
            product_id
            , CASE
                WHEN product_id = 1 THEN price * 10 * 2
                ELSE price * 10
            END     AS points
        FROM dannys_diner.menu b
        ) b ON a.product_id = b.product_id

    JOIN dannys_diner.members c ON a.customer_id = c.customer_id

WHERE a.order_date >= c.join_date
GROUP BY
    a.customer_id
ORDER BY
    a.customer_id

-- 10. In the first week after a customer joins the program (including their 
-- join date) they earn 2x points on all items, not just sushi - how many 
-- points do customer A and B have at the end of January?

-- **** SOLUTION ****
-- Asumption - the first week equals 7 days where the first day is the join 
-- date, so to find the end day of the first week - c.join_date + 6
SELECT
    a.customer_id
    , SUM(CASE
          WHEN (b.product_id = 1)
            OR (a.order_date <= (c.join_date + 6))
            THEN price * 10 * 2
          ELSE price * 10
      END)     AS points
FROM dannys_diner.sales a

    JOIN dannys_diner.menu b ON a.product_id = b.product_id

    JOIN dannys_diner.members c ON a.customer_id = c.customer_id

WHERE 
    a.order_date <= '2021-01-31'
    AND a.order_date >= c.join_date
    
GROUP BY
    a.customer_id
ORDER BY
    a.customer_id
