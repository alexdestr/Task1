WITH arrest_count AS (
  SELECT officer_defined_ethnicity, COUNT(*) FROM stopandsearchesbyforce
  WHERE outcome = 'Arrest'
  GROUP BY officer_defined_ethnicity
  HAVING TO_DATE(month, 'YYYY-MM') >= TO_DATE(''|| ? ||'', 'YYYY-MM')
  AND TO_DATE(month, 'YYYY-MM') <= TO_DATE(''|| ? ||'', 'YYYY-MM')
),

release_count AS (
  SELECT officer_defined_ethnicity, COUNT(*) FROM stopandsearchesbyforce
  WHERE outcome = 'A no further action disposal'
  GROUP BY officer_defined_ethnicity
  HAVING TO_DATE(month, 'YYYY-MM') >= TO_DATE(''|| ? ||'', 'YYYY-MM')
  AND TO_DATE(month, 'YYYY-MM') <= TO_DATE(''|| ? ||'', 'YYYY-MM')
),

other_count AS (
  SELECT officer_defined_ethnicity, COUNT(*) FROM stopandsearchesbyforce
  WHERE outcome != 'Arrest' AND outcome != 'A no further action disposal' AND outcome IS NOT NULL
  GROUP BY officer_defined_ethnicity
  HAVING TO_DATE(month, 'YYYY-MM') >= TO_DATE(''|| ? ||'', 'YYYY-MM')
  AND TO_DATE(month, 'YYYY-MM') <= TO_DATE(''|| ? ||'', 'YYYY-MM')
),

object_of_search AS (
  SELECT officer_defined_ethnicity, object_of_search, "count",
         ROW_NUMBER() OVER (PARTITION BY officer_defined_ethnicity ORDER BY "count" DESC) AS rn
  FROM (SELECT officer_defined_ethnicity, object_of_search, COUNT(*) FROM stopandsearchesbyforce GROUP BY officer_defined_ethnicity, object_of_search
  HAVING TO_DATE(month, 'YYYY-MM') >= TO_DATE(''|| ? ||'', 'YYYY-MM')
  AND TO_DATE(month, 'YYYY-MM') <= TO_DATE(''|| ? ||'', 'YYYY-MM')) AS a
)

SELECT a.officer_defined_ethnicity, a.count, concat(round(cast(b.count AS decimal) / (cast(a.count AS decimal)) * 100, 1), '%') AS arrest_rate, concat(round(cast(c.count AS decimal) / (cast(a.count AS decimal)) * 100, 1), '%') AS release_count, concat(round(cast(d.count AS decimal) / (cast(a.count AS decimal)) * 100, 1), '%') AS other_outcomes_count, f.object_of_search
FROM
(SELECT a.officer_defined_ethnicity, COUNT(*)
FROM stopandsearchesbyforce AS a
GROUP BY a.officer_defined_ethnicity)
AS a
JOIN arrest_count AS b ON a.officer_defined_ethnicity = b.officer_defined_ethnicity
JOIN release_count AS c ON b.officer_defined_ethnicity = c.officer_defined_ethnicity
JOIN other_count AS d ON c.officer_defined_ethnicity = d.officer_defined_ethnicity
JOIN object_of_search AS f ON d.officer_defined_ethnicity = f.officer_defined_ethnicity
GROUP BY a.officer_defined_ethnicity, a.count, arrest_rate, release_count, other_outcomes_count, f.object_of_search, f.rn
HAVING f.rn = 1