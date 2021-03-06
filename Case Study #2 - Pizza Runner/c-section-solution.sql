-- C. Ingredient Optimisation
-- 1. What are the standard ingredients for each pizza?
WITH ingredients AS (
    SELECT
        pizza_id
       , CAST(UNNEST(STRING_TO_ARRAY(toppings, ',' )) AS INTEGER) AS topping_id
    FROM pizza_runner.pizza_recipes
    ),

  ranks AS (
    SELECT
        a.topping_id
        , b.topping_name
        , DENSE_RANK() OVER (ORDER BY COUNT(a.topping_id) DESC) AS topping_rank
    FROM ingredients a
        JOIN pizza_runner.pizza_toppings b ON (a.topping_id = b.topping_id)
    GROUP BY
        a.topping_id
        , b.topping_name
    )

SELECT
    topping_id
    , topping_name
FROM ranks
WHERE topping_rank = 1


-- 2. What was the most commonly added extra?
WITH extras AS (
    SELECT
        CAST(UNNEST(STRING_TO_ARRAY(COALESCE(REPLACE(extras, 'null' , ''),''),
            ',' )) AS INTEGER) AS extra_id
    FROM pizza_runner.customer_orders
    ),

    ranks AS (
    SELECT
        a.extra_id
        , b.topping_name
        , DENSE_RANK() OVER (ORDER BY COUNT(a.extra_id) DESC) AS rank
    FROM extras a
        JOIN pizza_runner.pizza_toppings b ON (a.extra_id = b.topping_id)
    GROUP BY
        a.extra_id
        , b.topping_name
    )

SELECT
    extra_id
    , topping_name
FROM ranks
WHERE rank = 1

-- 3. What was the most common exclusion?
WITH exclusions AS (
    SELECT
        CAST(UNNEST(STRING_TO_ARRAY(COALESCE(REPLACE(exclusions, 'null' , ''),
            ''),',' )) AS INTEGER) AS exclusion_id
    FROM pizza_runner.customer_orders
  ),

    ranks AS (
    SELECT
        a.exclusion_id
        , b.topping_name
        , DENSE_RANK() OVER (ORDER BY COUNT(a.exclusion_id) DESC) AS rank
    FROM exclusions a
        JOIN pizza_runner.pizza_toppings b ON (a.exclusion_id = b.topping_id)
    GROUP BY
        a.exclusion_id
        , b.topping_name
    )

SELECT
   exclusion_id
   , topping_name
FROM ranks
WHERE rank = 1

-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?