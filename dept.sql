select * from dept;

	--1 get sellers and their revenues
select seller, sum(revenue) as revenue, sum(revenue_goal) as revenue_goal, sum(margin) as margin, sum(margin_goal) as margin_goal from dept
group by seller;

	--2 get isolated department data
select department, sum(sales_quantity) as 'sales count', sum(customers) as 'customers'
from dept
group by department;

	--3 get profit per sale
with cte_pps as(select sum(revenue) as rev, sum(sales_quantity) as sale from dept)
select rev/sale as profit_per_sale from cte_pps;

	--4 get profit per sale, yearly, removes a few nulls
with cte_pps as
(select date,
	sum(revenue) as rev,
	sum(sales_quantity) as sale
	from dept
	group by date)
select
	year(date),
	isnull(sum(rev) / nullif(sum(sale), 0),0) as profit_per_sale
	from cte_pps 
	group by year(date)
	order by year(date) desc;




	-- ended up not using these and went for AVG instead of SUM as it is more meaningful of a stat

--select top 2 year(date), sum(customers)
--from dept
--group by year(date)
--order by year(date) desc


--select top 2 year(date), sum(sales_quantity)
--from dept
--group by year(date)
--order by year(date) desc

--select top 2 year(date), sum(revenue)
--from dept
--group by year(date)
--order by year(date) desc

--select top 2 year(date), sum(margin)
--from dept
--group by year(date)
--order by year(date) desc

--select avg(profit_per_sale) from pps


	--get avgs for lcategorie
with CTE_avgs as (
select sum(margin) as margin, sum(revenue) as revenue, sum(customers) as customers, sum(sales_quantity) as sales_quantity, year(date) as year
from dept
group by year(date) 
)
select avg(margin) as marg, avg(revenue) as rev, avg(customers) as cust, avg(sales_quantity) as sales, year as yearr
from cte_avgs
group by year
order by year desc

	--table to set up margin differentials
drop table if exists  #dept
create table #dept
(year int, revenue bigint, margin bigint, sales bigint, customers bigint)

Insert into #dept
select year(date), sum(revenue), sum(margin), sum(sales_quantity), sum(customers)
from dept
group by year(date)

	--get difference (converted, below, to CTE for percent calcs)
--SELECT 	
--  year,
--  margin,
--    LAG(margin) over (order by year asc) AS prev_margin,
--	  margin - lead(margin) OVER (ORDER BY year desc) AS difference_year
--FROM #dept
--group by year, margin
--ORDER BY year desc

	--implicit cast float + get percentage from last year
with cte_per as (
SELECT 	
  year,
  margin,
    LAG(margin) over (order by year asc) AS prev_margin,
	  margin - lead(margin) OVER (ORDER BY year desc) AS difference_year
FROM #dept
group by year, margin
)
select year, margin, prev_margin, difference_year,
(1.00 * difference_year / prev_margin) * 100 as per
from cte_per


		--NOTICE
		--below is a repeate of above with "margin" replaced for each category
		----------------------------------------------------------------------------------------------------
--	with cte_per as (
--SELECT 	
--  year,
--  revenue,
--    LAG(revenue) over (order by year asc) AS prev_revenue,
--	  revenue - lead(revenue) OVER (ORDER BY year desc) AS difference_year
--FROM #dept
--group by year, revenue
--)
--select year, revenue, prev_revenue, difference_year,
--(1.00 * difference_year / prev_revenue) * 100 as per
--from cte_per


--	with cte_per as (
--SELECT 	
--  year,
--  sales,
--    LAG(sales) over (order by year asc) AS prev_sales,
--	  sales - lead(sales) OVER (ORDER BY year desc) AS difference_year
--FROM #dept
--group by year, sales
--)
--select year, sales, prev_sales, difference_year,
--(1.00 * difference_year / prev_sales) * 100 as per
--from cte_per


--	with cte_per as (
--SELECT 	
--  year,
--  customers,
--    LAG(customers) over (order by year asc) AS prev_customers,
--	  customers - lead(customers) OVER (ORDER BY year desc) AS difference_year
--FROM #dept
--group by year, customers
--)
--select year, customers, prev_customers, difference_year,
--(1.00 * difference_year / prev_customers) * 100 as per
--from cte_per


--	with cte_per as (
--SELECT 	
--  year,
--  customers,
--    LAG(customers) over (order by year asc) AS prev_customers,
--	  customers - lead(customers) OVER (ORDER BY year desc) AS difference_year
--FROM #dept
--group by year, customers
--)
--select year, customers, prev_customers, difference_year,
--(1.00 * difference_year / prev_customers) * 100 as per
--from cte_per


