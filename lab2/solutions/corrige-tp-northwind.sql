set tab off;
set linesize 100;
set PAGESIZE 60;

--Q2.1
SELECT table_name FROM user_tables;

DESC Categories;
DESC customers;
DESC employees;
DESC suppliers;
DESC shippers;
DESC products;
DESC orders;
DESC order_details;

-- Q2.2
-- fact table: order_details
-- recursive dimension: employees



-- Exercise GROUP BY extensions
-- customer.city and order.ship_city seem to refer to the same property.
-- I am assuming that customer country/city, etc is the shipping_country, etc... 
-- in this DB instance it is true BUT it may differ actually (if sending product to a friend, offering a present etc.)
-- BEWARE: unit_price in OD and P differ!

-- SELECT OD.Order_ID, OD.Quantity,P.product_name,OD.Unit_Price,OD.discount,P.Unit_Price FROM Order_details OD, Products P WHERE OD.product_id=P.product_id AND OD.Unit_Price<>P.Unit_Price

-- SELECT C.city, O.ship_city FROM orders O
-- 	INNER JOIN customers C ON O.CustomerID=C.CustomerID
-- where C.city <> O.Ship_city
-- GROUP BY C.city,O.ship_city;


-- Q2.3.1
SELECT country,count(*) nb
FROM customers 
GROUP BY country;

-- Q2.3.2
SELECT ship_country,ship_city,count(*) as nbOrders
FROM Orders 
GROUP BY ROLLUP(ship_country,ship_city)
ORDER BY ship_country,ship_city

-- Q2.3.3
SELECT C.country C_Country,S.country S_Country,SUM(Quantity) Quantity,
	COUNT (DISTINCT OD.Order_ID) NBOrder 
FROM Orders O,Customers C,Order_Details OD,Products P,Suppliers S
WHERE O.customer_id=C.customer_ID 
AND O.Order_id=OD.Order_ID
AND OD.Product_ID=P.Product_ID
AND P.Supplier_ID=S.Supplier_ID
GROUP BY C.country,S.country
ORDER BY C.country,S.country;

-- Q2.3.4
SELECT C.country C_Country,S.country S_Country,SUM(Quantity) Quantity,
	COUNT (DISTINCT OD.Order_ID) NBOrder 
FROM Orders O,Customers C,Order_Details OD,Products P,Suppliers S
WHERE O.customer_id=C.customer_ID 
AND O.Order_id=OD.Order_ID
AND OD.Product_ID=P.Product_ID
AND P.Supplier_ID=S.Supplier_ID
GROUP BY CUBE(C.country,S.country)
ORDER BY C.country,S.country;

-- Q2.3.5
SELECT ship_country,ship_region,ship_city,SUM(OD.Quantity * OD.Unit_price * (1-OD.Discount)) price
FROM Orders O,Customers C,Order_Details OD,Products P,Suppliers S
WHERE O.customer_id=C.customer_ID 
AND O.Order_id=OD.Order_ID
AND OD.Product_ID=P.Product_ID
AND P.Supplier_ID=S.Supplier_ID
AND S.Country='France'
GROUP BY ship_country, ROLLUP(ship_region,ship_city)
;
-- GROUP BY GROUPING SETS((ship_country, ship_region,ship_city),(ship_country,ship_region),(ship_country))

-- Q2.3.6
column S_country format a10;
column S_city format a15;
SELECT ship_country S_country,
	CASE WHEN GROUPING(ship_country)=0 AND GROUPING(ship_city)=1 
	THEN 'whole country' 
	ELSE ship_city END S_city,
	count(*) as nbOrders
FROM Orders 
GROUP BY ROLLUP(ship_country,ship_city)
ORDER BY ship_country,ship_city
;

-- Exercise Windowing
-- Q2.4.1
SELECT ship_country,ship_city, count(*) as nbOrders, 
	SUM(count(*)) OVER (PARTITION BY ship_country) nbOrdCty,
	MAX(count(*)) OVER (PARTITION BY ship_country) nbOrMaxCty
FROM Orders
GROUP BY ship_country,ship_city
;

-- Q2.4.2
SELECT ship_country,ship_city, count(*) as nbOrders, 
	DENSE_RANK() OVER (PARTITION BY ship_country ORDER BY count(*)) Rank
FROM Orders
GROUP BY ship_country,ship_city
;

-- Q2.4.3
column PERCENTG format 999.99;

SELECT ship_country,ship_city, count(*) as nbOrders, 
	DENSE_RANK() OVER (PARTITION BY ship_country ORDER BY count(*)) Rank,
	RATIO_TO_REPORT(COUNT(*)) OVER(PARTITION BY ship_country) AS PERCENTG
FROM Orders
GROUP BY ship_country,ship_city
;

-- Q2.4.4
WITH temp AS 
(SELECT order_id,SUM(OD.Quantity * OD.Unit_price * (1-Discount)) price, LAG(SUM(Unit_Price*Quantity)) OVER(ORDER BY order_id) priceprev
FROM Order_Details OD
GROUP BY order_id
)
SELECT order_id, price FROM temp
WHERE price<1.1*priceprev
;



-- Q2.4.5
WITH temp AS (SELECT EXTRACT(YEAR FROM Order_date) year, product_name, SUM(Quantity) qtity
FROM Orders O,Order_Details OD,Products P
WHERE O.Order_id=OD.Order_ID
AND OD.Product_ID=P.Product_ID
GROUP BY EXTRACT(YEAR FROM Order_date),OD.product_id,product_name
)
SELECT year, product_name, qtity FROM temp
NATURAL JOIN (SELECT year, MAX(qtity) qtity FROM temp
GROUP BY year) t;


WITH temp AS (SELECT EXTRACT(YEAR FROM Order_date) year, product_name, SUM(Quantity) qtity, (MAX(SUM(Quantity)) OVER (PARTITION BY EXTRACT(YEAR FROM Order_date))) mxqt
FROM Orders O,Order_Details OD,Products P
WHERE O.Order_id=OD.Order_ID
AND OD.Product_ID=P.Product_ID
GROUP BY EXTRACT(YEAR FROM Order_date),OD.product_id,product_name
)
SELECT year, product_name, qtity FROM temp
WHERE qtity=mxqt
;




-- Exercise Hierarchies
-- Q2.5

column mylis format 99;
SELECT LEVEL mylis FROM DUAL CONNECT BY LEVEL<60;

WITH liste_entiers(n) as 
(
SELECT 1 AS n FROM DUAL
UNION ALL
SELECT n+1 FROM liste_entiers
WHERE n<=59
)
SELECT n from liste_entiers;

-- Q2.6
column monthlis format a6;
SELECT to_char(add_months(SYSDATE, (LEVEL-1 )),'MON-YY') as monthlis
FROM dual 
CONNECT BY LEVEL <=30;

-- si on demandait la liste des jours entre 2 dates:

-- WITH liste_entiers(n) as
-- (
-- SELECT 0 AS n FROM DUAL
-- UNION ALL
-- SELECT n+1 FROM liste_entiers
-- WHERE n<=366
-- )
-- SELECT TO_DATE('01/01/2016', 'dd/mm/yyyy')+n jour
-- FROM liste_entiers
-- WHERE TO_DATE('01/01/2016', 'dd/mm/yyyy')+n < TO_DATE('01/01/2017', 'dd/mm/yyyy');
--

-- Q2.7
-- see lecture slides

-- Q2.8
WITH t(n, un) AS
(
SELECT 0, 127 FROM DUAL
UNION ALL
SELECT n+1, (CASE WHEN MOD(un,2)=0 THEN trunc(un/2,0) ELSE trunc(3*un+1,0) END) un
FROM t
WHERE n<50
)
SELECT n, un 
FROM t
WHERE n=50
;

-- Q2.8
create table d(
xo int,
yo int,
xd int,
yd int
);

sqlldr userid=C##bgroz_a/bgroz_a control=control-proba-depl.txt log=log.txt bad=bad.txt direct=y errors=0 skip=0

-- Q2.8.2.a
-- n represents the number of steps performed to reach x,y
WITH t(x, y, n) AS
(
SELECT 2, 2, 0 FROM DUAL
UNION ALL
SELECT xd,yd, n+1
FROM t, d
WHERE d.xo=t.x AND d.yo=t.y AND n<5
)
SELECT x,y
FROM t
WHERE n<=2
GROUP BY x,y
MINUS
(SELECT x,y
FROM t
WHERE n=2
GROUP BY x,y)
ORDER BY x,y;
-- same with n=3 for exactly 4
-- for at most 4 we can remove the where clause in the final query


-- Q2.8.2.b
WITH nb_deplacements_depuis_case(xo, yo, nb_depl) AS
(
	SELECT xo, yo, count(*) FROM d
	GROUP BY xo, yo
),
t (x,y,etape,pb) AS (
SELECT 2, 2, 0, 1.0 FROM DUAL
UNION ALL
SELECT xd,yd, etape+1, pb/nb_depl
FROM t, d, nb_deplacements_depuis_case nbd 
WHERE d.xo=t.x AND d.yo=t.y AND d.xo = nbd.xo AND d.yo = nbd.yo AND etape<4
)
select x,y, sum(pb) as pba
from t
where etape=4
group by x,y
;

-- Q2.8.2.c
set heading off
set feedback off
set markup csv on
spool heatmap.csv
WITH nb_deplacements_depuis_case(xo, yo, nb_depl) AS
(
	SELECT xo, yo, count(*) FROM d
	GROUP BY xo, yo
),
t (x,y,etape,pb) AS (
SELECT 2, 2, 0, 1.0 FROM DUAL
UNION ALL
SELECT xd,yd, etape+1, pb/nb_depl
FROM t, d, nb_deplacements_depuis_case nbd 
WHERE d.xo=t.x AND d.yo=t.y AND d.xo = nbd.xo AND d.yo = nbd.yo AND etape<4
)
select x,y, sum(pb) as pba
from t
where etape=4
group by x,y
;
spool off