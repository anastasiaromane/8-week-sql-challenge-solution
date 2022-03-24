-- B. Runner and Customer Experience Metrics
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 
-- 2021-01-01)

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

-- 4. What was the average distance travelled for each customer?

-- **** SOLUTION ****
SELECT
    b.customer_id
    , ROUND(AVG(CAST(regexp_replace(a.distance, '[^\d.,]+', '') AS DECIMAL)), 
        1) AS avg_distance
FROM pizza_runner.runner_orders a
    JOIN pizza_runner.customer_orders b ON (a.order_id = b.order_id)
WHERE a.pickup_time <> 'null'
GROUP BY
    b.customer_id
ORDER BY
    b.customer_id

-- 5. What was the difference between the longest and shortest delivery times 
-- for all orders?


-- **** SOLUTION ****
WITH dur AS (
    SELECT
        a.order_id
        , CAST(regexp_replace(a.duration, '[^\d.,]+', '') AS DECIMAL) 
            AS duration
    FROM pizza_runner.runner_orders a
    WHERE a.pickup_time <> 'null'
    ORDER BY
        a.order_id
    ) 
SELECT
    MAX(duration)
    , MIN(duration)
    , MAX(duration) - MIN(duration) AS diff_duration
FROM dur

-- 6. What was the average speed for each runner for each delivery and do you 
-- notice any trend for these values?

-- **** SOLUTION ****
WITH temp AS (
    SELECT
        a.runner_id
        , a.order_id
        , ROUND(CAST(regexp_replace(a.duration, '[^\d.,]+', '') AS DECIMAL) 
            / 60, 2) AS duration
        , CAST(regexp_replace(a.distance, '[^\d.,]+', '') AS DECIMAL)
            AS distance
    FROM pizza_runner.runner_orders a
    WHERE a.pickup_time <> 'null'
    ORDER BY
        a.runner_id
    )
SELECT
    runner_id
    , order_id
    , ROUND(AVG(distance / duration), 0) AS speed
FROM temp
GROUP BY
    runner_id
    , order_id
ORDER BY
    runner_id
    , order_id



-- 7. What is the successful delivery percentage for each runner?

-- **** SOLUTION ****
