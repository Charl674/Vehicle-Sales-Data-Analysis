---inspecting data
select * from [dbo].[sales_data_sample]


---using DISTINCT to check the unique values

select distinct Status from [dbo].[sales_data_sample] ---cool to visualize
select distinct Country from [dbo].[sales_data_sample]
select distinct YEAR_ID from [dbo].[sales_data_sample]
select distinct DEALSIZE from [dbo].[sales_data_sample]
select distinct PRODUCTLINE from [dbo].[sales_data_sample]---cool to visualize


---ANALYSIS

---group by the unique values of Productline with their corresponding sum of sales
---remember that anytime you use an aggregate fxn, you'd have to use a GROUP BY

select Productline, sum(sales) Revenue
from [dbo].[sales_data_sample]
group by PRODUCTLINE
Order by 2 desc



--analyze the year with the best sales

select YEAR_ID, sum(sales) Revenue
from [dbo].[sales_data_sample]
group by YEAR_ID
Order by 2 desc


--here's why 2005 is their worst year
select distinct month_id from [dbo].[sales_data_sample]
where YEAR_ID=2005
--from this analysis, we can see that the company operated only in 5 months of 2005



---What was  the best month in a specific year? How much was earned that year?
select distinct MONTH_ID, sum(sales) Revenue, COUNT(ORDERNUMBER) fREQUENCY
from [dbo].[sales_data_sample]
where YEAR_ID = 2005
group by MONTH_ID
Order by 2 desc   ---MAY was their best year
--REPEAT SAME LOGIC FOR OTHER YEARS


--WHO IS OUR BEST CUSTOMER?? 
/* Now let's use RFM to answer this.
-RFM : Recency Frequency Monetary. It is an indexing technique that uses past purchase behaviour to segment customers.
An RFM report is away of segmenting customers using 3 key metrics:
-Recency : last order date
-Frequency: count of total orders
-Monetary : total spend
*/

;with rfm as 
(
	 Select 
		CUSTOMERNAME,
		SUM(SALES) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ordernumber) Frequency,
		max(orderdate) last_order_date,
		(select max(orderdate) from [dbo].[sales_data_sample]) max_order_date,
		DATEDIFF(DD,max(orderdate),(select max(orderdate) from [dbo].[sales_data_sample])) Recency

	 from [dbo].[sales_data_sample]
	 group by CUSTOMERNAME
),

rfm_calc as(
select r.*,
     NTILE(4) OVER (order by Recency desc) rfm_recency,
	 NTILE(4) OVER (order by Frequency) rfm_Frequency,
	 NTILE(4) OVER (order by AvgMonetaryValue) rfm_Monetary
from rfm r
)
select c* 
from rfm_calc c