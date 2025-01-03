/*
Video Game Data Exploration

Skills to use: Joins, CTE's, Temp Tables, Window Functions, Aggregate Functions, Creating Views
*/

-- View of the whole data

SELECT *
FROM PortfolioWork.dbo.VGData

-- Select Data that i'm going to be starting with

SELECT title, console, genre, total_sales, release_date
FROM PortfolioWork.dbo.VGData
WHERE total_sales is not NULL
ORDER BY 2, 4 DESC

-- Analysing the data using Aggregate and Window Functions

-- Total sales and Avg total sales per console
SELECT console, ROUND(AVG(total_sales * 1000000), 0 ) as avg_sales_per_console, 
ROUND(SUM(total_sales * 1000000), 0 ) as total_sales_per_console
FROM PortfolioWork.dbo.VGData
WHERE total_sales is not NULL
GROUP BY console
ORDER BY 3 DESC

-- Total sales and Avg total sales per genre
SELECT genre, ROUND(AVG(total_sales * 1000000), 0 ) as avg_sales_per_genre, 
ROUND(SUM(total_sales * 1000000), 0 ) as total_sales_per_genre
FROM PortfolioWork.dbo.VGData
WHERE total_sales is not NULL
GROUP BY genre
ORDER BY 2 DESC

-- Dominant genre per console using Windows Functions
SELECT console, genre, COUNT(genre) genre_per_console,
FORMAT(
(COUNT(genre) * 100.00 / SUM(COUNT(genre)) OVER (PARTITION BY console)), 'N2'
) as percentage_of_genre_dominance
FROM PortfolioWork.dbo.VGData
WHERE total_sales is not NULL
GROUP BY console, genre
ORDER BY 1, 3 DESC

-- Percentage of regional sales
SELECT title, console, genre, total_sales * 1000000 as world_title_sales,
FORMAT(
((na_sales * 100.00) / total_sales),'N2'
) as na_sales_percentage, 
FORMAT(
((jp_sales * 100.00) / total_sales),'N2')
as jp_sales_percentage, 
FORMAT(
((pal_sales * 100.00) / total_sales),'N2'
) as pal_sales_percentage, 
FORMAT(
((other_sales * 100.00) / total_sales),'N2'
)as other_sales_percentage
FROM PortfolioWork.dbo.VGData
WHERE total_sales is not NULL 
AND na_sales is not NULL
AND jp_sales is not NULL
AND pal_sales is not NULL
AND other_sales is not NULL
ORDER BY world_title_sales DESC

-- total_sales per console
SELECT console, SUM((total_sales * 1000000)) AS total_sales
FROM PortfolioWork.dbo.VGData
WHERE total_sales is not NULL	
GROUP BY console
ORDER BY 2 DESC

-- Finding title total sales difference percentage by console using self join
SELECT DISTINCT vg1.title, vg1.console AS console1, vg1.total_sales * 1000000 AS console1_sales, 
vg2.console AS console2, vg2.total_sales * 1000000 AS console2_sales,
ABS(
((vg1.total_sales-vg2.total_sales) / ((vg1.total_sales+vg2.total_sales)/2)) * 100.00
) AS diff_percentage
FROM PortfolioWork.dbo.VGData vg1
JOIN PortfolioWork.dbo.VGData vg2 ON
	vg1.title = vg2.title AND
	vg1.console <> vg2.console
WHERE vg1.total_sales IS NOT NULL AND
vg2.total_sales IS NOT NULL AND
vg1.total_sales <> 0 AND
vg2.total_sales <> 0
ORDER BY diff_percentage DESC

-- Using CTE's to get a genre sale comparison per console
WITH FilteredVGData AS 
(SELECT console, genre, SUM((total_sales * 1000000)) as genre_sales
FROM PortfolioWork.dbo.VGData
WHERE total_sales IS NOT NULL AND
total_sales <> 0
GROUP BY console, genre
),
ConsolePair AS 
(SELECT vg1.genre, vg1.console AS console1, vg1.genre_sales AS console1_sales, 
vg2.console, vg2.genre_sales AS console2_sales
FROM FilteredVGData vg1
JOIN FilteredVGData vg2 ON 
	vg1.genre = vg2.genre AND vg1.console <> vg2.console
)
SELECT DISTINCT *
FROM ConsolePair
ORDER BY console1_sales DESC, console2_sales ASC

-- Using Temp Tables to get a genre sale comparison per console

DROP TABLE if exists #GenreConsoleSales
CREATE TABLE #GenreConsoleSales
(console nvarchar(255),
genre nvarchar(255),
genre_sales numeric)

INSERT INTO #GenreConsoleSales
SELECT console, genre, SUM((total_sales * 1000000))
FROM PortfolioWork.dbo.VGData
WHERE total_sales IS NOT NULL AND
total_sales <> 0
GROUP BY console, genre

SELECT DISTINCT vg1.genre, vg1.console AS console1, vg1.genre_sales AS console1_sales, 
vg2.console, vg2.genre_sales AS console2_sales
FROM #GenreConsoleSales vg1
JOIN #GenreConsoleSales vg2 ON 
	vg1.genre = vg2.genre AND vg1.console <> vg2.console
ORDER BY console1_sales DESC, console2_sales ASC

-- Creating View to store data for later visualization

CREATE VIEW TitleSaleDifferencePerConsole AS
SELECT DISTINCT vg1.title, vg1.console AS console1, vg1.total_sales * 1000000 AS console1_sales, 
vg2.console AS console2, vg2.total_sales * 1000000 AS console2_sales,
ABS(
((vg1.total_sales-vg2.total_sales) / ((vg1.total_sales+vg2.total_sales)/2)) * 100.00
) AS diff_percentage
FROM PortfolioWork.dbo.VGData vg1
JOIN PortfolioWork.dbo.VGData vg2 ON
	vg1.title = vg2.title AND
	vg1.console <> vg2.console
WHERE vg1.total_sales IS NOT NULL AND
vg2.total_sales IS NOT NULL AND
vg1.total_sales <> 0 AND
vg2.total_sales <> 0