USE world_layoffs;

-- Initial data inspection: Select all records from the 'layoffs_staging2' table
SELECT * FROM layoffs_staging2;

-- EDA Step 1: Identify the maximum values for 'total_laid_off' and 'percentage_laid_off'
SELECT 
    MAX(total_laid_off) AS max_total_laid_off, 
    MAX(percentage_laid_off) AS max_percentage_laid_off
FROM
    layoffs_staging2;

-- EDA Step 2: Find companies where 100% of the workforce was laid off and sort by funds raised
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- EDA Step 3: Calculate total layoffs by company to identify companies with the highest layoffs
SELECT 
    company, 
    SUM(total_laid_off) AS total_laid_off
FROM
    layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC;

-- EDA Step 4: Find the time range of the data by identifying the earliest and latest dates
SELECT 
    MIN(`date`) AS min_date, 
    MAX(`date`) AS max_date
FROM
    layoffs_staging2;

-- EDA Step 5: Calculate total layoffs by industry to identify the most affected industries
SELECT 
    industry, 
    SUM(total_laid_off) AS total_laid_off
FROM
    layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- EDA Step 6: Perform another inspection of all records
SELECT 
    *
FROM
    layoffs_staging2;

-- EDA Step 7: Calculate total layoffs by country to identify the most affected countries
SELECT 
    country, 
    SUM(total_laid_off) AS total_laid_off
FROM
    layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;

-- EDA Step 8: Calculate total layoffs by year to observe trends over time
SELECT 
    YEAR(`date`) AS year, 
    SUM(total_laid_off) AS total_laid_off
FROM
    layoffs_staging2
GROUP BY year
ORDER BY year DESC;

-- EDA Step 9: Calculate total layoffs by company stage to understand which stages were most affected
SELECT 
    stage, 
    SUM(total_laid_off) AS total_laid_off
FROM
    layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- EDA Step 10: Calculate monthly total layoffs to observe trends and seasonality
SELECT 
    SUBSTRING(`date`, 1, 7) AS `month`, 
    SUM(total_laid_off) AS total_laid_off
FROM
    layoffs_staging2
WHERE
    SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY `month`;

-- EDA Step 11: Calculate the rolling total of layoffs by month using a CTE
WITH Rolling_total AS (
    SELECT 
        SUBSTRING(`date`, 1, 7) AS `month`, 
        SUM(total_laid_off) AS total_off
    FROM
        layoffs_staging2
    WHERE 
        SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY `month`
    ORDER BY `month`
)
SELECT 
    `month`, 
    total_off, 
    SUM(total_off) OVER(ORDER BY `month`) AS rolling_total 
FROM 
    Rolling_total;

-- EDA Step 12: Calculate total layoffs by company again 
SELECT 
    company, 
    SUM(total_laid_off) AS total_laid_off
FROM
    layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC;

-- EDA Step 13: Calculate total layoffs by company and year to observe annual trends by company
SELECT 
    company, 
    YEAR(`date`) AS year, 
    SUM(total_laid_off) AS total_laid_off
FROM
    layoffs_staging2
GROUP BY company, year
ORDER BY total_laid_off DESC;

-- EDA Step 14: Use CTEs to rank companies by total layoffs per year, showing the top 5 companies per year
WITH company_year AS (
    SELECT 
        company, 
        YEAR(`date`) AS year, 
        SUM(total_laid_off) AS total_laid_off
    FROM
        layoffs_staging2
    GROUP BY company, year
    ORDER BY total_laid_off DESC
), 
Company_year_rank AS (
    SELECT 
        *, 
        DENSE_RANK() OVER(PARTITION BY year ORDER BY total_laid_off DESC) AS rank_no 
    FROM 
        company_year
    WHERE 
        year IS NOT NULL
)
SELECT 
    * 
FROM 
    Company_year_rank 
WHERE 
    rank_no <= 5;
