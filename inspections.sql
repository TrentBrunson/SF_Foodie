/*
Write SQL Statements to answer each of the following questions. You should use a single SQL statement
for each question. The overall purpose of these questions is to confirm that you understand the basic
syntax and functionality of SQL. In answering these questions, do not worry about the �quality� of the
data. Write the queries to retrieve data �as is�.
1. (5 points) Create a list of food service businesses and their owners. Include the business id,
business name, owner name, owner address, owner city, owner state, and owner ZIP columns.
Sort the results by state, city, and business name.
2. (5 points) How many records per business are included in the inspections table? Sort the result
set in descending order by record count.
3. (10 points) Are there any businesses in the violations table that are not in the businesses table?
4. (10 points) How many violations does each business have for each inspection? Your response
should only include businesses that exist in the businesses table.
5. (10 points) List the business id, business name, inspection date, inspection score, and inspection
type for all inspections that included violation type id = 103123 (food in poor condition).
6. (10 points) Create a list of latitude/longitude pairs for businesses that have latitude and
longitude values and the latitude and longitude values are not equal to �0�. The result table
should include business name, latitude, longitude, and the latitude/longitude pair. If the latitude
for a record = 37.8 and longitude = -122.5, the latitude/longitude pair should look like (37.8, -
122.5). Your result should include the (), comma, and space. 
*/

-- initial familiarity checks
--check data in tables
SELECT TOP 1000 * FROM businesses;
-- lots of variation in city name for the same city; use other fields
-- records appear mostly unique
SELECT TOP 1000 * FROM inspections;
-- 4 columns; score column with many empty cells
-- biz ID may match to businesses table
SELECT TOP 1000 * FROM violations;
-- 5 columns; same biz ID values; no nulls observed

-- 1. Create a list of food service businesses and their owners. Include the business id,
-- business name, owner name, owner address, owner city, owner state, and owner ZIP columns.
SELECT business_id, name, owner_name, owner_address, owner_city, owner_state, owner_zip
	FROM businesses
	ORDER BY owner_state, owner_city, name
	-- many nulls in owner data; 7527 rows

-- 2. (5 points) How many records per business are included in the inspections table? Sort the result
-- set in descending order by record count.
select business_id, COUNT(business_id) recordCount from inspections
	GROUP BY business_id
	ORDER BY recordCount DESC;
	-- 5926 biz records that includes a max count of 22 for biz ID 1775

-- 3. (10 points) Are there any businesses in the violations table that are not in the businesses table?

SELECT * FROM violations
	WHERE business_id NOT IN
		(SELECT DISTINCT business_id FROM businesses);
-- 109 violation records returned not in the businesses table

SELECT DISTINCT business_id FROM violations
	WHERE business_id NOT IN
		(SELECT DISTINCT business_id FROM businesses);
		-- 22 unique values

-- 4. (10 points) How many violations does each business have for each inspection? Your response
-- should only include businesses that exist in the businesses table.
SELECT * FROM violations
	WHERE business_id IN
		(SELECT DISTINCT business_id FROM businesses);
-- 40183 rows in violation table out of 40292 rows that were found in the biz table

SELECT business_id, ViolationTypeID, COUNT(ViolationTypeID) cnt, description FROM violations
	WHERE business_id IN
		(SELECT DISTINCT business_id FROM businesses)
	GROUP BY business_id, ViolationTypeID, description;
	-- 31750 rows; some businesses with 1 violation; some with multiple
	-- visual scan seems to show all have a violation type and description filled in


	-- 90 records not in the biz table; some businesses with 1 violation; some with multiple
	-- one row for biz ID 7642 with a count but not type or decription

-- 5. (10 points) List the business id, business name, inspection date, inspection score, and inspection
-- type for all inspections that included violation type id = 103123 (food in poor condition).
SELECT b.business_id,
		b.name,
		i.date,
		i.Score,
		i.type  --,
		-- v.ViolationTypeID, comment out to match question; include only to verify pulled valid ID
		-- v.description
	FROM businesses b JOIN inspections i  ON
		b.business_id = i.business_id JOIN violations v ON
			i.business_id = v.business_id
	WHERE v.ViolationTypeID = '103123';
	-- 531 rows

/*
6. (10 points) Create a list of latitude/longitude pairs for businesses that have latitude and
longitude values and the latitude and longitude values are not equal to �0�. The result table
should include business name, latitude, longitude, and the latitude/longitude pair. If the latitude
for a record = 37.8 and longitude = -122.5, the latitude/longitude pair should look like (37.8, -
122.5). Your result should include the (), comma, and space.
*/

-- first check the pairs of lat-long are paired up
SELECT * 
	FROM businesses
	WHERE latitude <> '';
--4526 rows
SELECT * 
	FROM businesses
	WHERE longitude <> '';
-- 4526 rows
-- no visual blanks observed

SELECT name, latitude, longitude,
	'(' + latitude + ', ' + longitude + ')' [Latitude/Longitude Pair]
	FROM businesses
	WHERE longitude <> '';
	--4526 rows returned with the new columns

/*
Advanced SQL Queries
Write SQL statements to answer each of the following questions. Use as many SQL statements as
necessary to respond to the question. Add comments to explain your actions, observations, and
conclusions.

7. (15 points) Explore the type column in the inspections table. The data dictionary indicates that
the inspection type �must be (initial, routine, followup).� Are there any inspections with an
inspection type that is not a valid value? List the business id, business name, inspection date,
and inspection type for any inspections with invalid inspection types. Sort your results by
inspection type.
*/
SELECT DISTINCT type
	FROM inspections;
	-- 13 types, no blanks or nulls in this list
	-- 2 are types of 'Routine'
	-- 2 new = New Ownership, new construction
	-- 2 possible reinspections including: reinspection/follow-up, complaint reinspection/follow-up 
	-- perhaps the others are variations of new and routine (adminstrative may be routine); perhaps a parent category is missing
SELECT b.business_id, name, date, type
	FROM inspections i JOIN businesses b ON
		i.business_id = b.business_id
	WHERE type NOT LIKE '%New%' AND type NOT LIKE '%Routine%' AND type NOT LIKE '%Followup%'
	ORDER BY type
	;
-- done verifying

-- final answer
SELECT b.business_id, name, date, type
	FROM inspections i JOIN businesses b ON
		b.business_id = i.business_id
	WHERE type NOT LIKE '%New%' AND type NOT LIKE '%Routine%' AND type NOT LIKE '%Followup%'
	ORDER BY type
	;


/*
8. Explore the score column in the inspections table. Add a column with an appropriate
numeric data type to store a �cleaned� version of the score. Clean the score data by converting
the data into appropriate numeric values and storing the cleaned values in the new column you
added. Store a NULL value in the cleaned column for any records with unknown numeric values
for score.
*/

SELECT Score
	FROM inspections;
	-- some blanks; will add nulls for these

-- doing data cleaning, so will make new tables
SELECT * INTO businessAnalysis FROM businesses;
SELECT * INTO inspectionsAnalysis FROM inspections;
SELECT * INTO violationsAnalysis FROM violations;

/*
(7527 rows affected)

(27283 rows affected)

(40292 rows affected)
*/

ALTER TABLE inspectionsAnalysis
ADD [clean_Score] INT null;

SELECT clean_Score FROM inspectionsAnalysis;
-- verified null fields; checked object explorer to verify data type as int and nullable 
UPDATE inspectionsAnalysis
	SET clean_Score = Score
	WHERE Score <> '';

SELECT clean_Score, Score FROM inspectionsAnalysis;
-- nulls populated and values match for 27283 rows


/*
9. Assume you would like to convert the violation risk category into a set of numeric
values where High Risk = 3, Moderate Risk = 2, and Low Risk = 1 (i.e., create a �risk score� for
each category). Add a column with an appropriate numeric data type to the violations table to
store the numeric values for risk category. For each record, convert the risk category into a
numeric score to store in the new column. The values in this new column represent a risk score. 
*/

ALTER TABLE violationsAnalysis
ADD [Risk_Score] INT null;

SELECT Risk_Score FROM violationsAnalysis;
-- verified null fields; checked object explorer to verify data type as int and nullable 
SELECT DISTINCT risk_category FROM violationsAnalysis;
-- verify values

UPDATE violationsAnalysis
	SET Risk_Score = (CASE WHEN risk_category = 'Low Risk' THEN 1
							WHEN risk_category = 'Moderate Risk' THEN 2
							WHEN risk_category = 'High Risk' THEN 3
						END)
	;
-- 40292 rows affected
SELECT * FROM violationsAnalysis ORDER BY Risk_Score;
-- verified that the N/A are nulls now and values as prescribed


/*
10.  Create a new table that includes the following columns from the inspections and
violations tables. Name the new table [cleaned_inspections_data].
a. Business id
b. Inspection date
c. Inspection score (cleaned version)
d. Inspection type
e. Count of violation records associated with the inspection
f. Total risk score for the violations associated with the inspection (see #9)
*/

SELECT business_id, date, ViolationTypeID, COUNT(ViolationTypeID) 
	FROM violationsAnalysis
	GROUP BY business_id, ViolationTypeID, date
	ORDER BY date, business_id;

SELECT i.business_id [Business ID], 
		i.date [Inspection Date], 
		clean_Score [Inspection Score], 
		type [Inspection Type], 
		COUNT(ViolationTypeID) ViolationCount, 
		Risk_Score [Total Risk Score] 
	INTO cleaned_inspections_data 
	FROM inspectionsAnalysis i JOIN violationsAnalysis v ON
		i.business_id = v.business_id AND i.date = v.date 
	GROUP BY i.business_id, i.date, clean_Score, type, Risk_Score;
	-- 24889 rows affected

-- verify desired results achieved
SELECT * FROM cleaned_inspections_data ORDER BY [Inspection Date], [Business ID];
-- nulls present in clean_Score
-- 6 columns with new headers
-- 24889 rows


-- verfying ***********************************************************
-- samples from all tables
SELECT * from violationsAnalysis WHERE business_id = '10877'
SELECT * from inspectionsAnalysis WHERE business_id = '10877'
SELECT * from cleaned_inspections_data WHERE [Business ID] = '10877'

SELECT * from violationsAnalysis WHERE business_id = '1352'
SELECT * from inspectionsAnalysis WHERE business_id = '1352'
SELECT * from cleaned_inspections_data WHERE [Business ID] = '1352'

-- w/out the date condition for the join
SELECT i.business_id [Business ID], 
		i.date [Inspection Date], 
		clean_Score [Inspection Score], 
		type [Inspection Type], 
		COUNT(ViolationTypeID) ViolationCount, 
		Risk_Score [Total Risk Score] 
	FROM inspectionsAnalysis i JOIN violationsAnalysis v ON
		i.business_id = v.business_id  
	GROUP BY i.business_id, i.date, clean_Score, type, Risk_Score;
-- got worse - more duplicate entries: 60043 rows
/*
This is producing errors due to the assignment of Risk Score based on
Risk Category.  There were multiple violations in a single inspection date
so there are multiple Risk Scores now for each date; JOINS will need to be corrected
*/