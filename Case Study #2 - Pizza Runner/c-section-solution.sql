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


-- What was the most commonly added extra?
-- What was the most common exclusion?
-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?