/*	Create a list of food service businesses and their owners. Include the business id, 
	business name, owner name, owner address, owner city, owner state, and owner ZIP columns. 
	Sort the results by state, city, and business name. */

SELECT business_id, [name], owner_name, owner_address, owner_city, owner_state, owner_zip
FROM businesses
ORDER BY owner_state, owner_city, [name];

-- RESULTS: 7,527 records

/*	How many records per business are included in the inspections table? Sort the 
	result set in descending order by record count. */

SELECT business_id, COUNT(*) AS [Number of Inspections]
FROM inspections
GROUP BY business_id
ORDER BY 2 DESC; 

-- RESULTS: 5,926 records; most inspections = 22; least inspections = 1
-- It appears that some businesses have never been inspected

/* ALTERNATE SOLUTION  */

-- the key difference is this query only returns records for businesses in inspections
-- that exist in businesses
-- not the main solution since did not specify to filter the inspections table for matching businesses

SELECT b.business_id, COUNT(*) AS [Number of Inspections]
FROM inspections i
		JOIN businesses b ON i.business_id = b.business_id
GROUP BY B.business_id
ORDER BY 2 DESC

-- there are 22 businesses in inspections that have no matching record in businesses  
-- and 86 associated inspections records shown by the following queries 

SELECT DISTINCT business_id
FROM inspections
WHERE business_id NOT IN 
	(SELECT DISTINCT business_id FROM businesses)

SELECT *
FROM inspections
WHERE business_id NOT IN 
	(SELECT DISTINCT business_id FROM businesses)

/*	Are there any businesses in the violations table that are not 
	in the businesses table? */

SELECT DISTINCT business_id
FROM violations
WHERE business_id NOT IN 
	(SELECT DISTINCT business_id FROM businesses);

-- RESULTS: 22 records meaning 22 businesses are listed in violations but have no match in businesses

/* ALTERNATE SOLUTION */
 
-- the key difference is the first query returns the 22 business ids for businesses that 
-- are in the violations table but not in the businesses table

-- the second query returns all violations records (109) for the 22 businesses in the violations table
-- that do not have a matching record in the businesses table. It is difficult to know how many 
-- businesses are in the violations table that do not have matches in the businesses table

SELECT *
FROM violations
WHERE business_id NOT IN 
	(SELECT DISTINCT business_id FROM businesses);

/*	How many violations does each business have for each inspection? Your 
	response should only include businesses that exist in the businesses table. */

SELECT b.business_id, i.[date], i.Score, COUNT(*) AS [Number of Violations]
FROM violations v JOIN businesses b
	ON b.business_id = v.business_id JOIN inspections i 
	ON i.[date] = v.[date] and i.business_id = v.business_id
GROUP BY b.business_id, i.[date], i.Score
ORDER BY b.business_id, i.[date], i.Score;

--	RESULTS: 13,835 records

/* ALTERNATE SOLUTION */

-- the key difference between this alternative and the first solution is selecting and grouping 
-- inspection score. By excluding the inspection score, this solution ignores that multiple 
-- inspections could occur on a single day with a different outcomes. 

SELECT b.business_id, v.[date], COUNT(*) AS [Number of Violations]
FROM violations v JOIN businesses b
	ON b.business_id = v.business_id 
GROUP BY b.business_id, v.[date]
ORDER BY b.business_id;

-- RESULTS: 12,884 records

/* ALTERNATE SOLUTION */
-- this solution will receive full credit

-- the key difference between this alternative and the previous alternative is grouping by business_id
-- instead of business name. The difference in records (54) implies there are some businesses with
-- the exact same name but different business_id values. 

SELECT b.name, v.date, COUNT(*) AS [Number of Violations]
FROM businesses b JOIN violations v
	ON b.business_id = v.business_id 
GROUP BY b.name, v.date
ORDER BY b.name;

-- RESULTS: 12,830 records 

/* ALTERNATE SOLUTION */
-- this solution will receive partial credit

-- a key difference between for this alternative is the other solutions only returns records
-- for business_id values in violations that exist in businesses

SELECT business_id, [date], COUNT(*) AS [Number of Violations]
FROM violations 
GROUP BY business_id, [date]
ORDER BY business_id;

-- RESULTS: 12,935 records

/*	List the business id, business name, inspection date, inspection score, and 
	inspection type for all inspections that included violation type id = 103123 (food in 
	poor condition).  */

SELECT b.business_id, b.name, i.date, i.Score, i.type
FROM businesses b JOIN inspections i
	ON b.business_id = i.business_id JOIN violations v
	ON i.business_id = v.business_id AND i.date = v.date
WHERE ViolationTypeID = '103123'; 

-- RESULTS: 98 records

-- As an interesting side note, the following query shows there are only 89 records 
-- in the violations table with ViolationTypeID = '103123'

SELECT business_id, date
FROM violations
WHERE ViolationTypeID ='103123' 
ORDER BY business_id, date;

-- The 98 records returned in the first query occurs because their are 11 businesses 
-- that had multiple inspections on the day they received a 103123 violation and 
-- the business_id + date combination are not sufficient to uniquely identify
-- which violation records go with which inspection. Thus, the join returns double
-- match for those 11. (needs further investiation to identify missing results)

-- 89 (records from violations table with 103123) - 11 (duplicates) = 78 
-- 78 + 22 (duplicate records) = 100

SELECT i.business_id, count(*)
FROM inspections i JOIN violations v
	ON i.business_id = v.business_id AND i.date = v.date
WHERE ViolationTypeID = '103123'
GROUP BY i.business_id
ORDER BY 2 desc;

SELECT b.business_id, b.name, i.date, i.Score, i.type
FROM businesses b JOIN inspections i
	ON b.business_id = i.business_id JOIN violations v
	ON i.business_id = v.business_id AND i.date = v.date
WHERE ViolationTypeID = '103123' AND i.Score <> '';

SELECT b.business_id, b.name, i.date, i.Score, i.type
FROM businesses b JOIN inspections i
	ON b.business_id = i.business_id JOIN violations v
	ON i.business_id = v.business_id AND i.date = v.date
WHERE ViolationTypeID = '103123' AND i.Score = '';

/*	Create a list of latitude/longitude pairs for businesses that have latitude 
	and longitude values and the latitude and longitude values are not equal to �0�. The result 
	table should include business name, latitude, longitude, and the latitude/longitude pair. 
	If the latitude for a record = 37.8 and longitude = -122.5, the latitude/longitude pair 
	should look like (37.8, -122.5). Your result should include the (), comma, and space.  */

SELECT name, latitude, longitude, '(' + latitude + ', ' + longitude + ')' AS 'Lat/Long Pair'
FROM businesses
WHERE latitude <> '' AND longitude <> '' AND latitude <> '0' AND longitude <> '0'
ORDER BY latitude, longitude;

-- RESULTS: 4,511 records

/*	Explore the type column in the inspections table. The data dictionary indicates 
	that the inspection type �must be (initial, routine, followup).� Are there any inspections with 
	an inspection type that is not a valid value? List the business id, business name, inspection 
	date, and inspection type for any inspections with invalid inspection types. Sort your results 
	by inspection type.  */

-- this solution does not tell a complete story 

SELECT b.business_id, b.name, i.date, i.type, i.Score
FROM businesses b JOIN inspections i
	ON b.business_id = i.business_id
WHERE i.type NOT IN ('initial', 'routine', 'followup')
ORDER BY i.type;

-- RESULTS: 27,249 records

-- as it turns out, no inspection types have an exact match with the values in 
-- the data dictionary (i.e., the words initial, routine, or followup)
-- the following query shows 13 different inspection type values in inspections   

SELECT DISTINCT type
FROM inspections
ORDER BY type;

-- a visual scan of these results reveals two values that include the word 'routine'
-- (e.g., 'Routine - Scheduled' and 'Routine - Unscheduled')
-- two values includes the word 'followup' (e.g., 'Reinspection/Followup' and 'Complaint Reinspection/Followup')
-- the following query filters results by removing results that include these four inspection types

SELECT b.business_id, b.name, i.date, i.type, i.Score
FROM businesses b JOIN inspections i
	ON b.business_id = i.business_id
WHERE i.type NOT LIKE '%initial%' AND i.type NOT LIKE '%routine%' AND i.type NOT LIKE '%followup%'
ORDER BY i.type;

-- RESULTS: 6,131 records

-- an interesting observation is that only three of these inspections that have non-valid inspection types
-- according to the data dictionary have inspection scores (change order by to i.score desc)


/*	Explore the score column in the inspections table. Add a column with an appropriate numeric 
	data type to store a �cleaned� version of the score. Clean the score data by converting the data into 
	appropriate numeric values and storing the cleaned values in the new column you added. Store a NULL 
	value in the cleaned column for any records with unknown numeric values for score.  */

-- create a clean inspections table to work with

SELECT * 
INTO clean_inspections
FROM inspections;

-- see what values are in the scores column and how many records are
-- associated with each value

SELECT Score, COUNT(*) AS [number of records]
FROM clean_inspections
GROUP BY Score
ORDER BY Score;

-- 11,858 records have a blank score (representing 43.5% of
-- the records in the inspections table) I will convert these
-- blank values into NULL in the cleaned data column
-- the other values in the score column appear to be valid
-- integers between 0 and 100 I will convert these values
-- from string to integer data type in the clean column

ALTER TABLE clean_inspections
ADD clean_score int NULL;

-- this query checks the records with blank scores

SELECT *
FROM clean_inspections
WHERE Score = '';

-- this query converts scores that are not blank into integers and stores them in the clean_scores column

UPDATE clean_inspections
SET clean_score =
	CAST(Score AS int)
WHERE Score <> '';

-- the records with blank score have NULL stored in clean_score from new column creation
-- this query allows me to visually scan to see if my previous work was recorded accurately

SELECT * FROM clean_inspections;

-- It appears that my conversion to int data type for clean_score was completed accurately

/* Assume you would like to convert the violation risk category into a set of 
	numeric values where High Risk = 3, Moderate Risk = 2, and Low Risk = 1 (i.e., create 
	a �risk score� for each category). Add a column with an appropriate numeric data type 
	to the violations table to store the numeric values for risk category. For each record, 
	convert the risk category into a numeric score to store in the new column. The values in 
	this new column represent a risk score.  */

-- create a clean_violations table to work with

SELECT *
INTO clean_violations
FROM violations;

-- add a new column to store the clean_risk_score data

ALTER TABLE clean_violations
ADD clean_risk_score int NULL;

-- investigate the risk categories column values

SELECT risk_category, COUNT(*) AS [numer of records]
FROM clean_violations
GROUP BY risk_category;

-- I see 3 'N/A' records. I will convert these values to NULL risk scores
-- convert the text based risk categories into numeric risk scores

UPDATE clean_violations
SET clean_risk_score = 
	CASE risk_category
		WHEN 'High Risk'		THEN 3
		WHEN 'Moderate Risk'	THEN 2
		WHEN 'Low Risk'			THEN 1
		ELSE NULL
	END

--	I used the following query to visually scan the cleaned data to confirm successful updates
	
SELECT * FROM clean_violations ORDER BY clean_risk_score;

-- It appears my data conversion was successful

/*	Create a new table that includes the following columns from the inspections and 
	violations tables. Name the new table [cleaned_inspections_data]. 

	a.	Business id
	b.	Inspection date
	c.	Inspection score (cleaned version)
	d.	Inspection type
	e.	Count of violation records associated with the inspection
	f.	Total risk score for the violations associated with the inspection (see #9)
  */

-- I will use a select into statement to create the final data set. Because the question does not
-- ask for any fields that are included in the businesses table beyond the business_id, I will 
-- only use the inspections and violations table

-- to get accurate aggregations, I have to join inspections to violations on business_id and date
-- as both are required to uniquely match an inspection to a violation

-- I can count the number of violation records to get number of violations for each inspection
-- I can sum the newly created risk score values to get the total score for each inspection

SELECT	i.business_id, 
		i.[date], 
		i.clean_score, 
		i.[type], 
		COUNT(i.business_id) as [number of violations], 
		SUM(v.clean_risk_score) as [total risk score]
INTO cleaned_inspections_data
FROM clean_inspections i
	JOIN clean_violations v
	ON i.business_id = v.business_id AND i.[date] = v.[date]
GROUP BY i.business_id, i.[date], i.clean_score, i.[type];

-- RESULTS: 13,950 records

-- I used this query to visually scan my results to confirm I selected the right data
-- and that my aggregate queries did what I expected. 

SELECT * FROM cleaned_inspections_data;

/* ADDITIONAL NOTES AND OBSERVATIONS */

/*	

	The collective data represented by the inspections and violations tables is 
	problematic because you have to use business_id, date, and type to uniquely 
	identify a single inspection in the inspection table. However, the violations 
	table does not include the inspection type field. Thus, it is not possible to
	uniquely match an inspection record with the set of violation records for that
	inspection. 

	As a result, the query I provide above as a "solution" to question 10 can only 
	be considered logically "correct" because it represents the idea of matching the
	inspection and violation data from the two tables. However, from a technical 
	standpoint the resulting data should not be used for any additional analysis
	without further investigation to determine the best way to match violation records
	with inspection records. 

	In grading responses to question 10, I operated under the assumption stated in the
	exam specifications that the combination of business_id and date could uniquely 
	match inspections to violations. As a result, answers like the one I share above received
	full credit as long as you provided sufficient comments to support your selection. 

*/

-- This next query shows that a number of businesses had multiple inspections on the same date

select business_id, [date], count(*) as [number of records]
from clean_inspections
group by business_id, [date]
having count(*) > 1
order by 3 desc, 1, 2

-- I used business_id = 3819 and date = 20150610 to explore the violations table

select business_id, [date], count(*) as [number of records]
from clean_violations
where business_id = '3819' and [date] = '20150610'
group by business_id, [date]
order by 3 desc, 1, 2

-- to use the inspection and violation data, I somehow need to resolve how the three violations
-- in the violations table for business 3819 on 20150610 match with the four records in the
-- inspections table for the same business on the same date. 