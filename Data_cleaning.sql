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

select *, row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num from layoffs_staging;

with duplicate_cte as (
select *, row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num from layoffs_staging)
select * from duplicate_cte where row_num>1;

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
drop table if exists layoffs_staging2;

insert into layoffs_staging2 
select *, row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num from layoffs_staging;

SELECT 
    *
FROM
    layoffs_staging2;

DELETE FROM layoffs_staging2 
WHERE
    row_num > 1;

-- Standardizing the Data

SELECT 
    company, TRIM(company)
FROM
    layoffs_staging2;

UPDATE layoffs_staging2 
SET 
    company = TRIM(company);

SELECT 
    company
FROM
    layoffs_staging2;

SELECT DISTINCT
    industry
FROM
    layoffs_staging2
ORDER BY 1;

select * from layoffs_staging2 where industry like 'Crypto%';

UPDATE layoffs_staging2 
SET 
    industry = 'Crypto'
WHERE
    industry LIKE 'Crypto%';

Select distinct industry from layoffs_staging2 order by 1;


SELECT DISTINCT
    country, TRIM(TRAILING '.' FROM country)
FROM
    layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2 
SET 
    country = TRIM(TRAILING '.' FROM country)
WHERE
    country LIKE 'United States%';
    
    
SELECT DISTINCT
    country
FROM
    layoffs_staging2 ;
    
SELECT 
    `date`
FROM
    layoffs_staging2;	
    
update layoffs_staging2
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `Date` date;

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;


SELECT 
    *
FROM
    layoffs_staging2
WHERE
    company = 'Airbnb';
    
SELECT 
    *
FROM
    layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company
WHERE
    (t1.industry IS NULL OR t1.industry = '')
        AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 
SET 
    industry = NULL
WHERE
    industry = '';

UPDATE layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company 
SET 
    t1.industry = t2.industry
WHERE
    (t1.industry IS NULL OR t1.industry = '')
        AND t2.industry IS NOT NULL;
        
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    company like 'Bally%';
    
-- Deleting unwanted rows
    
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2 
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;
  
alter table layoffs_staging2
drop column row_num;

-- Cleaned Data
SELECT 
    *
FROM
    layoffs_staging2;