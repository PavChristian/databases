
DELIMITER //
CREATE PROCEDURE AnalyzeRevenueDays(
    IN revenue_column VARCHAR(50)  -- Input parameter to specify the revenue column name
)
BEGIN
    -- Construct the query dynamically using the input column name
    SET @query = CONCAT(
        'WITH rank_cte AS (
            SELECT
                campaign_name,
                c_date,
                ', revenue_column, ' AS revenue,  -- Dynamic revenue column
                DENSE_RANK() OVER (PARTITION BY campaign_name ORDER BY ', revenue_column, ' DESC) AS rank_var
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
                GROUP_CONCAT(DISTINCT campaign_name ORDER BY campaign_name SEPARATOR \', \') AS campaigns
            FROM worst_days
            GROUP BY c_date
            HAVING COUNT(*) > 1
        ),
        top_days_count AS (
            SELECT
                c_date,
                COUNT(*) AS number_mentions,
                SUM(revenue) AS total_revenue,
                GROUP_CONCAT(DISTINCT campaign_name ORDER BY campaign_name SEPARATOR \', \') AS campaigns
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
        FROM worst_days_count;'
    );

    -- Prepare and execute the dynamically constructed SQL statement
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER;

DELIMITER //

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDayTypeAverages`(
    IN campaign_name_input VARCHAR(100)  -- Input parameter for the campaign name
)
BEGIN
    -- Drop temporary tables if they exist to avoid conflicts
    DROP TEMPORARY TABLE IF EXISTS transformed_days;

    -- Create a temporary table to perform transformations
    CREATE TEMPORARY TABLE transformed_days AS
    SELECT
        *,
        DAYNAME(c_date) AS day_of_week,
        GetDayType(c_date) AS day_type
    FROM
        marketing
    WHERE 
        campaign_name = campaign_name_input;  -- Filter by the specified campaign name

    -- Now perform the aggregation on the temporary table
    SELECT
        day_type,
        ROUND(AVG(revenue), 1) AS average_revenue,
        ROUND(AVG(clicks), 1) AS average_clicks,
        ROUND(AVG(leads), 1) AS average_leads
    FROM
        transformed_days
    GROUP BY
        day_type;

    -- Drop the temporary table after use
    DROP TEMPORARY TABLE IF EXISTS transformed_days;
END //

DELIMITER;

DELIMITER//
CREATE DEFINER=`root`@`localhost` PROCEDURE `KPI_Summary`(
    IN campaign_name_input VARCHAR(100)  -- Input parameter for the campaign name
)
BEGIN
    SET @query = CONCAT(
        'SELECT
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
            campaign_name = ? 
        GROUP BY 
            campaign_name,
            c_date'
    );

    PREPARE stmt FROM @query;
    SET @campaign_name = campaign_name_input;  -- Set the campaign name input
    EXECUTE stmt USING @campaign_name;
    DEALLOCATE PREPARE stmt;
END//
DELIMITER;