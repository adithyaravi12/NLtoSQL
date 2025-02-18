SELECT TOP 5 * FROM [proj1].[dbo].[sales];
SELECT TOP 5 * FROM [proj1].[dbo].[stores];
SELECT TOP 5 * FROM [proj1].[dbo].[products];
SELECT TOP 5 * FROM [proj1].[dbo].[inventory];

SELECT
	COLUMN_NAME, DATA_TYPE
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_SCHEMA = 'dbo' AND
	TABLE_NAME = 'sales';

SELECT
	COLUMN_NAME, DATA_TYPE
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_SCHEMA = 'dbo' AND
	TABLE_NAME = 'stores';

SELECT
	COLUMN_NAME, DATA_TYPE
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_SCHEMA = 'dbo' AND
	TABLE_NAME = 'products';

SELECT
	COLUMN_NAME, DATA_TYPE
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_SCHEMA = 'dbo' AND
	TABLE_NAME = 'inventory';

SELECT 
    'sales' AS TableName,
    SUM(CASE WHEN Sale_ID IS NULL THEN 1 ELSE 0 END) AS Sale_ID_Nulls,
    SUM(CASE WHEN Date IS NULL THEN 1 ELSE 0 END) AS Date_Nulls,
    SUM(CASE WHEN Store_ID IS NULL THEN 1 ELSE 0 END) AS Store_ID_Nulls,
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS Product_ID_Nulls,
    SUM(CASE WHEN Units IS NULL THEN 1 ELSE 0 END) AS Units_Nulls
FROM sales
UNION ALL
SELECT 
    'stores',
    SUM(CASE WHEN Store_ID IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN Store_Name IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN Store_City IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN Store_Location IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN Store_Open_Date IS NULL THEN 1 ELSE 0 END)
FROM stores
UNION ALL
--SELECT 
--    'inventory',
--    SUM(CASE WHEN Store_ID IS NULL THEN 1 ELSE 0 END),
--    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END),
--    SUM(CASE WHEN Stock_On_Hand IS NULL THEN 1 ELSE 0 END),
--    NULL, NULL
--FROM inventory
SELECT 
    'inventory',
    COALESCE(SUM(CASE WHEN Store_ID IS NULL THEN 1 ELSE 0 END), 0),
    COALESCE(SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END), 0),
    COALESCE(SUM(CASE WHEN Stock_On_Hand IS NULL THEN 1 ELSE 0 END), 0),
    0, 0 
FROM inventory
UNION ALL
SELECT 
    'products',
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN Product_Name IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN Product_Category IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN Product_Cost IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN Product_Price IS NULL THEN 1 ELSE 0 END)
FROM products;

SELECT Sale_ID, COUNT(*)
	FROM [dbo].[sales]
	GROUP BY Sale_ID
	HAVING COUNT(*) > 1;

ALTER TABLE [dbo].[sales] 
	ADD CONSTRAINT PK_Sales PRIMARY KEY (Sale_ID);

SELECT Store_ID, COUNT(*)
	FROM [dbo].[stores]
	GROUP BY Store_ID
	HAVING COUNT(*) > 1;

ALTER TABLE [dbo].[stores] 
	ADD CONSTRAINT PK_Stores PRIMARY KEY (Store_ID);

SELECT Product_ID, COUNT(*)
	FROM [dbo].[products]
	GROUP BY Product_ID
	HAVING COUNT(*) > 1;

ALTER TABLE [dbo].[products] 
	ADD CONSTRAINT PK_Products PRIMARY KEY (Product_ID);

SELECT Store_ID, Product_ID, COUNT(*) AS duplicate_count
	FROM [dbo].[inventory]
	GROUP BY Store_ID, Product_ID
	HAVING COUNT(*) > 1;

SELECT s.*
	FROM sales s
	LEFT JOIN stores st ON s.Store_ID = st.Store_ID
	WHERE st.Store_ID IS NULL;

SELECT s.*
	FROM sales s
	LEFT JOIN products p ON s.Product_ID = p.Product_ID
	WHERE p.Product_ID IS NULL;

SELECT i.*
	FROM inventory i
	LEFT JOIN stores s ON i.Store_ID = s.Store_ID
	LEFT JOIN products p ON i.Product_ID = p.Product_ID
	WHERE s.Store_ID IS NULL OR p.Product_ID IS NULL;

-------------------------------------------------------------------------
-- Total Sale
SELECT s.Store_ID, st.Store_Name, SUM(s.Units) AS Total_Units_Sold
	FROM [dbo].[sales] s
	JOIN [dbo].[stores] st ON s.Store_ID = st.Store_ID
		GROUP BY s.Store_ID, st.Store_Name
			ORDER BY Total_Units_Sold DESC;

-- Total Revenue
SELECT s.Store_ID, st.Store_Name, SUM(s.Units * p.Product_Price) AS Total_Revenue
	FROM [dbo].[sales] s
	JOIN [dbo].[stores] st ON s.Store_ID = st.Store_ID
		JOIN [dbo].[products] p ON s.Product_ID = p.Product_ID
		GROUP BY s.Store_ID, st.Store_Name
			ORDER BY Total_Revenue DESC;

-- Top 5 toys
SELECT TOP 5 p.Product_Name, SUM(s.Units) AS Total_Units_Sold
	FROM [dbo].[sales] s
	JOIN [dbo].[products] p ON s.Product_ID = p.Product_ID
		GROUP BY p.Product_Name
			ORDER BY Total_Units_Sold DESC;

-- low stock
SELECT i.Store_ID, st.Store_Name, i.Product_ID, p.Product_Name, i.Stock_On_Hand
	FROM inventory i
	JOIN stores st ON i.Store_ID = st.Store_ID
		JOIN products p ON i.Product_ID = p.Product_ID
		WHERE i.Stock_On_Hand < 10
			ORDER BY i.Stock_On_Hand ASC;

SELECT @@SERVERNAME, @@SERVICENAME;

SELECT * FROM sys.dm_exec_connections;
EXEC xp_readerrorlog 0, 1, N'listening on';


ALTER LOGIN sa WITH PASSWORD = '';
ALTER LOGIN sa ENABLE;
GO

