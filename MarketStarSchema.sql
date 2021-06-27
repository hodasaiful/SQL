/*-------------------------------------------------------------------------

From the market_star_schema;  

Calculate
 - Profits per product category
 - Profits per product subcategory
 - Average profit per order for each category

 
--------------------------------------------------------------------------*/


 -- 1. Profits per product category
 
 
--------------------------------------------------------------------------
 
 USE market_star_schema;
 
 SELECT 
 P.Product_Category
 ,SUM(M.Profit) AS 'Profit'
 FROM market_fact_full AS M
      INNER JOIN prod_dimen AS P ON M.Prod_id = P.Prod_id
 GROUP BY  P.Product_Category
 ORDER BY SUM(M.Profit) DESC;
 
 
 Product_Category	Profit 	
 TECHNOLOGY 	        886313.52
 OFFICE SUPPLIES 	518021.43
 FURNITURE 	        117433.03
 
 -- Technology is the most profitable category and Furniture the least.
 
 
---------------------------------------------------------------------------
 
  -- 2. Profits per product subcategory
  
---------------------------------------------------------------------------
   USE market_star_schema;
   
   SELECT 
   P.Product_Category
   ,P.Product_Sub_Category
   ,SUM(M.Profit) AS 'Profit'
   FROM market_fact_full AS M
        INNER JOIN prod_dimen AS P ON M.Prod_id = P.Prod_id
   GROUP BY  P.Product_Category
   		   , P.Product_Sub_Category
   ORDER BY P.Product_Category
            ,SUM(M.Profit) DESC;
   
  
  
  Product_Category 	Product_Sub_Category		Profit 	
  FURNITURE 		CHAIRS & CHAIRMATS 		149649.73
  FURNITURE 		OFFICE FURNISHINGS 		100427.93
  FURNITURE 		BOOKCASES 			-33582.13
  FURNITURE 		TABLES 				-99062.50
  OFFICE SUPPLIES 	BINDERS AND BINDER ACCESSORIES 	307413.39
  OFFICE SUPPLIES 	APPLIANCES 			97158.06
  OFFICE SUPPLIES 	ENVELOPES 			48182.60
  OFFICE SUPPLIES 	PAPER 				45263.20
  OFFICE SUPPLIES 	LABELS 				13677.17
  OFFICE SUPPLIES 	PENS & ART SUPPLIES 		7564.78
  OFFICE SUPPLIES 	STORAGE & ORGANIZATION 		6664.15
  OFFICE SUPPLIES 	RUBBER BANDS 			-102.67
  OFFICE SUPPLIES 	SCISSORS, RULERS AND TRIMMERS 	-7799.25
  TECHNOLOGY 		TELEPHONES AND COMMUNICATION 	316951.62
  TECHNOLOGY 		OFFICE MACHINES 		307712.93
  TECHNOLOGY 		COPIERS AND FAX 		167361.49
  TECHNOLOGY 		COMPUTER PERIPHERALS 		94287.48

/*The above query groups data by product categories, so it is easy to understand
 the profit per sub-category that belongs to a ceratin Category*/
 
 
 ---------------------------------------------------------------------------
  
   -- 3. Average profit per order
   
----------------------------------------------------------------------------
/*
Before we try to answer, we explore the relationship between Order_id and Order_Number 
in order to find the right denominator to calculate the average
*/

USE market_star_schema;

-- There are no duplicate id & number combination
SELECT 
	Ord_id
	,Order_Number
	,COUNT(*)
FROM orders_dimen
GROUP BY 
	Ord_id
	,Order_Number
HAVING COUNT(*)>1;


------------------------------------------------------------------------------
SELECT
   COUNT(*) AS 'Total_Records'
   ,COUNT(DISTINCT Ord_id) AS 'Order_Id_Count'
   ,COUNT(DISTINCT Order_Number) AS 'Order_Number_Count'
FROM orders_dimen;

Total_Records 	Order_Id_Count 	Order_Number_Count 	
5506 		5506 		5496

 
-- Conclusion : Count of Order_Id is greater than the count Order Number; or one Order id is 
-- mapped to an order number 

-----------------------------------------------------------------------------------------------
-- For my reference, I extract the details from the orders_dimen for the above order numbers

USE market_star_schema;

SELECT * 
FROM orders_dimen 
WHERE Order_Number IN 
	(SELECT 
	Order_Number
	FROM orders_dimen
	GROUP BY Order_Number
	HAVING COUNT(Ord_id)>1);


/*------------------------------------------------------------------------------------------------
In order to find the average profit, I divide the sum of profit by the count of Order Id and NOT
Order Number; It's always worth doing an investigation before choosing the right denominator which 
might vary from case to case
--------------------------------------------------------------------------------------------------*/

USE market_star_schema;

SELECT 
P.Product_Category
,SUM(M.Profit)
,ROUND((SUM(M.Profit)/COUNT(DISTINCT O.Ord_id)),2) AS 'Average Profit'
FROM market_fact_full AS M
INNER JOIN prod_dimen AS P ON M.Prod_id = P.Prod_id 
INNER JOIN orders_dimen AS O ON M.Ord_id = O.Ord_id
GROUP BY P.Product_Category
ORDER BY 3 DESC;

Product_Category	SUM(M.Profit)	Average Profit 	
TECHNOLOGY 		886313.52 	477.03
OFFICE SUPPLIES 	518021.43 	142.63
FURNITURE 		117433.03 	75.23




