CREATE DATABASE Medical_drugs;

EXEC sp_rename drug_review_test, drugs;

DELETE FROM drugs
WHERE condition LIKE '%</span>%';

EXEC sp_rename 'drugs.patient_id',  'Review_id', 'COLUMN';
EXEC sp_rename 'drugs.date',  'Review_date', 'COLUMN';


