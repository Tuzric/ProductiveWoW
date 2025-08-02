-- v1.3

-- TABLE FUNCTIONS --
--------------------------------------------------------------------------------------------------------------------------------

-- Count the number of elements in a table
function ProductiveWoW_tableLength(tbl)
	local count = 0
	for element in pairs(tbl) do
		count = count + 1
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
	if ProductiveWoW_tableIsArray(tbl1) and ProductiveWoW_tableIsArray(tbl2) then
		for i, val in ipairs(tbl2) do
			table.insert(tbl1, val)
		end
		return tbl1
	end
end

-- Get random subset of size n from array-type table
function ProductiveWoW_getRandomSubsetOfArrayTable(tbl, size)
	if ProductiveWoW_tableLength(tbl) >= size then
		local tempTable = ProductiveWoW_tableShallowCopy(tbl)
		local subset = {}
		while size ~= 0 do
			local randomIndex = math.random(1, size)
			table.insert(subset, tempTable[randomIndex])
			table.remove(tempTable, randomIndex)
			size = size - 1
		end
		return subset
	end
	return tbl
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
