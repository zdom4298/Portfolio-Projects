

--Cleaning Data in SQL Quieries

Select * 
From [Portfolio Project].[dbo].[NashvilleHousing ]





--Standarize Date Format



Select SaleDateConverted, Convert(Date, SaleDate)
From [Portfolio Project].[dbo].[NashvilleHousing ]

Select SaleDate
From  [Portfolio Project].[dbo].[NashvilleHousing ]

Alter Table NashvilleHousing
add SaleDateConverted Date;

Update [NashvilleHousing ]
Set SaleDateConverted = Convert(Date, SaleDate)




--Populate Proporty Address data


Select *
From  [Portfolio Project].[dbo].[NashvilleHousing ]
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From  [Portfolio Project].[dbo].[NashvilleHousing ] a 
Join [Portfolio Project].[dbo].[NashvilleHousing ] b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From  [Portfolio Project].[dbo].[NashvilleHousing ] a 
Join [Portfolio Project].[dbo].[NashvilleHousing ] b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




--Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From [Portfolio Project].[dbo].[NashvilleHousing ]

Select 
SUBSTRING(PropertyAddress,1, CharIndex(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CharIndex(',',PropertyAddress) +1, Len(PropertyAddress)) as Address
From [Portfolio Project].[dbo].[NashvilleHousing ]

Alter Table NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set  PropertySplitAddress= SUBSTRING(PropertyAddress,1, CharIndex(',',PropertyAddress) -1)

Alter Table NashvilleHousing
add PropertySplitCity nvarchar(255);

Update NashvilleHousing 
Set PropertySplitCity = SUBSTRING(PropertyAddress, CharIndex(',',PropertyAddress) +1,Len(PropertyAddress))

Select *
From [Portfolio Project].[dbo].[NashvilleHousing ]



Select OwnerAddress
From [Portfolio Project].[dbo].[NashvilleHousing ]


Select 
Parsename(Replace (OwnerAddress,',','.'),3),
Parsename(Replace (OwnerAddress,',','.'),2),
Parsename(Replace (OwnerAddress,',','.'),1)
From [Portfolio Project].[dbo].[NashvilleHousing ]
Where OwnerAddress is not null


Alter Table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set  OwnerSplitAddress =Parsename(Replace (OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitCity=Parsename(Replace (OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
add OwnerSplitState nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitState=Parsename(Replace (OwnerAddress,',','.'),1)



--Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), Count(SoldASVacant)
From [Portfolio Project].[dbo].[NashvilleHousing ] 
Group by SoldAsVacant
Order by 2

select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'   
When SoldAsVacant = 'N' then'No'
Else SoldAsVacant
End
From [Portfolio Project].[dbo].[NashvilleHousing ] 


Update [NashvilleHousing ]
set SoldAsVacant=Case  When SoldAsVacant = 'Y' Then 'Yes'                          
When SoldAsVacant = 'N' then'No'
Else SoldAsVacant
End



--Remove Duplicates

With RowNumCTE AS(
Select *,
ROW_NUMBER() over (
Partition BY ParcelID,
             PropertyAddress,
			 Saleprice,
			 SaleDate,
			 LegalReference
			 Order by 
			 UniqueID
			 )row_num
From [Portfolio Project].[dbo].[NashvilleHousing ] 
)
Select *
From RowNumCTE
where row_num >1



--Delete Unsend Columns

Select *
From [Portfolio Project].[dbo].[NashvilleHousing ] 


Alter Table NashvilleHousing
Drop column PropertyAddress, SaleDate,OwnerAddress, TaxDistrict