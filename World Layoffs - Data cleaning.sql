-- Data Cleaning

SELECT * FROM layoffs;

--------------------------------------------------------------------------------------------------
-- 1. Remove duplicates  				
-- 2. Standardise the data
-- 3. Null values or blank values
-- 4. Remove unnecessary columns
--------------------------------------------------------------------------------------------------

-- Creating new table for data manipulation
CREATE TABLE layoffs_staging
LIKE layoffs;   

SELECT * FROM layoffs_staging;

INSERT INTO layoffs_staging		
SELECT *
FROM layoffs;
--------------------------------------------------------------------------------------------------

-- Finding dupicates

SELECT *,
ROW_NUMBER() 
OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num  
FROM layoffs_staging;

WITH  duplicate_cte AS
(
SELECT *,
ROW_NUMBER() 
OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num  
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1 ;

-- Checking
SELECT * FROM layoffs_staging
WHERE company = 'Casper';
--------------------------------------------------------------------------------------------------

-- New table with row_num as a column
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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() 
OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoffs_staging;
--------------------------------------------------------------------------------------------------

-- Removing Duplicates
SELECT * FROM layoffs_staging2
WHERE row_num >1;

DELETE
FROM layoffs_staging2
WHERE row_num >1;
--------------------------------------------------------------------------------------------------

-- STANDARDIZING DATA

-- Removing extra spaces
SELECT company, TRIM(company)			
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Looking for spelling mistakes
SELECT DISTINCT (industry)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry = 'crypto'
WHERE industry like 'CRYPTO%' ;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = 'United States'
where country like 'United States%';


-- Change into Date format

SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')			
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date`= str_to_date(`date`, '%m/%d/%Y')	;			

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2			
MODIFY COLUMN `date` DATE;				


-- Look for blanks or null values

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';			

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';				

SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1 
JOIN layoffs_staging2 t2				
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;
					
UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';


-- Filling blank or null values

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2						
	ON t1.company = t2.company					
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;	

-- Deleting unnecessary rows

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;					

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;			

-- Removing extra column 
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Cleaned data
SELECT *
FROM layoffs_staging2;


