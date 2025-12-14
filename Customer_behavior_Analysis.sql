create database customer_shopping;

use customer_shopping;
-- 1 . what is the total revenue genereted by male vs female customers?

SELECT 
    gender, SUM(purchase_amount) AS revenue
FROM
    customer_dataa
GROUP BY gender;

-- 2.witch customers used a discount but still spent more 
-- than then average  purchase amount?

SELECT 
    customer_id, purchase_amount
FROM
    customer_dataa
WHERE
    discount_applied = 'Yes'
        AND purchase_amount >= (SELECT 
            AVG(purchase_amount)
        FROM
            customer_dataa);

-- 3.witch are the top 5 products with highest average review rating?
SELECT 
    item_purchased,
    ROUND(AVG(review_rating), 2) AS average_view_rating
FROM
    customer_dataa
GROUP BY item_purchased
ORDER BY AVG(review_rating) DESC
LIMIT 5;

-- 4.compare the average purchase amount between standad and express shipping.

SELECT 
    shipping_type,
    ROUND(AVG(purchase_amount), 2) AS avg_pur_amount
FROM
    customer_dataa
WHERE
    shipping_type IN ('standard' , 'Express')
GROUP BY shipping_type;

-- 5. do subsraibed customers spand more? compare average spandnand total revanue
-- between subscraibers  and non-subscraibers.

SELECT 
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_spend,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM
    customer_dataa
GROUP BY subscription_status
ORDER BY total_revenue , avg_spend DESC;

-- 6.  witch 5 products have the highest percentage of purchases with discounts applied?

SELECT 
    item_purchased,
    ROUND(SUM(CASE
                WHEN discount_applied = 'Yes' THEN 1
                ELSE 0
            END) / COUNT(*) * 100,
            2) AS discount_rate
FROM
    customer_dataa
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;
-- 7 .segment customer into new returning and loyal based  on thair total
-- number of previous purchases ,and show the count of each segment.alter

with customer_type as (
select customer_id,previous_purchases,
CASE
    WHEN previous_purchases = 1 then "new"
    when previous_purchases  BETWEEN 2 AND 10 THEN "returning"
    else "loyal"
    end as customre_segment
from customer_dataa
)
select  customre_segment,count(*) as number_of_customers
from customer_type
group by customre_segment;

-- 8 . what are the top 3 most purchased products within each category?

WITH item_counts AS (
    SELECT 
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER(
            PARTITION BY category 
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rnk
    FROM customer_dataa
    GROUP BY category, item_purchased
)
SELECT 
    item_rnk,
    category,
    item_purchased,
    total_orders
FROM item_counts
WHERE item_rnk <= 3;
-- 9. are customers who are repeat buyers(more then 5 previous purchases) also
-- likely to subscraibe?
SELECT 
    subscription_status, COUNT(customer_id) AS repeat_buyers
FROM
    customer_dataa
WHERE
    previous_purchases > 5
GROUP BY subscription_status;

-- 10. what is the revenue contribution of each age group?
SELECT 
    age_group, SUM(purchase_amount) AS total_revenue
FROM
    customer_dataa
GROUP BY age_group
ORDER BY total_revenue DESC;