use world_layoffs;

SELECT 
    *
FROM
    layoffs;
    
-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Handle Null or Blank values
-- 4. Remove columns


create table layoffs_staging like layoffs;

select * from layoffs_staging;

insert layoffs_staging 
select * from layoffs;

-- Removing Duplicates

-- Step 1: Create a temporary table with row numbers assigned to each row based on all columns to identify duplicates
SELECT *, 
       ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoffs_staging;

-- Step 2: Use a CTE to select rows from the original table and assign row numbers to identify duplicates
WITH duplicate_cte AS (
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
    FROM layoffs_staging
)
-- Select rows that are identified as duplicates (row_num > 1)
SELECT * 
FROM duplicate_cte 
WHERE row_num > 1;

-- Step 4: Drop the new table if it already exists to avoid conflicts
DROP TABLE IF EXISTS layoffs_staging2;

-- Step 3: Create a duplicate table to store the data with assigned row numbers
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Step 5: Insert data into the new table with row numbers assigned to identify duplicates
INSERT INTO layoffs_staging2 
SELECT *, 
       ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoffs_staging;

-- Step 7: Remove duplicate rows from the new table, keeping only the first occurrence (row_num = 1)
DELETE FROM layoffs_staging2 
WHERE row_num > 1;

-- Step 6: Select all data from the new table for verification
SELECT * 
FROM layoffs_staging2;



-- Standardizing the Data

-- Step 1: Standardize the 'company' column by trimming whitespace
-- Preview the changes
SELECT 
    company, TRIM(company) AS trimmed_company
FROM
    layoffs_staging2;

-- Update the 'company' column to remove leading and trailing whitespace
UPDATE layoffs_staging2 
SET 
    company = TRIM(company);

-- Verify the changes
SELECT 
    company
FROM
    layoffs_staging2;

-- Step 2: Standardize the 'industry' column by consolidating similar entries
-- Display distinct values in the 'industry' column
SELECT DISTINCT
    industry
FROM
    layoffs_staging2
ORDER BY industry;

-- Identify entries that start with 'Crypto'
SELECT * 
FROM layoffs_staging2 
WHERE industry LIKE 'Crypto%';

-- Update 'industry' column to consolidate 'Crypto' entries
UPDATE layoffs_staging2 
SET 
    industry = 'Crypto'
WHERE
    industry LIKE 'Crypto%';

-- Verify the changes
SELECT DISTINCT 
    industry 
FROM layoffs_staging2 
ORDER BY industry;

-- Step 3: Standardize the 'country' column by removing trailing periods and ensuring consistent naming
-- Preview the changes
SELECT DISTINCT
    country, TRIM(TRAILING '.' FROM country) AS trimmed_country
FROM
    layoffs_staging2
ORDER BY country;

-- Update the 'country' column to remove trailing periods
UPDATE layoffs_staging2 
SET 
    country = TRIM(TRAILING '.' FROM country)
WHERE
    country LIKE 'United States%';

-- Verify the changes
SELECT DISTINCT 
    country 
FROM layoffs_staging2;

-- Step 4: Standardize the 'date' column by converting it to a proper date format
-- Preview the 'date' column values
SELECT 
    `date`
FROM
    layoffs_staging2;    

-- Update the 'date' column to convert string dates to DATE type
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Modify the column type to ensure it is a DATE type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Handling null and missing values

-- Step 1: Identify rows with both 'total_laid_off' and 'percentage_laid_off' as NULL
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

-- Step 2: Inspect all records for the company 'Airbnb'
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    company = 'Airbnb';

-- Step 3: Find rows with missing 'industry' information that can be filled from other rows with the same company
SELECT 
    *
FROM
    layoffs_staging2 t1
JOIN
    layoffs_staging2 t2 ON t1.company = t2.company
WHERE
    (t1.industry IS NULL OR t1.industry = '')
    AND t2.industry IS NOT NULL;

-- Step 4: Set 'industry' to NULL where it is an empty string
UPDATE layoffs_staging2 
SET 
    industry = NULL
WHERE
    industry = '';

-- Step 5: Update 'industry' in rows with missing values using information from other rows of the same company
UPDATE layoffs_staging2 t1
JOIN
    layoffs_staging2 t2 ON t1.company = t2.company 
SET 
    t1.industry = t2.industry
WHERE
    (t1.industry IS NULL OR t1.industry = '')
    AND t2.industry IS NOT NULL;
        
-- Step 6: Inspect all records for companies starting with 'Bally'
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    company LIKE 'Bally%';

-- Step 7: Identify rows to be deleted where both 'total_laid_off' and 'percentage_laid_off' are NULL
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

-- Step 8: Delete rows where both 'total_laid_off' and 'percentage_laid_off' are NULL
DELETE FROM layoffs_staging2 
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

-- Step 9: Drop the 'row_num' column as it is no longer needed
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Displaying  Cleaned Data
SELECT 
    *
FROM
    layoffs_staging2;
