CREATE DATABASE shipping_data;
USE shipping_data;
# Create port table
DROP TABLE IF EXISTS outbound_agri_data;
CREATE TABLE outbound_agri_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Terminal_name VARCHAR(255),
    Vessel_name VARCHAR(255),
    Stop_departure_date DATE,
    anchor_hrs double,
    cargo_type VARCHAR(255),
    cargo_weight FLOAT
);

SET SQL_SAFE_UPDATES = 0;
DELETE FROM outbound_agri_data;
SET SQL_SAFE_UPDATES = 1;

SET SQL_SAFE_UPDATES = 0;
DROP TABLE table2;
SET SQL_SAFE_UPDATES = 1;

select count(*)
from table2;

 #Insert port data
INSERT INTO outbound_agri_data (Terminal_name,Vessel_name ,Stop_departure_date, anchor_hrs,cargo_type, cargo_weight)
SELECT Terminal_name, Vessel_Name,stop_departure_date, hrs_anchor,Product, weight_qty
FROM table1;

INSERT INTO outbound_agri_data (Terminal_name, Vessel_Name,Stop_departure_date, anchor_hrs,cargo_type, cargo_weight)
SELECT Terminal_name, Vessel_Name,stop_departure_date, hrs_anchor,Product, weight_qty
FROM table2;

select *
from outbound_agri_data;

SELECT 
    YEAR(Stop_departure_date) AS year,
    COUNT(DISTINCT Vessel_name) AS num_vessels
FROM outbound_agri_data
WHERE Stop_departure_date IS NOT NULL 
GROUP BY YEAR(Stop_departure_date)
ORDER BY year;



# Create rain table
CREATE TABLE rain_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Station_Name VARCHAR(255),
    Climate_ID INT,
    Climate_date DATE,
    Total_Precip_mm FLOAT
);

# Insert rain data 
INSERT INTO rain_data (Station_Name, Climate_ID, Climate_date, Total_Precip_mm)
SELECT `Station Name`, `Climate ID`, `date`, `Total Precip (mm)`
FROM rain_2014;

INSERT INTO rain_data (Station_Name, Climate_ID, Climate_date, Total_Precip_mm)
SELECT `Station Name`, `Climate ID`, `Date`, `Total Precip (mm)`
FROM rain_2015;

INSERT INTO rain_data (Station_Name, Climate_ID, Climate_date, Total_Precip_mm)
SELECT `Station Name`, `Climate ID`, `Date`, `Total Precip (mm)`
FROM rain_2016;

INSERT INTO rain_data (Station_Name, Climate_ID, Climate_date, Total_Precip_mm)
SELECT `Station Name`, `Climate ID`, `Date`, `Total Precip (mm)`
FROM rain_2017;

INSERT INTO rain_data (Station_Name, Climate_ID, Climate_date, Total_Precip_mm)
SELECT `Station Name`, `Climate ID`, `Date`, `Total Precip (mm)`
FROM rain_2018;

select count(*)
from rain_data;

# handling missing values
SELECT COUNT(*) AS missing_count
FROM rain_data
WHERE Total_Precip_mm IS NULL;

SET SQL_SAFE_UPDATES = 0;
UPDATE rain_data
SET Total_Precip_mm = 0
WHERE Total_Precip_mm IS NULL;
SET SQL_SAFE_UPDATES = 1;

-- consecutive rainy days

SET @threshold = 8;

WITH rain_above_threshold AS (
    SELECT 
        id,
        Climate_date,
        Total_Precip_mm,
        YEAR(Climate_date) as per_year,
        ROW_NUMBER() OVER (ORDER BY Climate_date) AS rn
    FROM rain_data
    WHERE Total_Precip_mm > @threshold 
),

consecutive_groups AS (
    SELECT 
        r1.per_year,
        r1.Climate_date,
        r1.Total_Precip_mm,
        -- Grouping key: difference between row number and date offset
        DATE_SUB(r1.Climate_date, INTERVAL (r1.rn) DAY) AS group_key
    FROM rain_above_threshold r1
    
),
grouped_counts AS (
    SELECT
        per_year,
        group_key,
        MIN(Climate_date) AS start_date,
        COUNT(*) AS consecutive_days
    FROM consecutive_groups
    GROUP BY per_year, group_key
)


SELECT 
    per_year,
    consecutive_days,
    COUNT(*) AS number_of_sequences
FROM grouped_counts
WHERE consecutive_days BETWEEN 1 AND 6
GROUP BY per_year, consecutive_days
ORDER BY per_year, consecutive_days;



# Analzying number of vessels leaving the port, tonagae loaded, and anchorage_level for one threshold

SET @threshold = 63;

WITH rain_above_threshold AS (
    SELECT 
        id,
        Climate_date,
        Total_Precip_mm,
        YEAR(Climate_date) AS per_year,
        ROW_NUMBER() OVER (PARTITION BY YEAR(Climate_date) ORDER BY Climate_date) AS rn
    FROM rain_data
    WHERE Total_Precip_mm > @threshold 
),

consecutive_groups AS (
    SELECT 
        r1.per_year,
        r1.Climate_date,
        DATE_SUB(r1.Climate_date, INTERVAL (r1.rn) DAY) AS group_key
    FROM rain_above_threshold r1
),

grouped_counts AS (
    SELECT
        per_year,
        group_key,
        MIN(Climate_date) AS start_date,
        COUNT(*) AS consecutive_days
    FROM consecutive_groups
    GROUP BY per_year, group_key
),

joined_with_vessels AS (
    SELECT 
        gc.per_year,
        gc.consecutive_days,
        gc.start_date,
        SUM(v.vessel_count) AS total_vessel_count,
        SUM(v.total_tonnage) AS total_tonnage,
        SUM(v.total_anchor_hrs) AS total_anchor_hrs
    FROM grouped_counts gc
    JOIN (
        SELECT 
            Stop_departure_date,
            COUNT(DISTINCT Terminal_name) AS vessel_count,
            SUM(cargo_weight) AS total_tonnage,
            SUM(anchor_hrs) AS total_anchor_hrs
        FROM outbound_agri_data
        GROUP BY Stop_departure_date
    ) v
    ON v.Stop_departure_date BETWEEN gc.start_date AND DATE_ADD(gc.start_date, INTERVAL gc.consecutive_days - 1 DAY)
    WHERE gc.consecutive_days BETWEEN 1 AND 6
    GROUP BY gc.per_year, gc.consecutive_days, gc.start_date
)

SELECT 
    per_year,
    consecutive_days,
    COUNT(*) AS number_of_sequences,
    ROUND(SUM(total_vessel_count) / SUM(consecutive_days), 2) AS avg_vessels_per_day,
    ROUND(SUM(total_tonnage) / SUM(consecutive_days), 2) AS avg_tonnage_per_day,
    ROUND(SUM(total_anchor_hrs) / SUM(consecutive_days), 2) AS avg_anchor_hrs_per_day
FROM joined_with_vessels
GROUP BY per_year, consecutive_days
ORDER BY per_year, consecutive_days;


### Analyzing different thresholds

DROP TABLE IF EXISTS rain_analysis_results;

CREATE TABLE rain_analysis_results (
    threshold INT,
    per_year INT,
    consecutive_days INT,
    number_of_sequences INT,
    avg_vessels_per_day FLOAT,
    avg_tonnage_per_day FLOAT
);
DROP PROCEDURE IF EXISTS analyze_thresholds;

DELIMITER $$

CREATE PROCEDURE analyze_thresholds()
BEGIN
  DECLARE th INT DEFAULT 8;

  WHILE th <= 70 DO

    INSERT INTO rain_analysis_results (
        threshold, per_year, consecutive_days,
        number_of_sequences, avg_vessels_per_day, avg_tonnage_per_day
    )
    SELECT 
        th AS threshold,
        per_year, 
        consecutive_days,
        COUNT(*) AS number_of_sequences,
        ROUND(SUM(total_vessel_count) / SUM(consecutive_days), 2) AS avg_vessels_per_day,
        ROUND(SUM(total_tonnage) / SUM(consecutive_days), 2) AS avg_tonnage_per_day
    FROM (
        SELECT 
            gc.per_year,
            gc.start_date,
            gc.consecutive_days,
            SUM(v.vessel_count) AS total_vessel_count,
            SUM(v.total_tonnage) AS total_tonnage
        FROM (
            SELECT 
                per_year,
                DATE_SUB(Climate_date, INTERVAL rn DAY) AS group_key,
                MIN(Climate_date) AS start_date,
                COUNT(*) AS consecutive_days
            FROM (
                SELECT 
                    id,
                    Climate_date,
                    Total_Precip_mm,
                    YEAR(Climate_date) AS per_year,
                    ROW_NUMBER() OVER (PARTITION BY YEAR(Climate_date) ORDER BY Climate_date) AS rn
                FROM rain_data
                WHERE Total_Precip_mm > th
            ) AS rain_above_threshold
            GROUP BY per_year, group_key
        ) AS gc
        JOIN (
            SELECT 
                Stop_departure_date,
                COUNT(DISTINCT Terminal_name) AS vessel_count,
                SUM(cargo_weight) AS total_tonnage
            FROM outbound_agri_data
            GROUP BY Stop_departure_date
        ) AS v
        ON v.Stop_departure_date BETWEEN gc.start_date AND DATE_ADD(gc.start_date, INTERVAL gc.consecutive_days - 1 DAY)
        WHERE gc.consecutive_days BETWEEN 1 AND 6
        GROUP BY gc.per_year, gc.consecutive_days, gc.start_date
    ) AS joined_with_vessels
    GROUP BY per_year, consecutive_days;

    SET th = th + 5;
  END WHILE;

  SELECT * FROM rain_analysis_results ORDER BY threshold, per_year, consecutive_days;

END $$

DELIMITER ;
CALL analyze_thresholds();


