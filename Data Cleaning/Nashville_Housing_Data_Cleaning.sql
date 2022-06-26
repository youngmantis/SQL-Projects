
SELECT * 
FROM NashvilleHousing

--Standardize date formatt

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM NashvilleHousing


--Populate property address data 
SELECT *
FROM NashvilleHousing 
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT *
FROM NashvilleHousing AS A
	JOIN NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) AS Address
FROM NashvilleHousing AS A
	JOIN NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing AS A
	JOIN NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]

--Breaking out property address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING  (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))  AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertyCityAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertyCityAddress = SUBSTRING  (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * 
FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

SELECT *
FROM NashvilleHousing


--Change Y and N to Yes and No in the SoldAsVacant column

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC


--Remove duplicates

SELECT * FROM NashvilleHousing
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	ORDER BY
		UniqueID
	) AS row_num

FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY ParcelID


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	ORDER BY
		UniqueID
	) AS row_num

FROM NashvilleHousing
--ORDER BY ParcelID
)
DELETE  FROM RowNumCTE
WHERE row_num > 1
--ORDER BY ParcelID

--Delete unused columns

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict,SaleDate

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

SELECT * FROM NashvilleHousing