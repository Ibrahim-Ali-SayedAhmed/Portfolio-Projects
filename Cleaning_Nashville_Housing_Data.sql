USE nashville_housing_data;

SELECT 
    *
FROM
    nashville_housing;

---------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize DATE Format

#1

ALTER TABLE nashville_housing
MODIFY SaleDate DATE NULL;

#2 

UPDATE nashville_housing
SET SaleDate = CONVERT( SaleDate , DATE);

---------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

#1 Retrieve a column with the required data to be populated 'updated_PropertyAddress'

SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    COALESCE(a.PropertyAddress, b.PropertyAddress) AS updated_PropertyAddress
FROM
    nashville_housing a
        JOIN
    nashville_housing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID
WHERE
    a.PropertyAddress IS NULL;
    

UPDATE nashville_housing
        JOIN
    nashville_housing a ON nashville_housing.ParcelID = a.ParcelID
        AND nashville_housing.UniqueID <> a.UniqueID
SET nashville_housing.PropertyAddress = COALESCE(nashville_housing.PropertyAddress, a.PropertyAddress)
WHERE
    nashville_housing.PropertyAddress IS NULL;

---------------------------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into individual columns (Address, City, State)

SELECT 
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
    SUBSTRING_INDEX(PropertyAddress, ',', - 1) AS city
FROM
    nashville_housing;

ALTER TABLE nashville_housing
ADD COLUMN Address VARCHAR(100) NULL AFTER PropertyAddress;

UPDATE nashville_housing
SET Address = SUBSTRING_INDEX(PropertyAddress, ',', 1);

ALTER TABLE nashville_housing
ADD COLUMN city VARCHAR(100) NULL AFTER Address;

UPDATE nashville_housing
SET city = SUBSTRING_INDEX(PropertyAddress, ',', - 1);


SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerSplitAddress,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1) AS OwnerCity,
    SUBSTRING_INDEX(OwnerAddress, ',', - 1) AS OwnerState
FROM
    nashville_housing;

ALTER TABLE nashville_housing
ADD COLUMN OwnerSplitAddress VARCHAR(100) NULL AFTER OwnerAddress;
 
UPDATE nashville_housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashville_housing
ADD COLUMN OwnerCity VARCHAR(100) NULL AFTER OwnerSplitAddress;

UPDATE nashville_housing
SET OwnerCity = Substring_index(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE nashville_housing
ADD COLUMN OwnerState VARCHAR(100) NULL AFTER OwnerCity;

UPDATE nashville_housing
SET OwnerState = SUBSTRING_INDEX(OwnerAddress, ',', - 1);


---------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and NO in "SoldAsVacant" field

SELECT DISTINCT
    SoldAsVacant, COUNT(SoldAsVacant)
FROM
    nashville_housing
GROUP BY SoldAsVacant;


SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'N' THEN 'No'
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        ELSE SoldAsVacant
    END AS Updated_SoldAsVacant
FROM
    nashville_housing;
    
UPDATE nashville_housing
SET SoldAsVacant = CASE
        WHEN SoldAsVacant = 'N' THEN 'No'
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        ELSE SoldAsVacant
    END;
    
---------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates (Not the best practice to remove data in the database but just for project practice)

WITH row_num_cte AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY UniqueID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY UniqueId
                 ) AS row_num  
FROM 
    nashville_housing
)

SELECT 
    *
FROM
    row_num_cte
WHERE
    row_num > 1
ORDER BY PropertyAddress;


WITH row_num_cte AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY UniqueID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY UniqueId
                 ) AS row_num  
FROM 
    nashville_housing
)

DELETE FROM row_num_cte 
WHERE
    row_num > 1 ORDER BY PropertyAddress;
    
---------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE nashville_housing
DROP Column PropertyAddress, 
DROP COLUMN TaxDistrict,
DROP COLUMN OwnerAddress;


