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

-- How many of each type of pizza was delivered?

-- **** SOLUTION ****


-- How many Vegetarian and Meatlovers were ordered by each customer?
-- What was the maximum number of pizzas delivered in a single order?
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- How many pizzas were delivered that had both exclusions and extras?
-- What was the total volume of pizzas ordered for each hour of the day?
-- What was the volume of orders for each day of the week?

