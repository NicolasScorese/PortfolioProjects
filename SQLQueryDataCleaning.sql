--Cleaning data in SQL queries



SELECT *
FROM [Sample_Project].[dbo].[NashvilleHousing]


--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [Sample_Project].[dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--------------------------------------------------------------------------------------------

--Populate Property Addess data

SELECT *
FROM [Sample_Project].[dbo].[NashvilleHousing]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Sample_Project].[dbo].[NashvilleHousing] a
JOIN [Sample_Project].[dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Sample_Project].[dbo].[NashvilleHousing] a
JOIN [Sample_Project].[dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

--------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM [Sample_Project].[dbo].[NashvilleHousing]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM [Sample_Project].[dbo].[NashvilleHousing]

ALTER TABLE NashVilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashVilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
FROM [Sample_Project].[dbo].[NashvilleHousing]


----

SELECT OwnerAddress
FROM [Sample_Project].[dbo].[NashvilleHousing]

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Sample_Project].[dbo].[NashvilleHousing]

ALTER TABLE NashVilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashVilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashVilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM [Sample_Project].[dbo].[NashvilleHousing]


--------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant' field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Sample_Project].[dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
  END
FROM [Sample_Project].[dbo].[NashvilleHousing]

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [Sample_Project].[dbo].[NashvilleHousing]
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress

--SELECT *
--FROM RowNumCTE
--WHERE row_num >1




SELECT *
FROM [Sample_Project].[dbo].[NashvilleHousing]



--------------------------------------------------------------------------------------------


--Delete Unused Columns


SELECT *
FROM [Sample_Project].[dbo].[NashvilleHousing]


ALTER TABLE [Sample_Project].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Sample_Project].[dbo].[NashvilleHousing]
DROP COLUMN SaleDate