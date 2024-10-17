/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------------------------

-- Standarize Date Format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

------------------------------------------------------------------------------------------------------------------------

-- Populate Property Adress data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


------------------------------------------------------------------------------------------------------------------------

-- Breaking down Adress into individual columns (Adress, City, State)


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Adress
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAdress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT PropertySplitAdress, PropertySplitCity
FROM PortfolioProject..NashvilleHousing




SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Adress
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM PortfolioProject..NashvilleHousing
WHERE OwnerAddress IS NOT NULL





ALTER TABLE NashvilleHousing
ADD OwnerSplitAdress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT OwnerSplitAdress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject..NashvilleHousing
WHERE OwnerSplitAdress IS NOT NULL

------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in sold as vacant

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNum_CTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
	             SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
)

SELECT *
FROM RowNum_CTE
WHERE row_num > 1






------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


	SELECT *
	FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



------------------------------------------------------------------------------------------------------------------------