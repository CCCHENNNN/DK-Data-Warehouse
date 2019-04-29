set heading off
set feedback off
set markup csv on
spool heatmap-cte.csv
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