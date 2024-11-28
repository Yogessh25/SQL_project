/*

-----------------------------------------------------------------------------------------------------------------------------------
                                               Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------

                                                         Queries*/
  select*from orders.online_customer
  limit 5;
/*-----------------------------------------------------------------------------------------------------------------------------------
-- 1. WRITE A QUERY TO DISPLAY CUSTOMER FULL NAME WITH THEIR TITLE (MR/MS), BOTH FIRST NAME AND LAST NAME ARE IN UPPER CASE WITH 
-- CUSTOMER EMAIL ID, CUSTOMER CREATIONDATE AND DISPLAY CUSTOMER’S CATEGORY AFTER Aselect concat(case 	CUSTOMER_GENDER  
			     when 'M' then 'Mr.'
				 when 'F' then 'Ms.'
				 end,' ',upper(CUSTOMER_FNAME),' ',upper(CUSTOMER_LNAME)) as CUSTOMER_FULLNAME,CUSTOMER_EMAIL,CUSTOMER_CREATION_DATE,
                 case when year(CUSTOMER_CREATION_DATE)<2005 then 'CATEGORY A'
                 when year(CUSTOMER_CREATION_DATE)>=2005 and year(CUSTOMER_CREATION_DATE) < 2011   then 'CATEGORY B'
                 when year(CUSTOMER_CREATION_DATE)>=2011 then 'CATEGORY C' end as CUSTOMER_CATEGORY
from online_customer;PPLYING BELOW CATEGORIZATION RULES:
	-- i.IF CUSTOMER CREATION DATE YEAR <2005 THEN CATEGORY A
    -- ii.IF CUSTOMER CREATION DATE YEAR >=2005 AND <2011 THEN CATEGORY B
    -- iii.IF CUSTOMER CREATION DATE YEAR>= 2011 THEN CATEGORY C
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER TABLE] */
    
 select concat(case CUSTOMER_GENDER when 'M' then 'Mr.' when 'F' then 'Ms.' end ,' ',upper(CUSTOMER_FNAME),' ' ,upper(CUSTOMER_LNAME)) as CUSTOMER_FULL_NAME, 
 CUSTOMER_EMAIL, CUSTOMER_CREATION_DATE, case when year(CUSTOMER_CREATION_DATE)<2005 then 'A' when 2005<=year(CUSTOMER_CREATION_DATE) and year(CUSTOMER_CREATION_DATE)<2011 then 'B' else 'C' end as CUSTOMERS_CATEGORY 
 from online_customer;

/*-- 2. WRITE A QUERY TO DISPLAY THE FOLLOWING INFORMATION FOR THE PRODUCTS, WHICH HAVE NOT BEEN SOLD:  PRODUCT_ID, PRODUCT_DESC, 
-- PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE,INVENTORY VALUES(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE), NEW_PRICE AFTER APPLYING DISCOUNT 
-- AS PER BELOW CRITERIA. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- i.IF PRODUCT PRICE > 20,000 THEN APPLY 20% DISCOUNT
    -- ii.IF PRODUCT PRICE > 10,000 THEN APPLY 15% DISCOUNT
    -- iii.IF PRODUCT PRICE =< 10,000 THEN APPLY 10% DISCOUNT */
       -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE] IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -PRODUCT, ORDER_ITEMS TABLE] 
    select 
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    p.PRODUCT_QUANTITY_AVAIL,
    p.PRODUCT_PRICE,
    (p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) AS INVENTORY_VALUES,
    CASE
        WHEN p.PRODUCT_PRICE > 20000 THEN round((p.PRODUCT_PRICE * 0.8),2)
        WHEN p.PRODUCT_PRICE > 10000 THEN round((p.PRODUCT_PRICE * 0.85),2)
        ELSE round((p.PRODUCT_PRICE * 0.9),2)
    END AS NEW_PRICE
FROM 
    product as p
LEFT JOIN 
    order_items oi ON p.PRODUCT_ID = oi.PRODUCT_ID
WHERE 
    oi.order_id IS NULL
ORDER BY 
    INVENTORY_VALUES DESC;
    
/*-- 3. WRITE A QUERY TO DISPLAY PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESCRIPTION, COUNT OF PRODUCT TYPE IN EACH PRODUCT CLASS, 
-- INVENTORY VALUE (P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE). INFORMATION SHOULD BE DISPLAYED FOR ONLY THOSE PRODUCT_CLASS_CODE 
-- WHICH HAVE MORE THAN 1,00,000 INVENTORY VALUE. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS]*/
select pc.PRODUCT_CLASS_CODE, 
pc.PRODUCT_CLASS_DESC, 
count(p.PRODUCT_ID), 
sum(p.PRODUCT_QUANTITY_AVAIL*p.PRODUCT_PRICE) as INVENTORY_VALUE 
from  product_class pc
left join product p on pc.PRODUCT_CLASS_CODE = p.PRODUCT_CLASS_CODE
group by pc.PRODUCT_CLASS_CODE, pc.PRODUCT_CLASS_DESC
having 
INVENTORY_VALUE>100000
order by
INVENTORY_VALUE desc;

/*-- 4. WRITE A QUERY TO DISPLAY CUSTOMER_ID, FULL NAME, CUSTOMER_EMAIL, CUSTOMER_PHONE AND COUNTRY OF CUSTOMERS WHO HAVE CANCELLED 
-- ALL THE ORDERS PLACED BY THEM(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]*/

select o.customer_id,concat(upper(o.customer_fname),' ',upper(o.customer_lname)) Full_Name,o.customer_email, o.customer_phone,a.country from ((online_customer o 
inner join address a on o.ADDRESS_ID=a.ADDRESS_ID) 
inner join order_header oh on o.CUSTOMER_ID= oh.CUSTOMER_ID) where Order_status= 'Cancelled';

/*-- 5. WRITE A QUERY TO DISPLAY SHIPPER NAME, CITY TO WHICH IT IS CATERING, NUMBER OF CUSTOMER CATERED BY THE SHIPPER IN THE CITY AND 
-- NUMBER OF CONSIGNMENTS DELIVERED TO THAT CITY FOR SHIPPER DHL(9 ROWS)
	-- [NOTE: TABLES TO BE USED -SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER] */
 SELECT 
    s.shipper_name,
    a.city AS city_catering,
    COUNT(DISTINCT oc.customer_id) AS customers_catered,
    COUNT(*) AS consignments_delivered
FROM 
    (((shipper s
INNER JOIN 
    order_header oh ON s.shipper_id = oh.shipper_id)
INNER JOIN 
    online_customer oc ON oh.customer_id = oc.customer_id)
INNER JOIN 
    address a ON oc.address_id = a.address_id)
WHERE 
    s.shipper_name = 'DHL'
GROUP BY 
    s.shipper_name, a.city;
 

/*-- 6. WRITE A QUERY TO DISPLAY CUSTOMER ID, CUSTOMER FULL NAME, TOTAL QUANTITY AND TOTAL VALUE (QUANTITY*PRICE) SHIPPED WHERE MODE 
-- OF PAYMENT IS CASH AND CUSTOMER LAST NAME STARTS WITH 'G'
	-- [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]*/
SELECT OC.CUSTOMER_ID, CONCAT(OC.CUSTOMER_FNAME,' ',OC.CUSTOMER_LNAME) AS FULL_NAME, SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY,
    SUM(OI.PRODUCT_QUANTITY * P.PRODUCT_PRICE) AS TOTAL_VALUE 
FROM 
    (((online_customer OC 
INNER JOIN 
    order_header OH ON OC.CUSTOMER_ID = OH.CUSTOMER_ID)
INNER JOIN 
    order_items OI ON OH.ORDER_ID = OI.ORDER_ID)
INNER JOIN 
    product P ON OI.PRODUCT_ID = P.PRODUCT_ID)
WHERE 
    OH.PAYMENT_MODE = 'Cash'
    AND OC.CUSTOMER_LNAME LIKE 'G%'
GROUP BY 
    OC.customer_id, OC.CUSTOMER_FNAME, OC.CUSTOMER_LNAME;
    
/*-- 7. WRITE A QUERY TO DISPLAY ORDER_ID AND VOLUME OF BIGGEST ORDER (IN TERMS OF VOLUME) THAT CAN FIT IN CARTON ID 10  
	-- [NOTE: TABLES TO BE USED -CARTON, ORDER_ITEMS, PRODUCT]*/
    SELECT 
    OI.ORDER_ID,
    SUM(OI.PRODUCT_QUANTITY * (C.LEN * C.WIDTH * C.HEIGHT)) AS TOTAL_VOLUME
FROM 
    ((order_items OI
INNER JOIN 
    product P ON OI.PRODUCT_ID = p.PRODUCT_ID)
INNER JOIN 
    carton C ON C.CARTON_ID = 10)
WHERE 
    OI.ORDER_ID IN (
        SELECT 
            order_id
        FROM 
            order_items
        WHERE 
            carton_id = 10
    )
GROUP BY 
    OI.order_id
ORDER BY 
    TOTAL_VOLUME DESC
LIMIT 1;

/*-- 8. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, QUANTITY SOLD, AND SHOW INVENTORY STATUS OF 
-- PRODUCTS AS BELOW AS PER BELOW CONDITION:
	-- A.FOR ELECTRONICS AND COMPUTER CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 10% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY', 
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 50% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 50% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- B.FOR MOBILES AND WATCHES CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 20% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 60% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 60% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- C.REST OF THE CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 30% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 70% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv. IF INVENTORY QUANTITY IS MORE OR EQUAL TO 70% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
        
			-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] (USE SUB-QUERY)*/
         
 SELECT res.product_id, res.product_desc , res.product_quantity_avail, res.quantity_sold,
	CASE WHEN pc.PRODUCT_CLASS_DESC IN ( 'Computer','Electronics' )
		THEN
			CASE WHEN res.quantity_sold = 0 THEN 'No Sales in past, give discount to reduce inventory'
				WHEN res.product_quantity_avail < res.quantity_sold * 10 / 100 THEN 'Low inventory, need to add inventory'
				WHEN res.product_quantity_avail < res.quantity_sold * 50 / 100 THEN 'Medium inventory, need to add some inventory'
				WHEN res.product_quantity_avail >= res.quantity_sold * 50 / 100 THEN 'Sufficient inventory' 
			END
        WHEN pc.PRODUCT_CLASS_DESC IN ( 'Mobiles', 'Watches' )
        THEN    
            CASE WHEN res.quantity_sold = 0 THEN 'No Sales in past, give discount to reduce inventory'
				WHEN res.product_quantity_avail < res.quantity_sold * 20 / 100 THEN 'Low inventory, need to add inventory'
				WHEN res.product_quantity_avail < res.quantity_sold * 60 / 100 THEN 'Medium inventory, need to add some inventory'
				WHEN res.product_quantity_avail >= res.quantity_sold * 60 / 100 THEN 'Sufficient inventory' 
			END 
		ELSE 
			CASE WHEN res.quantity_sold = 0 THEN 'No Sales in past, give discount to reduce inventory'
				WHEN res.product_quantity_avail < res.quantity_sold * 30 / 100 THEN 'Low inventory, need to add inventory'
				WHEN res.product_quantity_avail < res.quantity_sold * 70 / 100 THEN 'Medium inventory, need to add some inventory'
				WHEN res.product_quantity_avail >= res.quantity_sold * 70 / 100 THEN 'Sufficient inventory' 
			END 
        END AS inventory_status
FROM orders.PRODUCT_CLASS pc 
INNER JOIN (
	SELECT p.PRODUCT_CLASS_CODE, p.PRODUCT_ID AS product_id, p.PRODUCT_DESC AS product_desc, SUM(p.PRODUCT_QUANTITY_AVAIL) AS product_quantity_avail,
 	   COALESCE(SUM(oi.PRODUCT_QUANTITY), 0) AS quantity_sold
	FROM orders.PRODUCT p
	LEFT JOIN orders.ORDER_ITEMS oi ON oi.PRODUCT_ID = p.PRODUCT_ID
	GROUP BY p.PRODUCT_ID, p.PRODUCT_DESC, p.PRODUCT_CLASS_CODE
    ) res ON res.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE; 
    
/*-- 9. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC AND TOTAL QUANTITY OF PRODUCTS WHICH ARE SOLD TOGETHER WITH PRODUCT ID 201 
-- AND ARE NOT SHIPPED TO CITY BANGALORE AND NEW DELHI. DISPLAY THE OUTPUT IN DESCENDING ORDER WITH RESPECT TO TOT_QTY.(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED -ORDER_ITEMS,PRODUCT,ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS] */
SELECT P.PRODUCT_ID, P.PRODUCT_DESC, SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY_OF_PRODUCTS
FROM (PRODUCT P
INNER JOIN order_items OI ON  P.PRODUCT_ID = OI.PRODUCT_ID)
WHERE 
    OI.ORDER_ID IN (
        SELECT 
            OH.ORDER_ID
        FROM 
            order_header OH
        JOIN 
            online_customer OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
        JOIN 
            address A ON OC.ADDRESS_ID = A.ADDRESS_ID
        WHERE 
            A.CITY NOT IN ('Bangalore', 'New Delhi')
    )
    AND OI.PRODUCT_ID = 201
GROUP BY 
    OI.PRODUCT_ID, p.PRODUCT_DESC
ORDER BY 
    TOTAL_QUANTITY_OF_PRODUCTS DESC;

/*-- 10. WRITE A QUERY TO DISPLAY THE ORDER_ID,CUSTOMER_ID AND CUSTOMER FULLNAME AND TOTAL QUANTITY OF PRODUCTS SHIPPED FOR ORDER IDS 
-- WHICH ARE EVENAND SHIPPED TO ADDRESS WHERE PINCODE IS NOT STARTING WITH "5" 
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER,ORDER_HEADER, ORDER_ITEMS, ADDRESS]
  */  
SELECT 
    OH.ORDER_ID, OC.CUSTOMER_ID, CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS FULLNAME,
    SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY_SHIPPED
FROM 
    (((order_header OH
INNER JOIN 
    online_customer OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID)
INNER JOIN 
    address a ON oc.ADDRESS_ID = a.ADDRESS_ID)
INNER JOIN 
    order_items OI ON OH.ORDER_ID = OI.ORDER_ID)
WHERE 
    OH.ORDER_ID % 2 = 0
    AND NOT (a.PINCODE LIKE '5%')
GROUP BY 
    OH.ORDER_ID, OC.CUSTOMER_ID, OC.CUSTOMER_FNAME,OC.CUSTOMER_LNAME ;