-- Retrieve the total number of orders placed.
select count(*) from orders;

-- Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_sales
FROM order_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id;

-- Identify the highest-priced pizza.
Select pt.name, p.price
from pizza_types pt
join pizzas p on pt.pizza_type_id = p.pizza_type_id
order by p.price desc
limit 1;

-- Identify the most common pizza size ordered.
select p.size , count(od.order_details_id) as order_count from pizzas p 
join order_details od on od.pizza_id = p.pizza_id
group by p.size
order by order_count desc;

-- List the top 5 most ordered pizza types along with their quantities.
select pt.name, sum(od.quantity) as Quantity_ordered from pizza_types pt 
join pizzas p on pt.pizza_type_id = p.pizza_type_id
join order_details od on p.pizza_id = od.pizza_id
group by pt.name
order by Quantity_ordered desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered
select pt.category, sum(od.quantity) as Quantity_ordered from pizza_types pt
join pizzas p on pt.pizza_type_id = p.pizza_type_id
join order_details od on p.pizza_id = od.pizza_id
group by pt.category
order by Quantity_ordered desc;

-- Determine the distribution of orders by hour of the day.
select hour(order_time), count(order_id) from orders 
group by hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas
select category, count(name) from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
Select round(avg(quantity),0) from (
select o.order_date, sum(od.quantity) as quantity from orders o 
join order_details od on o.order_id = od.order_id
group by o.order_date) as T;

-- Determine the top 3 most ordered pizza types based on revenue.
select pt.name, round(sum(od.quantity*p.price),2) as revenue from pizza_types pt 
join pizzas p on pt.pizza_type_id = p.pizza_type_id
join order_details od on p.pizza_id = od.pizza_id
group by pt.name
order by revenue desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
Select * ,  (revenue/( SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_sales
FROM order_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id)) *100 as Percentage_revenue from
(
select pt.category, round(sum(od.quantity*p.price),2) as revenue
from pizza_types pt 
join pizzas p on pt.pizza_type_id = p.pizza_type_id
join order_details od on p.pizza_id = od.pizza_id
group by pt.category
order by revenue desc) T;

-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_revenue 
from (
select o.order_date, round(sum(od.quantity*p.price),2) as revenue
from order_details od 
join pizzas p on od.pizza_id = p.pizza_id
join orders o on od.order_id = o.order_id
group by o.order_date ) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
Select * from 
(Select category, name, revenue, rank() over(partition by category order by revenue desc) as rk
from (
select pt.category, pt.name, round(sum(od.quantity*p.price),2) as revenue
from pizza_types pt 
join pizzas p on pt.pizza_type_id = p.pizza_type_id
join order_details od on p.pizza_id = od.pizza_id
group by pt.category, pt.name
order by revenue desc) T ) b
 where rk<4;