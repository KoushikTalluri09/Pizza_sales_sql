-- select a table

SELECT *
FROM order_details
SELECT *
FROM orders
SELECT *
FROM pizza_types
SELECT *
FROM pizzas 

-- check the data types in each col of a table
SELECT COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'orders';

-- making new constraints for the cols

ALTER TABLE orders ADD CONSTRAINT pk PRIMARY KEY (order_id);
ALTER TABLE order_details ADD CONSTRAINT pk1 PRIMARY KEY (order_details_id);

-- Q1 Retive the total number of orders placed

SELECT count(order_id) AS Total_orders
FROM orders 

--Q2 Calculate the total revenue generated from pizza sales.

SELECT round(sum(od.quantity*p.price)) AS Total_revenue
FROM order_details AS od
JOIN pizzas AS p ON p.pizza_id= od.pizza_id 

--Q3 Identify the highest-priced pizza.

SELECT pt.name, p.price
FROM pizza_types AS pt
JOIN pizzas AS p ON p.pizza_type_id= pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1 

--Q4 Identify the most common pizza size ordered.

SELECT p.size,
       count(od.order_details_id) AS Order_count
FROM pizzas AS p
JOIN order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY(p.size)
ORDER BY Order_count DESC
LIMIT 1

-- Q5 List the top 5 most ordered pizza types along with their quantities.

SELECT pt.name,
       count(od.order_details_id) AS quantity
FROM pizza_types AS pt
JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details AS od ON od.pizza_id=p.pizza_id
GROUP BY(pt.name)
ORDER BY count(od.order_details_id) DESC
LIMIT 5 

--Q6 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pt.category,
       sum(od.quantity) AS quantity
FROM pizza_types AS pt
JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details AS od ON od.pizza_id=p.pizza_id
GROUP BY(pt.category)
ORDER BY count(od.order_details_id) DESC 

--Q7 Determine the distribution of orders by hour of the day.

SELECT extract(HOUR
               FROM o.time) AS HOUR,
       count(o.order_id) AS order_count
FROM orders AS o
GROUP BY (HOUR)
ORDER BY order_count DESC 

--Q8 Join relevant tables to find the category-wise distribution of pizzas.

SELECT category,
       count(name)
FROM pizza_types
GROUP BY(category)

--Q9 Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT round(avg(quantity), 2) AS average_quantity
FROM
  (SELECT date(o.date) AS date,
          sum(od.quantity) AS quantity
   FROM orders AS o
   JOIN order_details AS od ON od.order_id = o.order_id
   GROUP BY(date))AS qnt 
   
--Q10 Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name,
       sum(od.quantity*p.price) AS revenue
FROM order_details AS od
JOIN pizzas AS p ON od.pizza_id=p.pizza_id
JOIN pizza_types AS pt ON pt.pizza_type_id= p.pizza_type_id
GROUP BY(pt.name)
ORDER BY revenue DESC
LIMIT 3 

--Q11 Calculate the percentage contribution of each pizza type to total revenue.

WITH revenue_per_category AS
  (SELECT pt.category,
          round(cast(sum(od.quantity*p.price)AS numeric), 2) AS category_revenue
   FROM order_details AS od
   JOIN pizzas AS p ON od.pizza_id=p.pizza_id
   JOIN pizza_types AS pt ON pt.pizza_type_id= p.pizza_type_id
   GROUP BY(pt.category)
   ORDER BY category_revenue DESC),
      total_revenue AS
  (SELECT SUM(category_revenue) AS total_revenue
   FROM revenue_per_category)
SELECT rpc.category,
       rpc.category_revenue,
       tr.total_revenue,
       round(cast((rpc.category_revenue / tr.total_revenue) * 100 AS numeric), 2) AS percentage
FROM revenue_per_category rpc,
     total_revenue tr
ORDER BY percentage DESC;

--Q12 Analyze the cumulative revenue generated over time.

SELECT date, sum(revenue) OVER (ORDER BY date) AS cumulative_revenue
FROM
  (SELECT o.date AS date,
          round(cast(sum(od.quantity*p.price) AS numeric), 2) AS revenue
   FROM order_details AS od
   JOIN pizzas AS p ON od.pizza_id=p.pizza_id
   JOIN orders AS o ON o.order_id=od.order_id
   GROUP BY (date)) sales 

--Q13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category,
       name,
       revenue,
       rank
FROM
  (SELECT category,
          name,
          revenue,
          rank()over(PARTITION BY category
                     ORDER BY revenue DESC) AS rank
   FROM
     (SELECT pt.category,
             pt.name,
             sum(od.quantity*p.price) AS revenue
      FROM pizza_types AS pt
      JOIN pizzas AS p ON pt.pizza_type_id=p.pizza_type_id
      JOIN order_details AS od ON od.pizza_id=p.pizza_id
      GROUP BY (pt.category,
                pt.name)) AS a) AS b
WHERE rank<4














