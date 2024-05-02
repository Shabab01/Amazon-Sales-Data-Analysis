/*


The major aim of this project is to gain insight into the sales data of Amazon to
understand the different factors that affect sales of the different branches.


*/




-- Build a database 

create database if not exists AmazonSalesData;

/*

Created a table and inserted the data.
 No null values in our database as in creating the tables, 
 we set NOT  NULL for each field, hence null values are filtered out.
 
 */

create table if not exists sales(
	invoice_id varchar(30) not null primary key,
    branch varchar(5) not null,
    city varchar(30) not null,
    customer_type varchar(30) not null,
    gender varchar(10) not null,
    product_line varchar(100) not null,
    unit_price decimal(10,2) not null,
    quantity int not null,
    VAT float(6,4) not null,
    total decimal(12, 4) not null,
    date datetime not null,
    time time not null,
    payment_method varchar(15) not null,
    cogs decimal(10,2) not null,
    gross_margin_pct float(11,9),
    gross_income decimal(12,2) not null,
    rating float(2,1)
);



describe sales;

select * from sales;

-- -----------------------------| FEATURE ENGINEERING |---------------------------------------------


/*

Adding a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening.
This will help answer the question on which part of the day most sales are made.

 */
 
 
-- ------------
-- time_of_day  |
-- ------------

select
	time,
	case 
		when time between "00:00:00" and "12:00:00" then "Morning"
		when time between "12:01:00" and "16:00:00" then "Afternoon"
		else "Evening"
	end as time_of_day
	from sales;
    
    alter table sales add column time_of_day varchar(20);
    update sales
    set time_of_day = (
    case 
		when time between "00:00:00" and "12:00:00" then "Morning"
		when time between "12:01:00" and "16:00:00" then "Afternoon"
		else "Evening"
	end
    );
    
    
    /*
    
     Add a new column named dayname that contains the extracted days of the week
     on which the given transaction took place (Mon, Tue, Wed, Thur, Fri).
     This will help answer the question on which week of the day each branch is busiest.
  
  */
    
-- ---------
-- day name |
-- ---------
    
    
  select
	date,
	dayname(date) as day_name
from sales;

alter table sales add column day_name varchar(20);

update sales
set day_name = dayname(date);


/*

Adding a new column named monthname that contains the extracted months of the year 
on which the given transaction took place (Jan, Feb, Mar).
Help determine which month of the year has the most sales and profit.

*/

-- -----------
-- month_name |
-- -----------


select
	date,
    monthname(date) as month_name
from sales;

alter table sales add column month_name varchar(20);

update sales
set month_name = monthname(date);




-- Business Questions To Answer:

-- 1. What is the count of distinct cities in the dataset?

select
	count(distinct city) as count_of_cities
from sales ;

-- Findings: Count of distinct cities: There are 3 unique cities in the dataset.
-- ------------------------------------------------------------------------------------------------------------------------------------

-- 2. For each branch, what is the corresponding city? 

select
	distinct branch, city
from sales;


-- Findings : Branches and corresponding cities: Each branch is located in different cities.
-- ------------------------------------------------------------------------------------------------------------------------------------

-- 3. What is the count of distinct product lines in the dataset?

select 
	count(distinct product_line) as count_of_products
from sales;


-- Findings : Count of distinct product lines: There are 6 unique product lines in the dataset.
-- ------------------------------------------------------------------------------------------------------------------------------------

-- 4. Which payment method occurs most frequently?

select
	payment_method,
	count(payment_method) as no_of_transaction
from sales
group by payment_method
order by no_of_transaction desc ;


-- Findings : Most frequent payment method: "Cash" is the most frequently used payment method.
-- ------------------------------------------------------------------------------------------------------------------------------------

-- 5. Which product line has the highest sales?

select
	product_line,
	count(product_line) as most_selling_pr
from sales
group by product_line
order by most_selling_pr desc ;


-- Findings : Product line with highest sales: "Fashion accessories" has the highest sales.
-- ------------------------------------------------------------------------------------------------------------------------------------

-- 6. How much revenue is generated each month?

select 
	month_name as month,
    sum(total) as total_revenue_by_month
from sales
    group by month
    order by total_revenue_by_month desc ;
    
    
-- Findings : Revenue generated each month: Revenue peaks in "January" with $116291.86.
-- ------------------------------------------------------------------------------------------------------------------------------------
    
-- 7. In which month did the cost of goods sold reach its peak?

select
	month_name as month,
    sum(cogs) as cogs
from sales
group by month 
order by cogs desc;


-- Findings : Peak month for cost of goods sold: "January" saw the highest cost of goods sold.
-- ------------------------------------------------------------------------------------------------------------------------------------

-- 8. Which product line generated the highest revenue?

select
	product_line,
    sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc;


-- Findings : Product line with highest revenue: "Food and beverages" generates the highest revenue.
-- ------------------------------------------------------------------------------------------------------------------------------------

-- 9. In which city was the highest revenue recorded?

select
	branch,
	city,
    sum(total) as total_revenue
from sales
group by branch, city
order by total_revenue desc;


-- Findings : City with highest revenue: "Naypyitaw" records the highest revenue.
-- ------------------------------------------------------------------------------------------------------------------------------------

-- 10. Which product line incurred the highest Value Added Tax?

select
	product_line,
	sum(VAT) as VAT
from sales
group by product_line
order by VAT desc ;


-- Findings : Product line with highest VAT: "Food and beverages" incurs the highest VAT.
-- ------------------------------------------------------------------------------------------------------------------------------------

-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad".

select 
	round(avg(total),2) as avg_total
from sales;

select
	product_line,
	case
		when avg(total) >= 322.50 then "Good"
        else  "Bad"
    end as remark
from sales
group by product_line;


-- Findings : Product lines with sales above average: 
-- "Health and beauty", "Sports and travel", "Home and lifestyle", "Home and lifestyle" is marked as "Good".
-- ------------------------------------------------------------------------------------------------------------------------------------

-- 12. Identify the branch that exceeded the average number of products sold.

 select
 branch, sum(quantity) as quantity
from sales group by branch having sum(quantity) > avg(quantity) order by quantity desc limit 1;


-- Findings : Branch with above-average product sales: "Branch A " exceeded average product sales.
-- ------------------------------------------------------------------------------------------------------------------------------------

-- 13. Which product line is most frequently associated with each gender?

 select 
	gender,
    product_line,
    count(gender) as gender_cnt
from sales
group by gender, product_line 
order by gender_cnt desc;

    
    
-- Findings : Most frequently associated product lines by gender: "Fashion accessories" is most frequently associated with "Female".
-- ------------------------------------------------------------------------------------------------------------------------------------
    
-- 14. Calculate the average rating for each product line.

select
	product_line,
    round(avg(rating), 2) as avg_rating
from sales 
group by product_line;


-- Findings : Average rating for each product line: "Food and beverages" has an average rating of 7.11.
-- ------------------------------------------------------------------------------------------------------------------------------------

-- 15. Count the sales occurrences for each time of day on every weekday(Monday).

select
		time_of_day,
        count(*) as total_sales
	from sales
    where day_name = "Monday"
    group by time_of_day
    order by total_sales desc ;
 
 
 -- Findings : Sales occurrences by time of day on Mondays: Most sales occur in the "Evening" on Mondays.
-- ------------------------------------------------------------------------------------------------------------------------------------
    
-- 16. Identify the customer type contributing the highest revenue.

 select 
		customer_type,
        round(sum(total), 2) as rev
	from sales
    group by customer_type
    order by rev desc ;


 -- Findings :  Customer type contributing highest revenue: "Member" contributes the highest revenue.   
-- ------------------------------------------------------------------------------------------------------------------------------------
    
-- 17. Determine the city with the highest VAT percentage.

select 
		city,
        round(sum(VAT), 2) as total_tax
	from sales 
    group by city
    order by total_tax desc;


 -- Findings :  City with highest VAT percentage: "Naypyitaw" has the highest VAT percentage.   
-- ------------------------------------------------------------------------------------------------------------------------------------
    
-- 18. Identify the customer type with the highest VAT payments.

select 
		customer_type,
        round(avg(VAT),1) as VAT_paid
	from sales
    group by customer_type
    order by VAT_paid desc ;


-- Findings :  Customer type with highest VAT payments: "Member" has the highest VAT payments on average
-- ------------------------------------------------------------------------------------------------------------------------------------
    
-- 19. What is the count of distinct customer types in the dataset?

  select 
		distinct customer_type 
	from sales;


-- Findings : Count of distinct customer types: There are 2 distinct customer types in the dataset.     
-- ------------------------------------------------------------------------------------------------------------------------------------
    
-- 20. What is the count of distinct payment methods in the dataset?

 
    select 
		distinct payment_method
	from sales;
    
    
-- Findings : Count of distinct payment methods: There are 3 distinct payment methods in the dataset.    
-- ------------------------------------------------------------------------------------------------------------------------------------

-- 21. Which customer type occurs most frequently?

  select 
		customer_type,
        count(*) as cust_cnt
	from sales 
    group by customer_type 
    order by cust_cnt desc;


-- Findings : Most frequent customer type: "Member" is the most frequently occurring.    
-- ------------------------------------------------------------------------------------------------------------------------------------
    
-- 22. Identify the customer type with the highest purchase frequency.

    select 
		customer_type,
        count(*) as cust_cnt
	from sales 
    group by customer_type 
    order by cust_cnt desc;


 -- Findings :  Customer type with highest purchase frequency: "Member" has the highest purchase frequency.  
-- ------------------------------------------------------------------------------------------------------------------------------------
    
-- 23. Determine the predominant gender among customers.
    
     select
		gender,
        count(*) as gend_cnt
	from sales
    group by gender
    order by gend_cnt desc ;
    

 -- Findings : Predominant gender among customers: "Male" is the predominant gender among customers.
-- ------------------------------------------------------------------------------------------------------------------------------------
    
-- 24. Examine the distribution of genders within each branch.

-- Branch A 

 select 
		 gender,
         count(*) as cnt
	from sales 
    where branch = "A"
    group by gender
    order by cnt desc ;

-- Branch B 

 select 
		 gender,
         count(*) as cnt
	from sales 
    where branch = "B"
    group by gender
    order by cnt desc ;
    
-- Branch C
 
 select 
		 gender,
         count(*) as cnt
	from sales 
    where branch = "C"
    group by gender
    order by cnt desc ;

-- Findings : Gender distribution within each branch: "Male" is more in Branch A & B and "Female" in Branch C.   
-- ------------------------------------------------------------------------------------------------------------------------------------
    
-- 25. Identify the time of day when customers provide the most ratings.

  select
		time_of_day,
        avg(rating) as avg_rtng
	from sales 
    group by time_of_day
    order by avg_rtng desc ;


-- Findings : Time of day with highest ratings: "Afternoon" sees the highest average ratings.    
-- ------------------------------------------------------------------------------------------------------------------------------------
    
-- 26. Determine the time of day with the highest customer ratings for each branch.

-- Branch A 

    select
		time_of_day,
        avg(rating) as avg_rtng
	from sales 
    where branch = "A"
    group by time_of_day
    order by avg_rtng desc ;
    
-- Branch B 

    select
		time_of_day,
        avg(rating) as avg_rtng
	from sales 
    where branch = "B"
    group by time_of_day
    order by avg_rtng desc ;
    
-- Branch C 

    select
		time_of_day,
        avg(rating) as avg_rtng
	from sales 
    where branch = "C"
    group by time_of_day
    order by avg_rtng desc ;


-- Findings : Time of day with highest ratings for each branch: 
-- Each branch has a specific time of day with the highest ratings.
--  Branch A in Afternoon, Branch B in Morning, Branch C in Evening.    
-- ------------------------------------------------------------------------------------------------------------------------------------
    
-- 27. Identify the day of the week with the highest average ratings.

    select
		day_name,
        avg(rating) as avg_rtng
	from sales 
    group by day_name 
    order by avg_rtng desc limit 1 ;


-- Findings : Day of week with highest average ratings: "Monday" has the highest average ratings.
-- ------------------------------------------------------------------------------------------------------------------------------------
    
-- 28. Determine the day of the week with the highest average ratings for each branch.

  -- Branch A
  
  select
		day_name,
        avg(rating) as avg_rtng
	from sales 
    where branch = "A"
    group by day_name 
    order by avg_rtng desc limit 1 ;

-- Branch B 

  select
		day_name,
        avg(rating) as avg_rtng
	from sales 
    where branch = "B"
    group by day_name 
    order by avg_rtng desc limit 1 ;
    
-- Branch C 

  select
		day_name,
        avg(rating) as avg_rtng
	from sales 
    where branch = "C"
    group by day_name 
    order by avg_rtng desc limit 1 ;


-- Findings :  Day of week with highest average ratings for each branch: 
-- Each branch has a specific day with the highest average ratings.
-- Branch A in Friday, Branch b in Monday, Branch C in Saturday.





   
-- ------------------------------------------------------------------------------------------------------------------------------------
   
   
   

 --                                         ||   CONCLUSION   ||                              --
 
 -- Sales of goods are better in afternoon.
 -- promotion for usage of online transaction for 'Ewallet' should be done everywhere.
 -- Should focus on widening the brand within these two product lines - 'health and beauty' and 'fashion and accessories' to generate revenue
 
 
-- ----------------------------------------| THANK YOU |----------------------------------------
    
    








