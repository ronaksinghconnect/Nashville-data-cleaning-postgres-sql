# SQL Data Cleaning Project – Nashville Housing Dataset (PostgreSQL)

## Dataset Context:
The dataset contains residential property transaction records from Nashville, Tennessee.
It includes sale dates, prices, parcel identifiers, addresses, and property attributes.
The data required extensive cleaning due to missing values, inconsistent formats, and duplicate records.

## Overview
This project demonstrates a complete **SQL-based data cleaning workflow** using PostgreSQL on a real-world housing dataset.  
All cleaning operations are performed directly on the working table to produce an **analysis-ready dataset**, while the original raw data is backed up and preserved for safety.

The focus of this project is improving **data quality, consistency, and structure**, following practices commonly used in real analytics and data engineering work.

---

## Dataset Description
The dataset contains property sales records for Nashville housing, including information such as parcel identifiers, addresses, sale dates, prices, legal references, and vacancy status.

Key columns include:
- `parcelid` – property identifier
- `propertyaddress` – full property address
- `saledate` – date of sale
- `saleprice` – transaction price
- `legalreference` – legal sale reference
- `soldasvacant` – vacancy indicator
- `uniqueid` – unique row identifier

---

## Data Cleaning Process

The dataset was first explored to understand its structure, columns, and potential quality issues. Initial inspection revealed inconsistent date formats, missing property addresses, duplicated records, mixed categorical values, and redundant columns.

The `saledate` column was originally stored as text and was standardized by converting it into a proper PostgreSQL `DATE` datatype. This ensures correct chronological sorting and enables time-based analysis.

Missing values in the `propertyaddress` column were resolved using a self-join strategy. Since `parcelid` uniquely identifies a property, rows with null addresses were matched to other records with the same parcel ID and a non-null address. This allowed reliable backfilling without introducing incorrect data.

To improve table structure, the `propertyaddress` column was split into two separate columns: `street_address` and `city`. This normalization step makes the dataset easier to filter, group, and analyze by location.

The `soldasvacant` column contained inconsistent values such as `Y`, `N`, `Yes`, and `No`. These were standardized into consistent `Yes` and `No` values using conditional logic, improving clarity and downstream usability.

Duplicate records were identified using a window function. A `ROW_NUMBER()` function partitioned records by key sale-related columns and assigned an order based on `uniqueid`. Rows with a row number greater than one were flagged as duplicates. After verification, duplicate rows were removed while retaining a single valid record per transaction.

Once the data was cleaned and validated, unused columns that were no longer necessary—such as `taxdistrict` and the original `propertyaddress` column—were safely removed to reduce redundancy and simplify the schema.

---

## Results
- Dates standardized and converted to proper `DATE` datatype  
- Missing property addresses resolved using reliable matching logic  
- Address data normalized into separate street and city columns  
- Categorical values cleaned and standardized  
- Duplicate records removed (104 rows)  
- Table schema simplified by dropping unused columns  

The final dataset is clean, consistent, and ready for analysis.

---

## SQL Concepts Used
- Data type conversion
- Self joins
- Window functions (`ROW_NUMBER`)
- Common Table Expressions (CTEs)
- Conditional updates (`CASE`)
- String functions (`SPLIT_PART`, `TRIM`)
- Schema modification (`ALTER TABLE`)
- Data validation before destructive operations

---
## Tools
- PostgreSQL  
- pgAdmin  
- SQL  
## Data Source: (Public Nashville housing records, made available via Kaggle for educational and analytical use.)


---

## Notes
All destructive operations (such as DELETE and DROP COLUMN) were executed only after validation.  
The original raw dataset was backed up before performing any modifications.
