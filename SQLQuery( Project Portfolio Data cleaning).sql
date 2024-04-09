/*

Cleaning Data in SQL Queries

*/

Select *
From NashvilleHousing

---------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;


Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select PropertyAddress
From NashvilleHousing
Where PropertyAddress is null

Select *
From NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL( a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
join NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL

Update  a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
join NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL


-------------------------------------------------------------------------------------------------------

-- Breaking out address into Individual Columns (Address, City, State)


Select PropertyAddress
From NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From NashvilleHousing

/*
It means that we are looking in propertyaddress and stating that start from 1 value and find
, in it that also from propertyaddress and to remove we specified -1

we gonna create two new columns as we can't separate two values from one column

*/

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))




Select OwnerAddress
From NashvilleHousing

/*
We will use PARSENAME but remember one thing that PARSENAME WORKS BACKWARDS AND ONLY WORKS WITH PERIOD(.)
*/

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



-------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From NashVilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End


-------------------------------------------------------------------------------------------------

-- Remove Duplicates
With RowNumCTE AS (
Select * , ROW_NUMBER() OVER(
           PARTITION BY ParcelID,
		                PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY 
						     UniqueID
							 ) as row_num
From NashvilleHousing
--Order by ParcelID
--Where row_num > 1
)

Delete
--Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


-----------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From NashvilleHousing

--ALTER TABLE NashvilleHousing
--DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate