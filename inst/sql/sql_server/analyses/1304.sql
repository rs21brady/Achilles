-- 1304	Number of persons with at least one visit detail, by visit_detail_concept_id by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	vd.visit_detail_concept_id AS stratum_1,
	YEAR(vd.visit_detail_start_date) AS stratum_2,
	p.gender_concept_id AS stratum_3,
	FLOOR((YEAR(vd.visit_detail_start_date) - p.year_of_birth) / 10) AS stratum_4,
	COUNT_BIG(DISTINCT p.PERSON_ID) AS count_value
FROM 
	@cdmDatabaseSchema.person p
JOIN 
	@cdmDatabaseSchema.visit_detail vd ON p1.person_id = vd.person_id 
JOIN
	@cdmDatabaseSchema.observation_period op on vd.person_id = op.person_id
-- only include events that occur during observation period
WHERE 
	op.observation_period_start_date <= vd.visit_detail_start_date 
AND 
	vd.visit_detail_start_date <= COALESCE(vd.visit_detail_end_date,vd.visit_detail_start_date) 
AND
	COALESCE(vd.visit_detail_end_date,vd.visit_detail_start_date) <= op.observation_period_end_date
GROUP BY 
	vd.visit_detail_concept_id,
    YEAR(vd.visit_detail_start_date),
    p.gender_concept_id,
    FLOOR((YEAR(vd.visit_detail_start_date) - p.year_of_birth)/10)
)
SELECT
	1304 as analysis_id,
	CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
	CAST(stratum_2 AS VARCHAR(255)) AS stratum_2,
	CAST(stratum_3 AS VARCHAR(255)) AS stratum_3,
	CAST(stratum_4 AS VARCHAR(255)) AS stratum_4,
	cast(null as varchar(255)) AS stratum_5,
	count_value
INTO @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1304
FROM rawData;
