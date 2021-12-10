#Cleaning data in SQL
#First look at the whole data
SELECT *
FROM `portfolio-project-334404.Nashville_Housing_Data.data_table` 

#I notice that there are missing addresses in Property Adress
#I notice that for each ParcelID, there is only one address attaching to that ID, So I'm going to replace null values with correct address value from the previous entered addresses
#Double check the information
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM `portfolio-project-334404.Nashville_Housing_Data.data_table` a
JOIN `portfolio-project-334404.Nashville_Housing_Data.data_table` b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

#The theory is correct. It's time to update the table
#First we need to create a CTE
WITH address_temp AS (SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM `portfolio-project-334404.Nashville_Housing_Data.data_table` a
JOIN `portfolio-project-334404.Nashville_Housing_Data.data_table` b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null
)
SELECT * FROM address_temp

#Then create a temp table 
CREATE TABLE portfolio-project-334404.Nashville_Housing_Data.address_temp AS (
    SELECT a.ParcelID, b.PropertyAddress
    FROM `portfolio-project-334404.Nashville_Housing_Data.data_table` a
    JOIN `portfolio-project-334404.Nashville_Housing_Data.data_table` b
        ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID
    WHERE a.PropertyAddress is null
)

#Update the data table using the new address from address_temp
UPDATE `portfolio-project-334404.Nashville_Housing_Data.data_table`
SET PropertyAddress = 'portfolio-project-334404.Nashville_Housing_Data.address_temp.PropertyAddress'
WHERE PropertyAddress is null

#Take a look at PropertyAddress we can see the City name and the address in a chunk. I want to have a separate colums for citys, streets and house numbers
SELECT PropertyAddress
FROM `portfolio-project-334404.Nashville_Housing_Data.data_table`

#The result shows us that City names and Addresses are separated by ",". Let's use that to get the addresses!!!!
SELECT SUBSTR(PropertyAddress, 1, STRPOS(PropertyAddress, ',')) as Address, SUBSTR(PropertyAddress, STRPOS(PropertyAddress, ',')+1,LENGTH(PropertyAddress)) as City
FROM `portfolio-project-334404.Nashville_Housing_Data.data_table`

#We get what we wanted. Time to add this to the table
#I'm going to add 2 schemas "PropertySplitAddress" and "PropertySplitCity" and then add the information

UPDATE portfolio-project-334404.Nashville_Housing_Data.data_table
SET PropertySplitAddress = SUBSTR(PropertyAddress, 1, STRPOS(PropertyAddress, ','))
WHERE PropertyAddress is not null

UPDATE portfolio-project-334404.Nashville_Housing_Data.data_table
SET PropertySplitCity = SUBSTR(PropertyAddress, STRPOS(PropertyAddress, ',')+1,LENGTH(PropertyAddress))
WHERE PropertyAddress is not null

#I'm going to do the same thing for OwnerAddress, this time I'm using SPLIT to keep it simple
SELECT 
    SPLIT(OwnerAddress)[SAFE_OFFSET(0)] as OwnerSplitAddress,
    SPLIT(OwnerAddress)[SAFE_OFFSET(1)] as OwnerSplitCity, 
    SPLIT(OwnerAddress)[SAFE_OFFSET(2)] as OwnerSplitState
FROM portfolio-project-334404.Nashville_Housing_Data.data_table

#The results was good, Next step is adding 3 more schemas to the table and update the value 
UPDATE portfolio-project-334404.Nashville_Housing_Data.data_table
SET OwnerSplitAddress = SPLIT(OwnerAddress)[SAFE_OFFSET(0)]
WHERE OwnerAddress is not null

UPDATE portfolio-project-334404.Nashville_Housing_Data.data_table
SET OwnerSplitCity = SPLIT(OwnerAddress)[SAFE_OFFSET(1)]
WHERE OwnerAddress is not null

UPDATE portfolio-project-334404.Nashville_Housing_Data.data_table
SET OwnerSplitState = SPLIT(OwnerAddress)[SAFE_OFFSET(2)]
WHERE OwnerAddress is not null



