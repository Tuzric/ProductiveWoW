-- Count the number of elements in a table
function ProductiveWoW_tableLength(tbl)
	local count = 0
	for element in pairs(tbl) do
		count = count + 1
	end
	return count
end

-- Check if a value exists in a table's keys
function ProductiveWoW_inTableKeys(value_to_check, tbl)
	for key, value in pairs(tbl) do
		if key == value_to_check then
			return true
		end
	end
	return false
end

-- Remove an element from an array by value
function ProductiveWoW_removeByValue(value, tbl)
	for i = #tbl, 1, -1 do
		if (tbl[i] == value) then
			table.remove(tbl, i)
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

-- String only contains whitespace
function ProductiveWoW_stringContainsOnlyWhitespace(string)
	return string:match("^%s*$") ~= nil
end


-- Number of days since date
function ProductiveWoW_numberOfDaysSinceDate(since_date)
	local sinceDateTimestamp = time(since_date)
	local todayTimestamp = date("*t")
	todayTimestamp = time(todayTimestamp)
	local diffSeconds = todayTimestamp - sinceDateTimestamp
	local daysBetween = math.floor(diffSeconds / (24 * 60 * 60))
	return daysBetween
end