DELIMITER //
CREATE FUNCTION CalculateROMI(
    revenue DECIMAL(10, 2), 
    spending DECIMAL(10, 2)  
) 
RETURNS DECIMAL(10, 2) 
DETERMINISTIC
BEGIN
    DECLARE romi DECIMAL(10, 2);

    -- Check if spending is zero to avoid division by zero
    IF spending = 0 THEN
        SET romi = NULL;  
    ELSE
        -- Calculate ROMI
        SET romi = ((revenue - spending) / spending) * 100;
    END IF;

    -- Return the calculated ROMI
    RETURN romi;
END //

DELIMITER;

DELIMITER //

CREATE DEFINER=`root`@`localhost` FUNCTION `CalculateConversionRate`(
    leads INT,    
    clicks INT    
) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
    DECLARE conversion_rate DECIMAL(10, 2); 


    IF clicks = 0 THEN
        SET conversion_rate = 0; 
    ELSE

        SET conversion_rate = (leads / clicks) * 100;
    END IF;


    RETURN conversion_rate;
END //
DELIMITER; 


DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `ExtractTier`(input_string VARCHAR(255)) RETURNS varchar(5) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE last_char CHAR(1);  -- Variable to store the last character

    -- Get the last character of the input string
    SET last_char = RIGHT(input_string, 1);

    -- Check if the last character is a digit (0-9)
    IF last_char REGEXP '^[0-9]$' THEN
        RETURN last_char;
    ELSE
        RETURN 'NA';  -- Return 'NA' if the last character is not a number
    END IF;
END //
DELIMITER;

DELIMITER //

CREATE DEFINER=`root`@`localhost` FUNCTION `GetDayType`(order_date DATE) RETURNS varchar(10) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE day_name VARCHAR(10);  -- Variable to store the name of the day
    DECLARE day_type VARCHAR(10);  -- Variable to store whether it is a Weekday or Weekend

    -- Get the name of the day
    SET day_name = DAYNAME(order_date);

    -- Determine if it's a Weekday or Weekend
    CASE day_name
        WHEN 'Saturday' THEN SET day_type = 'Weekend';
        WHEN 'Sunday' THEN SET day_type = 'Weekend';
        ELSE SET day_type = 'Weekday';
    END CASE;

    -- Return whether it is a Weekday or Weekend
    RETURN day_type;
END //
DELIMITER; 

