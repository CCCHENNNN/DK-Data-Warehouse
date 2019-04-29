--1
select COUNTRY, count(*) num from CUSTOMERS group by COUNTRY;

--2
select SHIP_COUNTRY,SHIP_CITY,count(SHIP_CITY) 
from ORDERS 
group by ROLLUP(SHIP_COUNTRY,SHIP_CITY)
order by SHIP_COUNTRY,SHIP_CITY;


--3
select C.COUNTRY CUSTOMER_COUNTRY,S.COUNTRY SUPPLIER_COUNTRY,sum(OD.QUANTITY),count(distinct(OD.ORDER_ID))
from ORDER_DETAILS OD,CUSTOMERS C,SUPPLIERS S,ORDERS OS,PRODUCTS PR
where OD.ORDER_ID = OS.ORDER_ID and OS.CUSTOMER_ID = C.CUSTOMER_ID and 
OD.PRODUCT_ID = PR.PRODUCT_ID and PR.SUPPLIER_ID = S.SUPPLIER_ID
group by C.COUNTRY,S.COUNTRY
order by C.COUNTRY,S.COUNTRY;

--4
select C.COUNTRY CUSTOMER_COUNTRY,S.COUNTRY SUPPLIER_COUNTRY,sum(OD.QUANTITY),count(distinct(OD.ORDER_ID))
from ORDER_DETAILS OD,CUSTOMERS C,SUPPLIERS S,ORDERS OS,PRODUCTS PR
where OD.ORDER_ID = OS.ORDER_ID and OS.CUSTOMER_ID = C.CUSTOMER_ID and 
OD.PRODUCT_ID = PR.PRODUCT_ID and PR.SUPPLIER_ID = S.SUPPLIER_ID
group by cube(S.COUNTRY,C.COUNTRY)
order by C.COUNTRY,S.COUNTRY;

--5
-- select C.COUNTRY, C.REGION, C.CITY , (OD.UNIT_PRICE * OD.QUANTITY) PRICE
-- from ORDER_DETAILS OD,CUSTOMERS C,SUPPLIERS S,ORDERS OS,PRODUCTS PR
-- where OD.ORDER_ID = OS.ORDER_ID
-- and OS.CUSTOMER_ID = C.CUSTOMER_ID
-- and OD.PRODUCT_ID = PR.PRODUCT_ID
-- and PR.SUPPLIER_ID = S.SUPPLIER_ID
-- and S.COUNTRY = 'France'
-- order by C.COUNTRY,S.COUNTRY;

select SHIP_COUNTRY, SHIP_REGION, SHIP_CITY , sum(OD.UNIT_PRICE * OD.QUANTITY) PRICE
from ORDER_DETAILS OD,CUSTOMERS C,SUPPLIERS S,ORDERS OS,PRODUCTS PR
where OD.ORDER_ID = OS.ORDER_ID
and OS.CUSTOMER_ID = C.CUSTOMER_ID
and OD.PRODUCT_ID = PR.PRODUCT_ID
and PR.SUPPLIER_ID = S.SUPPLIER_ID
and S.COUNTRY = 'France'
group by SHIP_COUNTRY, ROLLUP(SHIP_REGION,SHIP_CITY);

--6

column S_country format a10;
column S_city format a15;
SELECT ship_country S_country,
    CASE WHEN GROUPING(ship_country) = 0 AND GROUPING(ship_city) = 1
    THEN 'whole country'
    ELSE ship_city END S_city,
    count(*) as nbOrders
FROM ORDERS
GROUP BY ROLLUP(ship_country,ship_city)
ORDER BY ship_country,ship_city;

--1
select ship_country, ship_city,
sum(count(*)) over (Partition by ship_country) as NBORDER,
sum(count(*)) over (Partition by ship_city) as NBORDCTY,
max(count(*)) over (Partition by ship_country) as NBORMAXCTY
from orders
group by ship_country, ship_city
order by ship_country, ship_city;

--2
select o.ship_country, o.ship_city,
sum(count(*)) OVER (Partition by o.ship_city) as NBORDERS,
RANK() OVER (Partition by o.ship_country order by count(*) DESC) as rank
from Orders o
group by o.ship_country, o.ship_city
order by o.ship_country, o.ship_city;

--3
select o.ship_country, o.ship_city,
sum(count(*)) over (Partition by ship_city) as NB_OR_CITY,
sum(count(*)) over (Partition by ship_country) as NB_OR_CNY,
RATIO_TO_REPORT(count(*)) over (Partition by ship_country) as percentage
from Orders o
group by o.ship_country, o.ship_city
order by o.ship_country, o.ship_city;

--4
WITH prices_with_previous_price(oid,price,pre_price) as
(
    select o.ORDER_ID,sum(UNIT_PRICE*QUANTITY),LAG(sum(UNIT_PRICE*QUANTITY)) over (order by o.ORDER_ID)
    from ORDER_DETAILS o
    group by o.ORDER_ID
)
select pp.oid id,pp.price price,pp.pre_price pre_price
from prices_with_previous_price pp
where price > 1.1 * pre_price;

--5

with temps as(
	select EXTRACT(year from od.order_date) as year, pd.product_name as name, sum(oe.quantity) as num,
	max(sum(oe.quantity)) over(Partition by EXTRACT(year from od.order_date)) as maxq
	from orders od, order_details oe, products pd
	where od.order_id = oe.order_id
	and oe.product_id = pd.product_id
	group by EXTRACT(year from od.order_date), pd.product_name
)
select year, name, maxq
from temps
where temps.num = temps.maxq
order by year desc
;


with temp(u) as(
	select 0 from DUAL
	UNION ALL
	select u+1 from temp
	where u < 60
)
select * from temp;



select ORDER_ID as id, QUANTITY as Q
from order_details
group id,Q;






















