create database Bank_CRM;
use Bank_CRM;


-- --------
select * from customerinfo
limit 5;

-- CustomerId column in customerinfo
ALTER TABLE customerinfo
RENAME COLUMN ï»¿CustomerId TO CustomerId;

-- BankDOJ column in customerinfo
ALTER TABLE customerinfo
RENAME COLUMN `Bank DOJ` TO BankDOJ;

UPDATE customerinfo
SET BankDOJ = STR_TO_DATE(BankDOJ, '%d-%m-%Y')
WHERE BankDOJ IS NOT NULL;

ALTER TABLE customerinfo
MODIFY COLUMN BankDOJ DATE;

-- ------------
select * from bank_churn
limit 5;

ALTER TABLE bank_churn
RENAME COLUMN ï»¿CustomerId TO CustomerId;

-- -------------
SELECT * FROM activecustomer;

ALTER TABLE activecustomer
RENAME COLUMN ï»¿ActiveID TO ActiveID;


-- -------------
SELECT * FROM creditcard;

ALTER TABLE creditcard
RENAME COLUMN ï»¿CreditID TO CreditID;

-- -------------
SELECT * FROM exitcustomer;

ALTER TABLE exitcustomer
RENAME COLUMN ï»¿ExitID TO ExitID;


-- -------------
SELECT * FROM gender;

ALTER TABLE gender
RENAME COLUMN ï»¿GenderID TO GenderID;


-- -------------
SELECT * FROM geography;

ALTER TABLE geography
RENAME COLUMN ï»¿GeographyID TO GeographyID;


-- -------------

-- Objective Questions
-- 2.	Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)

SELECT date_format(BankDOJ, '%m-%Y') AS month_year, CustomerId, Surname,  EstimatedSalary
FROM customerinfo
WHERE QUARTER(BankDOJ) = 4
ORDER BY EstimatedSalary DESC
LIMIT 5;



-- 3.	Calculate the average number of products used by customers who have a credit card. (SQL)

SELECT AVG(NumOfProducts) AS AverageProductsUsed
FROM (
SELECT CustomerId, NumOfProducts 
FROM bank_churn
WHERE HasCrCard =  1
) dt ;



-- 5.	Compare the average credit score of customers who have exited and those who remain. (SQL)

SELECT 
AVG(CASE WHEN Exited = 1 THEN CreditScore ELSE 0 END) AS Exited_Credit_Score,
AVG(CASE WHEN Exited = 0 THEN CreditScore ELSE 0 END) AS Not_Exited_Credit_Score
FROM (
SELECT CustomerId, CreditScore, Exited
FROM bank_churn
) dt;



-- 6.	Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)

SELECT GenderCategory, ROUND(AVG(EstimatedSalary), 2) AS AverageEstimatedSalary, 
COUNT(CASE WHEN IsActiveMember = 1 THEN 1 END) AS ActiveMemberCount
FROM customerinfo c
JOIN bank_churn b ON c.CustomerId = b.CustomerId
JOIN gender g ON c.GenderID = g.GenderID
GROUP BY 1
ORDER BY 2 DESC;
				-- Females have higher average estimated salary, whereas there are less female active members as compared to males.



-- 7.	Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)

SELECT Credit_Score_Segment, 
ROUND(COUNT(CASE WHEN Exited = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS ExitRate
FROM (
SELECT 
CreditScore, 
CASE WHEN CreditScore BETWEEN 300 AND 579 THEN 'Poor'
WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very Good'
WHEN CreditScore >= 800 THEN 'Excellent' 
END AS Credit_Score_Segment,
Exited
FROM bank_churn
) dt
GROUP BY Credit_Score_Segment
ORDER BY ExitRate DESC;



-- 8.	Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)

SELECT c.GeographyID, GeographyLocation, COUNT(c.CustomerId) as CustomerCount
FROM customerinfo c
JOIN bank_churn b ON c.CustomerId = b.CustomerId
JOIN geography g ON c.GeographyID = g.GeographyID
WHERE b.IsActiveMember = 1 AND Tenure > 5
GROUP BY 1, 2
ORDER BY 3 DESC;



-- 11.	Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.

SELECT YEAR(BankDOJ) as YearOfJoining, COUNT(CustomerId) as  CustomersJoined
FROM customerinfo
GROUP BY 1
ORDER BY 1;

SELECT DATE_FORMAT(BankDOJ, '%M') as MonthOfJoining, COUNT(CustomerId) as  CustomersJoined
FROM customerinfo
GROUP BY 1;

SELECT DATE_FORMAT(BankDOJ, '%Y-%m') as MonthOfJoining, COUNT(CustomerId) as CustomersJoined
FROM customerinfo
GROUP BY 1
ORDER BY 2 DESC;
        
              
        
-- 15.	Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. 
--      Also, rank the gender according to the average value. (SQL)

SELECT c.GeographyID, GeographyLocation, GenderCategory, ROUND(AVG(EstimatedSalary), 2) as AverageIncome,
DENSE_RANK() OVER(ORDER BY AVG(EstimatedSalary) DESC) as Ranking
FROM customerinfo c
JOIN gender g ON c.GenderID = g.GenderID
JOIN geography geo ON c.GeographyID = geo.GeographyID
GROUP BY 1, 2, 3;




-- 16.	Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).

SELECT 
CASE WHEN Age BETWEEN 18 AND 29 THEN '18-30'
WHEN Age BETWEEN 30 AND 49 THEN '30-50'
ELSE '50+' 
END AS AgeBracket, 
ROUND(AVG(b.Tenure), 2) as AverageTenure
FROM customerinfo c 
JOIN bank_churn b ON c.CustomerId = b.CustomerId
WHERE b.Exited = 1
GROUP BY 1
ORDER BY 1;



-- 23.	Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.

SELECT 
bc.*,
(SELECT ec.ExitCategory 
FROM exitcustomer ec 
WHERE ec.ExitID = bc.Exited) AS ExitCategory
FROM bank_churn bc;



-- 25.	Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.

SELECT c.CustomerId, c.Surname AS LastName, ac.ActiveCategory
FROM customerinfo c
LEFT JOIN bank_churn bc ON c.CustomerId = bc.CustomerId
LEFT JOIN activecustomer ac ON bc.IsActiveMember = ac.ActiveID
WHERE c.Surname like '%on';
-- and ActiveCategory = 'Active Member';



-- 26.	Can you observe any data disrupency in the Customer’s data? As a hint it’s present in the IsActiveMember and Exited columns. 
--      One more point to consider is that the data in the Exited Column is absolutely correct and accurate.
SELECT CustomerId, IsActiveMember, Exited 
FROM bank_churn
WHERE (IsActiveMember = 1  AND Exited = 1)
OR  (IsActiveMember = 0  AND Exited = 0);
		-- there are data points which indicate the opposite of each other, like a member is active and has excited as well.




-- Subjective 
-- 9.	Utilize SQL queries to segment customers based on demographics and account details.
SELECT 
CASE WHEN Age BETWEEN 0 AND 20 THEN '18-20'
WHEN Age BETWEEN 21 AND 40 THEN '21-40'
WHEN Age BETWEEN 41 AND 60 THEN '41-60'
ELSE '60+'
END AS AgeBucket, 
COUNT(*) AS CustomerCount
FROM customerinfo
GROUP BY 1
ORDER BY 1;

SELECT GenderCategory, COUNT(*) AS CustomerCount
FROM customerinfo c
JOIN gender g ON c.GenderID = g.GenderID
GROUP BY 1;

SELECT GeographyLocation AS GeographicLocation, COUNT(*) AS CustomerCount
FROM customerinfo c
JOIN geography g ON c.GeographyID = g.GeographyID
GROUP BY 1;

SELECT DATE_FORMAT(BankDOJ, '%M-%Y') as JoiningMonth, COUNT(CustomerId) as CustomerCount
FROM customerinfo
GROUP BY 1
ORDER BY 2
-- ORDER BY 2 DESC
lIMIT 10;

SELECT  
CASE WHEN CreditScore BETWEEN 300 AND 499 THEN 'Poor(300-499)'
WHEN CreditSCore BETWEEN 500 AND 649 THEN 'Average(500-649)'
WHEN CreditScore BETWEEN 650 AND 749 THEN 'Good(650-749)'
ELSE 'Ecxellent(750 and above)' END AS Credit_Score_Segment,
COUNT(CustomerId) AS CustomerCount
FROM bank_churn
GROUP BY 1;

SELECT 
CASE WHEN EstimatedSalary BETWEEN 0 AND 50000 THEN '0-50000'
WHEN EstimatedSalary BETWEEN 50001 AND 100000 THEN '50001-100000'
WHEN EstimatedSalary BETWEEN 100001 AND 150000 THEN '100001-150000'
ELSE 'Above 150000'
END AS SalaryBucket,
COUNT(*) AS CustomerCount
FROM customerinfo
GROUP BY 1
ORDER BY 1;

SELECT Category as CreditCard, COUNT(CustomerId) as CustomerCount
FROM bank_churn b
JOIN creditcard cc ON cc.CreditID = b.HasCrCard
GROUP BY 1;

SELECT ExitCategory, COUNT(CustomerId) as CustomerCount
FROM bank_churn b
JOIN exitcustomer ec ON b.Exited = ec.ExitID
GROUP BY 1;

-- END