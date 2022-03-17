-- A. Pizza Metrics
-- 1. How many pizzas were ordered?

-- **** SOLUTION ****
SELECT 
COUNT(a.pizza_id)      AS pizzas_ordered
FROM pizza_runner.customer_orders a

-- 2. How many unique customer orders were made?

-- **** SOLUTION ****
SELECT 
COUNT(DISTINCT a.customer_id)   AS customers
FROM pizza_runner.customer_orders a

-- 3. How many successful orders were delivered by each runner?

-- **** SOLUTION ****
SELECT
    a.runner_id,
    COUNT(DISTINCT a.order_id)      AS orders
FROM pizza_runner.runner_orders a
WHERE COALESCE(a.cancellation, 'null') NOT IN ('Restaurant Cancellation',
    'Customer Cancellation')
GROUP BY
    a.runner_id
ORDER BY
    a.runner_id

-- 4. How many of each type of pizza was delivered?

-- **** SOLUTION ****
SELECT 
    b.pizza_id
    , b.pizza_name
    , COUNT(a.order_id)      AS orders
FROM pizza_runner.customer_orders a
    JOIN pizza_runner.pizza_names b ON (a.pizza_id = b.pizza_id)
GROUP BY
    b.pizza_id
    , b.pizza_name

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

-- **** SOLUTION ****
SELECT 
    a.customer_id
    , b.pizza_name
    , COUNT(a.order_id)      AS orders
FROM pizza_runner.customer_orders a
    JOIN pizza_runner.pizza_names b ON (a.pizza_id = b.pizza_id)
GROUP BY
    a.customer_id
    , b.pizza_name
ORDER BY
    a.customer_id

-- **** ALTERNATIVE SOLUTION ****
-- to store counts in columns
SELECT 
    a.customer_id
    , COUNT(CASE 
                WHEN  b.pizza_id = 1 
                THEN a.order_id
           END)      AS count_meatlovers
     , COUNT(CASE 
                WHEN  b.pizza_id = 2 
                THEN a.order_id
           END)      AS count_vegetarian
FROM pizza_runner.customer_orders a
    JOIN pizza_runner.pizza_names b ON (a.pizza_id = b.pizza_id)
GROUP BY
    a.customer_id
ORDER BY
    a.customer_id

-- 6. What was the maximum number of pizzas delivered in a single order?

-- **** SOLUTION ****
SELECT 
    a.order_id
    , COUNT(a.pizza_id) AS pizzas
FROM pizza_runner.customer_orders a
GROUP BY
    a.order_id
ORDER BY 
    COUNT(a.pizza_id) DESC
limit 1


-- **** ALTERNATIVE SOLUTION ****
-- to use DENSE_RANK
WITH ranks AS (
    SELECT 
        a.order_id
        , COUNT(a.pizza_id) AS pizzas
        , DENSE_RANK() OVER (ORDER BY COUNT(a.pizza_id) DESC) AS pizza_rank
FROM pizza_runner.customer_orders a
GROUP BY
    a.order_id
    )
SELECT
    order_id
    , pizzas
    , pizza_rank
FROM ranks
WHERE ranks.pizza_rank = 1


-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- How many pizzas were delivered that had both exclusions and extras?
-- What was the total volume of pizzas ordered for each hour of the day?
-- What was the volume of orders for each day of the week?

