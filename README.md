# Patient reviews Analytics  
**Objective**: To perform descriptive and sentiment analysis on patient reviews related to the usage of various medical drugs.

**Tools used**: MS SQL Server, MS Power BI, MS Excel

**Brief Description**  
This project analyzes patient reviews on medical drugs using SQL and Power BI. The SQL queries generate insights such as average ratings by drug, condition, and year, as well as review lengths and sentiment-based analysis. The Power BI dashboard visualizes sentiment trends, with a gauge chart displaying average ratings, filters for various parameters, and breakdowns of ratings by drug, condition, and year. This project is designed to help track sentiment trends and improve decision-making in a healthcare firm.

---  

### SQL  

Total number of Queries: 22  
      
![image](https://github.com/user-attachments/assets/770c2d3b-3f9f-42f9-a75f-d727b473a93b)  

---
## SNAPSHOTS  


#1 Average Ratings by Drugs (with contribution of review on basis of drugs)   <BR>

```
SELECT  drug_name,
        COUNT(Review_id) AS Total_number_of_reviews,
        CAST(COUNT(Review_id)*1.00/(SELECT COUNT(Review_id) AS total
                                    FROM drugs)*100 AS DECIMAL(5,2)) AS contribution_percent,
        CAST(AVG(rating) AS Decimal(5,2)) AS Average_ratings
FROM drugs
GROUP BY drug_name
ORDER BY Total_number_of_reviews DESC;

```

![image](https://github.com/user-attachments/assets/bcdc6082-f6d1-4ba3-9391-55b9647d4ad5)  

#2 Average ratings by condition (with contribution of review on basis of condition)   <BR>

```
SELECT  condition,
        COUNT(Review_id) AS Total_number_of_reviews,
        CAST(COUNT(Review_id)*1.00/(SELECT COUNT(Review_id) AS total
                                    FROM drugs)*100 AS DECIMAL(5,2)) AS contribution_percent,
        CAST(AVG(rating) AS Decimal(5,2)) AS Average_ratings
FROM drugs
GROUP BY condition
ORDER BY Total_number_of_reviews DESC;

```

![image](https://github.com/user-attachments/assets/4552371e-ce11-4044-af88-195d937296dc)

#3 Most common used drugs for the condition (Most common combination)   <BR>

```
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

```

![image](https://github.com/user-attachments/assets/1dee8a1a-fa4e-4691-bd35-495ba4881e70)

#4 Perfect ratings by Years   <BR>

```
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

```

![image](https://github.com/user-attachments/assets/7609376f-c747-4abb-88ab-3d5dd98a63d5)  

#5 Count of reviews containing positive keywords (good, effective, excellent, recommended, great)   <BR>

```
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


```

![image](https://github.com/user-attachments/assets/b5be8548-bee7-42b3-8ccf-51f3ea748f6f)

#6 Ratings breakdown by condition  <BR>

```
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


```

![image](https://github.com/user-attachments/assets/c862dc2a-a177-463b-a984-b6309f133e9e)










