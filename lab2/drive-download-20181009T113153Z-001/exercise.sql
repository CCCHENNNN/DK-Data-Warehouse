1.3
1.

SELECT country, COUNT(customer_id) AS nbcustomer
FROM customers
GROUP BY country;

2.
SELECT ship_country,ship_city,COUNT(order_id) AS nborders
FROM orders
GROUP BY rollup(ship_country,ship_city)
ORDER BY ship_country,ship_city;

3.
SELECT ct.country AS c_country,sp.country AS s_country, SUM(od.quantity) AS quantity,COUNT(DISTINCT od.order_id) AS nborder
FROM order_details od,orders os,customers ct,products pr,suppliers sp
WHERE od.order_id = os.order_id
AND os.customer_id = ct.customer_id
AND od.product_id = pr.product_id
AND pr.supplier_id = sp.supplier_id
GROUP BY ct.country,sp.country
ORDER BY ct.country,sp.country;

4.
SELECT ct.country AS c_country,sp.country AS s_country, SUM(od.quantity) AS quantity,COUNT(DISTINCT od.order_id) AS nborder
FROM order_details od,orders os,customers ct,products pr,suppliers sp
WHERE od.order_id = os.order_id
AND os.customer_id = ct.customer_id
AND od.product_id = pr.product_id
AND pr.supplier_id = sp.supplier_id
GROUP BY cube(ct.country,sp.country)
ORDER BY ct.country,sp.country;

5.
SELECT os.ship_country AS ship_country,os.ship_region AS ship_region,os.ship_city AS ship_city,SUM(od.unit_price * od.quantity) AS price
FROM order_details od,orders os,products pr,suppliers sp
WHERE od.order_id = os.order_id
AND od.product_id = pr.product_id
AND pr.supplier_id = sp.supplier_id
AND sp.country = 'France'
GROUP BY os.ship_country,rollup(os.ship_region,os.ship_city);

SELECT os.ship_country AS ship_country,os.ship_region AS ship_region,os.ship_city AS ship_city,SUM(od.unit_price * od.quantity) AS price
FROM order_details od,orders os,products pr,suppliers sp
WHERE od.order_id = os.order_id
AND od.product_id = pr.product_id
AND pr.supplier_id = sp.supplier_id
AND sp.country = 'France'
GROUP BY GROUPING SETS((os.ship_country,os.ship_region,os.ship_city),(os.ship_country,os.ship_region),(os.ship_country));

6.
SELECT ship_country,
CASE WHEN GROUPING(ship_city) = 1 AND GROUPING(ship_country) = 0 THEN 'whole country' ELSE ship_city END s_city,
COUNT(order_id) AS nborders
FROM orders
GROUP BY rollup(ship_country,ship_city)
ORDER BY ship_country,ship_city;

1.4
1.
SELECT ship_country,ship_city,
COUNT(DISTINCT order_id) AS nborders,
MAX(COUNT(DISTINCT order_id)) OVER(PARTITION BY ship_country) AS nbordcty,
SUM(COUNT(DISTINCT order_id)) OVER(PARTITION BY ship_country) AS nbormaxcty
FROM orders
GROUP BY ship_country,ship_city
ORDER BY ship_country,ship_city;

2.
SELECT ship_country,ship_city,COUNT(DISTINCT order_id) AS nborders,
RANK() OVER(PARTITION BY ship_country ORDER BY COUNT(DISTINCT order_id)) rank
FROM orders
GROUP BY ship_country,ship_city
ORDER BY ship_country,rank;

3.
SELECT ship_country,ship_city,COUNT(DISTINCT order_id) AS nborders,
RANK() OVER(PARTITION BY ship_country ORDER BY COUNT(DISTINCT order_id)) rank,
RATIO_TO_REPORT(COUNT(DISTINCT order_id)) OVER(PARTITION BY ship_country) percentg
FROM orders
GROUP BY ship_country,ship_city
ORDER BY ship_country,rank;

4.
WITH preceding_price AS(
	SELECT order_id,SUM(unit_price * quantity) AS price,
	LAG(SUM(unit_price * quantity)) OVER (ORDER BY order_id) pre_price
	FROM order_details
	GROUP BY order_id
)
SELECT order_id,price
FROM preceding_price
WHERE price < 1.1 * pre_price;

5.
WITH year_product AS(
	SELECT 
	EXTRACT(year FROM os.order_date) AS year,
	pr.product_name AS product_name,
	SUM(od.quantity) AS qtity,
	MAX(SUM(od.quantity)) OVER(PARTITION BY EXTRACT(year FROM os.order_date)) AS maxp
	FROM order_details od,orders os,products pr
	WHERE od.product_id = pr.product_id
	AND od.order_id = os.order_id
	GROUP BY EXTRACT(year FROM os.order_date),pr.product_name
)
SELECT year,product_name,qtity
FROM year_product
WHERE qtity = maxp
ORDER BY year desc;

WITH year_product AS(
	SELECT EXTRACT(year FROM os.order_date) AS year,
	pr.product_name AS product_name,
	SUM(od.quantity) AS qtity
	FROM order_details od,orders os,products pr
	WHERE od.product_id = pr.product_id
	AND od.order_id = os.order_id
	GROUP BY EXTRACT(year FROM os.order_date),pr.product_name
)
SELECT year,MAX(qtity)
FROM year_product
GROUP BY year;

1.5
WITH temp(nb) AS(
	SELECT 0 FROM DUAL
	UNION ALL
	SELECT nb+1 FROM temp
	WHERE nb<60
)
SELECT *
FROM temp;

1.6
WITH months(i,month) AS(
	SELECT 0,to_char(sysdate,'mm-yy') FROM DUAL
	UNION ALL
	SELECT i+1,to_char(ADD_MONTHS(sysdate,i),'mm-yy') FROM months
	WHERE i <= 30
)
SELECT month FROM months;

WITH seq(n,un) AS(
	SELECT 0,127 FROM DUAL
	UNION ALL
	SELECT n+1,
	CASE WHEN MOD(un,2)=0 THEN un/2
	ELSE TRUNC(3*un/2+1) END FROM seq
	WHERE n<50
)
SELECT * FROM seq;

--TP1
1.1
egrep '^aa' words
egrep '^a{2}' words
egrep -c 'hard' words
egrep 'hard' words | wc -l
egrep --color='auto' '[^aeiouy]{6}' words
egrep '[^[=a=][=e=][=i=][=o=][=u=][=y=]]{6}' words
egrep --color='auto' '([a-zA-Z])\1\1' words
egrep --color='auto' '([[:alpha:]])\1\1' words

1.2
???并没有什么变化

CREATE TABLE codesPostaux(
    insee varchar2(6),
    nom_commune varchar2(50),
    zip varchar2(50),
    LIBELLE varchar2(50),
    dum1 varchar2(50)
);

vim control.txt
LOAD DATA INFILE 'codes_postaux.csv'
TRUNCATE
INTO TABLE codesPostaux
FIELDS TERMINATED BY ';'
(insee,nom_commune,zip, LIBELLE,dum1)

vim bad.txt
vim log.txt
sqlldr userid=C##hchen4_a/hchen4_a control=control.txt log=log.txt bad=bad.txt \direct=y errors=0 skip=1

SELECT insee,nom_commune
FROM codesPostaux
WHERE nom_commune LIKE '%VIGNOBLE%';

SELECT insee,nom_commune
FROM codesPostaux
WHERE REGEXP_LIKE(nom_commune,'VIGNOBLE');


SELECT nom_commune
FROM codesPostaux
WHERE REGEXP_LIKE(nom_commune,' S(AIN)?T ')
OR REGEXP_LIKE (nom_commune,'^S(AIN)?T');

UPDATE codesPostaux
SET INSEE=REGEXP_REPLACE(INSEE,'2A','20');


















