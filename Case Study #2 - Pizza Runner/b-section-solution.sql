-- B. Runner and Customer Experience Metrics
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

-- 2. What was the average time in minutes it took for each runner to arrive at 
-- the Pizza Runner HQ to pickup the order?

-- **** SOLUTION ****
SELECT
    a.runner_id
    , AVG(EXTRACT('minutes' FROM TO_TIMESTAMP(a.pickup_time,
        'YYYY-MM-DD hh24:mi:ss') - b.order_time)) AS avg_pickup_time
FROM pizza_runner.runner_orders a
    JOIN pizza_runner.customer_orders b ON (a.order_id = b.order_id)
WHERE a.pickup_time <> 'null'
GROUP BY
    a.runner_id
ORDER BY
    a.runner_id

-- 3. Is there any relationship between the number of pizzas and how long the 
-- order takes to prepare?

-- **** SOLUTION ****
SELECT
    a.order_id
    , count(a.pizza_id)
    , SUM(EXTRACT('minutes' FROM TO_TIMESTAMP(b.pickup_time,
        'YYYY-MM-DD hh24:mi:ss') - a.order_time)) AS prep_time
FROM pizza_runner.customer_orders  a
    JOIN pizza_runner.runner_orders b ON (a.order_id = b.order_id)
WHERE b.pickup_time <> 'null'
GROUP BY
    a.order_id
ORDER BY
    prep_time DESC

-- What was the average distance travelled for each customer?
-- What was the difference between the longest and shortest delivery times for all orders?
-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- What is the successful delivery percentage for each runner?

