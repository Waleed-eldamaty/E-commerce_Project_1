-- Question (1): Email was sent on 27th of November-2012.
-- Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?

-- -----------------------------------------------------------------------------------------------------------------------------

-- Solution Starts:

SELECT
YEAR(website_sessions.created_at) AS yr,
MONTH(website_sessions.created_at) AS Mth,
-- website_sessions.utm_campaign, (You can add this line and group by 1,2,3 as another solution to question 2)
COUNT(DISTINCT website_sessions.website_session_id) AS Number_of_Sessions,
COUNT(DISTINCT orders.order_id) AS Number_of_Orders,
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS Conversion_Rate
FROM website_sessions
LEFT JOIN Orders
ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.utm_source='gsearch'
AND website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

-- Conlcusion to question(1): Conversion Rate as well as Number of Sessions and Order are growing over the months

-- -----------------------------------------------------------------------------------------------------------------------------

-- Question(2): it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately .
--  I am wondering if brand is picking up at all. If so, this is a good story to tell.

-- -----------------------------------------------------------------------------------------------------------------------------

-- Solution Starts:

SELECT
YEAR(website_sessions.created_at) AS yr,
MONTH(website_sessions.created_at) AS Mth,
COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN website_sessions.website_session_id ELSE NULL END) AS Number_of_brand_sessions,
COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN orders.order_id ELSE NULL END) AS Number_of_brand_orders,
COUNT(DISTINCT CASE WHEN utm_campaign='nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS Number_of_nonbrand_sessions,
COUNT(DISTINCT CASE WHEN utm_campaign='nonbrand' THEN orders.order_id ELSE NULL END) AS Number_of_nonbrand_orders
FROM website_sessions
LEFT JOIN Orders
ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.utm_source='gsearch'
AND website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

-- Conlcusion to question(2): Brand sessions are picking up

-- -----------------------------------------------------------------------------------------------------------------------------

-- Question(3): While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? 
-- I want to flex our analytical muscles a little and show the board we really know our traffic sources.

-- -----------------------------------------------------------------------------------------------------------------------------

-- Solution Starts:

SELECT
YEAR(website_sessions.created_at) AS yr,
MONTH(website_sessions.created_at) AS Mth,
COUNT(DISTINCT CASE WHEN device_type='mobile' THEN website_sessions.website_session_id ELSE NULL END) AS Number_of_mobile_sessions,
COUNT(DISTINCT CASE WHEN device_type='mobile' THEN orders.order_id ELSE NULL END) AS Number_of_mobile_orders,
COUNT(DISTINCT CASE WHEN device_type='desktop' THEN website_sessions.website_session_id ELSE NULL END) AS Number_of_desktop_sessions,
COUNT(DISTINCT CASE WHEN device_type='desktop' THEN orders.order_id ELSE NULL END) AS Number_of_desktop_orders
FROM website_sessions
LEFT JOIN Orders
ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.utm_source='gsearch'
AND website_sessions.utm_campaign='nonbrand'
AND website_sessions.created_at < '2012-11-27'
GROUP BY 1,2 ;

-- Conlcusion to question(3): The ratio between Desktop orders and mobile orders have increased over the months. Same with sessions as well

-- -----------------------------------------------------------------------------------------------------------------------------

-- Question(4): I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch.
-- Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?

-- -----------------------------------------------------------------------------------------------------------------------------

-- Solution Starts:

-- First, we have to identify the different utm sources and referers to see the traffic we are getting

SELECT DISTINCT
utm_source,
utm_campaign,
http_referer
FROM website_sessions
WHERE created_at < '2012-11-27';

-- Use the outcome of the previous query to write the next conditions of the next query
-- When utm source & utm campaign are null AND there is no refering domain (Null), This means it was a direct type in Traffic
-- When the paid parameters (utm source & utm campaign) are null AND we have a search engine as the referer, this means it is an organic search traffic

SELECT
YEAR(website_sessions.created_at) AS yr,
MONTH(website_sessions.created_at) AS Mth,
COUNT(DISTINCT CASE WHEN utm_source='gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions, -- Covering Rows 1 & 3 from the outcome of the previous query
COUNT(DISTINCT CASE WHEN utm_source='bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions, -- Covering Rows 5 & 7 from the outcome of the previous query
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions, -- Covering Rows 4 & 6 from the outcome of the previous query
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_sessions -- Covering Row 2 from the outcome of the previous query
FROM website_sessions
LEFT JOIN Orders
ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2 ;

-- Conlcusion to question(4): The board and CEO will be excited about the organic and direct type in traffic because it came without paying for them.
-- Meanwhile gsearch and bsearch paid sessions indicate the cost of customer acquisition which eats into your margin

-- -----------------------------------------------------------------------------------------------------------------------------

-- Question(5): I’d like to tell the story of our website performance improvements over the course of the first 8 months.
-- Could you pull session to order conversion rates, by month ?

-- -----------------------------------------------------------------------------------------------------------------------------

-- Solution Starts:

SELECT
YEAR(website_sessions.created_at) AS yr,
MONTH(website_sessions.created_at) AS Mth,
COUNT(DISTINCT website_sessions.website_session_id) AS Number_of_Sessions,
COUNT(DISTINCT orders.order_id) AS Number_of_Orders,
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS Conversion_Rate
FROM website_sessions
LEFT JOIN Orders
ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

-- Conlcusion to question(5): The conversion rate has increased from 3.2 % to 4.4 % over the months

-- -----------------------------------------------------------------------------------------------------------------------------

-- Question(6): For the gsearch lander test, please estimate the revenue that test earned us
-- Hint: Look at the increase in CVR from the test (Jun 19 Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value

-- -----------------------------------------------------------------------------------------------------------------------------

-- Solution Starts:

-- To find the first pageview id where the lander-1 test started, we submit the following query:

SELECT
website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url= '/lander-1';

-- first_test_pv=23504
-- Then we use the first_test_pv to limit the next query and get the relevant sessions

CREATE TEMPORARY TABLE First_Test_pageviews
SELECT
website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id) AS min_test_pv
FROM website_pageviews
INNER JOIN website_sessions
ON website_pageviews.website_session_id=website_sessions.website_session_id
WHERE website_pageviews.created_at < '2012-07-28' -- Prescribed by assignment
-- WHERE website_pageviews.created_at BETWEEN '2012-06-19' AND '2012-07-28' -- can be used instead of the last condition of pageview id > 23504
AND website_sessions.utm_campaign='nonbrand' -- Prescribed by assignment
AND website_sessions.utm_source='gsearch' -- Prescribed by assignment
AND website_pageviews.website_pageview_id >= 23504 -- first_page_view
GROUP BY website_pageviews.website_session_id;

-- For QA
SELECT * FROM First_Test_pageviews;

-- Next, we will find the landing page for each session from the previous query
CREATE TEMPORARY TABLE Nonbrand_test_sessions_with_landing_page
SELECT
First_Test_pageviews.website_session_id,
First_Test_pageviews.min_test_pv,
website_pageviews.pageview_url AS Landing_Page
FROM First_Test_pageviews
LEFT JOIN website_pageviews
ON website_pageviews.website_pageview_id=First_Test_pageviews.min_test_pv
WHERE website_pageviews.pageview_url IN('/home','/lander-1');

-- For QA
SELECT * FROM Nonbrand_test_sessions_with_landing_page;

-- Bring the orders

CREATE TEMPORARY TABLE nonbrand_test_sessions_with_orders
SELECT
Nonbrand_test_sessions_with_landing_page.website_session_id,
Nonbrand_test_sessions_with_landing_page.Landing_page,
orders.order_id
FROM Nonbrand_test_sessions_with_landing_page
LEFT JOIN orders
ON Nonbrand_test_sessions_with_landing_page.website_session_id=orders.website_session_id;

-- For QA
SELECT * FROM nonbrand_test_sessions_with_orders;

-- To find the difference between the conversion rates

SELECT
Landing_page,
COUNT(DISTINCT website_session_id) AS Number_of_Sessions,
COUNT(DISTINCT order_id) AS Number_of_orders,
COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS Conversion_Rate
FROM nonbrand_test_sessions_with_orders
GROUP BY Landing_page;

-- The conversion rate of /lander-1 (0.0406) is fairly better than /home (0.0318)
-- We have 0.0087 (0.0406-0.0318) additional orders per session

-- To find the last pageview for gsearch nonbrand where the traffic was sent to /home

SELECT
MAX(website_pageviews.website_session_id) AS Latest_gsearch_nonbrand_home_pageview
FROM website_pageviews
LEFT JOIN website_sessions
ON website_pageviews.website_session_id=website_sessions.website_session_id
WHERE website_pageviews.created_at < '2012-11-27' -- email sent date
AND website_pageviews.pageview_url='/home'
AND website_sessions.utm_campaign='nonbrand' 
AND website_sessions.utm_source='gsearch' ;

-- Max website session ID = 17145, (Turns out the date it was Created at is 29/7 _ After the test was concluded), where we had nonbrand & gsearch traffic going to /home page.
-- After that website session id, all of the traffic has been rerouted to lander-1

-- Find the number of sessions where the traffic was routed to /lander-1
SELECT
COUNT(website_session_id) AS Sessions_Since_Test
from website_sessions
WHERE website_session_id > 17145 -- Last /home Session, afterwards it went to /lander-1
AND created_at < '2012-11-27' 
AND utm_campaign='nonbrand' 
AND utm_source='gsearch';

-- We had 22972 Sessions that was routed to lander-1 since the test was concluded 

-- Conlcusion to question(6):
-- 22972 (Sessions) * 0.0087 (Difference in Conversion Rate) = 202 (Incremental orders) since the test was concluded/finished on (29/7) 4 months ago (since email was sent on 27th of Nov).
-- Thats 50 extra ordres per month
-- -----------------------------------------------------------------------------------------------------------------------------

-- Question(7): For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each of the two pages to orders .
-- You can use the same time period you analyzed last time (Jun 19 Jul 28).

-- -----------------------------------------------------------------------------------------------------------------------------


-- Solution Starts:

-- STEP 1: Select all pageviews for relevant sessions & STEP 2: Identify each pageview as the specfic funnel step


SELECT
website_sessions.website_session_id,
website_pageviews.pageview_url,
CASE WHEN pageview_url='/home' THEN 1 ELSE 0 END AS Home_Page, -- Creating flags for each page
CASE WHEN pageview_url='/lander-1' THEN 1 ELSE 0 END AS custom_Page, -- Creating flags for each page
CASE WHEN pageview_url='/products' THEN 1 ELSE 0 END AS Products_Page, -- Creating flags for each page
CASE WHEN pageview_url='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS Mr_Fuzzy_Page, -- Creating flags for each page
CASE WHEN pageview_url='/cart' THEN 1 ELSE 0 END AS cart_Page, -- Creating flags for each page
CASE WHEN pageview_url='/shipping' THEN 1 ELSE 0 END AS shipping_Page, -- Creating flags for each page
CASE WHEN pageview_url='/billing' THEN 1 ELSE 0 END AS billing_Page, -- Creating flags for each page
CASE WHEN pageview_url='/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_Page -- Creating flags for each page
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id=website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
AND utm_source='gsearch'
AND utm_campaign='nonbrand';


-- STEP 3: Create Session-Level conversion funnel view

-- We will put the previous Query into a subquery then use MAX to identify which page did each website session reached

SELECT
website_session_id,
MAX(Home_Page) AS Home_made_it,
MAX(Custom_Page) AS custom_made_it,
MAX(Products_Page) AS product_made_it,
MAX(Mr_Fuzzy_Page) AS Mr_Fuzzy_made_it,
MAX(cart_Page) AS cart_made_it,
MAX(shipping_Page) AS shipping_made_it,
MAX(billing_Page) AS billing_made_it,
MAX(thank_you_Page) AS thank_you_made_it
FROM(
SELECT
website_sessions.website_session_id,
website_pageviews.pageview_url,
CASE WHEN pageview_url='/home' THEN 1 ELSE 0 END AS Home_Page, -- Creating flags for each page
CASE WHEN pageview_url='/lander-1' THEN 1 ELSE 0 END AS Custom_Page, -- Creating flags for each page
CASE WHEN pageview_url='/products' THEN 1 ELSE 0 END AS Products_Page, -- Creating flags for each page
CASE WHEN pageview_url='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS Mr_Fuzzy_Page, -- Creating flags for each page
CASE WHEN pageview_url='/cart' THEN 1 ELSE 0 END AS cart_Page, -- Creating flags for each page
CASE WHEN pageview_url='/shipping' THEN 1 ELSE 0 END AS shipping_Page, -- Creating flags for each page
CASE WHEN pageview_url='/billing' THEN 1 ELSE 0 END AS billing_Page, -- Creating flags for each page
CASE WHEN pageview_url='/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_Page -- Creating flags for each page
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id=website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
AND utm_source='gsearch'
AND utm_campaign='nonbrand') AS PageView_Level
GROUP BY website_session_id;

-- STEP 4: Aggregate the data to asses the funnel performance
-- We will create a temporary table of the previous query


CREATE TEMPORARY TABLE session_level_made_it_with_Flags_Mid_Course
SELECT
website_session_id,
MAX(Home_Page) AS Home_made_it,
MAX(Custom_Page) AS custom_made_it,
MAX(Products_Page) AS product_made_it,
MAX(Mr_Fuzzy_Page) AS Mr_Fuzzy_made_it,
MAX(cart_Page) AS cart_made_it,
MAX(shipping_Page) AS shipping_made_it,
MAX(billing_Page) AS billing_made_it,
MAX(thank_you_Page) AS thank_you_made_it
FROM(
SELECT
website_sessions.website_session_id,
website_pageviews.pageview_url,
CASE WHEN pageview_url='/home' THEN 1 ELSE 0 END AS Home_Page, -- Creating flags for each page
CASE WHEN pageview_url='/lander-1' THEN 1 ELSE 0 END AS Custom_Page, -- Creating flags for each page
CASE WHEN pageview_url='/products' THEN 1 ELSE 0 END AS Products_Page, -- Creating flags for each page
CASE WHEN pageview_url='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS Mr_Fuzzy_Page, -- Creating flags for each page
CASE WHEN pageview_url='/cart' THEN 1 ELSE 0 END AS cart_Page, -- Creating flags for each page
CASE WHEN pageview_url='/shipping' THEN 1 ELSE 0 END AS shipping_Page, -- Creating flags for each page
CASE WHEN pageview_url='/billing' THEN 1 ELSE 0 END AS billing_Page, -- Creating flags for each page
CASE WHEN pageview_url='/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_Page -- Creating flags for each page
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id=website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
AND utm_source='gsearch'
AND utm_campaign='nonbrand') AS PageView_Level
GROUP BY website_session_id;

-- Start the Counting
SELECT
CASE 
 WHEN Home_made_it=1 THEN 'Saw_HomePage'
 WHEN Custom_Made_it=1 THEN 'Saw_Custom_lander'
 ELSE 'Check Logic'
 END AS segment,
COUNT(DISTINCT website_session_id) As Total_Number_of_Sessions,
COUNT(DISTINCT CASE WHEN product_made_it=1 THEN website_session_id ELSE NULL END) AS Made_it_to_products,
COUNT(DISTINCT CASE WHEN Mr_Fuzzy_made_it=1 THEN website_session_id ELSE NULL END) AS Made_it_to_Mr_Fuzzy,
COUNT(DISTINCT CASE WHEN cart_made_it=1 THEN website_session_id ELSE NULL END) AS Made_it_to_cart,
COUNT(DISTINCT CASE WHEN shipping_made_it=1 THEN website_session_id ELSE NULL END) AS Made_it_to_shipping,
COUNT(DISTINCT CASE WHEN billing_made_it=1 THEN website_session_id ELSE NULL END) AS Made_it_to_billing,
COUNT(DISTINCT CASE WHEN thank_you_made_it=1 THEN website_session_id ELSE NULL END) AS Made_it_to_thank_you
FROM session_level_made_it_with_Flags_Mid_Course
GROUP BY 1;

-- To calculate the Click Rates, repeat the previous query with small modifications:

SELECT
CASE 
 WHEN Home_made_it=1 THEN 'Saw_HomePage'
 WHEN Custom_Made_it=1 THEN 'Saw_Custom_lander'
 ELSE 'Check Logic'
 END AS segment,
COUNT(DISTINCT website_session_id) As Total_Number_of_Sessions,
COUNT(DISTINCT CASE WHEN product_made_it=1 THEN website_session_id ELSE NULL END)/ COUNT(DISTINCT website_session_id) AS lander_click_rate,
COUNT(DISTINCT CASE WHEN Mr_Fuzzy_made_it=1 THEN website_session_id ELSE NULL END)/ COUNT(DISTINCT CASE WHEN product_made_it=1 THEN website_session_id ELSE NULL END) AS product_click_rate,
COUNT(DISTINCT CASE WHEN cart_made_it=1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN Mr_Fuzzy_made_it=1 THEN website_session_id ELSE NULL END) AS mr_fuzzy_click_rate,
COUNT(DISTINCT CASE WHEN shipping_made_it=1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_made_it=1 THEN website_session_id ELSE NULL END) AS cart_click_rate,
COUNT(DISTINCT CASE WHEN billing_made_it=1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_made_it=1 THEN website_session_id ELSE NULL END) AS shipping_click_rate,
COUNT(DISTINCT CASE WHEN thank_you_made_it=1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_made_it=1 THEN website_session_id ELSE NULL END) AS billing_click_rate
FROM session_level_made_it_with_Flags_Mid_Course
GROUP BY 1;

-- Conlcusion to question(7):
-- The conversion rate of the new custom lander page is higher than the coversion rate of the original home page

-- -----------------------------------------------------------------------------------------------------------------------------

-- Question(8): I’d love for you to quantify the impact of our billing test , as well.
-- Please analyze the lift generated from the test (Sep 10 - Nov 10), in terms of revenue per billing page session
-- then pull the number of billing page sessions for the past month to understand monthly impact.

-- -----------------------------------------------------------------------------------------------------------------------------

-- Solution Starts:


SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS Billing_Version_seen,
orders.order_id,
orders.price_usd
FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id=orders.website_session_id
WHERE website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10' -- AS requested in the email
AND website_pageviews.pageview_url IN ('/billing', '/billing-2');


-- Next, Put the previous query into a subquery to start calling from it

SELECT
Billing_Version_seen,
COUNT(DISTINCT website_session_id) AS Number_of_Sessions,
SUM(price_usd)/COUNT(DISTINCT website_session_id) AS Revenue_Per_Billing_session
FROM
( SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS Billing_Version_seen,
orders.order_id,
orders.price_usd
FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id=orders.website_session_id
WHERE website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10' -- AS requested in the email
AND website_pageviews.pageview_url IN ('/billing', '/billing-2')) AS Billing_Pageviews_and_orders_info
GROUP BY Billing_Version_seen;

-- Old Version of Billing  has a revenue of 22.82 $ per billing page seen
-- New Version of Billing  has a revenue of 31.33 $ per billing page seen
-- LIFT= 31.33-22.82 = 8.5 $ per billing page seen.
-- This means that everytime a customer sees the billing the page, you are now making 8 dollars and 50 cents more than you were previosuly

-- To determine the number of billing page sessions for the past month

SELECT
COUNT(DISTINCT website_session_id) AS Number_of_sessions_in_the_last_month
FROM website_pageviews
WHERE website_pageviews.created_at BETWEEN '2012-10-27' AND '2012-11-27' -- Last month since email was sent
AND website_pageviews.pageview_url IN ('/billing', '/billing-2');

-- Conlcusion to question(8):
-- 1193 Billing Sessions since last month
-- Each session has a revenue of 8.5 $
-- Total Value of the Billing Test = 1193*8.5 = 10,140.5 $ ( Now we quantified the billing test we created)

-- -----------------------------------------------------------------------------------------------------------------------------
