-- Data Cleaning

SELECT * 
FROM NashvilleHousing

--Updating the sales date by removing the time that was 00:00 added to it...
SELECT SaleDate
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);

SELECT SaleDateConverted
FROM NashvilleHousing;


-- Populate property address data

-- Observe Where Property address IS NULL
SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- Did a self-join and joined on Parcel ID and where unique id is not the same
SELECT  a.ParcelID,
		a.PropertyAddress, 
		b.ParcelID, b.PropertyAddress, 
		ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Propert address Updated
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


-- Breaking out Address into individual columns (Address, city State)
-- PropertyAddress

SELECT PropertyAddress
FROM NashvilleHousing;

--Seperating by removing the Coma ',' and everything after it 
SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT * FROM
NashvilleHousing


-- Spliting the Owner Address
-- Using PARENAME method by replacing all ',' with '.' then split...
--because PARSE only works for period

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS UpdatedOwnerAddress,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS UpdatedOwnerCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS UpdatedOwnerState
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD UpdatedOwnerAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET UpdatedOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
ADD UpdatedOwnerCity NVARCHAR(255)

UPDATE NashvilleHousing
SET UpdatedOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
ADD UpdatedOwnerState NVARCHAR(255);

UPDATE NashvilleHousing
SET UpdatedOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashvilleHousing;


-- change Y and N to Yes and No

-- Observing distinct values
SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

-- make a case statement to manage inconsistencies in the data
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

-- Update it
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


-- Remove Duplicates

-- Delete duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UNIQUEID
				 ) Row_Num

FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE Row_Num > 1

--Delete Unused Columns
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

