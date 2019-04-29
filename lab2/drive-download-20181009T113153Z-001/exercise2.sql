1.
	A fact table is the central table in a star schema of a data warehouse. A fact table stores quantitative information for analysis and is often denormalized.
1.
SELECT country,COUNT(DISTINCT customer_id) AS nbcustomer
FROM customers
GROUP BY country
ORDER BY country;

2.
SELECT ship_country,ship_city,COUNT(DISTINCT order_id) AS nborders
FROM orders
GROUP BY rollup(ship_country,ship_city)
ORDER BY ship_country,ship_city;

3.
SELECT cs.country AS c_country,sp.country AS s_country,SUM(od.quantity) AS qtity,COUNT(DISTINCT od.order_id) AS nborders
FROM order_details od,orders os,customers cs,products pd,suppliers sp
WHERE od.order_id = os.order_id
AND os.customer_id = cs.customer_id
AND od.product_id = pd.product_id
AND pd.supplier_id = sp.supplier_id
GROUP BY cs.country,sp.country
ORDER BY cs.country,sp.country;

4.
SELECT cs.country AS c_country,sp.country AS s_country,SUM(od.quantity) AS qtity,COUNT(DISTINCT od.order_id) AS nborders
FROM order_details od,orders os,customers cs,products pd,suppliers sp
WHERE od.order_id = os.order_id
AND os.customer_id = cs.customer_id
AND od.product_id = pd.product_id
AND pd.supplier_id = sp.supplier_id
GROUP BY cube(cs.country,sp.country)
ORDER BY cs.country,sp.country;

5.
SELECT os.ship_country AS ship_country,os.ship_region AS ship_region,os.ship_city AS ship_city,SUM(od.quantity*od.unit_price) AS price
FROM order_details od,orders os,products pd,suppliers sp
WHERE od.order_id = os.order_id
AND od.product_id = pd.product_id
AND pd.supplier_id = sp.supplier_id
AND sp.country = 'France'
GROUP BY os.ship_country,rollup(os.ship_region,os.ship_city)
ORDER BY os.ship_country,os.ship_region,os.ship_city;

SELECT os.ship_country AS ship_country,os.ship_region AS ship_region,os.ship_city AS ship_city,SUM(od.quantity*od.unit_price) AS price
FROM order_details od,orders os,products pd,suppliers sp
WHERE od.order_id = os.order_id
AND od.product_id = pd.product_id
AND pd.supplier_id = sp.supplier_id
AND sp.country = 'France'
GROUP BY GROUPING SETS((os.ship_country,os.ship_region,os.ship_city),(os.ship_country,os.ship_region),(os.ship_country))
ORDER BY os.ship_country,os.ship_region,os.ship_city;

6.
SELECT ship_country,
CASE WHEN GROUPING(ship_city) = 1 AND GROUPING(ship_country) = 0 THEN 'whole country'
ELSE ship_city END,
COUNT(DISTINCT order_id) AS nborders
FROM orders
GROUP BY rollup(ship_country,ship_city)
ORDER BY ship_country,ship_city;


1.
SELECT ship_country,ship_city,COUNT(order_id) AS nborders,
SUM(COUNT(order_id)) OVER(PARTITION BY ship_country) AS nbordercty,
MAX(COUNT(order_id)) OVER(PARTITION BY ship_country) AS nbordermax
FROM orders
GROUP BY ship_country,ship_city
ORDER BY ship_country,ship_city;


2.
SELECT ship_country,ship_city,COUNT(DISTINCT order_id) AS nborders,
RANK() OVER(PARTITION BY ship_country ORDER BY COUNT(DISTINCT order_id)) AS rank
FROM orders
GROUP BY ship_country,ship_city;

3.
SELECT ship_country,ship_city,COUNT(DISTINCT order_id) AS nborders,
RANK() OVER(PARTITION BY ship_country ORDER BY COUNT(DISTINCT order_id) DESC) AS rank,
RATIO_TO_REPORT(COUNT(DISTINCT order_id)) OVER(PARTITION BY ship_country) AS percentage
FROM orders
GROUP BY ship_country,ship_city;

4. 
WITH pre_price AS(
	SELECT order_id,SUM(quantity*unit_price) AS price,
	LAG(SUM(quantity*unit_price)) OVER(ORDER BY order_id) AS pre_price
	FROM order_details
	GROUP BY order_id
)
SELECT *
FROM pre_price
WHERE price < 1.1 * pre_price; 

5.
WITH temp AS(
	SELECT EXTRACT(year FROM os.order_date) AS year,
	pd.product_name AS product_name,
	SUM(od.quantity) AS qtity,
	MAX(SUM(od.quantity)) OVER(PARTITION BY EXTRACT(year FROM os.order_date)) AS maxq
	FROM orders os,order_details od,products pd
	WHERE os.order_id = od.order_id
	AND od.product_id = pd.product_id
	GROUP BY EXTRACT(year FROM os.order_date),pd.product_name
)
SELECT year,product_name,qtity
FROM temp
WHERE qtity = maxq;

WITH temp AS(
	SELECT EXTRACT(year FROM os.order_date) AS year,
	pr.product_name AS product_name,
	SUM(od.quantity) AS qtity,
	FIRST_VALUE(SUM(od.quantity)) OVER(PARTITION BY EXTRACT(year FROM os.order_date) ORDER BY SUM(od.quantity) DESC) AS maxq
	FROM order_details od,orders os,products pr
	WHERE od.product_id = pr.product_id
	AND od.order_id = os.order_id
	GROUP BY EXTRACT(year FROM os.order_date),pr.product_name
)
SELECT year,product_name,qtity
FROM temp
WHERE qtity = maxq;

WITH y1 AS(
	SELECT EXTRACT(year FROM os.order_date) AS year,
	pr.product_name AS product_name,
	SUM(od.quantity) AS qtity
	FROM order_details od,orders os,products pr
	WHERE od.product_id = pr.product_id
	AND od.order_id = os.order_id
	GROUP BY EXTRACT(year FROM os.order_date),pr.product_name
),
y2 AS(
	SELECT year,MAX(qtity) AS maxq
	FROM y1
	GROUP BY year
)
SELECT y1.year AS year,y1.product_name AS product_name,y1.qtity AS qtity
FROM y1,y2
WHERE y1.qtity = y2.maxq
AND y1.year = y2.year;


WITH u(i) AS(
	SELECT 0 FROM DUAL
	UNION ALL
	SELECT i+1 FROM u
	WHERE i < 60
) 
SELECT *
FROM u;


WITH months(i,month) AS(
	SELECT 1,to_char(sysdate,'mm-yy') FROM DUAL
	UNION ALL
	SELECT i+1,to_char(ADD_MONTHS(sysdate,i),'mm-yy') FROM months
	WHERE i <=30
)
SELECT *
FROM months;


WITH temp(eid,rid,dist) AS(
	SELECT employee_id,reports_to,1
	FROM employees
	WHERE reports_to is NULL
	UNION ALL
	SELECT e.employee_id,e.reports_to,t.dist+1
	FROM employees e,temp t
	WHERE e.reports_to = t.eid
)
SELECT *
FROM temp;


WITH y1 AS(
	SELECT EXTRACT(year FROM os.order_date) AS year,
	pr.product_name AS product_name,
	SUM(od.quantity) AS qtity
	FROM order_details od,orders os,products pr
	WHERE od.product_id = pr.product_id
	AND od.order_id = os.order_id
	GROUP BY EXTRACT(year FROM os.order_date),pr.product_name
)
SELECT year,product_name,qtity
FROM y1 
NATURAL JOIN (SELECT year,MAX(qtity) AS qtity FROM y1 GROUP BY year) t;


SELECT LEVEL mylis FROM DUAL CONNECT BY LEVEL<60;

WITH t(i) AS(
	SELECT 1 FROM DUAL
	UNION ALL
	SELECT i+1 FROM t
	WHERE i<60
)
SELECT * FROM t;

WITH months(i,month) AS(
	SELECT 1,to_char(sysdate,'yy-mm') AS month FROM DUAL
	UNION ALL
	SELECT i+1,to_char(ADD_MONTHS(sysdate,i),'yy-mm') FROM months
	WHERE i<30
)
SELECT month FROM months;

SELECT LEVEL n FROM DUAL CONNECT BY LEVEL<=30;

SELECT to_char(ADD_MONTHS(sysdate,LEVEL-1),'yyyy-mm') FROM DUAL CONNECT BY LEVEL <30;

WITH t(n) AS(
	SELECT 0 FROM DUAL
	UNION ALL
	SELECT n+1 FROM t
	WHERE N<366
)
SELECT to_date('01/01/2016','dd/mm/yyyy')+n 
FROM t
WHERE to_date('01/01/2016','dd/mm/yyyy')+n < to_date('01/02/2017','dd/mm/yyyy');


WITH em(eid,rid,dist) AS(
	SELECT employee_id,reports_to,1
	FROM employees
	WHERE reports_to IS NULL
	UNION ALL
	SELECT e.employee_id,e.reports_to,em.dist+1
	FROM employees e,em
	WHERE e.reports_to = em.eid
)
SELECT * FROM em;


WITH t(n,un) AS(
	SELECT 0,127 FROM DUAL
	UNION ALL
	SELECT n+1,
	CASE WHEN MOD(un,2)=0 THEN TRUNC(un/2,0) ELSE TRUNC(3*un+1,0) END
	FROM t
	WHERE n<50
)
SELECT * FROM t;

CREATE table dd(
xo varchar2(5),yo varchar2(5),xd varchar2(5),yd varchar2(5)
);


LOAD DATA INFILE 'delp.csv'
     TRUNCATE
     INTO TABLE codesPostaux
     FIELDS TERMINATED BY ';'
     ( xo ,
     yo,
     xd,
     yd
)


WITH t(x,y,n) AS(
	SELECT 2,2,0 FROM DUAl
	UNION ALL
	SELECT xd,yd,n+1
	FROM t,d
	WHERE t.x = d.xo
	AND t.y= d.yo
	AND n<5
)
SELECT x,y
FROM t
WHERE n=2
GROUP BY x,y;





















