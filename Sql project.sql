

-- created a table by defining the datatypes...
create table Amazon_sales (
invoice_id VARCHAR(30),
branch VARCHAR(5),
city VARCHAR(30),
customer_type VARCHAR(30),
gender VARCHAR(10),
product_line VARCHAR(100),
unit_price DECIMAL(10,2),
quantity int,
VAT  FLOAT,
total DECIMAL(10,2),
date_ date ,
Time_  time,
payment_method varchar(100),
cogs DECIMAL(10,2),
gross_margin_percentage FLOAT,
gross_income DECIMAL(10,2),
rating FLOAT
);

-- checking whether the records are imported or not
select * from amazon_sales;

-- Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. This will help answer the question on which part of the day most sales are made.
alter table amazon_sales
add column timeofday varchar(10);
SET SQL_SAFE_UPDATES = 0;
-- using case statement for better insights of sales according to the time of day...
update amazon_sales 
set timeofday = case
when hour(time_) <= 0 and hour(time_) > 12 then 'Morning'
when hour(time_) >= 12 and hour(time_) < 17 then 'Afternoon'
else 'Evening'
end;
-- checking if the column is correctly filtered based on the actual time
select time_, timeofday from amazon_sales;


-- Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). 
-- This will help answer the question on which week of the day each branch is busiest.
alter table amazon_sales
add column Dayname varchar(10);
-- specifying the daynames to analyze easily on which day the transactions took place...
--  left is used to extract only the first 3 characters from the dayname as specified in the question..
UPDATE amazon_sales
SET dayname = LEFT(DAYNAME(date_), 3);
select dayname from amazon_sales;


-- Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). 
-- Help determine which month of the year has the most sales and profit.

alter table amazon_sales
add column Monthname varchar(20);
update amazon_sales
set Monthname = left(monthname(date_),3);
select date_ , monthname from amazon_sales;


-- What is the count of distinct cities in the dataset?
-- Distinct -- to get unique citynames
-- count -- to check the counnt of distinct cities
select count(distinct(city)) as Distinct_city_count from amazon_sales;

-- For each branch, what is the corresponding city?
select branch,city from amazon_sales
group by branch,city
order by branch;

-- What is the count of distinct product lines in the dataset?
select count(distinct product_line) as Number_of_productlines from amazon_sales;

-- Which payment method occurs most frequently?
select max(payment_method) as Frequent_payment_method from amazon_sales;

-- Which product line has the highest sales?
select product_line,sum(total) as Highest_sales from amazon_sales
group by product_line
order by highest_sales desc
limit 1;

-- How much revenue is generated each month?
select monthname, sum(total) as total_revenue from amazon_sales
group by monthname;

-- In which month did the cost of goods sold reach its peak?
select monthname, sum(cogs) as cogs from amazon_sales
group by monthname;

-- Which product line generated the highest revenue?
select product_line, sum(total) as total_revenue from amazon_sales
group by product_line
order by total_revenue desc
limit 1;


-- In which city was the highest revenue recorded?
select city, sum(total) as Highest_revenue from amazon_sales
group by city
order by highest_revenue desc
limit 1;


-- Which product line incurred the highest Value Added Tax?
select product_line, round(sum(VAT),2) as Highest_value_addedtax from amazon_sales
group by product_line
order by Highest_value_addedtax desc
limit 1;

-- For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."SELECT 
with Product_Des as (                            -- A Common Table Expression "ProductSales" is made here to fetch product line and their sum toal
select Product_Line,sum(Total) as Total_Sales
from Amazon_sales
group by Product_Line
),
Performance_Sales as(                
select Product_Line,CASE
        WHEN Total_Sales > (SELECT AVG(Total_Sales) FROM Product_Des ) 
        THEN 'Good'
        ELSE 'Bad'
    END AS Product_Line_Grade
from Product_Des
)
select PD.Product_Line,Total_Sales,Product_Line_Grade 
from Product_Des PD inner join Performance_Sales PS
on PD.Product_Line = PS.Product_Line;



-- Identify the branch that exceeded the average number of products sold.
select branch, SUM(quantity) AS total_products_sold
from amazon_sales
 group by branch
 having total_products_sold > (
    select AVG(total_quantity) 
    from (select SUM(quantity) as total_quantity from amazon_sales group by branch) as sub
);

-- Which product line is most frequently associated with each gender?
select product_line, gender ,count(*) as oocurences from amazon_sales
group by gender,product_line
order by gender,product_line  desc ;


-- Calculate the average rating for each product line.
select product_line , round(avg(rating),2) as averge_rating  from amazon_sales
group by product_line;

-- Count the sales occurrences for each time of day on every weekday.
select dayname, timeofday, COUNT(total) as sales_count
from amazon_sales
where dayname not in ('sat','sun')
 group by dayname, timeofday
order by dayname, timeofday;

-- Identify the customer type contributing the highest revenue.
SELECT customer_type, SUM(total) AS total_revenue
FROM amazon_sales
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;
-- Determine the city with the highest VAT percentage.
select city, AVG(vat / (total) * 100) AS avg_vat_percentage
from amazon_sales
GROUP BY city
ORDER BY avg_vat_percentage DESC
LIMIT 1;
-- Identify the customer type with the highest VAT payments.
select customer_type, round(sum(vat),2) as Highest_vat_payments from amazon_sales
group by customer_type
order by Highest_vat_payments desc
limit 1;
-- What is the count of distinct customer types in the dataset?
select count(distinct customer_type) as customer_types from amazon_sales;

-- What is the count of distinct payment methods in the dataset?
select count(distinct payment_method) as payment_methods  from amazon_sales;

-- Which customer type occurs most frequently?
SELECT customer_type, COUNT(*) AS occurrences
FROM amazon_sales
GROUP BY customer_type
ORDER BY occurrences DESC
LIMIT 1;

-- Identify the customer type with the highest purchase frequency.
SELECT customer_type, COUNT(*) AS purchase_frequency
FROM amazon_sales
GROUP BY customer_type
ORDER BY purchase_frequency DESC
LIMIT 1;

-- Determine the predominant gender among customers.
SELECT gender, COUNT(*) AS occurrences
FROM amazon_sales
GROUP BY gender
ORDER BY occurrences DESC
LIMIT 1;

-- Examine the distribution of genders within each branch.
select gender, branch,count(*) from amazon_sales
group by branch,gender
order by branch,gender;
-- Identify the time of day when customers provide the most ratings.
SELECT timeofday, COUNT(rating) AS rating_count
FROM amazon_sales
GROUP BY timeofday
ORDER BY rating_count DESC
LIMIT 1;

-- Determine the time of day with the highest customer ratings for each branch.
SELECT branch, time_of_day, rating
FROM sales s
WHERE rating = (
    SELECT MAX(rating)
    FROM sales
    WHERE branch = s.branch
);


-- Identify the day of the week with the highest average ratings.
select dayname,avg(rating) as avg_rating from amazon_sales
group by dayname
order by avg_rating desc
limit 1;

-- Determine the day of the week with the highest average ratings for each branch.
SELECT branch, day_of_week, avg_rating
FROM (
    SELECT 
        branch,
        dayname,
        AVG(rating) AS avg_rating,
        RANK() OVER (partition by branch ORDER BY AVG(rating) DESC) AS rnk
    FROM amazon_sales
    GROUP BY branch, dayname
) AS ranked
WHERE rnk = 1;

