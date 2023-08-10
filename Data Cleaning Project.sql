/*

Cleaning Data in SQL Queries

*/

select *
from PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Sale Date Format

select SaleDate, CONVERT(date,SaleDate)
from PortfolioProject..NashvilleHousing

--update PortfolioProject..NashvilleHousing
--set SaleDate = CONVERT(date,SaleDate)

select SaleDate
from PortfolioProject..NashvilleHousing

-- If it doesn't Update properly

alter table PortfolioProject..NashvilleHousing
add SaleDateConverted Date;

--update PortfolioProject..NashvilleHousing
--set SaleDateConverted = CONVERT(date,SaleDate)

select SaleDateConverted
from PortfolioProject..NashvilleHousing


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


select *
from PortfolioProject..NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--update a
--set Propertyaddress = isnull(a.PropertyAddress, b.PropertyAddress)
--from PortfolioProject..NashvilleHousing a
--join PortfolioProject..NashvilleHousing b
--on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as State
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255);

--update PortfolioProject..NashvilleHousing
--set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255);

--update PortfolioProject..NashvilleHousing
--set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

select PropertyAddress, PropertySplitAddress, PropertySplitCity
from PortfolioProject..NashvilleHousing



--- Lets work with another way to split address

select OwnerAddress
from PortfolioProject..NashvilleHousing


select OwnerAddress,
PARSENAME(REPLACE(Owneraddress, ',', '.'),3),
PARSENAME(REPLACE(Owneraddress, ',', '.'),2),
PARSENAME(REPLACE(Owneraddress, ',', '.'),1)
from PortfolioProject..NashvilleHousing
where OwnerAddress is not null


alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255);

--update PortfolioProject..NashvilleHousing
--set OwnerSplitAddress = PARSENAME(REPLACE(Owneraddress, ',', '.'),3)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255);

--update PortfolioProject..NashvilleHousing
--set OwnerSplitCity = PARSENAME(REPLACE(Owneraddress, ',', '.'),2)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255);

--update PortfolioProject..NashvilleHousing
--set OwnerSplitState = PARSENAME(REPLACE(Owneraddress, ',', '.'),1)


select OwnerAddress,OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
from PortfolioProject..NashvilleHousing
where OwnerAddress is not null


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'yes'
	when SoldAsVacant = 'n' then 'No'
	else SoldAsVacant end
from PortfolioProject..NashvilleHousing

--update PortfolioProject..NashvilleHousing
--set SoldAsVacant = case when SoldAsVacant = 'Y' then 'yes'
--	when SoldAsVacant = 'n' then 'No'
--	else SoldAsVacant end


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE as(
select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, SaleDate, SalePrice, LegalReference order by UniqueID) as Row_Num
from PortfolioProject..NashvilleHousing
)

select *
from RowNumCTE
where Row_num > 1


select *
from PortfolioProject..NashvilleHousing





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



select *
from PortfolioProject..NashvilleHousing

--alter table PortfolioProject..NashvilleHousing
--drop column PropertyAddress, TaxDistrict, OwnerAddress, SaleDate




-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO