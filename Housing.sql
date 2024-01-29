---- Data overview
Select *
From Housing$

---- Standardize Date Format
Select SaleDate, CONVERT(Date,SaleDate)
From Housing$

ALTER TABLE Housing$
Add SaleDateConverted Date;

Update Housing$
SET SaleDateConverted = CONVERT(date,SaleDate)

---- Populating Property Address Data
-- Finding Null addresses
Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL (a.PropertyAddress,b.PropertyAddress)
From Housing$ a
JOIN Housing$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is NULL

--Updating addresses
Update a
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
From Housing$ a
JOIN Housing$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is NULL


----Breaking out property address information into individual columns
Select PropertyAddress
From Housing$

--Finding the delimeter (comma)
SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From Housing$

--Adding columns to add separated data

Alter table Housing$
Add PropertySplitAddress Nvarchar(255);

Update Housing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table Housing$
Add PropertySplitCity Nvarchar(255);

Update Housing$
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


----Breaking out owner address information into individual columns

Select OwnerAddress
From Housing$

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From Housing$

--Adding columns to add separated address data

Alter table Housing$
Add OwnerSplitAddress Nvarchar(255);

Update Housing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter table Housing$
Add OwnerSplitCity Nvarchar(255);

Update Housing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter table Housing$
Add OwnerSplitState Nvarchar(255);

Update Housing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--- Standardize SoldasVacant changing Y and N to Yes and No
Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 Else SoldAsVacant
		 END
From Housing$

Update Housing$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 Else SoldAsVacant
		 END


--- Removing duplicates
--Not considering UniqueID on partition for the sake of practice

With RowNumCTE AS (
Select *, 
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From Housing$
)

Select *
From RowNumCTE
Where row_num >1

DELETE
From RowNumCTE
Where row_num >1

--- Deleting unused columns

Select *
From Housing$

Alter table Housing$
Drop Column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate