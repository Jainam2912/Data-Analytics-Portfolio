-- 1. How many records are there in the dataset?
SELECT COUNT(*)
FROM `airbnb-eda.Airbnb1.Airbnb_data`

-- 2. How many unique cities are there in the European dataset?
SELECT COUNT(DISTINCT City) AS Number_of_Cities
FROM `airbnb-eda.Airbnb1.Airbnb_data`

-- 3. What are names of cities in the dataset?
SELECT DISTINCT City AS Cities_List
FROM `airbnb-eda.Airbnb1.Airbnb_data`

-- 4. How many bookings are there in each city?
SELECT City, COUNT(*) AS No_of_bookings
FROM `airbnb-eda.Airbnb1.Airbnb_data`
GROUP BY City
ORDER BY No_of_bookings DESC

-- 5. What is the total booking revenue for each city?
SELECT City, ROUND(SUM(Price),2) AS Total_booking_amount
FROM `airbnb-eda.Airbnb1.Airbnb_data`
GROUP BY City
ORDER BY Total_booking_amount DESC

-- 6. What is the average guest satisfaction score for each city?
SELECT City, ROUND(AVG(`Guest Satisfaction`),2) AS Avg_guest_satisfaction_score
FROM `airbnb-eda.Airbnb1.Airbnb_data`
GROUP BY City
ORDER BY Avg_guest_satisfaction_score DESC

-- 7. What are minimum, maximum and average booking price?
SELECT ROUND(MIN(Price),2) as min_price, ROUND(MAX(Price),2) as max_price, ROUND(AVG(Price),2) as avg_price
from `airbnb-eda.Airbnb1.Airbnb_data`

-- 8. What is the median price?
WITH quartile AS (
    SELECT 
        Price, 
        NTILE(2) OVER (ORDER BY Price) AS price_range
    FROM `airbnb-eda.Airbnb1.Airbnb_data`
    WHERE Price IS NOT NULL
),

median AS (
SELECT 
    MAX(CASE WHEN price_range = 1 THEN Price END) AS max_quartile_1,
    MIN(CASE WHEN price_range = 2 THEN Price END) AS min_quartile_2
FROM quartile)

SELECT (max_quartile_1 + min_quartile_2)/2 as median_price
FROM median

-- 9. How many outliers are there in price field?

WITH quartile AS (
          SELECT 
            Price, 
            NTILE(4) OVER (ORDER BY Price) AS price_range
    FROM `airbnb-eda.Airbnb1.Airbnb_data`
    WHERE Price IS NOT NULL
),

quartile_char AS (
          SELECT 
              MAX(CASE WHEN price_range = 1 THEN Price END) AS Q1,
              MAX(CASE WHEN price_range = 3 THEN Price END) AS Q3
          FROM quartile
),

quartile_prop AS (
          SELECT 
            (Q3 - Q1) AS IQR,
            Q1 - 1.5*(Q3 - Q1) AS lower_bound,
            Q3 + 1.5*(Q3 - Q1) AS upper_bound
          FROM quartile_char
)

SELECT COUNT(*)
FROM quartile, quartile_prop
WHERE Price < lower_bound or Price > upper_bound

-- 10. What are the characteristics for outliers in terms of room_type, number of bookings, and price

CREATE OR REPLACE VIEW airbnb-eda.Airbnb1.outlier_data AS (
      WITH quartile AS (
        SELECT 
            Price, 
            NTILE(4) OVER (ORDER BY Price) AS price_range
        FROM `airbnb-eda.Airbnb1.Airbnb_data`
      ),

      five_number_summary AS (
        SELECT
          MIN(Price) AS min_price,
          MAX(Price) AS max_price,
          MAX(CASE WHEN price_range = 1 THEN Price END) AS Q1,
          MAX(CASE WHEN price_range = 2 THEN Price END) AS median,
          MAX(CASE WHEN price_range = 3 THEN Price END) AS Q3
        FROM quartile
      ),

      hinges AS (
        SELECT 
          Q1,
          Q3,
          (Q3 - Q1) AS IQR,
          (Q1 - 1.5*(Q3 - Q1)) as lower_bound,
          (Q3 + 1.5*(Q3 - Q1)) as upper_bound
        FROM five_number_summary
      )

      SELECT a.*
      FROM `airbnb-eda.Airbnb1.Airbnb_data` a 
      JOIN hinges h 
      ON a.Price < h.lower_bound OR a.Price > h.upper_bound
)

SELECT 
    `Room Type` as room_type,
    COUNT(*) AS no_of_bookings,
    ROUND(MIN(Price), 2) AS min_outlier_price,
    ROUND(MAX(Price), 2) AS max_outlier_price,
    ROUND(AVG(Price), 2) AS avg_outlier_price
FROM `Airbnb1.outlier_data`
GROUP BY room_type

--  11. How does the average price differ between the main dataset and dataset with outliers removed?

CREATE OR REPLACE VIEW airbnb-eda.Airbnb1.cleaned_data AS (
      WITH quartile AS (
        SELECT 
            Price, 
            NTILE(4) OVER (ORDER BY Price) AS price_range
        FROM `airbnb-eda.Airbnb1.Airbnb_data`
      ),

      five_number_summary AS (
        SELECT
          MIN(Price) AS min_price,
          MAX(Price) AS max_price,
          MAX(CASE WHEN price_range = 1 THEN Price END) AS Q1,
          MAX(CASE WHEN price_range = 2 THEN Price END) AS median,
          MAX(CASE WHEN price_range = 3 THEN Price END) AS Q3
        FROM quartile
      ),

      hinges AS (
        SELECT 
          Q1,
          Q3,
          (Q3 - Q1) AS IQR,
          (Q1 - 1.5*(Q3 - Q1)) as lower_bound,
          (Q3 + 1.5*(Q3 - Q1)) as upper_bound
        FROM five_number_summary
      )

      SELECT a.*
      FROM `airbnb-eda.Airbnb1.Airbnb_data` a  
      WHERE a.Price >= (SELECT lower_bound FROM hinges) AND a.Price <= (SELECT upper_bound FROM hinges)
)

SELECT ROUND(AVG(c.Price),2) AS cleaned_data_avg_price,
      ROUND(AVG(o.Price),2) AS original_avg_price
FROM `Airbnb1.cleaned_data` c, `airbnb-eda.Airbnb1.Airbnb_data` o

-- 12. What is the average price of each room type?

SELECT `Room Type`, ROUND(AVG(Price), 2) as avg_room_price
FROM `airbnb-eda.Airbnb1.Airbnb_data`
GROUP BY `Room Type`
ORDER BY avg_room_price DESC

-- 13. How do weekend and weekday booking compare in terns of average price and number of bookings?

SELECT Day, COUNT(*), ROUND(AVG(Price), 2) as avg_price
FROM `airbnb-eda.Airbnb1.Airbnb_data`
GROUP BY Day
ORDER BY avg_price DESC

-- 14. How many bookings are there for each room type on weekdays and weekends?

SELECT Day, `Room Type`, COUNT(*)
FROM `airbnb-eda.Airbnb1.Airbnb_data`
GROUP BY Day, `Room Type`
ORDER BY Day, `Room Type`

-- 15. What is the average distance from metro and city center for each city?

SELECT City, ROUND(AVG(`Metro Distance _km_`), 2) AS avg_distance_from_metro, ROUND(AVG(`City Center _km_`), 2) as avg_distance_from_city
FROM `airbnb-eda.Airbnb1.Airbnb_data`
GROUP BY City

-- 16. What is the booking revenue for each room type on weekdays vs. weekends?

SELECT Day, `Room Type`, ROUND(SUM(Price),2) AS total_revenue
FROM `airbnb-eda.Airbnb1.Airbnb_data`
GROUP BY Day, `Room Type`
ORDER BY Day, `Room Type`

-- 17. What is the overall minimum, maximum, average guest satisfaction score?

SELECT MIN(`Guest Satisfaction`) as min_score,
      MAX(`Guest Satisfaction`) as max_score,
      ROUND(AVG(`Guest Satisfaction`), 2) as avg_score
FROM `airbnb-eda.Airbnb1.Airbnb_data`

-- 18. How does the guest satisfaction score vary by city?

SELECT City, 
      MIN(`Guest Satisfaction`) as min_score,
      MAX(`Guest Satisfaction`) as max_score,
      ROUND(AVG(`Guest Satisfaction`), 2) as avg_score
FROM `airbnb-eda.Airbnb1.Airbnb_data`
GROUP BY City

-- 19. What is the average booking value across all cleaned data?

SELECT ROUND(AVG(Price), 2) as avg_price
FROM `Airbnb1.cleaned_data`

-- 20. What is the average cleanliness score across all cleaned data?

SELECT ROUND(AVG(`Cleanliness Rating`), 2) as avg_price
FROM `Airbnb1.cleaned_data`

-- 21. How do cities rank in terms of total revenue?

SELECT City, ROUND(SUM(Price), 2) as total_revenue, ROW_NUMBER() OVER (ORDER BY SUM(PRICE) DESC) as rank
FROM `Airbnb1.cleaned_data`
GROUP BY City
