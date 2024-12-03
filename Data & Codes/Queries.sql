-- Uncovering Insights in Drug Reviews Through SQL Sentiment Analysis
USE Medical_drugs;
-- -------------------------
-- Query 1
-- Average Rating (Overall)

SELECT  COUNT(Review_id) AS Total_number_of_reviews,
		CAST(AVG(rating) AS Decimal(5,2)) AS Average_ratings
FROM drugs;

-- -------------------------
-- Query 2
-- Average Ratings by Drugs (with contribution of review on basis of drugs)

SELECT  drug_name,
		COUNT(Review_id) AS Total_number_of_reviews,
		CAST(COUNT(Review_id)*1.00/(SELECT COUNT(Review_id) AS total
									FROM drugs)*100 AS DECIMAL(5,2)) AS contribution_percent,
		CAST(AVG(rating) AS Decimal(5,2)) AS Average_ratings
FROM drugs
GROUP BY drug_name
ORDER BY Total_number_of_reviews DESC;

-- -------------------------
-- Query 3
-- Average ratings by condition (with contribution of review on basis of condition)

SELECT  condition,
		COUNT(Review_id) AS Total_number_of_reviews,
		CAST(COUNT(Review_id)*1.00/(SELECT COUNT(Review_id) AS total
									FROM drugs)*100 AS DECIMAL(5,2)) AS contribution_percent,
		CAST(AVG(rating) AS Decimal(5,2)) AS Average_ratings
FROM drugs
GROUP BY condition
ORDER BY Total_number_of_reviews DESC;

-- -------------------------

-- Query 4
-- Total combinations (with contribution of review on basis of combination)

SELECT drug_name,
       condition,
	   CONCAT(drug_name,' - ',condition) AS combinations,
	   COUNT(CONCAT(drug_name,' ',condition)) AS count_of_combination,
	   CAST(COUNT(Review_id)*1.00/(SELECT COUNT(Review_id) AS total
								   FROM drugs)*100 AS DECIMAL(5,2)) AS contribution_percent
FROM drugs
GROUP BY drug_name,
	     condition,
	     CONCAT(drug_name,' - ',condition)
ORDER BY count_of_combination DESC;

-- -------------------------

-- Query 5
-- Most common used drugs for the condition (Most common combination)

WITH Most_common AS
					(SELECT drug_name,
							condition,
							Count_of_combination,
							RANK() OVER(partition by condition ORDER BY count_of_combination DESC) AS Ranking
							FROM combinations_view)
	SELECT condition,
	       drug_name,
		   count_of_combination
	FROM Most_common
	WHERE ranking=1
	ORDER BY count_of_combination DESC;

-- -------------------------

-- Query 6
-- Average ratings by year (with contribution of review on basis of year)

SELECT YEAR(Review_date) AS Years,
       COUNT(rating)  AS Total_reviews,
	   CAST(COUNT(Review_id)*1.00/(SELECT COUNT(Review_id) AS total
						           FROM drugs)*100 AS DECIMAL(5,2)) AS contribution_percent,
	   CAST(AVG(rating) AS DECIMAL(5,2)) AS ratings
FROM drugs
GROUP BY YEAR(Review_date)
ORDER BY Years ASC;

-- -------------------------

-- Query 7
-- Average ratings by combination

SELECT CONCAT(drug_name,' - ',condition) AS combinations,
       COUNT(rating)  AS Total_reviews,
	   CAST(AVG(rating) AS DECIMAL(5,2)) AS ratings
FROM drugs
GROUP BY CONCAT(drug_name,' - ',condition)
ORDER BY COUNT(rating) DESC,CAST(AVG(rating) AS DECIMAL(5,2))DESC;

-- -------------------------

-- Query 8
-- Ranking Reviews by length

SELECT drug_name,
	   condition,
	   CAST(rating AS DECIMAL(5,2)) AS ratings ,
	   review,
	   review_length
FROM drugs
ORDER BY review_length DESC;

-- -------------------------

-- Query 9
-- Average review length by Drug

SELECT drug_name,
	   COUNT(review_length) AS total_reviews,
	   AVG(review_length) AS average_length
FROM drugs
GROUP BY drug_name
ORDER BY Total_reviews DESC;

-- -------------------------

-- Query 10
-- Average review length by condition

SELECT condition,
	   COUNT(review_length) AS total_reviews,
	   AVG(review_length) AS average_length
FROM drugs
GROUP BY condition
ORDER BY Total_reviews DESC;

-- -------------------------

-- Query 11
-- Average review length by combination

SELECT CONCAT(drug_name,' - ',condition) AS combinations,
	   COUNT(review_length) AS total_reviews,
	   AVG(review_length) AS average_length
FROM drugs
GROUP BY CONCAT(drug_name,' - ',condition)
ORDER BY Total_reviews DESC;

-- -------------------------

-- Query 12
-- Total number of reviews by ratings (with contribution)

SELECT CAST(rating AS DECIMAL(5,2)) AS ratings,
	   COUNT(Review_id) AS total_reviews,
	   CAST(COUNT(Review_id)*1.00/(SELECT COUNT(Review_id) AS total
						       FROM drugs)*100 AS DECIMAL(5,2)) AS contribution_percent
FROM drugs
GROUP BY rating
ORDER BY rating ASC;

-- -------------------------

-- Query 13
-- Perfect ratings by Years

WITH Perfect AS 
				(SELECT YEAR(review_date) AS Years,
				 COUNT(Rating) AS Perfect_reviews
				 FROM drugs
				 WHERE Rating=10
				 GROUP BY YEAR(review_date)),
	 Yearly_reviews AS
				       (SELECT YEAR(Review_date) AS Years,
							   COUNT(Rating) AS total_reviews
						FROM drugs
						GROUP BY YEAR(Review_date))
SELECT Yearly_reviews.Years,
	   Perfect_reviews,
	   total_reviews,
	   CAST(Perfect_reviews*1.00/total_reviews*100 AS DECIMAL(5,2)) AS Perfect_review_contribution
FROM Perfect
JOIN Yearly_reviews 
ON Perfect.Years=Yearly_reviews.Years
ORDER BY Yearly_reviews.Years ASC;

-- -------------------------

-- Query 14
-- Worst ratings by Years

WITH Perfect AS 
				(SELECT YEAR(review_date) AS Years,
				 COUNT(Rating) AS Worst_reviews
				 FROM drugs
				 WHERE Rating=1
				 GROUP BY YEAR(review_date)),
	 Yearly_reviews AS
				       (SELECT YEAR(Review_date) AS Years,
							   COUNT(Rating) AS total_reviews
						FROM drugs
						GROUP BY YEAR(Review_date))
SELECT Yearly_reviews.Years,
	   Worst_reviews,
	   total_reviews,
	   CAST(Worst_reviews*1.00/total_reviews*100 AS DECIMAL(5,2)) AS Worst_review_contribution
FROM Perfect
JOIN Yearly_reviews 
ON Perfect.Years=Yearly_reviews.Years
ORDER BY Yearly_reviews.Years ASC;

-- -------------------------

-- Query 15
-- Average Review Length By rating

SELECT CAST(rating AS DECIMAL(5,2)) AS ratings ,
	   AVG(review_length) AS avg_review_length
FROM drugs
GROUP BY rating
ORDER BY rating ASC;

-- -------------------------

-- Query 16
-- Average Rating Monthly trend

WITH Monthly_Trends AS
					   (SELECT  MONTH(Review_date) AS Month_number,
						DATENAME(MONTH,Review_date) AS Months,
						YEAR(Review_date) AS Years,
						CAST(AVG(Rating) AS DECIMAL(5,2)) AS Average_ratings
						FROM drugs
						GROUP BY MONTH(Review_date) ,
								 DATENAME(MONTH,Review_date), 
								 YEAR(Review_date))
	 SELECT Month_number,
			Months,
			Years,
			Average_ratings,
            ISNULL(Average_ratings-LAG(Average_ratings) OVER(ORDER BY Years ASC,
													   Month_number ASC),0) AS Monthly_trends
	 FROM Monthly_trends;

-- -------------------------

-- Query 17
-- Count of reviews containing positive keywords (good, effective, excellent, recommended, great)

WITH Positive_reviews AS	
						(SELECT Year(Review_date) AS years,
						        COUNT(Review) AS Positive_count	
						 FROM drugs
						 WHERE review LIKE '%good%'
						    OR review LIKE '%recommended%'
						    OR review LIKE '%effective%'
						    OR review LIKE '%excellent%'
						    OR review LIKE '%great%'
						 GROUP BY Year(Review_date)),
	  Total_reviews AS
					    (SELECT Year(Review_date) AS years,
								COUNT(review) AS Yearly_reviews
						 FROM drugs
						 GROUP BY Year(Review_date))
	  SELECT Total_reviews.years,
		     Positive_count,
			 Yearly_reviews,
			 CAST((Positive_count*1.00/Yearly_reviews)*100 AS DECIMAL(5,2)) AS Percentage_of_positive
	  FROM Positive_reviews
	  JOIN Total_reviews
	  ON Total_reviews.years=Positive_reviews.years
	  ORDER BY years ASC;

-- -------------------------

-- Query 18
-- Count of reviews containing negative keywords (bad, terrible,poor,ineffective, useless)

WITH negative_reviews AS	
						(SELECT Year(Review_date) AS years,
						        COUNT(Review) AS negative_count	
						FROM drugs
						WHERE review LIKE '%bad%'
						OR review LIKE '%terrible%'
						OR review LIKE '%useless%'
						OR review LIKE '%ineffective%'
						OR review LIKE '%poor%'
						GROUP BY Year(Review_date)),
	  Total_reviews AS
					    (SELECT Year(Review_date) AS years,
								COUNT(review) AS Yearly_reviews
						 FROM drugs
						 GROUP BY Year(Review_date))
	  SELECT Total_reviews.years,
		     negative_count,
			 Yearly_reviews,
			 CAST((negative_count*1.00/Yearly_reviews)*100 AS DECIMAL(5,2)) AS Percentage_of_negative
	  FROM negative_reviews
	  JOIN Total_reviews
	  ON Total_reviews.years=negative_reviews.years
	  ORDER BY years ASC;

-- -------------------------

-- Query 19
-- Reviews mentioning side effects

SELECT drug_name ,
	   COUNT(CASE
	              WHEN review LIKE '%side effects%' THEN review
			      WHEN review LIKE '%side effect%'THEN review 
			 END) AS Side_effect_count,
	   COUNT(review) AS total_count,
	   CAST(COUNT(CASE
	              WHEN review LIKE '%side effects%' THEN review
			      WHEN review LIKE '%side effect%'THEN review 
				  END)*1.00/COUNT(review) *100 AS DECIMAL(5,2)) AS [percent]
FROM drugs
GROUP BY drug_name
ORDER BY Side_effect_count DESC;

-- -------------------------

-- Query 20
-- Ratings breakdown by drugs 

WITH Review_analysis AS
						(SELECT drug_name,
							   COUNT(CASE WHEN rating IN (1) THEN Review_id END) AS Worst,
							   COUNT(CASE WHEN rating IN (2,3,4) THEN Review_id END) AS Bad,
							   COUNT(CASE WHEN rating IN (5,6) THEN Review_id END) AS Neutral,
							   COUNT(CASE WHEN rating IN (7,8,9) THEN Review_id END) AS Good,
							   COUNT(CASE WHEN rating IN (10) THEN Review_id END) AS Perfect
						FROM Drugs
						GROUP BY drug_name),
	 Total_reviews AS
					 (SELECT drug_name,
							 COUNT(Review_id) AS total
					  FROM drugs
					  GROUP BY Drug_name)
	SELECT Total_reviews.drug_name,
		   Total,
		   CAST ((Worst*1.00/Total)*100 AS DECIMAL(5,2)) AS Worst_percent,
		   CAST ((Bad*1.00/Total)*100 AS DECIMAL(5,2)) AS Bad_percent,
		   CAST ((Neutral*1.00/Total)*100 AS DECIMAL(5,2)) AS Neutral_percent,
		   CAST ((Good*1.00/Total)*100 AS DECIMAL(5,2)) AS Good_percent,
		   CAST ((Perfect*1.00/Total)*100 AS DECIMAL(5,2)) AS Perfect_percent
    FROM Review_Analysis
	JOIN Total_reviews
	ON Total_reviews.drug_name=Review_Analysis.drug_name
	ORDER BY Total DESC;

-- -------------------------

-- Query 21
-- Ratings breakdown by condition

WITH Review_analysis AS
						(SELECT condition,
							   COUNT(CASE WHEN rating IN (1) THEN Review_id END) AS Worst,
							   COUNT(CASE WHEN rating IN (2,3,4) THEN Review_id END) AS Bad,
							   COUNT(CASE WHEN rating IN (5,6) THEN Review_id END) AS Neutral,
							   COUNT(CASE WHEN rating IN (7,8,9) THEN Review_id END) AS Good,
							   COUNT(CASE WHEN rating IN (10) THEN Review_id END) AS Perfect
						FROM Drugs
						GROUP BY condition),
	 Total_reviews AS
					 (SELECT condition,
							 COUNT(Review_id) AS total
					  FROM drugs
					  GROUP BY condition)
	SELECT Total_reviews.condition,
		   Total,
		   CAST ((Worst*1.00/Total)*100 AS DECIMAL(5,2)) AS Worst_percent,
		   CAST ((Bad*1.00/Total)*100 AS DECIMAL(5,2)) AS Bad_percent,
		   CAST ((Neutral*1.00/Total)*100 AS DECIMAL(5,2)) AS Neutral_percent,
		   CAST ((Good*1.00/Total)*100 AS DECIMAL(5,2)) AS Good_percent,
		   CAST ((Perfect*1.00/Total)*100 AS DECIMAL(5,2)) AS Perfect_percent
    FROM Review_Analysis
	JOIN Total_reviews
	ON Total_reviews.condition=Review_Analysis.condition
	ORDER BY Total DESC;

-- -------------------------

-- Query 22
-- Ratings breakdown by years

WITH Review_analysis AS
						(SELECT YEAR(Review_date) AS Years,
							   COUNT(CASE WHEN rating IN (1) THEN Review_id END) AS Worst,
							   COUNT(CASE WHEN rating IN (2,3,4) THEN Review_id END) AS Bad,
							   COUNT(CASE WHEN rating IN (5,6) THEN Review_id END) AS Neutral,
							   COUNT(CASE WHEN rating IN (7,8,9) THEN Review_id END) AS Good,
							   COUNT(CASE WHEN rating IN (10) THEN Review_id END) AS Perfect
						FROM Drugs
						GROUP BY YEAR(Review_date)),
	 Total_reviews AS
					 (SELECT YEAR(Review_date) AS Years,
							 COUNT(Review_id) AS total
					  FROM drugs
					  GROUP BY YEAR(Review_date))
	SELECT Total_reviews.Years,
		   Total,
		   CAST ((Worst*1.00/Total)*100 AS DECIMAL(5,2)) AS Worst_percent,
		   CAST ((Bad*1.00/Total)*100 AS DECIMAL(5,2)) AS Bad_percent,
		   CAST ((Neutral*1.00/Total)*100 AS DECIMAL(5,2)) AS Neutral_percent,
		   CAST ((Good*1.00/Total)*100 AS DECIMAL(5,2)) AS Good_percent,
		   CAST ((Perfect*1.00/Total)*100 AS DECIMAL(5,2)) AS Perfect_percent
    FROM Review_Analysis
	JOIN Total_reviews
	ON Total_reviews.Years=Review_Analysis.Years
	ORDER BY Years ASC;
	 

-- Queries Created for Power BI

--1 Review status

SELECT Review_id,
       CAST (rating AS DECIMAL(5,0)) AS Ratings,
	   Review_date,
	   CASE
			WHEN rating<5 THEN 'Bad'
			WHEN rating<8 THEN 'OK'
			ELSE 'Good'
		END AS Status
FROM drugs;

--2 Positive%

SELECT Review_id,
	   review_date
FROM drugs
WHERE
		   review LIKE '%good%'
		OR review LIKE '%recommended%'
		OR review LIKE '%effective%'
		OR review LIKE '%excellent%'
	    OR review LIKE '%great%';


--3 Negative%

SELECT Review_id,
	   review_date
FROM drugs
WHERE
	 review LIKE '%bad%'
  OR review LIKE '%terrible%'
  OR review LIKE '%useless%'
  OR review LIKE '%ineffective%'
  OR review LIKE '%poor%';


	   

