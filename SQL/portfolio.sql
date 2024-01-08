-- First, let's check the data that we'll be using
-- Since the data includes continents in the entity column, we'll remove them by adding a 
-- Where clause to not include the 'NA' codes (which are the continent's code)
-- Also for World (with code: OWID_WRL)
-- Data Source: https://github.com/rfordatascience/tidytuesday
-- https://www.kaggle.com/datasets/sujaykapadnis/life-expectancy-prediction-dataset
SELECT * FROM life_expectancy
WHERE (code <> 'NA') AND (code <> 'OWID_WRL')

-- Get top 10 countries that have the lowest life expectancy in 1950-1959
-- This decade is marked by the post-World War II boom, the dawn of the Cold War and
-- the civil rights movement in the United States
-- Let's count the number of countries/territories first in that has data in 1950-1959
-- 236 countries/territories are available to be analyzed
SELECT COUNT(DISTINCT(entity)) AS data_count FROM life_expectancy
WHERE (year BETWEEN 1950 AND 1959) AND (code <> 'NA') AND (code <> 'OWID_WRL')

-- These countries came from African and Asian continents with
-- Mali had the lowest life expectancy with an average age of around 29 years 
-- Followed by Afghanistan and East Timor with an average age of around 30 years
SELECT entity, AVG(life_span) AS avg_life_span_50s FROM life_expectancy
WHERE (year BETWEEN 1950 AND 1959) AND (code <> 'NA') AND (code <> 'OWID_WRL')
GROUP BY entity
ORDER BY avg_life_span_50s ASC
LIMIT 10

-- Now, let's get the top 10 countries that have the highest life expectancy in 1950-1959
-- This list is dominated by European and European decent countries, with Norway topping the list with an average age of 73 years.
-- Followed by Iceland, Netherlands, Sweden and Guernsey (which is part of the British Isles) with an average age of 72 years
SELECT entity, AVG(life_span) AS avg_life_span_50s FROM life_expectancy
WHERE (year BETWEEN 1950 AND 1959) AND (code <> 'NA') AND (code <> 'OWID_WRL')
GROUP BY entity
ORDER BY avg_life_span_50s DESC
LIMIT 10

-- Now we're going to look at the discrepancy between the country with the lowest average life span vs 
-- the highest life span
-- We'll create a CTE first to get the average life expectancy in order to perform operations on it
WITH avg_life_expectancy (life_span) 
	AS (
	SELECT AVG(life_span) AS avg_life_span_50s FROM life_expectancy
	WHERE (year BETWEEN 1950 AND 1959) AND (code <> 'NA') AND (code <> 'OWID_WRL')
	GROUP BY entity
	)

-- Get the difference between the highest average age vs the lowest
-- We get around 44 years, that's a whooping 4 decades of age disparity! 
-- If you live in Norway, you'll likely live 4 more decades than if you live in Mali in the 50s
SELECT MAX(life_span)-MIN(life_span) AS age_difference FROM avg_life_expectancy

-- Let's see if that's the same case in the year 2021
-- Many countries experienced economic growth during this period, driven by factors such as globalization, 
-- technological advancements, and increased trade.
-- Also, advances in medical research and technology led to breakthroughs in treatment options for various diseases.
-- Let's count the number of countries/territories first in that has data in 2021
-- 236 countries/territories are available to be analyzed
SELECT COUNT(DISTINCT(entity)) AS data_count FROM life_expectancy
WHERE year = 2021 AND (code <> 'NA') AND (code <> 'OWID_WRL')

-- Check the top 10 countries with the lowest life expectancy
-- Chad topped the list, with age around 53 years followed by Nigeria and Lesotho with around that age also.
SELECT entity, life_span FROM life_expectancy
WHERE year = 2021 AND (code <> 'NA') AND (code <> 'OWID_WRL')
ORDER BY life_span ASC
LIMIT 10

-- Next, let's check the top 10 countries with the highest life expectancy in 2021
-- The average year of the top 10 countries with the highest life expectancy in 2021 is 84.4
-- Monaco topped the list with around 86 years, followed by Hong Kong and Macao.
-- Notice that the top 3 countries/territories are small in terms of area. 
SELECT entity, life_span FROM life_expectancy
WHERE year = 2021 AND (code <> 'NA') AND (code <> 'OWID_WRL')
ORDER BY life_span DESC
LIMIT 10

-- Check discrepancy between the country with the lowest vs highest life expectancy
-- We get 33.4 years in gap. As compared to the 1950s, 
-- there is an 10.6 years of improvement on the difference between the countries/territories with lowest and highest life expectancy
SELECT MAX(life_span)-MIN(life_span) AS age_difference FROM life_expectancy 
WHERE year = 2021 AND (code <> 'NA') AND (code <> 'OWID_WRL')

-- Now let's compare the overall life expectancy vs the life expectancy of males and females
-- Open life_expectancy_male_female
-- life_expectancy_diff is female - male life expectancy
SELECT * FROM life_expectancy_female_male

-- Let's compare the overall life expectancy and the life expectancy difference 
-- between genders in the Philippines
-- Join life_expectancy and life_expectancy_female_male tables
SELECT overall_life_exp.entity, overall_life_exp.year, life_exp_fm_m.life_expectancy_diff, overall_life_exp.life_span 
FROM life_expectancy overall_life_exp
INNER JOIN life_expectancy_female_male life_exp_fm_m
ON overall_life_exp.code = life_exp_fm_m.code
AND overall_life_exp.year = life_exp_fm_m.year
WHERE overall_life_exp.entity = 'Philippines'
ORDER BY overall_life_exp.year

-- Now let's check if there is an increase/decrease of years in life expectancy difference between genders
-- and overall life expectancy for each year in the Philippines 
-- Create rolling count for life expectancy difference between genders in the Philippines
-- Create rolling count for overall life expectancy for each year in the Philippines
-- Used lag to get the previous row value and deduct it to the next year to get the rolling count 
-- Used coalesce to make null values '0'
-- Create CTE (common table expression) to perform operations (get MAX, MIN)
WITH rolling (entity, year, gender_diff, gender_diff_rolling_count, overall_life_span, overall_rolling_count)
	AS(
	SELECT overall_life_exp.entity, overall_life_exp.year, life_exp_fm_m.life_expectancy_diff AS gender_diff,
	COALESCE(life_exp_fm_m.life_expectancy_diff - LAG(life_exp_fm_m.life_expectancy_diff) 
			 OVER (PARTITION BY overall_life_exp.entity 
				   ORDER BY overall_life_exp.year), 0)
				   AS gender_diff_rolling_count,
	overall_life_exp.life_span AS overall_life_span,
	COALESCE(overall_life_exp.life_span - LAG(overall_life_exp.life_span) 
			 OVER (PARTITION BY overall_life_exp.entity 
				   ORDER BY overall_life_exp.year), 0)
				   AS overall_rolling_count
	FROM life_expectancy overall_life_exp
	INNER JOIN life_expectancy_female_male life_exp_fm_m
	ON overall_life_exp.code = life_exp_fm_m.code
	AND overall_life_exp.year = life_exp_fm_m.year
	WHERE overall_life_exp.entity = 'Philippines'
	ORDER BY overall_life_exp.year
	)

-- Using 'rolling' virtual table, we can get the top 10 years that has the highest age difference between genders
-- 2021 saw a huge disparity between male and female life expectancy with around 0.56 years,
-- which tells us that female tend to live around 6 months more than males in the Philippines
SELECT entity, year, gender_diff, gender_diff_rolling_count
FROM rolling
ORDER BY gender_diff_rolling_count DESC
LIMIT 10

-- Using 'rolling' virtual table, we can get the top 10 years that has the highest year/s 
-- added to a filipino's life span
-- 1992 had the highest uptick, with 0.78 years added as compared to the previous year
SELECT entity, year, overall_life_span, overall_rolling_count
FROM rolling
ORDER BY overall_rolling_count DESC
LIMIT 10