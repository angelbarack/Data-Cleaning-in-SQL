--Nashville Data Housing in SQL

--Standarize DateFormat

SELECT saledate
FROM NashvilleHousing

SELECT Saledate, CONVERT(Date, saledate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, saledate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted =  CONVERT(Date, saledate)

SELECT *
FROM NashvilleHousing

--Populate Property Address Data... ( there are some Null address, we are going to do Self join 
--so we can populate addresses for NUll addresses)

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

--LETS USE ISNULL 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

--LETS Update..(in update you have to use aliase like a )

UPDATE a
SET PropertyAddress =ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


--Breaking out Address into indiviual columns(Address, City, State)

SELECT propertyaddress
From NashvilleHousing

--Lets split address into individual columns of Address and city with the help of Substring and Charindex 
--lets use CHARINDEX

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) as Address
From NashvilleHousing

--lets find out the position of comma ,

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) as Address,
 charindex(',',Propertyaddress)
From NashvilleHousing

--Now since we know the position of comma is at 16 or 17 lets -1 so we can remove that comma

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
From NashvilleHousing

--LETS use LENGTH because some addresses are longer than other   (if we remove +1 from the below query we can see ,)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address

From NashvilleHousing

--Lets add extra columns for Address and city with the help of Alter table & Update

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity  =  SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 

--Lets split Owner Address into individual columns( Address, City, State) with help of ParseName
--(ParseName is only usefull with period . lets use REPLACE to replace , comma with .
--ParseName works backwords

SELECT
PARSENAME(OwnerAddress, 1)
FROM NashvilleHousing

--(No change for the above query since there was comma not period so now we 
-- changing comma to period then using ParseName.

SELECT
PARSENAME(Replace(OwnerAddress, ',','.') ,1),
PARSENAME(Replace(OwnerAddress, ',','.') ,2),
PARSENAME(Replace(OwnerAddress, ',','.') ,3)
FROM NashvilleHousing

--since ParseName works backwords lets change the position of 123

SELECT
PARSENAME(Replace(OwnerAddress, ',','.') ,3),
PARSENAME(Replace(OwnerAddress, ',','.') ,2),
PARSENAME(Replace(OwnerAddress, ',','.') ,1)
FROM NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.') ,3)


Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity  = PARSENAME(Replace(OwnerAddress, ',','.') ,2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState  = PARSENAME(Replace(OwnerAddress, ',','.') ,1) 


--Change Y and N to Yes and No in "Sold as Vacant" field 

--lets use Distinct
SELECT Distinct(SoldAsVacant)
FROM NashvilleHousing

--Lets Count
SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
Group by SoldAsVacant
ORDER by 2

--In order to change Y & N to YES & NO we will use Case Statement 
SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing

--LETS UPDATE

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Remove Duplicates

Select *,
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order BY
				    UniqueID
					 ) row_num
From NashvilleHousing
ORDER BY ParcelID

--LETS USE CTE

WITH RowNumCTE As(
Select *,
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order BY
				    UniqueID
					 ) row_num
From NashvilleHousing
--ORDER BY ParcelID
)

select *
FROM RowNumCTE
Where row_num > 1
--Order by PropertyAddress

-- To remove duplicate values we will use DELETE instead of SELECT in the above query
-- after we did delete then we will again apply SELECT * to see the change 




--DELETE Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT *
FROM NashvilleHousing