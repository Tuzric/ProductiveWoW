-- v1.3

-- DEV AND DEBUG ONLY --
local resetSavedVariables = false -- Reset ProductiveWoWData and ProductiveWoWSavedSettings
local runUnitTests = false


-- INITIALIZE VARIABLES --
-- GLOBALS --
--------------------------------------------------------------------------------------------------------------------------------
ProductiveWoW_ADDON_NAME = "ProductiveWoW"
ProductiveWoW_ADDON_VERSION = "v1.3"


-- CONSTANTS --
--------------------------------------------------------------------------------------------------------------------------------
local EASY = "easy" -- Constant string value representing the Easy difficulty of a card
local MEDIUM = "medium" -- Constant string value representing the Medium difficulty of a card
local HARD = "hard" -- Constant string value representing the Hard difficulty of a card
local NEW_DECK_DATE = date("*t", time() - 180000) -- About 2 days before today. This is the initial value of deck["date last played"] when a new deck is created and it has to be 2 days before so that its status is set to "Not Played Today"
local ALL_CARDS = -1 -- Test on all cards per day
-- All variables with _KEY contain the string value used as the key in some table
local DECKS_KEY = "decks"
local CURRENTLY_SELECTED_DECK_KEY = "currently_selected_deck"
local CARDS_KEY = "cards"
local QUESTION_KEY = "question"
local ANSWER_KEY = "answer"
local DIFFICULTY_KEY = "difficulty"
local STARTED_TODAY_KEY = "started today"
local COMPLETED_TODAY_KEY = "completed today"
local DATE_LAST_PLAYED_KEY = "date last played"
local LIST_OF_CARDS_REMAINING_TODAY_KEY = "list of cards remaining today"
local DAILY_NUMBER_OF_CARDS_KEY = "daily number of cards"
local NUMBER_OF_TIMES_PLAYED_KEY = "number of times played"
local NEXT_CARD_ID_KEY = "next card id"
local DAY_KEY = "day"
local HOUR_KEY = "hour"
local NUMBER_OF_TIMES_EASY_KEY = "number of times easy"
local NUMBER_OF_TIMES_MEDIUM_KEY = "number of times medium"
local NUMBER_OF_TIMES_HARD_KEY = "number of times hard"


-- DECK VARIABLES --
--------------------------------------------------------------------------------------------------------------------------------
local deckTableDefaultValues = {[CARDS_KEY] = {}, [NEXT_CARD_ID_KEY] = 1, [STARTED_TODAY_KEY] = false, [COMPLETED_TODAY_KEY] = false,
								[DATE_LAST_PLAYED_KEY] = NEW_DECK_DATE, [LIST_OF_CARDS_REMAINING_TODAY_KEY] = {},
								[DAILY_NUMBER_OF_CARDS_KEY] = ALL_CARDS, [NUMBER_OF_TIMES_PLAYED_KEY] = 0}

-- CARD VARIABLES -- 
--------------------------------------------------------------------------------------------------------------------------------
local cardTableDefaultValues = {[QUESTION_KEY] = "", [ANSWER_KEY] = "", [DIFFICULTY_KEY] = HARD, [DATE_LAST_PLAYED_KEY] = NEW_DECK_DATE,
								[NUMBER_OF_TIMES_PLAYED_KEY] = 0, [NUMBER_OF_TIMES_EASY_KEY] = 0, [NUMBER_OF_TIMES_MEDIUM_KEY] = 0,
								[NUMBER_OF_TIMES_HARD_KEY] = 0}


-- QUIZ VARIABLES -- 
--------------------------------------------------------------------------------------------------------------------------------
ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs = {} -- When you press "Go" to start the quiz, this table stores the subset of Card IDs from the deck that is being quizzed
local currentCardID = nil -- Tracks the Card ID of the current card being shown to the user in the quiz
local timeWhenDeckCanBePlayedAgain = 10 -- Each new day, the deck can be played again at 10am regardless if 24h has passed or not


-- OTHER --
--------------------------------------------------------------------------------------------------------------------------------
local savedSettingsTableInitialValues = {[CURRENTLY_SELECTED_DECK_KEY] = nil}
local dataTableInitialValues = {[DECKS_KEY] = {}}


--============================================================================================================================--


-- LOAD SAVED VARIABLES --
ProductiveWoWSavedSettings = ProductiveWoWSavedSettings or savedSettingsTableInitialValues
ProductiveWoWData = ProductiveWoWData or dataTableInitialValues


--============================================================================================================================--


-- FUNCTION DEFINITIONS --

-- GETTERS AND SETTERS --

-- GETTERS --
--------------------------------------------------------------------------------------------------------------------------------

-- Get all decks
function ProductiveWoW_getAllDecks()
	return ProductiveWoWData[DECKS_KEY]
end

-- Get current card shown on flashcard frame during a quiz
function ProductiveWoW_getCurrentCardID()
	return currentCardID
end

-- Get current deck name
function ProductiveWoW_getCurrentDeckName()
	return ProductiveWoWSavedSettings[CURRENTLY_SELECTED_DECK_KEY]
end

-- Get current deck contents
function ProductiveWoW_getCurrentDeck()
	return ProductiveWoWData[DECKS_KEY][ProductiveWoW_getCurrentDeckName()]
end

-- Get deck by name
function ProductiveWoW_getDeck(deckName)
	return ProductiveWoWData[DECKS_KEY][deckName]
end

-- Get deck's cards by deck name
function ProductiveWoW_getDeckCards(deckName)
	return ProductiveWoWData[DECKS_KEY][deckName][CARDS_KEY]
end

-- Get deck's next Card ID
function ProductiveWoW_getDeckNextCardId(deckName)
	return ProductiveWoW_getDeck(deckName)[NEXT_CARD_ID_KEY]
end

-- Get deck daily number of cards
function ProductiveWoW_getDeckDailyNumberOfCards(deckName)
	return ProductiveWoW_getDeck(deckName)[DAILY_NUMBER_OF_CARDS_KEY]
end

-- Get deck list of remaining cards to be tested today
function ProductiveWoW_getDeckListOfRemainingCardsToday(deckName)
	return ProductiveWoW_getDeck(deckName)[LIST_OF_CARDS_REMAINING_TODAY_KEY]
end

-- Get card by ID
function ProductiveWoW_getCardByID(deckName, cardId)
	return ProductiveWoW_getDeckCards(deckName)[cardId]
end

-- Get card by ID for current deck
function ProductiveWoW_getCardByIDForCurrentlySelectedDeck(cardId)
	local currentDeckName = ProductiveWoW_getCurrentDeckName()
	if currentDeckName ~= nil then
		return ProductiveWoW_getCardByID(currentDeckName, cardId)
	end
end

-- Get card by question
function ProductiveWoW_getCardByQuestion(deckName, question)
	for cardId, contents in pairs(ProductiveWoW_getDeckCards(deckName)) do
		if contents[QUESTION_KEY] == question then
			return contents
		end
	end
end

-- Get card's question
function ProductiveWoW_getCardQuestion(deckName, cardId)
	return ProductiveWoW_getCardByID(deckName, cardId)[QUESTION_KEY]
end

-- Get a question given a card table
function ProductiveWoW_getQuestionFromCardTable(cardTable)
	return cardTable[QUESTION_KEY]
end

-- Get card's answer
function ProductiveWoW_getCardAnswer(deckName, cardId)
	return ProductiveWoW_getCardByID(deckName, cardId)[ANSWER_KEY]
end

-- Get a answer given a card table
function ProductiveWoW_getAnswerFromCardTable(cardTable)
	return cardTable[ANSWER_KEY]
end

-- Get card date last played
function ProductiveWoW_getCardDateLastPlayed(deckName, cardId)
	return ProductiveWoW_getCardByID(deckName, cardId)[DATE_LAST_PLAYED_KEY]
end

-- Get card difficulty
function ProductiveWoW_getCardDifficulty(deckName, cardId)
	return ProductiveWoW_getCardByID(deckName, cardId)[DIFFICULTY_KEY]
end

-- Get table of card IDs by card difficulty
local function getCardIdsByDifficulty(deckName, difficulty)
	local cards = ProductiveWoW_getDeckCards(deckName)
	local cardIds = {}
	for cardId, card in pairs(cards) do
		if card[DIFFICULTY_KEY] == difficulty then
			table.insert(cardIds, cardId)
		end
	end
	return cardIds
end

-- SETTERS --
--------------------------------------------------------------------------------------------------------------------------------

-- Set the currently selected deck
function ProductiveWoW_setCurrentlySelectedDeck(deckName)
	ProductiveWoWSavedSettings[CURRENTLY_SELECTED_DECK_KEY] = deckName
end

-- Set deck done for today
function ProductiveWoW_setDeckCompletedForToday(deckName)
	local deck = ProductiveWoW_getDeck(deckName)
	deck[COMPLETED_TODAY_KEY] = true
end

function ProductiveWoW_setDeckNotPlayedYetToday(deckName)
	local deck = ProductiveWoW_getDeck(deckName)
	deck[STARTED_TODAY_KEY] = false
	deck[COMPLETED_TODAY_KEY] = false
	deck[LIST_OF_CARDS_REMAINING_TODAY_KEY] = {}
end

local function setDeckStartedToday(deckName, cardsRemainingTable)
	local deck = ProductiveWoW_getDeck(deckName)
	deck[STARTED_TODAY_KEY] = true
	deck[LIST_OF_CARDS_REMAINING_TODAY_KEY] = cardsRemainingTable
	deck[DATE_LAST_PLAYED_KEY] = date("*t")
end

-- Set max daily cards value for deck
function ProductiveWoW_setMaxDailyCardsForDeck(deckName, maxDailyCards)
	local deck = ProductiveWoW_getDeck(deckName)
	deck[DAILY_NUMBER_OF_CARDS_KEY] = maxDailyCards
end

-- Set the next card id of the deck. Card Ids are assigned sequentially (e.g. first card has an Id of 1, 2nd one is 2, etc.)
function ProductiveWoW_setDeckNextCardId(deckName, nextCardId)
	ProductiveWoW_getDeck(deckName)[NEXT_CARD_ID_KEY] = nextCardId
end

-- Set date last played of a card
function ProductiveWoW_setCardDateLastPlayed(deckName, cardId, date)
	ProductiveWoW_getCardByID(deckName, cardId)[DATE_LAST_PLAYED_KEY] = date
end

-- Set difficulty of a card
function ProductiveWoW_setCardDifficulty(deckName, cardId, difficulty)
	ProductiveWoW_getCardByID(deckName, cardId)[DIFFICULTY_KEY] = difficulty
end

-- If more keys have been added to the deck table in newer versions of the addon, and a deck doesn't have them, add them in
local function setDeckTableMissingKeys(deck)
	for key, val in pairs(deckTableDefaultValues) do
		if type(val) == "table" and deck[key] == nil then
			-- If it's a nested table, need to set it to a copy of the table
			deck[key] = ProductiveWoW_tableShallowCopy(val)
		elseif deck[key] == nil then
			deck[key] = val
		end
	end
end

-- If more keys have been added to the card table in newer versions of the addon, and a card doesn't have them, add them in
local function setCardTableMissingKeys(card)
	for key, val in pairs(cardTableDefaultValues) do
		if type(val) == "table" and card[key] == nil then
			-- If it's a nested table, need to set it to a copy of the table
			card[key] = ProductiveWoW_tableShallowCopy(val)
		elseif card[key] == nil then
			card[key] = val
		end
	end
end

-- Set the card's question
function ProductiveWoW_setCardQuestion(deckName, cardId, question)
	ProductiveWoW_getCardByID(deckName, cardId)[QUESTION_KEY] = question
end

-- Set the card's answer
function ProductiveWoW_setCardAnswer(deckName, cardId, answer)
	ProductiveWoW_getCardByID(deckName, cardId)[ANSWER_KEY] = answer
end

-- DECK FUNCTIONS --
--------------------------------------------------------------------------------------------------------------------------------

-- Initialize deck with default table values
local function initializeDeckTable()
	local newDeck = {}
	setDeckTableMissingKeys(newDeck) -- Since it's an empty table, all keys will be missing and they will all be added
	return newDeck
end

-- Add a deck
function ProductiveWoW_addDeck(deckName)
	local existingDeck = ProductiveWoW_getDeck(deckName)
	if existingDeck == nil then
		ProductiveWoWData[DECKS_KEY][deckName] = initializeDeckTable()
	else
		print(existingDeck.. " already exists.")
	end
end

-- Delete a deck
function ProductiveWoW_deleteDeck(deckName)
	ProductiveWoWData[DECKS_KEY][deckName] = nil
	if ProductiveWoWSavedSettings[CURRENTLY_SELECTED_DECK_KEY] == deckName then
		ProductiveWoWSavedSettings[CURRENTLY_SELECTED_DECK_KEY] = nil
	end
	print(deckName .. " has been successfully deleted.")
end

-- Check if a deck exists
function ProductiveWoW_deckExists(deckName)
	if ProductiveWoW_getDeck(deckName) ~= nil then
		return true
	end
	return false
end

-- Check if a deck exists in ProductiveWoWDecks.lua where decks are bulk imported from
function ProductiveWoW_deckExistsInBulkImportFile(deckName)
	if ProductiveWoW_inTableKeys(deckName, ProductiveWoW_cardsToAdd) or ProductiveWoW_ankiDeckName == deckName or ProductiveWoW_inTableKeys(deckName, ProductiveWoW_cardsToDelete) then
		return true
	end
	return false
end

-- Check if this is the first time playing the deck today
function ProductiveWoW_isDeckNotPlayedYetToday(deckName)
	local deck = ProductiveWoW_getDeck(deckName)
	local currentDate = date("*t")
	local daysSinceLastPlayed = ProductiveWoW_numberOfDaysSinceDate(deck[DATE_LAST_PLAYED_KEY])
	if daysSinceLastPlayed >= 1 then
		return true
	end
	-- Check for case when daysSinceLastPlayed is 0 as in 24h have not passed yet, but it is the next day, will reset it at 10am
	if currentDate[DAY_KEY] - deck[DATE_LAST_PLAYED_KEY][DAY_KEY] == 1 and currentDate[HOUR_KEY] >= timeWhenDeckCanBePlayedAgain then
		return true
	end
	return false
end

-- Check if deck has been completed today
function ProductiveWoW_isDeckCompletedForToday(deckName)
	return ProductiveWoW_getDeck(deckName)[COMPLETED_TODAY_KEY]
end

local function updateDeckValues()
	for deckName, deck in pairs(ProductiveWoWData[DECKS_KEY]) do
		-- Check to make sure all the deck keys exist if more of them were added in newer versions of the addon (past v1.0)
		setDeckTableMissingKeys(deck) -- Only adds missing keys
		if ProductiveWoW_isDeckNotPlayedYetToday(deckName) then
			ProductiveWoW_setDeckNotPlayedYetToday(deckName)
		end
	end
end

function ProductiveWoW_getDeckCardsContainingSubstringInQuestionOrAnswer(deckName, substring)
	local cards = ProductiveWoW_getDeckCards(deckName)
	local matches = {}
	for cardId, cardTable in pairs(cards) do
		local question = ProductiveWoW_getQuestionFromCardTable(cardTable)
		local answer = ProductiveWoW_getAnswerFromCardTable(cardTable)
		if string.find(string.lower(question), string.lower(substring)) or string.find(string.lower(answer), string.lower(substring)) then
			matches[cardId] = cardTable
		end
	end
	return matches
end

-- CARD FUNCTIONS --
--------------------------------------------------------------------------------------------------------------------------------

-- Create a new card table with all default values
local function initializeCardTable()
	local card = {}
	setCardTableMissingKeys(card) -- Since a new card will be missing all the keys, they will all be initialized with default values
	return card
end

-- Update card tables with new keys that were added in newer versions of the addon
local function updateCardValues()
	for deckName, deck in pairs(ProductiveWoW_getAllDecks()) do
		for cardId, card in pairs(ProductiveWoW_getDeckCards(deckName)) do
			setCardTableMissingKeys(card)
		end
	end
end

-- Check if a question already exists
function ProductiveWoW_questionAlreadyExistsInDeck(question, deckName)
	return ProductiveWoW_getCardByQuestion(deckName, question) ~= nil
end

-- Check if a card exists in ProductiveWoWDecks.lua where decks are bulk imported from
function ProductiveWoW_cardExistsInBulkImportFile(deckName, cardQuestion)
	if ProductiveWoW_deckExistsInBulkImportFile(deckName) then
		if ProductiveWoW_inTableKeys(cardQuestion, ProductiveWoW_cardsToAdd[deckName]) or ProductiveWoW_inTable(cardQuestion, ProductiveWoW_cardsToDelete[deckName]) then
			return true
		end
	end
	return false
end

-- Add a card
function ProductiveWoW_addCard(deckName, question, answer)
	local nextId = ProductiveWoW_getDeckNextCardId(deckName)
	ProductiveWoW_getDeckCards(deckName)[nextId] = initializeCardTable()
	ProductiveWoW_setCardQuestion(deckName, nextId, question)
	ProductiveWoW_setCardAnswer(deckName, nextId, answer)
	ProductiveWoW_setDeckNextCardId(deckName, nextId + 1)
end

-- Delete a card by ID
function ProductiveWoW_deleteCardByID(deckName, cardId)
	ProductiveWoW_getDeckCards(deckName)[cardId] = nil
end

-- Delete a card by question
function ProductiveWoW_deleteCardByQuestion(deckName, question)
	for cardId, card in pairs(ProductiveWoW_getDeckCards(deckName)) do
		if ProductiveWoW_getCardQuestion(cardId) == question then
			ProductiveWoW_deleteCardByID(deckName, cardId)
		end
	end
end

-- Increment the views of a card
function ProductiveWoW_onViewedCard(cardId)
	local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(cardId)
	card[NUMBER_OF_TIMES_PLAYED_KEY] = card[NUMBER_OF_TIMES_PLAYED_KEY] + 1
	ProductiveWoW_setCardDateLastPlayed(ProductiveWoW_getCurrentDeckName(), cardId, date("*t"))
end

-- Card was easy
function ProductiveWoW_cardEasyDifficultyChosen(cardId)
	local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(cardId)
	card[NUMBER_OF_TIMES_EASY_KEY] = card[NUMBER_OF_TIMES_EASY_KEY] + 1
	ProductiveWoW_setCardDifficulty(ProductiveWoW_getCurrentDeckName(), cardId, EASY)
end

-- Card was medium difficulty
function ProductiveWoW_cardMediumDifficultyChosen(cardId)
	local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(cardId)
	card[NUMBER_OF_TIMES_MEDIUM_KEY] = card[NUMBER_OF_TIMES_MEDIUM_KEY] + 1
	ProductiveWoW_setCardDifficulty(ProductiveWoW_getCurrentDeckName(), cardId, MEDIUM)
end

-- Card was easy
function ProductiveWoW_cardHardDifficultyChosen(cardId)
	local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(cardId)
	card[NUMBER_OF_TIMES_HARD_KEY] = card[NUMBER_OF_TIMES_HARD_KEY] + 1
	ProductiveWoW_setCardDifficulty(ProductiveWoW_getCurrentDeckName(), cardId, HARD)
end


-- BULK CARD IMPORT FUNCTIONS --
--------------------------------------------------------------------------------------------------------------------------------

-- Import decks from ProductiveWoWDecks.lua
function ProductiveWoW_importDecks()
	for deckName, cards in pairs(ProductiveWoW_cardsToAdd) do
		-- If deck does not already exist, create it
		if ProductiveWoW_getDeck(deckName) == nil then
			ProductiveWoW_addDeck(deckName)
		end
		-- Once deck exists for sure, populate it with newly added cards (if question does not already exist)
		for question, answer in pairs(cards) do
			if not ProductiveWoW_questionAlreadyExistsInDeck(question, deckName) then
				ProductiveWoW_addCard(deckName, question, answer)
			end
		end
		-- Delete cards
		if ProductiveWoW_cardsToDelete[deckName] ~= nil then
			for i, question in ipairs(ProductiveWoW_cardsToDelete[deckName]) do
				ProductiveWoW_deleteCardByQuestion(deckName, question)
			end
		end
	end
end


-- QUIZ FUNCTIONS --
--------------------------------------------------------------------------------------------------------------------------------

local function getDeckSubsetForQuiz()
	local currentDeckName = ProductiveWoW_getCurrentDeckName()
	local subset = {}
	if ProductiveWoW_getDeckDailyNumberOfCards(currentDeckName) == ALL_CARDS then
		-- No limit to the number of cards being tested per day
		return ProductiveWoW_getKeys(ProductiveWoW_getDeckCards(currentDeckName)) -- Table of Card IDs
	else
		local maxLimit = tonumber(ProductiveWoW_getDeckDailyNumberOfCards(currentDeckName))
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
	return ProductiveWoW_getDeckListOfRemainingCardsToday(currentDeckName)
end

-- Draw random next card
function ProductiveWoW_drawRandomNextCard()
	local numCards = ProductiveWoW_tableLength(ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs)
	local currentDeckName = ProductiveWoW_getCurrentDeckName()
	if numCards >= 1 then
		local randomIndex = math.random(1, numCards)
		currentCardID = ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs[randomIndex]
		table.remove(ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs, randomIndex)
		table.remove(ProductiveWoW_getDeckListOfRemainingCardsToday(currentDeckName), randomIndex)
	else
		ProductiveWoW_setDeckCompletedForToday(ProductiveWoW_getCurrentDeckName())
		ProductiveWoW_showMainMenu()
		print("Congratulations, you completed this for today.")
	end
end

-- Begin quiz
function ProductiveWoW_beginQuiz()
	local currentDeckName = ProductiveWoW_getCurrentDeckName()
	-- Load the subset of cards to be quizzed on
	ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs = getDeckSubsetForQuiz()
	if ProductiveWoW_isDeckNotPlayedYetToday(currentDeckName) then
		setDeckStartedToday(currentDeckName, ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs)
	end
	ProductiveWoW_drawRandomNextCard()
end


--============================================================================================================================--


-- Required to run in this block to ensure that saved variables are loaded before this code runs
EventUtil.ContinueOnAddOnLoaded(ProductiveWoW_ADDON_NAME, function()

	-- DEBUG AND DEV ONLY
	if resetSavedVariables == true then
		ProductiveWoWSavedSettings = {[CURRENTLY_SELECTED_DECK_KEY] = nil}
		ProductiveWoWData = {[DECKS_KEY] = {}}
	end

	-- Import decks from ProductiveWoWDecks.lua
	ProductiveWoW_importDecks()

	-- For now this checks if it's a new day, and the number of cards remaining to play for today needs to be reset
	-- It also checks if new values were added to decks from newer versions of this addon so that decks that were saved in older
	-- versions will not cause any bugs
	updateDeckValues()
	-- Update cards with new keys added since newer versions of the addon
	updateCardValues()

	-- SLASH COMMANDS --
	-- SLASH_ prefix is required and used by WoW to find the slash commands automatically. These variables have to be global
	SLASH_ProductiveWoW1 = "/productivewow"
	SLASH_ProductiveWoW2 = "/flashcards"
	SLASH_ProductiveWoW3 = "/flashcard"
	SLASH_ProductiveWoW4 = "/fc"
	SlashCmdList[ProductiveWoW_ADDON_NAME] = function()
		if ProductiveWoW_anyFrameIsShown() then
			ProductiveWoW_hideAllFrames()
		else
			ProductiveWoW_showMainMenu()
		end
	end

	-- -- OPTIONS TAB -- Currently not used
	-- -- Options config panel
	-- -- Parent layout
	-- local category = Settings.RegisterVerticalLayoutCategory("ProductiveWoW")

	-- -- Add settings
	-- -- Open main menu button


	-- Settings.RegisterAddOnCategory(category)

end)


-- UNIT TESTS --
--============================================================================================================================--


if runUnitTests == true then

	-- ProductiveWoWUtilities.lua Unit Tests --
	local function ProductiveWoW_tableIsArray_testValueIsArray()
		local testTable = {"A", {}, true, 1}
		local testResult = ProductiveWoW_tableIsArray(testTable) == true
		print("tableIsArray_testValueIsArray() passed: " .. tostring(testResult))
	end

	local function ProductiveWoW_tableIsArray_testValueIsNotArray()
		local testTable = {"A", {}, true, [5] = 2}
		local testResult = ProductiveWoW_tableIsArray(testTable) == false
		print("tableIsArray_testValueIsNotArray() passed: " .. tostring(testResult))
	end

	local function ProductiveWoW_tableLength_returnsZeroOnEmptyTable()
		local testTable = {}
		local tableLength = ProductiveWoW_tableLength(testTable)
		local testResult = tableLength == 0
		print("tableLength_returnsZeroOnEmptyTable() passed: " .. tostring(testResult))
	end

	local function ProductiveWoW_tableLength_returnsCorrectCount()
		local testTable = {1, "A", true, {}}
		local tableLength = ProductiveWoW_tableLength(testTable)
		local testResult = tableLength == 4
		print("tableLength_returnsCorrectCount() passed: " .. tostring(testResult))
	end

	local function ProductiveWoW_inTableKeys_valueNotInKeys()
		local testTable = {[1] = 2, ["A"] = "B"}
		local testValue = "FAIL"
		local testResult = ProductiveWoW_inTableKeys(testValue, testTable) == false
		print("inTableKeys_valueNotInKeys() passed: " .. tostring(testResult))
	end

	local function ProductiveWoW_inTableKeys_stringValueInKeys()
		local testTable = {[1] = 2, ["A"] = "B"}
		local testValue = "A"
		local testResult = ProductiveWoW_inTableKeys(testValue, testTable) == true
		print("inTableKeys_stringValueInKeys() passed: " .. tostring(testResult))
	end

	ProductiveWoW_tableIsArray_testValueIsArray()
	ProductiveWoW_tableIsArray_testValueIsNotArray()
	ProductiveWoW_tableLength_returnsZeroOnEmptyTable()
	ProductiveWoW_tableLength_returnsCorrectCount()
	ProductiveWoW_inTableKeys_valueNotInKeys()
	ProductiveWoW_inTableKeys_stringValueInKeys()

end