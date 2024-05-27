use world_layoffs;

select * from layoffs_staging2;

SELECT 
    MAX(total_laid_off), MAX(percentage_laid_off)
FROM
    layoffs_staging2;
    
    
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT 
    company, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT 
    MIN(`Date`), MAX(`Date`)
FROM
    layoffs_staging2;

SELECT 
    industry, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

SELECT 
    *
FROM
    layoffs_staging2;

SELECT 
    country, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;


SELECT 
    YEAR(`date`), SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
    stage, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

-- rolling total of layoffs
SELECT 
    SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM
    layoffs_staging2
WHERE
    SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY 1
ORDER BY 1;

with Rolling_total as(
SELECT 
    substring(`date`,1,7) as `MONTH` , SUM(total_laid_off) as total_off
FROM
    layoffs_staging2
    where substring(`date`,1,7) is not null
GROUP BY 1
order by 1)
select `MONTH` ,total_off, sum(total_off) over(order by `MONTH`) as rolling_total from Rolling_total;

SELECT 
    company, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT 
    company, YEAR(`date`), SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company , 2
ORDER BY 3 DESC;


with company_year (company,years,total_laid_off)as(
SELECT 
    company, YEAR(`date`), SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company , 2
ORDER BY 3 DESC), 
Company_year_rank as (
select * ,dense_rank() over(partition by years order by total_laid_off desc) as rank_no from company_year
where years is not null)
select * from Company_year_rank where rank_no<=5;