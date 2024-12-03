GO

CREATE VIEW combinations_view
AS
SELECT drug_name,
       condition,
	   CONCAT(drug_name,' ',condition) AS combinations,
	   COUNT(CONCAT(drug_name,' ',condition)) AS count_of_combination
FROM drugs
GROUP BY drug_name,
	     condition,

	     CONCAT(drug_name,' ',condition);

