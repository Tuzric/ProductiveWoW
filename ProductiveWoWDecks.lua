-- v1.3.4

-- IMPORTANT NOTE: Double check you closed off all the brackets (both curly and square) and that you added all the commas and quotes properly.
-- if the addon doesn't load, it's because you messed up something here

-- List additional cards to add to decks. This only adds additional cards, it does not define the comprehensive list 
-- of cards in a deck.

-- If you delete a card in this list through the in-game UI, it will reappear when you /reload or login again because it gets re-added
-- due to being in this list.

-- RECOMMENDATION: To avoid the above issue, login once to load the cards you want to bulk add/delete, then come back to this file
-- and delete them from here so that you can edit/delete these cards through the UI without your changes being reset upon the next login
ProductiveWoW_cardsToAdd = {
	-- ["Capitals of the World"] = {
	-- 	["What's the capital of the USA?"] = "Washington D.C.",
	-- 	["What's the capital of Canada?"] = "Ottawa",
	-- 	["What's the capital of Mexico?"] = "Mexico City",
	-- 	["What's the capital of Afghanistan?"] = "Kabul",
	-- 	["What's the capital of Albania?"] = "Tirana",
	-- 	["What's the capital of Algeria?"] = "Algiers",
	-- 	["What's the capital of Andorra?"] = "Andorra la Vella",
	-- 	["What's the capital of Angola?"] = "Luanda",
	-- 	["What's the capital of Antigua and Barbuda?"] = "Saint John's",
	-- 	["What's the capital of Argentina?"] = "Buenos Aires",
	-- 	["What's the capital of Armenia?"] = "Yerevan",
	-- 	["What's the capital of Australia?"] = "Canberra",
	-- 	["What's the capital of Austria?"] = "Vienna",
	-- 	["What's the capital of Azerbaijan?"] = "Baku",
	-- 	["What's the capital of the Bahamas?"] = "Nassau",
	-- 	["What's the capital of Bahrain?"] = "Manama",
	-- 	["What's the capital of Bangladesh?"] = "Dhaka",
	-- 	["What's the capital of Barbados?"] = "Bridgetown",
	-- 	["What's the capital of Belarus?"] = "Minsk",
	-- 	["What's the capital of Belgium?"] = "Brussels",
	-- 	["What's the capital of Belize?"] = "Belmopan",
	-- 	["What's the capital of Benin?"] = "Porto-Novo",
	-- 	["What's the capital of Bhutan?"] = "Thimphu",
	-- 	["What's the capital of Bolivia?"] = "La Paz (de jure), Sucre (seat of government)",
	-- 	["What's the capital of Bosnia and Herzegovina?"] = "Sarajevo",
	-- 	["What's the capital of Botswana?"] = "Gaborone",
	-- 	["What's the capital of Brazil?"] = "Brasilia",
	-- 	["What's the capital of Brunei?"] = "Bandar Seri Begawan",
	-- 	["What's the capital of Bulgaria?"] = "Sofia",
	-- 	["What's the capital of Burkina Faso?"] = "Ouagadougou",
	-- 	["What's the capital of Cabo Verde?"] = "Praia",
	-- 	["What's the capital of Cambodia?"] = "Phnom Pehn",
	-- 	["What's the capital of Cameroon?"] = "Yaounde",
	-- 	["What's the capital of the Central African Republic?"] = "Bangui",
	-- 	["What's the capital of Chad?"] = "N'Djamena",
	-- 	["What's the capital of Chile?"] = "Santiago",
	-- 	["What's the capital of China?"] = "Beijing",
	-- 	["What's the capital of Colombia?"] = "Bogota",
	-- 	["What's the capital of Comoros?"] = "Moroni",
	-- 	["What's the capital of the Democratic Republic of Congo?"] = "Kinshasa",
	-- 	["What's the capital of the Republic of Congo?"] = "Brazzaville",
	-- 	["What's the capital of Costa Rica?"] = "San Jose",
	-- 	["What's the capital of Cote D'Ivoire?"] = "Yamoussoukro",
	-- 	["What's the capital of Croatia?"] = "Zagreb",
	-- 	["What's the capital of Cuba?"] = "Havana",
	-- 	["What's the capital of Cyprus?"] = "Nicosia",
	-- 	["What's the capital of Czechia?"] = "Prague"
	-- },
	-- ["Birds"] = {
	-- 	["What's the airspeed velocity of an unladen swallow?"] = "What do you mean? African or European swallow?"
	-- }
}

-- List of cards to delete from a deck
ProductiveWoW_cardsToDelete = {
	-- ["Example Deck"] = {
	-- 	"Question 1 that you want to delete",
	-- 	"Question 2 that you want to delete"
	-- }
}

-- Anki integration: Go to your Anki, export a deck as a .txt file, open it, copy and paste the entire contents into the variable
-- below as a string. The function below will add it to the ProductiveWoW_cardsToAdd table which will import them into the game.
-- RECOMMENDATION: After you've logged in and loaded the cards you added from Anki, come back to this file, and delete the Anki
-- contents you pasted otherwise you might run into issues deleting the cards through the UI since they will be reloaded when you re-log
ProductiveWoW_ankiDeckName = ""
-- Paste contents between the 2 square brackets. E.g. [[contents]]. It can span multiple lines.
local ankiContents = [[]]

local function split(str, separator)
    local result = {}
    for part in string.gmatch(str, "([^" .. separator .. "]+)") do
        table.insert(result, part)
    end
    return result
end

local function importAnki(ankiContents)
	local line_separator = "\n"
	local question_answer_separator = "\t"
	local lines = split(ankiContents, line_separator)
	local count_of_cards_added = 0
	if (ProductiveWoW_cardsToAdd[ProductiveWoW_ankiDeckName] == nil) then
		ProductiveWoW_cardsToAdd[ProductiveWoW_ankiDeckName] = {}
	end
	for i, line in ipairs(lines) do
		if string.sub(line, 1, 1) ~= "#" then
			local question_answer = split(line, question_answer_separator)
			if question_answer ~= nil then
				if ProductiveWoW_tableLength(question_answer) == 2 then
					ProductiveWoW_cardsToAdd[ProductiveWoW_ankiDeckName][question_answer[1]] = question_answer[2]
					count_of_cards_added = count_of_cards_added + 1
				end
			end
		end
	end
	print(count_of_cards_added .. " cards from Anki have been imported.")
end

if ProductiveWoW_ankiDeckName ~= "" then
	if not ProductiveWoW_stringContainsOnlyWhitespace(ProductiveWoW_ankiDeckName) then
		if ankiContents ~= "" then
			importAnki(ankiContents)
		end
	else
		print("Attempt to import from Anki failed due to deck name containing only whitespace.")
	end
elseif ankiContents ~= "" then
	print("Could not import Anki deck. You need to give the deck a name in the ProductiveWoW_ankiDeckName variable.")
end