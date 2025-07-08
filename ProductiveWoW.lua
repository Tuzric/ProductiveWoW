-- LOAD SAVED VARIABLES --
ProductiveWoWSavedSettings = ProductiveWoWSavedSettings or {["currently_selected_deck"] = nil}
ProductiveWoWData = ProductiveWoWData or {["decks"] = {}}


-- INITIALIZE OTHER VARIABLES --
local currentSubsetOfCardsBeingQuizzedIDs = {}
local currentCardID = nil
local ALL_CARDS = -1 -- Test on all cards per day
local EASY = "easy"
local MEDIUM = "medium"
local HARD = "hard"
local NEW_DECK_DATE = date("*t", time() - 180000) -- About 2 days before today

-- FUNCTION DEFINITIONS --

-- Get current card shown on flashcard frame
function ProductiveWoW_getCurrentCardID()
	return currentCardID
end

-- Get current deck contents
function ProductiveWoW_getCurrentDeck()
	local deckName = ProductiveWoWSavedSettings["currently_selected_deck"]
	return ProductiveWoWData["decks"][deckName]
end

-- Get current deck name
function ProductiveWoW_getCurrentDeckName()
	return ProductiveWoWSavedSettings["currently_selected_deck"]
end

-- Get deck by name
function ProductiveWoW_getDeck(deck_name)
	return ProductiveWoWData["decks"][deck_name]
end

-- Get deck's cards by deck name
function ProductiveWoW_getDeckCards(deck_name)
	return ProductiveWoWData["decks"][deck_name]["cards"]
end

-- Add a deck
function ProductiveWoW_addDeck(deck_name)
	local existingDeck = ProductiveWoW_getDeck(deck_name)
	if existingDeck == nil then
		ProductiveWoWData["decks"][deck_name] = {["cards"] = {}, ["next_card_id"] = 1, ["date last played"] = NEW_DECK_DATE, ["completed today"] = false, ["started today"] = false, ["daily number of cards"] = ALL_CARDS, ["list of cards remaining for today"] = {}}
	else
		print(existingDeck .. " already exists.")
	end
end

-- Delete a deck
function ProductiveWoW_deleteDeck(deck_name)
	ProductiveWoWData["decks"][deck_name] = nil
	if ProductiveWoWSavedSettings["currently_selected_deck"] == deck_name then
		ProductiveWoWSavedSettings["currently_selected_deck"] = nil
	end
	print(deck_name .. " has been successfully deleted.")
end

-- Get card by ID
function ProductiveWoW_getCardByID(deck_name, card_id)
	return ProductiveWoW_getDeckCards(deck_name)[card_id]
end

-- Get card by ID for current deck
function ProductiveWoW_getCardByIDForCurrentlySelectedDeck(card_id)
	local currentDeck = ProductiveWoWSavedSettings["currently_selected_deck"]
	if currentDeck ~= nil then
		return ProductiveWoW_getCardByID(currentDeck, card_id)
	end
end

-- Get card by question
function ProductiveWoW_getCardByQuestion(deck_name, question)
	for card_id, contents in pairs(ProductiveWoW_getDeckCards(deck_name)) do
		if contents["question"] == question then
			return contents
		end
	end
end

local function createCardTable(question, answer)
	return {
				["question"] = question,
				["answer"] = answer,
				["tags"] = {},
				["date last viewed"] = "",
				["number of times viewed"] = 0,
				["number of times easy"] = 0,
				["number of times medium"] = 0,
				["number of times hard"] = 0,
				["difficulty"] = "hard",
			}
end

-- Increase the views of a card
function ProductiveWoW_viewedCard(card_id)
	local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(card_id)
	card["number of times viewed"] = card["number of times viewed"] + 1
	card["date last viewed"] = date("*t")
end

-- Card was easy
function ProductiveWoW_cardEasyDifficultyChosen(card_id)
	local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(card_id)
	card["number of times easy"] = card["number of times easy"] + 1
	card["difficulty"] = EASY
end

-- Card was medium difficulty
function ProductiveWoW_cardMediumDifficultyChosen(card_id)
	local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(card_id)
	card["number of times medium"] = card["number of times medium"] + 1
	card["difficulty"] = MEDIUM
end

-- Card was easy
function ProductiveWoW_cardHardDifficultyChosen(card_id)
	local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(card_id)
	card["number of times hard"] = card["number of times hard"] + 1
	card["difficulty"] = HARD
end

-- Add a card
function ProductiveWoW_addCard(deck_name, question, answer)
	local next_id = ProductiveWoW_getDeck(deck_name)["next_card_id"]
	ProductiveWoWData["decks"][deck_name]["cards"][next_id] = createCardTable(question, answer)
	ProductiveWoWData["decks"][deck_name]["next_card_id"] = next_id + 1
end

-- Delete a card by ID
function ProductiveWoW_deleteCardByID(deck_name, card_id)
	ProductiveWoWData["decks"][deck_name]["cards"][card_id] = nil
end

-- Delete a card by question
function ProductiveWoW_deleteCardByQuestion(deck_name, question)
	for card_id, contents in pairs(ProductiveWoW_getDeckCards(deck_name)) do
		if contents["question"] == question then
			ProductiveWoWData["decks"][deck_name]["cards"][card_id] = nil
		end
	end
end

-- Check if a question already exists
function ProductiveWoW_questionAlreadyExistsInDeck(question, deck_name)
	return ProductiveWoW_getCardByQuestion(deck_name, question) ~= nil
end

-- Import decks from ProductiveWoWDecks.lua
function ProductiveWoW_importDecks()
	for deck_name, card_list in pairs(ProductiveWoW_cardsToAdd) do
		-- If deck does not already exist, create it
		if ProductiveWoW_getDeck(deck_name) == nil then
			ProductiveWoW_addDeck(deck_name)
		end
		-- Once deck exists for sure, populate it with newly added cards (if question does not already exist)
		for question, answer in pairs(card_list) do
			if not ProductiveWoW_questionAlreadyExistsInDeck(question, deck_name) then
				ProductiveWoW_addCard(deck_name, question, answer)
			end
		end
		-- Delete cards
		if ProductiveWoW_cardsToDelete[deck_name] ~= nil then
			for i, question in ipairs(ProductiveWoW_cardsToDelete[deck_name]) do
				ProductiveWoW_deleteCardByQuestion(deck_name, question)
			end
		end
	end
end

-- Check if this is the first time playing the deck today
function ProductiveWoW_isDeckNotPlayedYetToday(deck_name)
	local deck = ProductiveWoW_getDeck(deck_name)
	local currentDate = date("*t")
	local daysSinceLastPlayed = ProductiveWoW_numberOfDaysSinceDate(deck["date last played"])
	if daysSinceLastPlayed >= 1 then
		return true
	end
	-- Check for case when daysSinceLastPlayed is 0 as in 24h have not passed yet, but it is the next day, will reset it at 10am
	if currentDate["day"] - deck["date last played"]["day"] == 1 and currentDate["hour"] >= 10 then
		return true
	end
	return false
end

-- Check if deck has been completed today
function ProductiveWoW_isDeckCompletedForToday(deck_name)
	local deck = ProductiveWoW_getDeck(deck_name)
	return deck["completed today"]
end

-- Set deck done for today
function ProductiveWoW_setDeckCompletedForToday(deck_name)
	local deck = ProductiveWoW_getDeck(deck_name)
	deck["completed today"] = true
end

function ProductiveWoW_setDeckNotPlayedYetToday(deck_name)
	local deck = ProductiveWoW_getDeck(deck_name)
	deck["started today"] = false
	deck["completed today"] = false
	deck["list of cards remaining for today"] = {}
end

local function setDeckStartedToday(deck_name, cards_remaining)
	local deck = ProductiveWoW_getDeck(deck_name)
	deck["started today"] = true
	deck["list of cards remaining for today"] = cards_remaining
	deck["date last played"] = date("*t")
end

-- Set max daily cards value for deck
function ProductiveWoW_setMaxDailyCardsForDeck(deck_name, max_daily_cards)
	local deck = ProductiveWoW_getDeck(deck_name)
	deck["daily number of cards"] = max_daily_cards
end

local function updateDeckValues()
	for deck_name, deck_contents in pairs(ProductiveWoWData["decks"]) do
		-- Check to make sure all the deck keys exist if more of them were added in newer versions of the addon (past v1.0)
		if deck_contents["date last played"] == nil then
			deck_contents["date last played"] = NEW_DECK_DATE
		end
		if deck_contents["completed today"] == nil then
			deck_contents["completed today"] = false
		end
		if deck_contents["started today"] == nil then
			deck_contents["started today"] = false
		end
		if deck_contents["daily number of cards"] == nil then
			deck_contents["daily number of cards"] = ALL_CARDS
		end
		if deck_contents["list of cards remaining for today"] == nil then
			deck_contents["list of cards remaining for today"] = {}
		end
		if ProductiveWoW_isDeckNotPlayedYetToday(deck_name) then
			ProductiveWoW_setDeckNotPlayedYetToday(deck_name)
		end
	end
end

-- Get table of card IDs by card difficulty
local function getCardIdsByDifficulty(deck_name, difficulty)
	local cards = ProductiveWoW_getDeckCards(deck_name)
	local cardIds = {}
	for cardId, card in pairs(cards) do
		if card["difficulty"] == difficulty then
			table.insert(cardIds, cardId)
		end
	end
	return cardIds
end

local function getDeckSubsetForQuiz()
	local currentDeckName = ProductiveWoW_getCurrentDeckName()
	local currentDeck = ProductiveWoW_getCurrentDeck()
	local subset = {}
	if currentDeck["daily number of cards"] == ALL_CARDS then
		-- No limit to the number of cards being tested per day
		return ProductiveWoW_getKeys(ProductiveWoW_getDeckCards(currentDeckName)) -- Table of Card IDs
	else
		local maxLimit = tonumber(currentDeck["daily number of cards"])
		-- Prioritize hard
		local hardCardIds = getCardIdsByDifficulty(currentDeckName, HARD)
		local numberOfHardCards = ProductiveWoW_tableLength(hardCardIds)
		if numberOfHardCards == maxLimit then
			return hardCardIds
		elseif numberOfHardCards > maxLimit then
			subset = ProductiveWoW_getRandomSubsetOfTable(hardCardIds, maxLimit)
			return subset
		else
			-- If it's smaller than maxLimit we need to add some Medium difficulty cards
			subset = hardCardIds
			local remainingLimit = maxLimit - numberOfHardCards
			local mediumCardIds = getCardIdsByDifficulty(currentDeckName, MEDIUM)
			local numberOfMediumCards = ProductiveWoW_tableLength(mediumCardIds)
			if numberOfMediumCards == remainingLimit then
				subset = ProductiveWoW_mergeTables(subset, mediumCardIds)
				return subset
			elseif numberOfMediumCards > remainingLimit then
				local mediumCardsSubset = ProductiveWoW_getRandomSubsetOfTable(mediumCardIds, remainingLimit)
				subset = ProductiveWoW_mergeTables(subset, mediumCardsSubset)
				return subset
			else
				-- If it's still smaller, add in the Easy cards
				subset = ProductiveWoW_mergeTables(subset, mediumCardIds)
				remainingLimit = remainingLimit - numberOfMediumCards
				local easyCardIds = getCardIdsByDifficulty(currentDeckName, EASY)
				local numberOfEasyCards = ProductiveWoW_tableLength(easyCardIds)
				if numberOfEasyCards <= remainingLimit then
					-- Since this is the final difficulty, we can just add all the easy cards if it's equal or less than the remaining limit
					subset = ProductiveWoW_mergeTables(subset, easyCardIds)
					return subset
				else
					-- If there are more easy cards than the remaining limit allows, get a random subset of them
					local easyCardsSubset = ProductiveWoW_getRandomSubsetOfTable(easyCardIds, remainingLimit)
					subset = ProductiveWoW_mergeTables(subset, easyCardsSubset)
					return subset
				end
			end
		end
	end
	-- User has already started playing the deck today so return cards remaining
	return currentDeck["list of cards remaining for today"]
end

-- Draw random next card
function ProductiveWoW_drawRandomNextCard()
	local numCards = ProductiveWoW_tableLength(currentSubsetOfCardsBeingQuizzedIDs)
	local currentDeck = ProductiveWoW_getCurrentDeck()
	if numCards >= 1 then
		local random_index = math.random(1, numCards)
		currentCardID = currentSubsetOfCardsBeingQuizzedIDs[random_index]
		table.remove(currentSubsetOfCardsBeingQuizzedIDs, random_index)
		table.remove(currentDeck["list of cards remaining for today"], random_index)
	else
		ProductiveWoW_setDeckCompletedForToday(ProductiveWoW_getCurrentDeckName())
		ProductiveWoW_showMainMenu()
		print("Congratulations, you completed this for today.")
	end
end

-- Set that the deck has been started today

-- Begin quiz
function ProductiveWoW_beginQuiz()
	local currentDeckName = ProductiveWoW_getCurrentDeckName()
	-- Load the subset of cards to be quizzed on
	currentSubsetOfCardsBeingQuizzedIDs = getDeckSubsetForQuiz()
	if ProductiveWoW_isDeckNotPlayedYetToday(currentDeckName) then
		setDeckStartedToday(currentDeckName, currentSubsetOfCardsBeingQuizzedIDs)
	end
	ProductiveWoW_drawRandomNextCard()
end

-- Required to run in this block to ensure that saved variables are loaded before this code runs
EventUtil.ContinueOnAddOnLoaded("ProductiveWoW", function()

	-- DEBUG AND DEV ONLY: Uncomment to reset saved variables on addon load
	-- ProductiveWoWSavedSettings = {["currently_selected_deck"] = nil}
	-- ProductiveWoWData = {["decks"] = {}}

	-- Import decks from ProductiveWoWDecks.lua
	ProductiveWoW_importDecks()

	-- For now this checks if it's a new day, and the number of cards remaining to play for today needs to be reset
	-- It also checks if new values were added to decks from newer versions of this addon so that decks that were saved in older
	-- versions will not cause any bugs
	updateDeckValues()

	-- SLASH COMMANDS --
	-- SLASH_ prefix is required and used by WoW to find the slash commands automatically
	SLASH_ProductiveWoW1 = "/productivewow"
	SLASH_ProductiveWoW2 = "/flashcards"
	SLASH_ProductiveWoW3 = "/flashcard"
	SLASH_ProductiveWoW4 = "/fc"
	SlashCmdList["ProductiveWoW"] = function()
		if ProductiveWoW_anyFrameIsShown() then
			ProductiveWoW_hideAllFrames()
		else
			ProductiveWoW_showMainMenu()
		end
	end


	-- OPTIONS TAB --
	-- Options config panel
	-- Parent layout
	local category = Settings.RegisterVerticalLayoutCategory("ProductiveWoW")

	-- Add settings
	-- Open main menu button


	Settings.RegisterAddOnCategory(category)

end)