#Exploratory data analysis

SELECT *
FROM layoffs_staging2;


-- Date range of layoffs
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Maximum % of employees laid off by company
SELECT MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT percentage_laid_off, COUNT(total_laid_off) AS Total_companies
FROM layoffs_staging2
GROUP BY percentage_laid_off
ORDER BY percentage_laid_off DESC;
-------------------------------------------------------------------------------------------------------------------

-- Total number of Companies, industries, Country & location
SELECT COUNT(DISTINCT(company)) Companies,COUNT(DISTINCT(industry)) Industries, 
COUNT(DISTINCT(country)) Country, COUNT(DISTINCT(location)) Location
FROM layoffs_staging2;

-- Total employees laid off
SELECT SUM(total_laid_off)
FROM layoffs_staging2;


-- Total employees laid off with average percentage & funds raised by each company
SELECT company, SUM(total_laid_off), AVG (percentage_laid_off), AVG (funds_raised_millions)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY SUM(total_laid_off) DESC;

-- Total employees laid off in each country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

-- Total employees laid off in each industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;

-- Total employees laid off in each company every year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY SUM(total_laid_off) DESC;
-------------------------------------------------------------------------------------------------------------------

-- Top 5 companies with maximum layoffs in each year

WITH cte as 
(SELECT company, year(`date`) , sum(total_laid_off), 
DENSE_RANK() OVER (PARTITION BY year(`date`) ORDER BY sum(total_laid_off) desc) as rankings
FROM layoffs_staging2
WHERE year(`date`) IS NOT NULL and total_laid_off IS NOT NULL
GROUP BY company, year(`date`)
ORDER BY year(`date`),sum(total_laid_off) desc)
SELECT * FROM cte WHERE rankings<= 5;
-------------------------------------------------------------------------------------------------------------------

-- Monthly report of total layoffs each year

WITH total as
(SELECT Year(`date`) as `year`, Month(`date`) as `month`, sum(total_laid_off) as Laid
FROM layoffs_staging2
WHERE Year(`date`) is not  null
GROUP BY Year(`date`),Month(`date`)
ORDER BY Year(`date`), Month(`date`)
)
SELECT  `year`, `month`, Laid, sum(Laid) OVER(ORDER BY `year`,`month`) as Rolling_total
FROM total;



