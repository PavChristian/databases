-- Looking at the data 
SELECT *
FROM churn_modelling;
-- Check that there are no duplicate rows
SELECT CustomerId, COUNT(*) AS count
FROM churn_modelling
GROUP BY CustomerId
HAVING COUNT(*) > 1;

-- Counting the number of NAs in each column (dynamic query generation)

SELECT
    CONCAT('SELECT ',
           GROUP_CONCAT(CONCAT('SUM(', COLUMN_NAME, ' IS NULL) AS null_count_', COLUMN_NAME) SEPARATOR ', '),
           ' FROM your_table;')
FROM
    information_schema.columns
WHERE
    table_schema = 'churn_rate'
    AND table_name = 'churn_modelling';
    
SELECT 
	SUM(Age IS NULL) AS null_count_Age, 
	SUM(Balance IS NULL) AS null_count_Balance, 
	SUM(CreditScore IS NULL) AS null_count_CreditScore, 
	SUM(CustomerId IS NULL) AS null_count_CustomerId, 
	SUM(EstimatedSalary IS NULL) AS null_count_EstimatedSalary, 
	SUM(Exited IS NULL) AS null_count_Exited, 
	SUM(Gender IS NULL) AS null_count_Gender, 
	SUM(Geography IS NULL) AS null_count_Geography, 
	SUM(HasCrCard IS NULL) AS null_count_HasCrCard, 
	SUM(IsActiveMember IS NULL) AS null_count_IsActiveMember, 
	SUM(NumOfProducts IS NULL) AS null_count_NumOfProducts, 
	SUM(RowNumber IS NULL) AS null_count_RowNumber, 
	SUM(Surname IS NULL) AS null_count_Surname, 
	SUM(Tenure IS NULL) AS null_count_Tenure 
FROM churn_modelling;

-- There are no NAs in the dataset

-- Look at the average score for each gender (there is virtually no difference) 

SELECT 
	AVG(CreditScore) AS avg_credit_score,
    Gender
FROM churn_modelling 
GROUP BY Gender;

-- Age analysis


 
SELECT
	aq.age_quantile,
    COUNT(aq.CustomerID) AS num_customers,
    ROUND(AVG(cm.CreditScore), 2) AS avg_credit_score,
    ROUND(AVG(cm.EstimatedSalary), 2) AS avg_estimate_salary,
    MAX(aq.age) AS max_quantile_age,
    MIN(aq.age) AS min_quantile_age
FROM 
	churn_modelling cm
LEFT JOIN 
	age_quantiles aq ON aq.CustomerID = cm.CustomerID
GROUP BY aq.age_quantile
ORDER BY aq.age_quantile DESC;

-- Churn rate analysis 


#This procedure is great for EDA (to see churn rate for different categories)

DELIMITER $$

CREATE PROCEDURE calculate_churn_rate_by(
    IN column_name CHAR(64),
    IN table_name CHAR(64)
)
BEGIN
    SET @query = CONCAT(
        'SELECT ', column_name, ', ROUND(SUM(Exited)/COUNT(CustomerID) * 100, 2) AS churn_rate ',
        'FROM ', table_name, ' ',
        'GROUP BY ', column_name, ';'
    );

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

DELIMITER ;


CALL calculate_churn_rate_by('Geography', 'churn_modelling'); #Germany has a much higher churn rate than France and Spain
CALL calculate_churn_rate_by('Gender', 'churn_modelling'); #Women have a much higher churn rate than men 
CALL calculate_churn_rate_by('HasCrCard', 'churn_modelling'); #Almost no difference
CALL calculate_churn_rate_by('IsActiveMember', 'churn_modelling');
-- Analyzing churn rate and numerical variables

SELECT 
	Exited,
    AVG(Age) AS avg_age,
    AVG(Balance) AS avg_balance,
    AVG(EstimatedSalary) AS avg_salary, 
    








