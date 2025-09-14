#Exploratory data analysis

SELECT *
FROM layoffs_staging2;


-- Date range of layoffs
SELECT min(`date`), max(`date`)
FROM layoffs_staging2;

-- Maximum % of employees laid off by company
select max(percentage_laid_off)
FROM layoffs_staging2;

SELECT percentage_laid_off, count(total_laid_off) As Total_companies
FROM layoffs_staging2
group by percentage_laid_off
ORDER BY percentage_laid_off desc;
-------------------------------------------------------------------------------------------------------------------

-- Total number of Companies, industries, Country & location
SELECT count(distinct(company)) Companies,count(distinct(industry)) Industries, 
count(distinct(country)) Country, count(distinct(location)) Location
FROM layoffs_staging2;

-- Total employees laid off
SELECT sum(total_laid_off)
FROM layoffs_staging2;


-- Total employees laid off with average percentage & funds raised by each company
SELECT company, sum(total_laid_off), avg (percentage_laid_off), avg (funds_raised_millions)
FROM layoffs_staging2
where total_laid_off is not null
Group by company
order by sum(total_laid_off) desc;

-- Total employees laid off in each country
SELECT country, sum(total_laid_off)
FROM layoffs_staging2
group by country
order by sum(total_laid_off) desc;

-- Total employees laid off in each industry
SELECT industry, sum(total_laid_off)
FROM layoffs_staging2
group by industry
order by sum(total_laid_off) desc;

-- Total employees laid off in each company every year
SELECT company, year(`date`), sum(total_laid_off)
FROM layoffs_staging2
group by company, year(`date`)
order by sum(total_laid_off) desc;
-------------------------------------------------------------------------------------------------------------------

-- Top 5 companies with maximum layoffs in each year

with cte as 
(SELECT company, year(`date`) , sum(total_laid_off), 
dense_rank() over (partition by  year(`date`) order by sum(total_laid_off) desc) as rankings
FROM layoffs_staging2
where year(`date`) is not null and total_laid_off is not null
group by company, year(`date`)
order by year(`date`),sum(total_laid_off) desc)
select * from cte where rankings<= 5;
-------------------------------------------------------------------------------------------------------------------

-- Monthly report of total layoffs each year

With total as
(SELECT Year(`date`) as `year`, Month(`date`) as `month`, sum(total_laid_off) as Laid
FROM layoffs_staging2
where Year(`date`) is not  null
group by Year(`date`),Month(`date`)
order by Year(`date`), Month(`date`)
)
SELECT  `year`, `month`, Laid, sum(Laid) over(order by  `year`,`month`) as Rolling_total
from total;



