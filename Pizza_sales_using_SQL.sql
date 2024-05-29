--Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

----------------------------------------------------------------------------
-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS total_sales
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id;

----------------------------------------------------------------------------

-- Identify the highest-priced pizza.
SELECT 
    pt.`name`, p.price AS highest_priced_pizza
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY 2 DESC
LIMIT 1;

---------------------------------------------------------------------------

-- Identify the most common pizza size ordered.
SELECT 
    p.size AS pizza_size,
    COUNT(od.order_details_id) AS order_count
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-------------------------------------------------------------------------

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.`name` AS pizza_type,
    SUM(od.quantity) AS quantity_ordered
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-----------------------------------------------------------------------

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity)
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY 1
ORDER BY 2;

----------------------------------------------------------------------


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY 1
order by 1;

---------------------------------------------------------------------

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(pizza_type_id)
FROM
    pizza_types
GROUP BY 1;

---------------------------------------------------------------------

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(order_quantity),0) as average_order_per_day from
(SELECT 
    order_date, sum(od.quantity) as order_quantity
FROM
    orders o join order_details od on o.order_id=od.order_id
GROUP BY 1) as order_data;

---------------------------------------------------------------------

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.`name`, SUM(od.quantity * p.price) AS total_sales
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3; 

------------------------------------------------------------------

--Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    CONCAT(ROUND(SUM(od.quantity * p.price) / (SELECT 
                            ROUND(SUM(p.price * od.quantity), 2) AS total_sales
                        FROM
                            pizzas p
                                JOIN
                            order_details od ON p.pizza_id = od.pizza_id) * 100,
                    2),
            '%') AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY 1
ORDER BY revenue DESC;

------------------------------------------------------------------

--Analyze the cumulative revenue generated over time.
select order_date, revenue, round(sum(revenue) over (order by order_date),2) as cumulative_revenue from
(SELECT 
    o.order_date,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    orders o ON o.order_id = od.order_id
GROUP BY 1) as sales

---------------------------------------------------------------

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with cte as(
select category,`name`,revenue, rank() over(partition by category order by revenue desc) as row_num from 
(SELECT 
    pt.category,
    pt.`name`,
    SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY 1 ,2) as sales)
select category,`name`, revenue from cte where row_num<=3 ;

--------------------------------------------------------------


