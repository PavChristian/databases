-- Preliminary EDA 

SELECT *
FROM marketing
LIMIT 10;

SELECT COUNT(*)
FROM marketing;

-- Checking for duplicates

SELECT id, COUNT(*)
FROM marketing
GROUP BY id
HAVING COUNT(*) > 1;

-- Obtaining unique campaign names 

SELECT DISTINCT campaign_name 
FROM marketing;

-- Calculating median Return on Marketing Investment (ROMI)

#Calling CalculateROMI from Functions

SELECT 
	CalculateROMI (SUM(revenue), SUM(mark_spent)) AS overall_romi
FROM marketing; # It is around 40% 

-- Calculating ROMI by each campaign

WITH romi_by_campaign AS (
	SELECT
        campaign_name,
		ROUND(CalculateROMI(SUM(revenue), SUM(mark_spent)), 2) AS romi,
        ROUND(AVG(revenue), 2) AS average_revenue
	FROM 
		marketing
	GROUP BY
		campaign_name
	ORDER BY
		(SUM(revenue) - SUM(mark_spent))/SUM(mark_spent) DESC
)
SELECT *
FROM romi_by_campaign;

-- Analyzing campaign dates

# Counting the number of days the database spans 

SELECT COUNT(DISTINCT c_date)
FROM marketing; #28 days in total 

#Finding top days for each campaign in terms of
 
# revenue 
# conversion rates 
# marketing spending
# average order values

# Overall analysis (for all companies)
WITH rank_cte AS (
	SELECT
		campaign_name,
		c_date,
		revenue,
		DENSE_RANK() OVER (PARTITION BY campaign_name ORDER BY revenue DESC) AS rank_var
	FROM 
		marketing
),
top_days AS (
	SELECT * 
	FROM rank_cte
	WHERE rank_var <= 5
),
worst_days AS (
	SELECT *
    FROM rank_cte
    WHERE rank_var > 25
),
worst_days_count AS (
	SELECT
		c_date,
		COUNT(*) AS number_mentions,
        SUM(revenue) AS total_revenue,
        GROUP_CONCAT(DISTINCT campaign_name ORDER BY campaign_name SEPARATOR ', ') AS campaigns
	FROM worst_days
    GROUP BY c_date
    HAVING COUNT(*) > 1
),
#Finding the best revenue days for different companies
top_days_count AS (
	SELECT
		c_date,
		COUNT(*) AS number_mentions,
        SUM(revenue) AS total_revenue,
        GROUP_CONCAT(DISTINCT campaign_name ORDER BY campaign_name SEPARATOR ', ') AS campaigns
	FROM top_days
    GROUP BY c_date
    HAVING COUNT(*) > 1
)
SELECT 
	*,
    "Best" AS day_status
FROM 
	top_days_count
UNION
	SELECT
		*,
        "Worst" AS day_status
	FROM worst_days_count;
#Putting the code above in a stored procedure and analysing the marketing spending
CALL OverallAnalysis('mark_spent');
CALL OverallAnalysis('clicks');
CALL OverallAnalysis('impressions');

-- Campaign specific analysis and daily performance

SELECT
	campaign_name,
    c_date,
    SUM(impressions) AS total_ads,
    SUM(clicks) AS total_daily_clicks,
    SUM(orders) AS num_orders,
    ROUND(CalculateROMI(SUM(revenue), SUM(mark_spent)), 2) AS daily_romi,
    CalculateConversionRate(SUM(leads), SUM(clicks)) AS daily_conversion_rate
FROM
	marketing
WHERE
	campaign_name = 'google_hot'
GROUP BY 
	campaign_name,
    c_date;

#Wrapping this code into a stored procedure and analyzing a couple of other companies

CALL KPI_Summary('instagram_tier1');
CALL KPI_Summary('google_wide');

-- Weekdays vs weekends

WITH transformed_days AS (
	SELECT
		*,
		DAYNAME(c_date) as day_of_week,
        GetDayType(c_date) as day_type
	FROM
		marketing
)
SELECT
	day_type,
    ROUND(AVG(revenue), 1) AS average_revenue,
    ROUND(AVG(clicks), 1) AS average_clicks,
    ROUND(AVG(leads), 1) AS average_leads,
    ROUND(AVG(clicks), 1) AS average_clicks
FROM
	transformed_days
GROUP BY
	day_type;
    
CALL GetDayTypeAverages('banner_partner');
CALL GetDayTypeAverages('instagram_tier2');

-- Deciding which type of campaign is the best for revenue

SELECT
	category,
	AVG(CalculateROMI(revenue, mark_spent)) AS avg_romi
FROM
	marketing
GROUP BY
	category;

-- Analyzing performance by tier

SELECT
	ExtractTier(campaign_name) AS tier, #This function extract the tier of each campaign
    ROUND(AVG(CalculateROMI(revenue, mark_spent)), 1) AS avg_romi,
    ROUND(AVG(revenue), 1) AS avg_revenue,
    ROUND(AVG(mark_spent), 1) AS avg_spending
FROM
	marketing
WHERE
	ExtractTier(campaign_name) != 'NA'
GROUP BY 
	ExtractTier(campaign_name);
    



    
    
    

	







