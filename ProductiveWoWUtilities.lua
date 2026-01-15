-- v1.3.4

-- TABLE FUNCTIONS --
--------------------------------------------------------------------------------------------------------------------------------

-- Count the number of elements in a table
function ProductiveWoW_tableLength(tbl)
	local count = 0
	for element in pairs(tbl) do
		if element ~= nil then
			count = count + 1
		end
	end
	return count
end

-- Check if a table is an array
function ProductiveWoW_tableIsArray(tbl)
	if type(tbl) ~= "table" then
		return false
	end
	local count = 0
	for key, val in pairs(tbl) do
		if type(key) ~= "number" then
			return false
		elseif key <= 0 or math.floor(key) ~= key then
			return false
		elseif key ~= (count + 1) then
			return false
		end
		count = count + 1
	end
	return ProductiveWoW_tableLength(tbl) == count
end

-- Converts a sparse array into a contiguous array
function ProductiveWoW_sparseArrayIntoContiguousArray(tbl)
	local contiguousArray = {}
	for key, val in pairs(tbl) do
		if val ~= nil then
			table.insert(contiguousArray, val)
		end
	end
	return contiguousArray
end

-- Check if a value exists in a table's keys
function ProductiveWoW_inTableKeys(valueToCheck, tbl)
	for key, value in pairs(tbl) do
		if key == valueToCheck then
			return true
		end
	end
	return false
end

-- Check if a value exists in a table's values
function ProductiveWoW_inTable(valueToCheck, tbl)
	for key, value in pairs(tbl) do
		if value == valueToCheck then
			return true
		end
	end
	return false
end

-- Binary search in sorted numerical tables
function ProductiveWoW_numericalTableBinarySearch(valueToCheck, tbl)
	local currentIndex = math.floor(ProductiveWoW_tableLength(tbl) / 2)
	while tbl[currentIndex] ~= valueToCheck do
		currentIndex = math.floor(currentIndex / 2)
		if currentIndex == 1 then
			if tbl[currentIndex] == valueToCheck then
				return true
			else
				return false
			end
		end
	end
end

-- Return a table that contains only the elements in the first table
function ProductiveWoW_getElementsOnlyContainedInFirstTable(tbl1, tbl2)
	local newTbl = {}
	for key, val in pairs(tbl1) do
		if ProductiveWoW_inTable(val, tbl2) == false then
			newTbl[key] = val
		end
	end
	return newTbl
end

-- Remove an element from an array by value, removes first only, modifies table in place
function ProductiveWoW_removeByValue(value, tbl)
	if not ProductiveWoW_tableIsArray(tbl) then
		error("Table has to be an array-type table.")
	end
	for i = 1, #tbl, 1 do
		if (tbl[i] == value) then
			table.remove(tbl, i)
			return
		end
	end
end

-- Shallow copy of a table, does not copy nested tables
function ProductiveWoW_tableShallowCopy(tbl)
	local copy = {}
	for key, val in pairs(tbl) do
		copy[key] = val
	end
	return copy
end

-- Return a table containing only the keys of another table
function ProductiveWoW_getKeys(tbl)
	local keys = {}
	for key, val in pairs(tbl) do
		table.insert(keys, key)
	end
	return keys
end

-- Returns table1 with table2 concatenated to it
function ProductiveWoW_mergeTables(tbl1, tbl2)
	for key, val in pairs(tbl2) do
		if val ~= nil then
			table.insert(tbl1, val)
		end
	end
	return tbl1
end

-- Get random subset of size n from array-type table
function ProductiveWoW_getRandomSubsetOfArrayTable(tbl, size)
	if ProductiveWoW_tableLength(tbl) >= size then
		local tempTable = ProductiveWoW_tableShallowCopy(tbl)
		local subset = {}
		local tableSize = nil
		while size ~= 0 do
			tableSize = ProductiveWoW_tableLength(tempTable)
			local randomIndex = math.random(1, tableSize)
			table.insert(subset, tempTable[randomIndex])
			table.remove(tempTable, randomIndex)
			size = size - 1
		end
		return subset
	end
	return tbl
end

-- Get the string value of a key (reverse lookup)
function ProductiveWoW_getKeyAsString(tbl, val)
	local key = nil
	local countOfMatchingValues = 0
	for k, v in pairs(tbl) do
		if v == val then
			if countOfMatchingValues == 0 then
				key = tostring(k)
			end
			countOfMatchingValues = countOfMatchingValues + 1
		end
	end
	if countOfMatchingValues >= 2 then
		error("ProductiveWoW_getKeyAsString: Table had 2 or more matching values.")
	else
		return key
	end
end

-- Check if an array-type table contains the exact same elements as another table regardless of ordering
function ProductiveWoW_arrayTablesContainSameElements(arrayTable1, arrayTable2)
	if not ProductiveWoW_tableIsArray(arrayTable1) or not ProductiveWoW_tableIsArray(arrayTable2) then
		error("One or both inputs are not array-type tables.")
	end
	local count = 0
	if ProductiveWoW_tableLength(arrayTable1) ~= ProductiveWoW_tableLength(arrayTable2) then
		return false
	else
		for i, val1 in ipairs(arrayTable1) do
			for j, val2 in ipairs(arrayTable2) do
				if val1 == val2 then
					count = count + 1
				end
			end
		end
	end
	if count == ProductiveWoW_tableLength(arrayTable1) then
		return true
	else
		return false
	end
end

-- Get max value in array of integers
function ProductiveWoW_getMax(tbl)
	if not ProductiveWoW_tableIsArray(tbl) then
		error("ProductiveWoW_getMax() table is not an array-type table.")
	end
	local currentMax = nil
	for i, v in ipairs(tbl) do
		if currentMax == nil or v > currentMax then
			if type(v) ~= "number" then
				error("ProductiveWoW_getMax() does not contain only numbers.")
			else
				currentMax = v
			end
		end
	end
	return currentMax
end

-- STRING FUNCTIONS --
--------------------------------------------------------------------------------------------------------------------------------

-- String only contains whitespace
function ProductiveWoW_stringContainsOnlyWhitespace(string)
	return string:match("^%s*$") ~= nil
end

-- Check if a string is a number
function ProductiveWoW_isNumeric(str)
    return str:match("^%d+$") ~= nil
end

-- Check if a string is a percent
function ProductiveWoW_isPercent(str)
	return str:match("^%d+%%?$") ~= nil
end


-- DATETIME FUNCTIONS -- 
--------------------------------------------------------------------------------------------------------------------------------

-- Number of days since date
function ProductiveWoW_numberOfDaysSinceDate(since_date)
	local sinceDateTimestamp = time(since_date)
	local todayTimestamp = date("*t")
	todayTimestamp = time(todayTimestamp)
	local diffSeconds = todayTimestamp - sinceDateTimestamp
	local daysBetween = math.floor(diffSeconds / (24 * 60 * 60))
	return daysBetween
end

-- Date to string
function ProductiveWoW_dateToString(date)
	return date["day"] .. "-" .. date["month"] .. "-" .. date["year"]
end
