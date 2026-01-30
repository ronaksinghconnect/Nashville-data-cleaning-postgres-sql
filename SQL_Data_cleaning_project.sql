--- THE DOCUMENTED QUERIES CHANGES/CLEANS THE WHOLE TABLE ITSELF
--- AS TO HAVE A SEPERATE CLEANED DATA WITHOUT OLD UNCLEANED DATASET
--- THE REAL DATASET IS BACKED UP AND SAFE

-- PREVIEW / EXPLORE THE COLUMNS AND DATASET
SELECT
    *
FROM
    public.nashville_housing;

-- PREVIEW / TEST
SELECT
    saledate
FROM
    public.nashville_housing
LIMIT 10;

-- STANDARDIZE DATE FORMAT
UPDATE public.nashville_housing
SET
    saledate = TO_DATE(saledate, 'Month DD/YYYY');

-- PREVIEW / TEST THE CHANGE
SELECT
    saledate
    -- TO_DATE(saledate, 'Month DD,YYYY')
FROM
    public.nashville_housing
LIMIT 10;

-- CHANGED THE DATA TYPE OF SALEDATE TO DATE
ALTER TABLE public.nashville_housing
ALTER COLUMN saledate TYPE DATE
USING saledate::DATE;

-- CONTAINS NULL IN PROPERTY ADDRESS
SELECT
    *
FROM
    public.nashville_housing
WHERE
    propertyaddress IS NULL;

-- FIXING NULLS BY JOINING TABLE BY ITSELF THROUGH PARCEL_ID AND UNIQUE ID AS NOT EQUAL
-- PARCEL ID = PROPERTY ID SO WE JOIN AS THE NULL PROPERTY ADDRESS THAT HAS SAME PARCEL/PROPERTYID THEN MATCH
-- JUST TO FIND THE ADDRESS ROWS
SELECT
    nh1.parcelid,
    nh1.propertyaddress,
    nh2.parcelid,
    nh2.propertyaddress
    -- COALESCE(nh1.propertyaddress, nh2.propertyaddress)
FROM
    public.nashville_housing nh1
    JOIN public.nashville_housing nh2
        ON nh1.parcelid = nh2.parcelid
        AND nh1.uniqueid <> nh2.uniqueid
WHERE
    nh1.propertyaddress IS NULL
    AND nh2.propertyaddress IS NOT NULL;

UPDATE public.nashville_housing nh1
SET
    propertyaddress = nh2.propertyaddress
FROM
    public.nashville_housing nh2
WHERE
    nh1.parcelid = nh2.parcelid
    AND nh1.uniqueid <> nh2.uniqueid
    AND nh1.propertyaddress IS NULL
    AND nh2.propertyaddress IS NOT NULL;

SELECT
    propertyaddress
FROM
    public.nashville_housing;

-- TO SPLIT THE PROPERTY ADDRESS BY CITY AND STREET NAME
-- JUST PREVIEW
SELECT
    propertyaddress,
    SPLIT_PART(propertyaddress, ',', 1) AS street_address,
    TRIM(SPLIT_PART(propertyaddress, ',', 2)) AS city
FROM
    public.nashville_housing;

-- NOW TO CHANGE TABLE STRUCTURE AS TO ADD NEW COLUMNS
ALTER TABLE public.nashville_housing
ADD COLUMN street_address TEXT,
ADD COLUMN city TEXT;

-- TO SPLIT THE PROPERTY ADDRESS BY CITY AND STREET NAME
-- TO SAVE INSIDE NEW COLUMN
UPDATE public.nashville_housing
SET
    street_address = SPLIT_PART(propertyaddress, ',', 1),
    city = TRIM(SPLIT_PART(propertyaddress, ',', 2));

-- CHECKING SOLDASVACANT COLUMN
SELECT
    soldasvacant,
    COUNT(soldasvacant)
FROM
    public.nashville_housing
GROUP BY
    soldasvacant
ORDER BY
    2;

-- FIXING SOLDASVACANT ERRORS
-- PREVIEW SOLDASVACANT
SELECT DISTINCT
    soldasvacant,
    CASE
        WHEN soldasvacant = 'Y' THEN 'Yes'
        WHEN soldasvacant = 'N' THEN 'No'
        ELSE soldasvacant
    END
FROM
    public.nashville_housing;

-- CHANGING / FIXING THE EXISTING COLUMN
UPDATE public.nashville_housing
SET
    soldasvacant = CASE
        WHEN soldasvacant = 'Y' THEN 'Yes'
        WHEN soldasvacant = 'N' THEN 'No'
        ELSE soldasvacant
    END;

-- REMOVE DUPLICATES
WITH row_num_cte AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                parcelid,
                propertyaddress,
                saleprice,
                saledate,
                legalreference
            ORDER BY
                uniqueid
        ) AS row_num
    FROM
        public.nashville_housing
    ORDER BY
        parcelid
)

----------- DELETED THE DUPLICATES ROWS (104 ROWS)
----------- ONLY WHEN NEEDED AND AUTHORIZED PERMISSION TO DELETE THE DATA

-- DELETE
-- FROM public.nashville_housing
-- USING row_num_cte
-- WHERE public.nashville_housing.uniqueid = row_num_cte.uniqueid
-- AND row_num > 1

-- TO CHECK IF ITS DELETED DONE BY COMMENTING THE DELETE SECTION
SELECT
    *
FROM
    row_num_cte
WHERE
    row_num > 1;

-- DELETE UNUSED COLUMN
-- ONLY WHEN NEEDED AND AUTHORIZED PERMISSION PROPERTY ADDRESS BECAUSE
-- WE ALREADY SEPERATED THE CITY AND STREET IN OTHER COLUMN AND TAXDISTRICT

SELECT
    *
FROM
    public.nashville_housing
LIMIT 20;

ALTER TABLE public.nashville_housing
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;
