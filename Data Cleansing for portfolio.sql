/*
cleaning Data in sql Queries
*/

select * from NashvilleHousing



--standardise date format

select SaleDateConverted, convert(date,SaleDate) from NashvilleHousing

update NashvilleHousing set SaleDate = CONVERT(date,SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted  Date;

update NashvilleHousing set SaleDateConverted = CONVERT(date,SaleDate)



--Populate Property Adress Data

select * from NashvilleHousing

order by ParcelId

select a.ParcelId, a.PropertyAddress, b.ParcelId,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a join NashvilleHousing b
on a.ParcelId = b.ParcelId and a.UniqueID <> b.UniqueId
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a join NashvilleHousing b
on a.ParcelId = b.ParcelId and a.UniqueID <> b.UniqueId
where a.PropertyAddress is null



--Breakingout Address into indiviadual columns(Address,Street,State)


select propertyAddress from NashvilleHousing

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(propertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyAddress)) as City
from NashvilleHousing



Alter table NashvilleHousing
Add PropertySplitAddress  nvarchar(255);

update NashvilleHousing set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)



Alter table NashvilleHousing
Add PropertySplitCity  nvarchar(255);

update NashvilleHousing set PropertySplitCity  = SUBSTRING(propertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyAddress))


select * from portfolio_data..NashvilleHousing



select OwnerAddress from NashvilleHousing


select
PARSENAME(Replace(ownerAddress,',','.'),3),
PARSENAME(Replace(ownerAddress,',','.'),2),
PARSENAME(Replace(ownerAddress,',','.'),1)
from NashvilleHousing


Alter table NashvilleHousing
Add OwnerSplitAddress  nvarchar(255);

update NashvilleHousing set OwnerSplitAddress = PARSENAME(Replace(ownerAddress,',','.'),3)



Alter table NashvilleHousing
Add OwnerSplitCity  nvarchar(255);

update NashvilleHousing set OwnerSplitCity  = PARSENAME(Replace(ownerAddress,',','.'),2)

Alter table NashvilleHousing
Add OwnerSplitState  nvarchar(255);

update NashvilleHousing set OwnerSplitState = PARSENAME(Replace(ownerAddress,',','.'),1)



--Change Y and N to yes and No
select distinct(soldAsvacant) ,count(soldasvacant)
from NashvilleHousing
group by soldasvacant
order by 2

select soldAsvacant,
case when soldAsvacant = 'Y' then 'Yes'
	when soldAsvacant = 'N' then 'No'
	else soldAsvacant
	end
from NashvilleHousing
--group by soldasvacant
--order by 2
update NashvilleHousing
set soldAsVacant = case when soldAsvacant = 'Y' then 'Yes'
	when soldAsvacant = 'N' then 'No'
	else soldAsvacant
	end



--Remove Duplicates



with RowNumCTE as(
select * ,Row_number() over(
partition by parcelId,
propertyAddress ,
salePrice,
saleDate,
LegalReference
order by uniqueId)
row_num
from portfolio_data..NashvilleHousing
)
select * from RowNumCTE
where row_num > 1
order by propertyAddress


--Delete unused co,lumns


Alter table portfolio_data..NashvilleHousing
drop column ownerAddress,TaxDistrict,PropertyAddress,SaleDate


select * from portfolio_data..NashvilleHousing