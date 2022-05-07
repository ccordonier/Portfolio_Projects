/*
Cleaning Data in SQL Queries
*/


Select *
From Portfolio_Projects..Nashville_Housing$

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE Portfolio_Projects..Nashville_Housing$
ALTER COLUMN [SaleDate] date


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From Portfolio_Projects..Nashville_Housing$
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Projects..Nashville_Housing$ a
JOIN Portfolio_Projects..Nashville_Housing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Projects..Nashville_Housing$ a
JOIN Portfolio_Projects..Nashville_Housing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From Portfolio_Projects..Nashville_Housing$

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From Portfolio_Projects..Nashville_Housing$


ALTER TABLE Portfolio_Projects..Nashville_Housing$
Add PropertySplitAddress Nvarchar(255);

Update Portfolio_Projects..Nashville_Housing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Portfolio_Projects..Nashville_Housing$
Add PropertySplitCity Nvarchar(255);

Update Portfolio_Projects..Nashville_Housing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From Portfolio_Projects..Nashville_Housing$


Select OwnerAddress
From Portfolio_Projects..Nashville_Housing$


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Portfolio_Projects..Nashville_Housing$


ALTER TABLE Portfolio_Projects..Nashville_Housing$
Add OwnerSplitAddress Nvarchar(255);

Update Portfolio_Projects..Nashville_Housing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Portfolio_Projects..Nashville_Housing$
Add OwnerSplitCity Nvarchar(255);

Update Portfolio_Projects..Nashville_Housing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Portfolio_Projects..Nashville_Housing$
Add OwnerSplitState Nvarchar(255);

Update Portfolio_Projects..Nashville_Housing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Portfolio_Projects..Nashville_Housing$




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Projects..Nashville_Housing$
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portfolio_Projects..Nashville_Housing$


Update Portfolio_Projects..Nashville_Housing$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolio_Projects..Nashville_Housing$)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From Portfolio_Projects..Nashville_Housing$




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From Portfolio_Projects..Nashville_Housing$


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate