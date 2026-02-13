# postgres-sql-data-cleaning-project
# SQL Data Cleaning Project – Nashville Housing Dataset (PostgreSQL)

## Overview
This project documents the complete data cleaning process performed on the `public.nashville_housing` table using PostgreSQL.
Improved data quality and reliability of a real estate sales dataset by cleaning, standardizing, and de-duplicating records in PostgreSQL, enabling accurate reporting and downstream analytics.
## Company & Dataset Context

This dataset represents residential property sales transactions from the Nashville housing market, commonly used by real estate analytics teams to monitor market trends, pricing behavior, and sales performance.  
The data captures property-level details such as sale date, sale price, legal reference, parcel identifiers, and property addresses, supporting location-based and time-based analysis.  
In a real-world business setting, this type of dataset is used by real estate firms, market research teams, and BI analysts to build sales reports, dashboards, and market performance insights.
## Business Problem

Real estate analytics teams rely on housing transaction data to analyze sales trends, pricing behavior, and market performance. However, the raw Nashville housing dataset contained multiple data quality issues that made it unreliable for reporting and analysis, including inconsistent date formats, missing property addresses, duplicate records, and inconsistent categorical values.

These issues lead to:
- Incorrect time-based analysis due to inconsistent sale date formats  
- Incomplete location-based insights due to missing property addresses  
- Inflated metrics and biased analysis caused by duplicate records  
- Inconsistent reporting in dashboards due to mixed categorical values (Y/N vs Yes/No)

As a result, analysts and stakeholders could not confidently use the dataset for decision-making, trend analysis, or dashboarding.

---

## Business Impact

This project converts a raw, error-prone real estate dataset into an analysis-ready table that can be safely used for:

- Sales trend analysis over time  
- City-level and street-level location analysis  
- Accurate KPI reporting (total sales, average sale price, transaction volume)  
- Feeding clean data into BI tools and dashboards (Tableau, Power BI)  
- Reducing downstream data errors in reporting and analytics pipelines  

By performing cleaning directly in PostgreSQL, this project mirrors real-world analytics workflows where data quality is enforced at the database level before consumption by reporting tools, increasing trust in insights and reducing manual correction work in dashboards.

---

## Key Outcome

Improved the reliability and usability of a real estate sales dataset by cleaning, standardizing, and de-duplicating records in PostgreSQL, enabling accurate downstream analytics and dashboarding.

Important notes:
- The documented queries directly clean and modify the working table.
- No separate cleaned table is created.
- The original raw dataset is backed up and remains safe.
- All destructive operations (UPDATE / DELETE / DROP) are executed only when required and with proper authorization.

---

## Preview & Exploration

Preview the dataset and explore all columns:
```sql
select *
FROM public.nashville_housing;
```

---

## Standardize Sale Date Format

### Preview SaleDate values
```sql
SELECT saledate
FROM public.nashville_housing
LIMIT 10;
```
### Convert SaleDate to proper date format

UPDATE public.nashville_housing
SET saledate = TO_DATE(saledate, 'month DD/YYYY');

### Verify the change
```sql
SELECT saledate
FROM public.nashville_housing
LIMIT 10;
```
### Change column data type to DATE
```sql
ALTER TABLE public.nashville_housing
ALTER COLUMN saledate TYPE DATE
USING saledate::DATE;
```
---

## Handle NULL Property Addresses

### Identify rows with NULL property address
```sql
SELECT *
FROM public.nashville_housing
WHERE propertyaddress IS NULL;
```
### Identify matching records using self-join
ParcelID represents the same property, so missing addresses can be filled using another row with the same ParcelID.
```sql
SELECT
    NH1.parcelid,
    NH1.propertyaddress,
    NH2.parcelid,
    NH2.propertyaddress
FROM public.nashville_housing NH1
JOIN public.nashville_housing NH2
    ON NH1.parcelid = NH2.parcelid
    AND NH1.uniqueid <> NH2.uniqueid
WHERE NH1.propertyaddress IS NULL
  AND NH2.propertyaddress IS NOT NULL;
```
### Update NULL property addresses
```sql
UPDATE public.nashville_housing NH1
SET propertyaddress = NH2.propertyaddress
FROM public.nashville_housing NH2
WHERE NH1.parcelid = NH2.parcelid
  AND NH1.uniqueid <> NH2.uniqueid
  AND NH1.propertyaddress IS NULL
  AND NH2.propertyaddress IS NOT NULL;
```
---

## Split Property Address into Street and City

### Preview split result
```sql
SELECT
    propertyaddress,
    SPLIT_PART(propertyaddress, ',', 1) AS street_address,
    TRIM(SPLIT_PART(propertyaddress, ',', 2)) AS city
FROM public.nashville_housing;
```
### Add new columns
```sql
ALTER TABLE public.nashville_housing
ADD COLUMN street_address TEXT;

ALTER TABLE public.nashville_housing
ADD COLUMN city TEXT;
```
### Populate new columns
```sql
UPDATE public.nashville_housing
SET street_address = SPLIT_PART(propertyaddress, ',', 1),
    city = TRIM(SPLIT_PART(propertyaddress, ',', 2));
```
---

## Clean SoldAsVacant Column

### Check distinct values
```sql
SELECT soldasvacant, COUNT(soldasvacant)
FROM public.nashville_housing
GROUP BY soldasvacant
ORDER BY 2;
```
### Preview standardized values
```sql
SELECT DISTINCT soldasvacant,
    CASE
        WHEN soldasvacant = 'Y' THEN 'Yes'
        WHEN soldasvacant = 'N' THEN 'No'
        ELSE soldasvacant
    END
FROM public.nashville_housing;
```
### Update column values
```sql
UPDATE public.nashville_housing
SET soldasvacant = CASE
    WHEN soldasvacant = 'Y' THEN 'Yes'
    WHEN soldasvacant = 'N' THEN 'No'
    ELSE soldasvacant
END;
```
---

## Remove Duplicate Records

Duplicates are identified using a combination of:
- parcelid
- propertyaddress
- saleprice
- saledate
- legalreference

### Identify duplicates using CTE
```sql
WITH row_num_cte AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY parcelid,
                         propertyaddress,
                         saleprice,
                         saledate,
                         legalreference
            ORDER BY uniqueid
        ) AS row_num
    FROM public.nashville_housing
)
SELECT *
FROM row_num_cte
WHERE row_num > 1;
```
### Delete duplicate rows (104 rows)
Executed only when explicitly authorized.
```sql
-- DELETE
-- FROM public.nashville_housing
-- USING row_num_cte
-- WHERE public.nashville_housing.uniqueid = row_num_cte.uniqueid
--   AND row_num > 1;

---
```
## Remove Unused Columns

PropertyAddress and TaxDistrict are removed since the address has already been split into separate columns.

### Final preview
```sql
SELECT *
FROM public.nashville_housing
LIMIT 20;
```
### Drop unused columns
```sql
ALTER TABLE public.nashville_housing
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;
```
---

## Result
The dataset is now:
- Cleaned
- Standardized
- De-duplicated
- Analysis-ready

This project demonstrates real-world SQL data cleaning skills using PostgreSQL while preserving data safety and auditability.


