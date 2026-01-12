-- v1.3.4

-- DEV AND DEBUG ONLY --
local resetSavedVariables = false -- Reset ProductiveWoWData and ProductiveWoWSavedSettings
local runUnitTests = false


-- INITIALIZE VARIABLES --
-- GLOBALS --
--------------------------------------------------------------------------------------------------------------------------------
ProductiveWoW_ADDON_NAME = "ProductiveWoW"
ProductiveWoW_ADDON_VERSION = "v1.3.4"


-- CONSTANTS --
--------------------------------------------------------------------------------------------------------------------------------
ProductiveWoW_EASY = "easy" -- Constant string value representing the Easy difficulty of a card
ProductiveWoW_MEDIUM = "medium" -- Constant string value representing the Medium difficulty of a card
ProductiveWoW_HARD = "hard" -- Constant string value representing the Hard difficulty of a card
local NEW_DECK_DATE = date("*t", time() - 180000) -- About 2 days before today. This is the initial value of deck["date last played"] when a new deck is created and it has to be 2 days before so that its status is set to "Not Played Today"
local ALL_CARDS = 1000000 -- Test on all cards per day
local DEFAULT_ROW_SCALE = 0.5 -- 50% of max allowed row scale
local DEFAULT_FLASHCARD_FONT_SIZE = 12
local FLASHCARD_DEFAULT_WIDTH = 450
local FLASHCARD_DEFAULT_HEIGHT = 250
local REMINDER_SOUND = SOUNDKIT.TELL_MESSAGE
-- All variables with _KEY contain the string value used as the key in some table
local DECKS_KEY = "decks"
local ADDON_VERSION_KEY = "addon version"
local CURRENTLY_SELECTED_DECK_KEY = "currently selected deck"
local ROW_SCALE_KEY = "row scale"
local FLASHCARD_FONT_SIZE_KEY = "flashcard font size"
local FLASHCARD_WIDTH_KEY = "flashcard width"
local FLASHCARD_HEIGHT_KEY = "flashcard height"
local ENABLE_REMINDERS_KEY = "enable reminders"
local FLIP_QUESTION_ANSWER_KEY = "flip question answer"
local REMINDER_KEY = "reminders"
local CARDS_KEY = "cards"
local DECK_LEVEL_KEY = "level"
local DECK_EXPERIENCE_KEY = "experience" -- Resets to 0 after each level up, not cumulative across levels
local QUESTION_KEY = "question"
local ANSWER_KEY = "answer"
local DIFFICULTY_KEY = "difficulty"
local CARD_TYPE_KEY = "card type"
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
-- Deck Reminders
ProductiveWoW_REMINDERS = {}
ProductiveWoW_REMINDERS.ON_FLIGHT_PATH = "On Flight Path Taken"
ProductiveWoW_REMINDERS.On_QUEST_ACCEPTED = "On Quest Accepted"
ProductiveWoW_REMINDERS.ON_QUEST_TURN_IN = "On Quest Turn In"
ProductiveWoW_REMINDERS.ON_PLAYER_LEVEL_UP = "On Level Up"
-- Deck experience values
ProductiveWoW_DECK_EXPERIENCE = {}
ProductiveWoW_DECK_EXPERIENCE.EASY = 5
ProductiveWoW_DECK_EXPERIENCE.MEDIUM = 10
ProductiveWoW_DECK_EXPERIENCE.HARD = 20
ProductiveWoW_DECK_EXPERIENCE.MEDIUM_TO_EASY = 30
ProductiveWoW_DECK_EXPERIENCE.HARD_TO_MEDIUM = 50
ProductiveWoW_DECK_EXPERIENCE.HARD_TO_EASY = 100
ProductiveWoW_DECK_EXPERIENCE.TYPED_IN_CORRECT_ANSWER = 50
-- Deck level experience requirements
local DECK_LEVELS = {[1]=0, [2]=500, [3]=1000, [4]=2000, [5]=5000, [6]=10000, [7]=17000, [8]=27000, [9]=40000, [10]=100000}
DECK_LEVELS.MAX_LEVEL = ProductiveWoW_getMax(ProductiveWoW_getKeys(DECK_LEVELS))
-- Card types
ProductiveWoW_CARD_TYPES = {}
ProductiveWoW_CARD_TYPES.BASIC = "Basic"
ProductiveWoW_CARD_TYPES.TYPE_IN_ANSWER = "Type in Answer"



-- DECK VARIABLES --
--------------------------------------------------------------------------------------------------------------------------------
local deckTableDefaultValues = {[CARDS_KEY] = {}, [NEXT_CARD_ID_KEY] = 1, [STARTED_TODAY_KEY] = false, [COMPLETED_TODAY_KEY] = false,
								[DATE_LAST_PLAYED_KEY] = NEW_DECK_DATE, [LIST_OF_CARDS_REMAINING_TODAY_KEY] = {},
								[DAILY_NUMBER_OF_CARDS_KEY] = 50, [NUMBER_OF_TIMES_PLAYED_KEY] = 0, [REMINDER_KEY] = {},
								[DECK_LEVEL_KEY] = 1, [DECK_EXPERIENCE_KEY] = 0}

-- CARD VARIABLES -- 
--------------------------------------------------------------------------------------------------------------------------------
local cardTableDefaultValues = {[QUESTION_KEY] = "", [ANSWER_KEY] = "", [DIFFICULTY_KEY] = ProductiveWoW_HARD, [DATE_LAST_PLAYED_KEY] = NEW_DECK_DATE,
								[NUMBER_OF_TIMES_PLAYED_KEY] = 0, [NUMBER_OF_TIMES_EASY_KEY] = 0, [NUMBER_OF_TIMES_MEDIUM_KEY] = 0,
								[NUMBER_OF_TIMES_HARD_KEY] = 0, [CARD_TYPE_KEY] = ProductiveWoW_CARD_TYPES.BASIC}

-- QUIZ VARIABLES -- 
--------------------------------------------------------------------------------------------------------------------------------
ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs = {} -- When you press "Go" to start the quiz, this table stores the subset of Card IDs from the deck that is being quizzed
ProductiveWoW_cardIdsNotCurrentlyBeingQuizzed = {} -- List of card IDs in deck that are not part of the daily subset being quizzed
local currentCardID = nil -- Tracks the Card ID of the current card being shown to the user in the quiz
local timeWhenDeckCanBePlayedAgain = 10 -- Each new day, the deck can be played again at 10am regardless if 24h has passed or not


-- OTHER --
--------------------------------------------------------------------------------------------------------------------------------
local savedSettingsTableInitialValues = {[ADDON_VERSION_KEY] = ProductiveWoW_ADDON_VERSION,
										 [CURRENTLY_SELECTED_DECK_KEY] = nil,
										 [ROW_SCALE_KEY] = DEFAULT_ROW_SCALE,
									     [FLASHCARD_FONT_SIZE_KEY] = DEFAULT_FLASHCARD_FONT_SIZE,
									     [FLASHCARD_WIDTH_KEY] = FLASHCARD_DEFAULT_WIDTH,
									 	 [FLASHCARD_HEIGHT_KEY] = FLASHCARD_DEFAULT_HEIGHT,
									 	 [ENABLE_REMINDERS_KEY] = true,
									 	 [FLIP_QUESTION_ANSWER_KEY] = false}
local dataTableInitialValues = {[DECKS_KEY] = {}}


--============================================================================================================================--


-- LOAD SAVED VARIABLES --
ProductiveWoWSavedSettings = ProductiveWoWSavedSettings or savedSettingsTableInitialValues
ProductiveWoWData = ProductiveWoWData or dataTableInitialValues


--============================================================================================================================--


-- FUNCTION DEFINITIONS --

-- GENERAL FUNCTIONS --
--------------------------------------------------------------------------------------------------------------------------------

-- If new keys were added to the saved settings table in newer versions of the addon, add the new keys and initialize them to the default values
local function updateSavedSettingsTableWithNewKeys()
	for key, defaultValue in pairs(savedSettingsTableInitialValues) do
		if ProductiveWoWSavedSettings[key] == nil then
			ProductiveWoWSavedSettings[key] = defaultValue
		end
	end
end

-- Print alert/reminder in red text
function ProductiveWoW_printReminder(message)
	print("|cFFFF0000" .. message .. "|r")
end


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
	local deck = ProductiveWoW_getDeck(deckName)
	if deck ~= nil then
		return ProductiveWoWData[DECKS_KEY][deckName][CARDS_KEY]
	else
		return nil
	end
end

-- Get deck's next Card ID
function ProductiveWoW_getDeckNextCardId(deckName)
	return ProductiveWoW_getDeck(deckName)[NEXT_CARD_ID_KEY]
end

-- Get deck daily number of cards
function ProductiveWoW_getDeckDailyNumberOfCards(deckName)
	return ProductiveWoW_getDeck(deckName)[DAILY_NUMBER_OF_CARDS_KEY]
end

-- Get deck started today yet flag
function ProductiveWoW_getDeckStartedToday(deckName)
	return ProductiveWoW_getDeck(deckName)[STARTED_TODAY_KEY]
end

-- Get deck completed today flag
function ProductiveWoW_getDeckCompletedToday(deckName)
	return ProductiveWoW_getDeck(deckName)[COMPLETED_TODAY_KEY]
end

-- Get deck list of remaining cards to be tested today
function ProductiveWoW_getDeckListOfRemainingCardsToday(deckName)
	local remainingCards = ProductiveWoW_getDeck(deckName)[LIST_OF_CARDS_REMAINING_TODAY_KEY]
	-- Return copy of the table rather than reference to it
	return ProductiveWoW_tableShallowCopy(remainingCards)
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
	local deckCards = ProductiveWoW_getDeckCards(deckName)
	if deckCards ~= nil then
		for cardId, contents in pairs(deckCards) do
			if contents[QUESTION_KEY] == question then
				return contents
			end
		end
	else
		return nil
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

-- Get card type
function ProductiveWoW_getCardType(deckName, cardId)
	if deckName ~= nil and cardId ~= nil then
		local card = ProductiveWoW_getCardByID(deckName, cardId)
		if card ~= nil then
			return card[CARD_TYPE_KEY]
		else
			return nil
		end
	end
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

-- Get number of times played
function ProductiveWoW_getCardNumberOfTimesPlayed(deckName, cardId)
	return ProductiveWoW_getCardByID(deckName, cardId)[NUMBER_OF_TIMES_PLAYED_KEY]
end

-- Get number of times Easy was chosen
function ProductiveWoW_getCardNumberOfTimesEasy(deckName, cardId)
	return ProductiveWoW_getCardByID(deckName, cardId)[NUMBER_OF_TIMES_EASY_KEY]
end

-- Get number of times Medium was chosen
function ProductiveWoW_getCardNumberOfTimesMedium(deckName, cardId)
	return ProductiveWoW_getCardByID(deckName, cardId)[NUMBER_OF_TIMES_MEDIUM_KEY]
end

-- Get number of times Hard was chosen
function ProductiveWoW_getCardNumberOfTimesHard(deckName, cardId)
	return ProductiveWoW_getCardByID(deckName, cardId)[NUMBER_OF_TIMES_HARD_KEY]
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

-- Get Saved Settings addon version
function ProductiveWoW_getSavedSettingsAddonVersion()
	return ProductiveWoWSavedSettings[ADDON_VERSION_KEY]
end

-- Get Saved Settings row scale value
function ProductiveWoW_getSavedSettingsRowScale()
	return ProductiveWoWSavedSettings[ROW_SCALE_KEY]
end

-- Get Saved Settings flashcard font size value
function ProductiveWoW_getSavedSettingsFlashcardFontSize()
	return ProductiveWoWSavedSettings[FLASHCARD_FONT_SIZE_KEY]
end

-- Get Saved Settings flashcard width value
function ProductiveWoW_getSavedSettingsFlashcardWidth()
	return ProductiveWoWSavedSettings[FLASHCARD_WIDTH_KEY]
end

-- Get Saved Settings flashcard height value
function ProductiveWoW_getSavedSettingsFlashcardHeight()
	return ProductiveWoWSavedSettings[FLASHCARD_HEIGHT_KEY]
end

-- Get Saved Settings reminders enabled
function ProductiveWoW_getSavedSettingsRemindersEnabled()
	return ProductiveWoWSavedSettings[ENABLE_REMINDERS_KEY]
end

-- Get Saved Settings flip question answer
function ProductiveWoW_getSavedSettingsFlipQuestionAnswer()
	return ProductiveWoWSavedSettings[FLIP_QUESTION_ANSWER_KEY]
end

-- Get deck's list of reminders
function ProductiveWoW_getDeckRemindersTable(deckName)
	return ProductiveWoW_getDeck(deckName)[REMINDER_KEY]
end

-- Get deck reminder by reminder key, true if it is set, false if it's not set
function ProductiveWoW_getDeckReminder(deckName, reminder)
	local reminderName = ProductiveWoW_REMINDERS[reminder]
	local reminderValue = ProductiveWoW_getDeckRemindersTable(deckName)[reminderName]
	if reminderValue == nil or reminderValue == false then
		return false
	end
	return true
end

-- Get if a deck has a reminder set on flight path taken
function ProductiveWoW_getDeckReminderOnFlightPath(deckName)
	local flightPathReminderKey = ProductiveWoW_getKeyAsString(ProductiveWoW_REMINDERS, ProductiveWoW_REMINDERS.ON_FLIGHT_PATH)
	return ProductiveWoW_getDeckReminder(deckName, flightPathReminderKey)
end

-- Get if a deck has a reminder set on quest turn in
function ProductiveWoW_getDeckReminderOnQuestTurnIn(deckName)
	local questTurnInReminderKey = ProductiveWoW_getKeyAsString(ProductiveWoW_REMINDERS, ProductiveWoW_REMINDERS.ON_QUEST_TURN_IN)
	return ProductiveWoW_getDeckReminder(deckName, questTurnInReminderKey)
end

-- Get if a deck has a reminder set on quest accepted
function ProductiveWoW_getDeckReminderOnQuestAccepted(deckName)
	local questAcceptedReminderKey = ProductiveWoW_getKeyAsString(ProductiveWoW_REMINDERS, ProductiveWoW_REMINDERS.On_QUEST_ACCEPTED)
	return ProductiveWoW_getDeckReminder(deckName, questAcceptedReminderKey)
end

-- Get if a deck has a reminder set on player level up
function ProductiveWoW_getDeckReminderOnPlayerLevelUp(deckName)
	local playerLevelUpKey = ProductiveWoW_getKeyAsString(ProductiveWoW_REMINDERS, ProductiveWoW_REMINDERS.ON_PLAYER_LEVEL_UP)
	return ProductiveWoW_getDeckReminder(deckName, playerLevelUpKey)
end

-- Check if any decks have reminders when flight path is taken
function ProductiveWoW_anyReminderOnFlightPathTakenExists()
	for deckName, deckTable in pairs(ProductiveWoW_getAllDecks()) do
		if ProductiveWoW_getDeckReminderOnFlightPath(deckName) == true then
			return true
		end
	end
	return false
end

-- Check if any decks have reminders when a quest is turned in
function ProductiveWoW_anyReminderOnQuestTurnInExists()
	for deckName, deckTable in pairs(ProductiveWoW_getAllDecks()) do
		if ProductiveWoW_getDeckReminderOnQuestTurnIn(deckName) == true then
			return true
		end
	end
	return false
end

-- Check if any decks have reminders when a quest is turned in
function ProductiveWoW_anyReminderOnQuestAcceptedExists()
	for deckName, deckTable in pairs(ProductiveWoW_getAllDecks()) do
		if ProductiveWoW_getDeckReminderOnQuestAccepted(deckName) == true then
			return true
		end
	end
	return false
end


-- Check if any decks have reminders when the player levels up
function ProductiveWoW_anyReminderOnPlayerLevelUpExists()
	for deckName, deckTable in pairs(ProductiveWoW_getAllDecks()) do
		if ProductiveWoW_getDeckReminderOnPlayerLevelUp(deckName) == true then
			return true
		end
	end
	return false
end

-- Get deck level
function ProductiveWoW_getDeckLevel(deckName)
	return ProductiveWoW_getDeck(deckName)[DECK_LEVEL_KEY]
end

-- Get deck experience accumulated for current level
function ProductiveWoW_getDeckExperienceForCurrentLevel(deckName)
	return ProductiveWoW_getDeck(deckName)[DECK_EXPERIENCE_KEY]
end

-- Get next deck level's exp requirements
function ProductiveWoW_getExperienceRequiredForNextDeckLevel(currentDeckLevel)
	if currentDeckLevel ~= DECK_LEVELS.MAX_LEVEL then
		return DECK_LEVELS[currentDeckLevel + 1]
	end
	return 0
end

-- SETTERS --
--------------------------------------------------------------------------------------------------------------------------------

-- Set the currently selected deck
function ProductiveWoW_setCurrentlySelectedDeck(deckName)
	ProductiveWoWSavedSettings[CURRENTLY_SELECTED_DECK_KEY] = deckName
end

-- Rename deck
function ProductiveWoW_renameDeck(oldDeckName, newDeckName)
	local oldDeck = ProductiveWoW_getDeck(oldDeckName)
	if oldDeck ~= nil then
		ProductiveWoWData[DECKS_KEY][newDeckName] = ProductiveWoWData[DECKS_KEY][oldDeckName]
		ProductiveWoWData[DECKS_KEY][oldDeckName] = nil
		if ProductiveWoW_getCurrentDeckName() == oldDeckName then
			ProductiveWoW_setCurrentlySelectedDeck(newDeckName)
		end
	else
		return nil
	end
end

-- Set deck done for today
function ProductiveWoW_setDeckCompletedToday(deckName)
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

-- Set deck reminder by key
function ProductiveWoW_setDeckReminder(deckName, reminder, newValue)
	local currentValue = ProductiveWoW_getDeckReminder(deckName, reminder)
	local reminderName = ProductiveWoW_REMINDERS[reminder]
	ProductiveWoW_getDeckRemindersTable(deckName)[reminderName] = newValue
end

-- Reset deck reminders
function ProductiveWoW_resetDeckReminders(deckName)
	ProductiveWoW_getDeck(deckName)[REMINDER_KEY] = {}
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

-- Set card type
function ProductiveWoW_setCardType(deckName, cardId, cardType)
	if ProductiveWoW_inTable(cardType, ProductiveWoW_CARD_TYPES) then
		ProductiveWoW_getCardByID(deckName, cardId)[CARD_TYPE_KEY] = cardType
	else
		error("Attempted to set invalid card type on card ID: " .. tostring(cardId))
	end
end

-- Set Saved Settings addon version
function ProductiveWoW_setSavedSettingsAddonVersion(newVersion)
	ProductiveWoWSavedSettings[ADDON_VERSION_KEY] = newVersion
end

-- Set Saved Settings row scale value
function ProductiveWoW_setSavedSettingsRowScale(newRowScale)
	ProductiveWoWSavedSettings[ROW_SCALE_KEY] = newRowScale
end

-- Set Saved Settings flashcard font size value
function ProductiveWoW_setSavedSettingsFlashcardFontSize(newFontSize)
	ProductiveWoWSavedSettings[FLASHCARD_FONT_SIZE_KEY] = newFontSize
end

-- Set Saved Settings flashcard width value
function ProductiveWoW_setSavedSettingsFlashcardWidth(newWidth)
	ProductiveWoWSavedSettings[FLASHCARD_WIDTH_KEY] = newWidth
end

-- Set Saved Settings flashcard height value
function ProductiveWoW_setSavedSettingsFlashcardHeight(newHeight)
	ProductiveWoWSavedSettings[FLASHCARD_HEIGHT_KEY] = newHeight
end

-- Set Saved Settings reminders enabled
function ProductiveWoW_setSavedSettingsRemindersEnabled(newValue)
	ProductiveWoWSavedSettings[ENABLE_REMINDERS_KEY] = newValue
end

-- Set Saved Settings flip question answer
function ProductiveWoW_setSavedSettingsFlipQuestionAnswer(newValue)
	ProductiveWoWSavedSettings[FLIP_QUESTION_ANSWER_KEY] = newValue
end

-- Set deck level
function ProductiveWoW_setDeckLevel(deckName, level)
	ProductiveWoW_getDeck(deckName)[DECK_LEVEL_KEY] = level
end

-- Set deck experience
function ProductiveWoW_setDeckExperience(deckName, experience)
	ProductiveWoW_getDeck(deckName)[DECK_EXPERIENCE_KEY] = experience
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
	-- If flag is explicitly false then it's already determined to be not played yet today
	if ProductiveWoW_getDeckStartedToday(deckName) == false then
		return true
	else
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

-- Send out reminders to do the deck
function ProductiveWoW_sendDeckReminder(deckName)
	ProductiveWoW_printReminder(ProductiveWoW_ADDON_NAME .. ": Reminder to study deck - " .. deckName)
end

-- Send reminders when flight path taken for all decks that have it set
function ProductiveWoW_sendDeckRemindersOnFlightPathTaken()
	local anyReminderSent = false
	for deckName, deckTable in pairs(ProductiveWoW_getAllDecks()) do
		if ProductiveWoW_getDeckReminderOnFlightPath(deckName) == true and ProductiveWoW_getDeckCompletedToday(deckName) == false then
			ProductiveWoW_sendDeckReminder(deckName)
			anyReminderSent = true
		end
	end
	if anyReminderSent == true then
		PlaySound(REMINDER_SOUND)
	end
end

-- Send reminders when quest is turned in for all decks that have it set
function ProductiveWoW_sendDeckRemindersOnQuestTurnIn()
	local anyReminderSent = false
	for deckName, deckTable in pairs(ProductiveWoW_getAllDecks()) do
		if ProductiveWoW_getDeckReminderOnQuestTurnIn(deckName) == true and ProductiveWoW_getDeckCompletedToday(deckName) == false then
			ProductiveWoW_sendDeckReminder(deckName)
			anyReminderSent = true
		end
	end
	if anyReminderSent == true then
		PlaySound(REMINDER_SOUND)
	end
end

-- Send reminders when quest is accepted for all decks that have it set
function ProductiveWoW_sendDeckRemindersOnQuestAccepted()
	local anyReminderSent = false
	for deckName, deckTable in pairs(ProductiveWoW_getAllDecks()) do
		if ProductiveWoW_getDeckReminderOnQuestAccepted(deckName) == true and ProductiveWoW_getDeckCompletedToday(deckName) == false then
			ProductiveWoW_sendDeckReminder(deckName)
			anyReminderSent = true
		end
	end
	if anyReminderSent == true then
		PlaySound(REMINDER_SOUND)
	end
end

-- Send reminders when the player levels up for all decks that have it set
function ProductiveWoW_sendDeckRemindersPlayerLevelUp()
	local anyReminderSent = false
	for deckName, deckTable in pairs(ProductiveWoW_getAllDecks()) do
		if ProductiveWoW_getDeckReminderOnPlayerLevelUp(deckName) == true and ProductiveWoW_getDeckCompletedToday(deckName) == false then
			ProductiveWoW_sendDeckReminder(deckName)
			anyReminderSent = true
		end
	end
	if anyReminderSent == true then
		PlaySound(REMINDER_SOUND)
	end
end

-- Level up the deck
function ProductiveWoW_deckLevelUp(deckName)
	local currentLevel = ProductiveWoW_getDeckLevel(deckName)
	if currentLevel ~= DECK_LEVELS.MAX_LEVEL then
		ProductiveWoW_setDeckLevel(deckName, currentLevel + 1)
		print("Congratulations! You leveled up " .. deckName .. " to level " .. tostring(currentLevel + 1) .. "!")
	end
end

-- Add deck experience
function ProductiveWoW_addDeckExperience(deckName, experience)
	local currentExperience = ProductiveWoW_getDeckExperienceForCurrentLevel(deckName)
	local newExperience = currentExperience + experience
	local currentDeckLevel = ProductiveWoW_getDeckLevel(deckName)
	if currentDeckLevel == DECK_LEVELS.MAX_LEVEL then
		ProductiveWoW_setDeckExperience(deckName, 0)
		return
	end
	if newExperience >= ProductiveWoW_getExperienceRequiredForNextDeckLevel(currentDeckLevel) then
		local leftoverExperience = newExperience - ProductiveWoW_getExperienceRequiredForNextDeckLevel(currentDeckLevel)
		ProductiveWoW_deckLevelUp(deckName)
		ProductiveWoW_setDeckExperience(deckName, leftoverExperience)
	else
		ProductiveWoW_getDeck(deckName)[DECK_EXPERIENCE_KEY] = newExperience
	end
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
function ProductiveWoW_addCard(deckName, question, answer, cardType)
	local nextId = ProductiveWoW_getDeckNextCardId(deckName)
	ProductiveWoW_getDeckCards(deckName)[nextId] = initializeCardTable()
	ProductiveWoW_setCardQuestion(deckName, nextId, question)
	ProductiveWoW_setCardAnswer(deckName, nextId, answer)
	ProductiveWoW_setCardType(deckName, nextId, cardType)
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
function ProductiveWoW_onPlayedCard(cardId)
	local deckName = ProductiveWoW_getCurrentDeckName()
	local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(cardId)
	card[NUMBER_OF_TIMES_PLAYED_KEY] = ProductiveWoW_getCardNumberOfTimesPlayed(deckName, cardId) + 1
	ProductiveWoW_setCardDateLastPlayed(deckName, cardId, date("*t"))
	-- Remove from cards remaining to be played today
	ProductiveWoW_removeByValue(cardId, ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs)
	ProductiveWoW_removeByValue(cardId, ProductiveWoW_getDeckListOfRemainingCardsToday(deckName))
end

-- Card was easy
function ProductiveWoW_cardEasyDifficultyChosen(cardId)
	local deckName = ProductiveWoW_getCurrentDeckName()
	local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(cardId)
	local previousDifficulty = ProductiveWoW_getCardDifficulty(deckName, cardId)
	card[NUMBER_OF_TIMES_EASY_KEY] = ProductiveWoW_getCardNumberOfTimesEasy(deckName, cardId) + 1
	ProductiveWoW_setCardDifficulty(deckName, cardId, ProductiveWoW_EASY)
	if previousDifficulty == ProductiveWoW_MEDIUM then
		ProductiveWoW_addDeckExperience(deckName, ProductiveWoW_DECK_EXPERIENCE.MEDIUM_TO_EASY)
	elseif previousDifficulty == ProductiveWoW_HARD then
		ProductiveWoW_addDeckExperience(deckName, ProductiveWoW_DECK_EXPERIENCE.HARD_TO_EASY)
	else
		ProductiveWoW_addDeckExperience(deckName, ProductiveWoW_DECK_EXPERIENCE.EASY)
	end
	ProductiveWoW_onPlayedCard(cardId)
end

-- Card was medium difficulty
function ProductiveWoW_cardMediumDifficultyChosen(cardId)
	local deckName = ProductiveWoW_getCurrentDeckName()
	local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(cardId)
	local previousDifficulty = ProductiveWoW_getCardDifficulty(deckName, cardId)
	card[NUMBER_OF_TIMES_MEDIUM_KEY] = ProductiveWoW_getCardNumberOfTimesMedium(deckName, cardId) + 1
	ProductiveWoW_setCardDifficulty(deckName, cardId, ProductiveWoW_MEDIUM)
	if previousDifficulty == ProductiveWoW_EASY then
		ProductiveWoW_addDeckExperience(deckName, ProductiveWoW_DECK_EXPERIENCE.EASY)
	elseif previousDifficulty == ProductiveWoW_HARD then
		ProductiveWoW_addDeckExperience(deckName, ProductiveWoW_DECK_EXPERIENCE.HARD_TO_MEDIUM)
	else
		ProductiveWoW_addDeckExperience(deckName, ProductiveWoW_DECK_EXPERIENCE.MEDIUM)
	end
	ProductiveWoW_onPlayedCard(cardId)
end

-- Card was easy
function ProductiveWoW_cardHardDifficultyChosen(cardId)
	local deckName = ProductiveWoW_getCurrentDeckName()
	local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(cardId)
	local previousDifficulty = ProductiveWoW_getCardDifficulty(deckName, cardId)
	card[NUMBER_OF_TIMES_HARD_KEY] = ProductiveWoW_getCardNumberOfTimesHard(deckName, cardId) + 1
	ProductiveWoW_setCardDifficulty(deckName, cardId, ProductiveWoW_HARD)
	if previousDifficulty == ProductiveWoW_EASY then
		ProductiveWoW_addDeckExperience(deckName, ProductiveWoW_DECK_EXPERIENCE.EASY)
	elseif previousDifficulty == ProductiveWoW_MEDIUM then
		ProductiveWoW_addDeckExperience(deckName, ProductiveWoW_DECK_EXPERIENCE.MEDIUM)
	else
		ProductiveWoW_addDeckExperience(deckName, ProductiveWoW_DECK_EXPERIENCE.HARD)
	end
	ProductiveWoW_onPlayedCard(cardId)
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
				ProductiveWoW_addCard(deckName, question, answer, ProductiveWoW_CARD_TYPES.BASIC)
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
		-- Unlimited cards used to be denoted by maxLimit being equal to -1, for backwards compatibility where older decks may be using -1 still, this fixes issues caused by it
		if maxLimit < 0 then
			maxLimit = 1000000
		end
		-- Prioritize hard
		local hardCardIds = getCardIdsByDifficulty(currentDeckName, ProductiveWoW_HARD)
		local numberOfHardCards = ProductiveWoW_tableLength(hardCardIds)
		if numberOfHardCards == maxLimit then
			return hardCardIds
		elseif numberOfHardCards > maxLimit then
			subset = ProductiveWoW_getRandomSubsetOfArrayTable(hardCardIds, maxLimit)
			return subset
		else
			-- If it's smaller than maxLimit we need to add some Medium difficulty cards
			subset = hardCardIds
			local remainingLimit = maxLimit - numberOfHardCards
			local mediumCardIds = getCardIdsByDifficulty(currentDeckName, ProductiveWoW_MEDIUM)
			local numberOfMediumCards = ProductiveWoW_tableLength(mediumCardIds)
			if numberOfMediumCards == remainingLimit then
				subset = ProductiveWoW_mergeTables(subset, mediumCardIds)
				return subset
			elseif numberOfMediumCards > remainingLimit then
				local mediumCardsSubset = ProductiveWoW_getRandomSubsetOfArrayTable(mediumCardIds, remainingLimit)
				subset = ProductiveWoW_mergeTables(subset, mediumCardsSubset)
				return subset
			else
				-- If it's still smaller, add in the Easy cards
				subset = ProductiveWoW_mergeTables(subset, mediumCardIds)
				remainingLimit = remainingLimit - numberOfMediumCards
				local easyCardIds = getCardIdsByDifficulty(currentDeckName, ProductiveWoW_EASY)
				local numberOfEasyCards = ProductiveWoW_tableLength(easyCardIds)
				if numberOfEasyCards <= remainingLimit then
					-- Since this is the final difficulty, we can just add all the easy cards if it's equal or less than the remaining limit
					subset = ProductiveWoW_mergeTables(subset, easyCardIds)
					return subset
				else
					-- If there are more easy cards than the remaining limit allows, get a random subset of them
					local easyCardsSubset = ProductiveWoW_getRandomSubsetOfArrayTable(easyCardIds, remainingLimit)
					subset = ProductiveWoW_mergeTables(subset, easyCardsSubset)
					return subset
				end
			end
		end
	end
end

-- Draw random next card
function ProductiveWoW_drawRandomNextCard()
	local numCards = ProductiveWoW_tableLength(ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs)
	local currentDeckName = ProductiveWoW_getCurrentDeckName()
	if numCards >= 1 then
		-- It's possible that this card was deleted in the meantime so do a quick check to see that it still exists and if not, replace it
		local cardHasBeenDeleted = true
		while cardHasBeenDeleted == true do
			local randomIndex = math.random(1, numCards)
			currentCardID = ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs[randomIndex]
			local currentCard = ProductiveWoW_getCardByID(currentDeckName, currentCardID)
			if currentCard ~= nil then
				cardHasBeenDeleted = false
			else
				-- Remove the deleted card from the subset
				ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs[randomIndex] = nil
				-- Above needs to be contiguous array
				ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs = ProductiveWoW_sparseArrayIntoContiguousArray(ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs)
				-- Replace it with a card that has not been deleted
				local replacementCardId = ProductiveWoW_getRandomCardFromCurrentDeckThatIsNotBeingQuizzed()
				if replacementCardId ~= nil then
					currentCardID = replacementCardId
					return
				end
			end
		end
	else
		ProductiveWoW_setDeckCompletedToday(ProductiveWoW_getCurrentDeckName())
		ProductiveWoW_showMainMenu()
		print("Congratulations, you completed this for today.")
	end
end

-- Get a random card from the current deck that is not already part of the subset of cards being quizzed
function ProductiveWoW_getRandomCardFromCurrentDeckThatIsNotBeingQuizzed()
	local numCards = ProductiveWoW_tableLength(ProductiveWoW_cardIdsNotCurrentlyBeingQuizzed)
	if numCards >= 1 then
		local randomIndex = math.random(1, numCards)
		local randomCardId = ProductiveWoW_cardIdsNotCurrentlyBeingQuizzed[randomIndex]
		return randomCardId
	end
	return nil
end

-- Begin quiz
function ProductiveWoW_beginQuiz()
	local currentDeckName = ProductiveWoW_getCurrentDeckName()
	if ProductiveWoW_isDeckNotPlayedYetToday(currentDeckName) then
		-- Load the subset of cards to be quizzed on if not yet started deck today
		ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs = getDeckSubsetForQuiz()
		setDeckStartedToday(currentDeckName, ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs)
	else
		-- Pick up where you left off today, for example if you had 10 cards to do today, you did 3 of them in the deck, logged off, logged back in, you'd still have 7 cards left to do
		ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs = ProductiveWoW_getDeckListOfRemainingCardsToday(currentDeckName)
	end
	local allCardIds = ProductiveWoW_getKeys(ProductiveWoW_getDeckCards(ProductiveWoW_getCurrentDeckName()))
	ProductiveWoW_cardIdsNotCurrentlyBeingQuizzed = ProductiveWoW_getElementsOnlyContainedInFirstTable(allCardIds, ProductiveWoW_currentSubsetOfCardsBeingQuizzedIDs)
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

	-- Print changelog message for newly installed version when user runs one of the slash commands
	local userJustUpdatedToNewVersionOfAddon = false
	if ProductiveWoW_getSavedSettingsAddonVersion() == nil or ProductiveWoW_getSavedSettingsAddonVersion() ~= ProductiveWoW_ADDON_VERSION then
		userJustUpdatedToNewVersionOfAddon = true
		ProductiveWoW_setSavedSettingsAddonVersion(ProductiveWoW_ADDON_VERSION)
	end

	-- Do things with CONSTANTS
	table.sort(ProductiveWoW_REMINDERS) -- Sort so that it appears alphabetically in Deck Settings reminder dropdown

	-- Update saved variables tables with any new keys that were added in subsequent versions of the addon
	updateSavedSettingsTableWithNewKeys()

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
			-- Print changelog message for newer versions of the addon just being installed
			if userJustUpdatedToNewVersionOfAddon == true then
				print("ProductiveWoW what's new in version " .. ProductiveWoW_ADDON_VERSION .. ": New Card Type 'Type in Answer' requires you to type in the answer. Go to Modify Deck > Right click a card and select 'Edit Card' then change the card type there. You can also select multiple cards and click 'Bulk Edit'.")
				userJustUpdatedToNewVersionOfAddon = false
			end
		end
	end

end)

















-- UNIT TESTS --
--============================================================================================================================--

local unitTests = {}
if runUnitTests == true then

	local anyFailed = false

	local function toRedText(text)
		return "|cFFFF0000" .. text .. "|r"
	end

	local function toGreenText(text)
		return "|cFF00FF00" .. text .. "|r"
	end

	local function printResult(testResult, callingFunctionName)
		local text = callingFunctionName .. " passed: " .. tostring(testResult)
		if testResult == true then
			print(toGreenText(text))
		else
			anyFailed = true
			print(toRedText(text))
		end
	end

	local function areSetsEqual(set1, set2)
	    if #set1 ~= #set2 then return false end
	    local found = {}
	    for _, v in ipairs(set1) do found[v] = true end
	    for _, v in ipairs(set2) do
	        if not found[v] then return false end
	    end
	    return true
	end

	-- God bless chatGPT

	-- ProductiveWoWUtilities.lua Unit Tests --
	function unitTests.ProductiveWoW_tableIsArray_testValueIsArray()
		local testTable = {"A", {}, true, 1}
		local testResult = ProductiveWoW_tableIsArray(testTable) == true
		printResult(testResult, "tableIsArray_testValueIsArray")
	end

	function unitTests.ProductiveWoW_tableIsArray_testValueIsNotArray()
		local testTable = {"A", {}, true, [5] = 2}
		local testResult = ProductiveWoW_tableIsArray(testTable) == false
		printResult(testResult, "tableIsArray_testValueIsNotArray")
	end

	function unitTests.ProductiveWoW_tableLength_returnsZeroOnEmptyTable()
		local testTable = {}
		local tableLength = ProductiveWoW_tableLength(testTable)
		local testResult = tableLength == 0
		printResult(testResult, "tableLength_returnsZeroOnEmptyTable")
	end

	function unitTests.ProductiveWoW_tableLength_returnsCorrectCount()
		local testTable = {1, "A", true, {}}
		local tableLength = ProductiveWoW_tableLength(testTable)
		local testResult = tableLength == 4
		printResult(testResult, "tableLength_returnsCorrectCount")
	end

	function unitTests.ProductiveWoW_tableLength_returnsCorrectCountWhenTableHasKeys()
		local testTable = {["1"] = 1, ["2"] = "A", ["3"] = true, ["4"] = {}}
		local tableLength = ProductiveWoW_tableLength(testTable)
		local testResult = tableLength == 4
		printResult(testResult, "tableLength_returnsCorrectCountWhenTableHasKeys")
	end

	function unitTests.ProductiveWoW_inTableKeys_valueNotInKeys()
		local testTable = {[1] = 2, ["A"] = "B"}
		local testValue = "B"
		local testResult = ProductiveWoW_inTableKeys(testValue, testTable) == false
		printResult(testResult, "inTableKeys_valueNotInKeys")
	end

	function unitTests.ProductiveWoW_inTableKeys_stringValueInKeys()
		local testTable = {[1] = 2, ["A"] = "B"}
		local testValue = "A"
		local testResult = ProductiveWoW_inTableKeys(testValue, testTable) == true
		printResult(testResult, "inTableKeys_stringValueInKeys")
	end

	function unitTests.ProductiveWoW_inTable_notInTable()
		local testTable = {["1"] = "Not", ["2"] = "in", ["3"] = "table"}
		local testValue = "2"
		local testResult = ProductiveWoW_inTable(testValue, testTable) == false
		printResult(testResult, "inTable_notInTable")
	end

	function unitTests.ProductiveWoW_inTable_stringValueIsInTable()
		local testTable = {"Not", "in", "table"}
		local testValue = "in"
		local testResult = ProductiveWoW_inTable(testValue, testTable) == true
		printResult(testResult, "inTable_stringValueIsInTable")
	end

	function unitTests.ProductiveWoW_removeByValue_removesExistingValue()
	    local tbl = { "apple", "banana", "cherry" }
	    ProductiveWoW_removeByValue("banana", tbl)
	    local testResult = (#tbl == 2 and tbl[1] == "apple" and tbl[2] == "cherry")
	    printResult(testResult, "removeByValue_removesExistingValue()")
	end

	function unitTests.ProductiveWoW_removeByValue_valueNotFound()
	    local tbl = { "apple", "banana", "cherry" }
	    ProductiveWoW_removeByValue("pear", tbl)
	    local testResult = (#tbl == 3 and tbl[1] == "apple" and tbl[2] == "banana" and tbl[3] == "cherry")
	    printResult(testResult, "removeByValue_valueNotFound()")
	end

	function unitTests.ProductiveWoW_removeByValue_removesFirstOnly()
	    local tbl = { "apple", "banana", "apple", "cherry" }
	    ProductiveWoW_removeByValue("apple", tbl)
	    local testResult = (#tbl == 3 and tbl[1] == "banana" and tbl[2] == "apple" and tbl[3] == "cherry")
	    printResult(testResult, "removeByValue_removesFirstOnly()")
	end

	function unitTests.ProductiveWoW_removeByValue_emptyTable()
	    local tbl = {}
	    ProductiveWoW_removeByValue("apple", tbl)
	    local testResult = (#tbl == 0)
	    printResult(testResult, "removeByValue_emptyTable()")
	end

	function unitTests.ProductiveWoW_removeByValue_numericValues()
	    local tbl = {1, 2, 3, 4}
	    ProductiveWoW_removeByValue(3, tbl)
	    local testResult = (#tbl == 3 and tbl[1] == 1 and tbl[2] == 2 and tbl[3] == 4)
	    printResult(testResult, "removeByValue_numericValues()")
	end

	function unitTests.ProductiveWoW_tableShallowCopy_copiesArray()
	    local original = { "a", "b", "c" }
	    local copy = ProductiveWoW_tableShallowCopy(original)
	    local testResult = (#copy == 3 and copy[1] == "a" and copy[2] == "b" and copy[3] == "c")
	    printResult(testResult, "tableShallowCopy_copiesArray()")
	end

	function unitTests.ProductiveWoW_tableShallowCopy_copiesKeyedTable()
	    local original = { x = 10, y = 20 }
	    local copy = ProductiveWoW_tableShallowCopy(original)
	    local testResult = (copy.x == 10 and copy.y == 20)
	    printResult(testResult, "tableShallowCopy_copiesKeyedTable()")
	end

	function unitTests.ProductiveWoW_tableShallowCopy_independentTopLevelValues()
	    local original = { a = 1 }
	    local copy = ProductiveWoW_tableShallowCopy(original)
	    original.a = 99
	    local testResult = (copy.a == 1)
	    printResult(testResult, "tableShallowCopy_independentTopLevelValues()")
	end

	function unitTests.ProductiveWoW_tableShallowCopy_sharedNestedTables()
	    local nested = { n = 5 }
	    local original = { inner = nested }
	    local copy = ProductiveWoW_tableShallowCopy(original)
	    nested.n = 99
	    local testResult = (copy.inner.n == 99)
	    printResult(testResult, "tableShallowCopy_sharedNestedTables()")
	end

	function unitTests.ProductiveWoW_tableShallowCopy_emptyTable()
	    local original = {}
	    local copy = ProductiveWoW_tableShallowCopy(original)
	    local testResult = (type(copy) == "table" and next(copy) == nil)
	    printResult(testResult, "tableShallowCopy_emptyTable()")
	end

	function unitTests.ProductiveWoW_getKeys_arrayOnly()
	    local tbl = { "a", "b", "c" }
	    local keys = ProductiveWoW_getKeys(tbl)
	    local testResult = areSetsEqual(keys, {1, 2, 3})
	    printResult(testResult, "getKeys_arrayOnly()")
	end

	function unitTests.ProductiveWoW_getKeys_keyedOnly()
	    local tbl = { x = 10, y = 20 }
	    local keys = ProductiveWoW_getKeys(tbl)
	    local testResult = areSetsEqual(keys, {"x", "y"})
	    printResult(testResult, "getKeys_keyedOnly()")
	end

	function unitTests.ProductiveWoW_getKeys_mixedTable()
	    local tbl = { "a", "b", x = 99 }
	    local keys = ProductiveWoW_getKeys(tbl)
	    local testResult = areSetsEqual(keys, {1, 2, "x"})
	    printResult(testResult, "getKeys_mixedTable()")
	end

	function unitTests.ProductiveWoW_getKeys_emptyTable()
	    local tbl = {}
	    local keys = ProductiveWoW_getKeys(tbl)
	    local testResult = (#keys == 0)
	    printResult(testResult, "getKeys_emptyTable()")
	end

	function unitTests.ProductiveWoW_getKeys_returnIsArray()
	    local tbl = { a = 1, b = 2 }
	    local keys = ProductiveWoW_getKeys(tbl)
	    local isArray = true
	    for k, _ in pairs(keys) do
	        if type(k) ~= "number" then
	            isArray = false
	            break
	        end
	    end
	    printResult(isArray, "getKeys_returnIsArray()")
	end

	function unitTests.ProductiveWoW_mergeTables_concatenatesTwoArrays()
	    local tbl1 = { "a", "b" }
	    local tbl2 = { "c", "d" }
	    local result = ProductiveWoW_mergeTables(tbl1, tbl2)
	    local testResult = (result == tbl1 and #tbl1 == 4 and tbl1[1] == "a" and tbl1[2] == "b" and tbl1[3] == "c" and tbl1[4] == "d")
	    printResult(testResult, "mergeTables_concatenatesTwoArrays()")
	end

	function unitTests.ProductiveWoW_mergeTables_handlesEmptySecond()
	    local tbl1 = { 1, 2 }
	    local tbl2 = {}
	    local result = ProductiveWoW_mergeTables(tbl1, tbl2)
	    local testResult = (result == tbl1 and #tbl1 == 2 and tbl1[1] == 1 and tbl1[2] == 2)
	    printResult(testResult, "mergeTables_handlesEmptySecond()")
	end

	function unitTests.ProductiveWoW_mergeTables_handlesEmptyFirst()
	    local tbl1 = {}
	    local tbl2 = { "x", "y" }
	    local result = ProductiveWoW_mergeTables(tbl1, tbl2)
	    local testResult = (result == tbl1 and #tbl1 == 2 and tbl1[1] == "x" and tbl1[2] == "y")
	    printResult(testResult, "mergeTables_handlesEmptyFirst()")
	end

	function unitTests.ProductiveWoW_mergeTables_bothEmpty()
	    local tbl1 = {}
	    local tbl2 = {}
	    local result = ProductiveWoW_mergeTables(tbl1, tbl2)
	    local testResult = (result == tbl1 and #tbl1 == 0)
	    printResult(testResult, "mergeTables_bothEmpty()")
	end

	function unitTests.ProductiveWoW_mergeTables_preservesSecondTable()
	    local tbl1 = {1, 2}
	    local tbl2 = {3, 4}
	    local result = ProductiveWoW_mergeTables(tbl1, tbl2)
	    tbl1[1] = 99
	    local testResult = (result == tbl1 and tbl1[3] == 3 and tbl2[1] == 3 and tbl2[2] == 4)
	    printResult(testResult, "mergeTables_preservesSecondTable()")
	end

	function unitTests.ProductiveWoW_mergeTables_worksWithMixedTypes()
	    local tbl1 = { true, "a" }
	    local tbl2 = { 5, false }
	    local result = ProductiveWoW_mergeTables(tbl1, tbl2)
	    local testResult = (result == tbl1 and tbl1[1] == true and tbl1[2] == "a" and tbl1[3] == 5 and tbl1[4] == false)
	    printResult(testResult, "mergeTables_worksWithMixedTypes()")
	end

	function unitTests.ProductiveWoW_getRandomSubsetOfArrayTable_returnsCorrectSize()
	    local tbl = {1, 2, 3, 4, 5}
	    local subset = ProductiveWoW_getRandomSubsetOfArrayTable(tbl, 3)
	    local testResult = (#subset == 3)
	    printResult(testResult, "getRandomSubsetOfTable_returnsCorrectSize()")
	end

	function unitTests.ProductiveWoW_getRandomSubsetOfArrayTable_sizeLargerThanTable()
	    local tbl = {10, 20}
	    local subset = ProductiveWoW_getRandomSubsetOfArrayTable(tbl, 5)
	    local testResult = (#subset == 2)
	    printResult(testResult, "getRandomSubsetOfTable_sizeLargerThanTable()")
	end

	function unitTests.ProductiveWoW_getRandomSubsetOfArrayTable_emptyTable()
	    local tbl = {}
	    local subset = ProductiveWoW_getRandomSubsetOfArrayTable(tbl, 3)
	    local testResult = (#subset == 0)
	    printResult(testResult, "getRandomSubsetOfTable_emptyTable()")
	end

	function unitTests.ProductiveWoW_getRandomSubsetOfArrayTable_sizeZero()
	    local tbl = { "a", "b" }
	    local subset = ProductiveWoW_getRandomSubsetOfArrayTable(tbl, 0)
	    local testResult = (#subset == 0)
	    printResult(testResult, "getRandomSubsetOfTable_sizeZero()")
	end

	function unitTests.ProductiveWoW_arrayTablesContainSameElements_sameElementsDifferentOrder()
	    local tbl1 = {1, 2, 3}
	    local tbl2 = {3, 1, 2}
	    local testResult = ProductiveWoW_arrayTablesContainSameElements(tbl1, tbl2) == true
	    printResult(testResult, "arrayTablesContainSameElements_sameElementsDifferentOrder()")
	end

	function unitTests.ProductiveWoW_arrayTablesContainSameElements_differentElements()
	    local tbl1 = {1, 2, 3}
	    local tbl2 = {4, 5, 6}
	    local testResult = ProductiveWoW_arrayTablesContainSameElements(tbl1, tbl2) == false
	    printResult(testResult, "arrayTablesContainSameElements_differentElements()")
	end

	function unitTests.ProductiveWoW_arrayTablesContainSameElements_differentLengths()
	    local tbl1 = {1, 2}
	    local tbl2 = {1, 2, 3}
	    local testResult = ProductiveWoW_arrayTablesContainSameElements(tbl1, tbl2) == false
	    printResult(testResult, "arrayTablesContainSameElements_differentLengths()")
	end

	function unitTests.ProductiveWoW_arrayTablesContainSameElements_identicalTables()
	    local tbl1 = { "a", "b", "c" }
	    local tbl2 = { "a", "b", "c" }
	    local testResult = ProductiveWoW_arrayTablesContainSameElements(tbl1, tbl2) == true
	    printResult(testResult, "arrayTablesContainSameElements_identicalTables()")
	end

	function unitTests.ProductiveWoW_arrayTablesContainSameElements_emptyTables()
	    local tbl1 = {}
	    local tbl2 = {}
	    local testResult = ProductiveWoW_arrayTablesContainSameElements(tbl1, tbl2) == true
	    printResult(testResult, "arrayTablesContainSameElements_emptyTables()")
	end

	function unitTests.ProductiveWoW_stringContainsOnlyWhitespace_spacesOnly()
	    local str = "     "
	    local testResult = ProductiveWoW_stringContainsOnlyWhitespace(str) == true
	    printResult(testResult, "stringContainsOnlyWhitespace_spacesOnly()")
	end

	function unitTests.ProductiveWoW_stringContainsOnlyWhitespace_tabsAndNewlines()
	    local str = "\t\n  \n\t"
	    local testResult = ProductiveWoW_stringContainsOnlyWhitespace(str) == true
	    printResult(testResult, "stringContainsOnlyWhitespace_tabsAndNewlines()")
	end

	function unitTests.ProductiveWoW_stringContainsOnlyWhitespace_emptyString()
	    local str = ""
	    local testResult = ProductiveWoW_stringContainsOnlyWhitespace(str) == true
	    printResult(testResult, "stringContainsOnlyWhitespace_emptyString()")
	end

	function unitTests.ProductiveWoW_stringContainsOnlyWhitespace_containsVisibleCharacters()
	    local str = "  a  "
	    local testResult = ProductiveWoW_stringContainsOnlyWhitespace(str) == false
	    printResult(testResult, "stringContainsOnlyWhitespace_containsVisibleCharacters()")
	end

	function unitTests.ProductiveWoW_stringContainsOnlyWhitespace_mixedContent()
	    local str = "\n\tword\t\n"
	    local testResult = ProductiveWoW_stringContainsOnlyWhitespace(str) == false
	    printResult(testResult, "stringContainsOnlyWhitespace_mixedContent()")
	end

	function unitTests.ProductiveWoW_isNumeric_pureDigits()
	    local str = "123456"
	    local testResult = ProductiveWoW_isNumeric(str) == true
	    printResult(testResult, "isNumeric_pureDigits()")
	end

	function unitTests.ProductiveWoW_isNumeric_leadingZeros()
	    local str = "00042"
	    local testResult = ProductiveWoW_isNumeric(str) == true
	    printResult(testResult, "isNumeric_leadingZeros()")
	end

	function unitTests.ProductiveWoW_isNumeric_emptyString()
	    local str = ""
	    local testResult = ProductiveWoW_isNumeric(str) == false
	    printResult(testResult, "isNumeric_emptyString()")
	end

	function unitTests.ProductiveWoW_isNumeric_containsLetters()
	    local str = "12a34"
	    local testResult = ProductiveWoW_isNumeric(str) == false
	    printResult(testResult, "isNumeric_containsLetters()")
	end

	function unitTests.ProductiveWoW_isNumeric_negativeSign()
	    local str = "-123"
	    local testResult = ProductiveWoW_isNumeric(str) == false
	    printResult(testResult, "isNumeric_negativeSign()")
	end

	function unitTests.ProductiveWoW_isNumeric_decimalNumber()
	    local str = "3.14"
	    local testResult = ProductiveWoW_isNumeric(str) == false
	    printResult(testResult, "isNumeric_decimalNumber()")
	end

	function unitTests.ProductiveWoW_isNumeric_whitespaceAroundDigits()
	    local str = " 123 "
	    local testResult = ProductiveWoW_isNumeric(str) == false
	    printResult(testResult, "isNumeric_whitespaceAroundDigits()")
	end

	function unitTests.ProductiveWoW_isPercent_wholeNumber()
	    local str = "75"
	    local testResult = ProductiveWoW_isPercent(str) == true
	    printResult(testResult, "isPercent_wholeNumber()")
	end

	function unitTests.ProductiveWoW_isPercent_validPercentage()
	    local str = "25%"
	    local testResult = ProductiveWoW_isPercent(str) == true
	    printResult(testResult, "isPercent_validPercentage()")
	end

	function unitTests.ProductiveWoW_isPercent_decimalNumber()
	    local str = "3.14"
	    local testResult = ProductiveWoW_isPercent(str) == false
	    printResult(testResult, "isPercent_decimalNumber()")
	end

	function unitTests.ProductiveWoW_isPercent_decimalWithPercent()
	    local str = "3.14%"
	    local testResult = ProductiveWoW_isPercent(str) == false
	    printResult(testResult, "isPercent_decimalWithPercent()")
	end

	function unitTests.ProductiveWoW_isPercent_emptyString()
	    local str = ""
	    local testResult = ProductiveWoW_isPercent(str) == false
	    printResult(testResult, "isPercent_emptyString()")
	end

	function unitTests.ProductiveWoW_isPercent_lettersInString()
	    local str = "abc"
	    local testResult = ProductiveWoW_isPercent(str) == false
	    printResult(testResult, "isPercent_lettersInString()")
	end

	function unitTests.ProductiveWoW_isPercent_onlyPercentSymbol()
	    local str = "%"
	    local testResult = ProductiveWoW_isPercent(str) == false
	    printResult(testResult, "isPercent_onlyPercentSymbol()")
	end

	function unitTests.ProductiveWoW_isPercent_percentWithSpaces()
	    local str = " 50% "
	    local testResult = ProductiveWoW_isPercent(str) == false
	    printResult(testResult, "isPercent_percentWithSpaces()")
	end

	function unitTests.ProductiveWoW_isPercent_multiplePercentSymbols()
	    local str = "50%%"
	    local testResult = ProductiveWoW_isPercent(str) == false
	    printResult(testResult, "isPercent_multiplePercentSymbols()")
	end

	function unitTests.ProductiveWoW_numberOfDaysSinceDate_todayIsZero()
	    local today = date("*t")
	    local testResult = ProductiveWoW_numberOfDaysSinceDate(today) == 0
	    printResult(testResult, "numberOfDaysSinceDate_todayIsZero()")
	end

	function unitTests.ProductiveWoW_numberOfDaysSinceDate_oneDayAgo()
	    local yesterday = date("*t", time() - 86400)
	    local testResult = ProductiveWoW_numberOfDaysSinceDate(yesterday) == 1
	    printResult(testResult, "numberOfDaysSinceDate_oneDayAgo()")
	end

	function unitTests.ProductiveWoW_numberOfDaysSinceDate_sevenDaysAgo()
	    local past = date("*t", time() - 86400 * 7)
	    local testResult = ProductiveWoW_numberOfDaysSinceDate(past) == 7
	    printResult(testResult, "numberOfDaysSinceDate_sevenDaysAgo()")
	end

	function unitTests.ProductiveWoW_numberOfDaysSinceDate_leapYearCheck()
	    local leapDay = { year = 2020, month = 2, day = 29 }
	    local now = date("*t")
	    local expectedDays = math.floor((time(now) - time(leapDay)) / 86400)
	    local testResult = ProductiveWoW_numberOfDaysSinceDate(leapDay) == expectedDays
	    printResult(testResult, "numberOfDaysSinceDate_leapYearCheck()")
	end

	function unitTests.ProductiveWoW_numberOfDaysSinceDate_futureDate()
	    local future = date("*t", time() + 86400 * 5)
	    local testResult = ProductiveWoW_numberOfDaysSinceDate(future) == -5
	    printResult(testResult, "numberOfDaysSinceDate_futureDate()")
	end

	function unitTests.ProductiveWoW_getKeyAsString_stringKey()
	    local tbl = { alpha = "hello", beta = "world" }
	    local keyStr = ProductiveWoW_getKeyAsString(tbl, "world")
	    local testResult = (keyStr == "beta")
	    printResult(testResult, "getKeyAsString_stringKey()")
	end

	function unitTests.ProductiveWoW_getKeyAsString_numericKey()
	    local tbl = { [42] = "answer", [99] = "question" }
	    local keyStr = ProductiveWoW_getKeyAsString(tbl, "answer")
	    local testResult = (keyStr == "42")
	    printResult(testResult, "getKeyAsString_numericKey()")
	end

	function unitTests.ProductiveWoW_getKeyAsString_valueNotFound()
	    local tbl = { a = "x", b = "y" }
	    local keyStr = ProductiveWoW_getKeyAsString(tbl, "z")
	    local testResult = (keyStr == nil)
	    printResult(testResult, "getKeyAsString_valueNotFound()")
	end

	function unitTests.ProductiveWoW_getKeyAsString_tableAsKey()
	    local keyTbl = {}
	    local tbl = { [keyTbl] = "value" }
	    local keyStr = ProductiveWoW_getKeyAsString(tbl, "value")
	    local testResult = (type(keyStr) == "string") -- any stringified key is acceptable here
	    printResult(testResult, "getKeyAsString_tableAsKey()")
	end

	function unitTests.ProductiveWoW_getMax_normalCase()
	    local tbl = {3, 7, 2, 9, 1}
	    local result = ProductiveWoW_getMax(tbl)
	    local testResult = (result == 9)
	    printResult(testResult, "getMax_normalCase()")
	end

	function unitTests.ProductiveWoW_getMax_allNegatives()
	    local tbl = {-10, -3, -99, -1}
	    local result = ProductiveWoW_getMax(tbl)
	    local testResult = (result == -1)
	    printResult(testResult, "getMax_allNegatives()")
	end

	function unitTests.ProductiveWoW_getMax_allSame()
	    local tbl = {5, 5, 5, 5}
	    local result = ProductiveWoW_getMax(tbl)
	    local testResult = (result == 5)
	    printResult(testResult, "getMax_allSame()")
	end

	function unitTests.ProductiveWoW_getMax_singleElement()
	    local tbl = {42}
	    local result = ProductiveWoW_getMax(tbl)
	    local testResult = (result == 42)
	    printResult(testResult, "getMax_singleElement()")
	end

	function unitTests.ProductiveWoW_getMax_emptyTable()
	    local tbl = {}
	    local result = ProductiveWoW_getMax(tbl)
	    local testResult = (result == nil)
	    printResult(testResult, "getMax_emptyTable()")
	end

	unitTests.ProductiveWoW_tableIsArray_testValueIsArray()
	unitTests.ProductiveWoW_tableIsArray_testValueIsNotArray()
	unitTests.ProductiveWoW_tableLength_returnsZeroOnEmptyTable()
	unitTests.ProductiveWoW_tableLength_returnsCorrectCount()
	unitTests.ProductiveWoW_tableLength_returnsCorrectCountWhenTableHasKeys()
	unitTests.ProductiveWoW_inTableKeys_valueNotInKeys()
	unitTests.ProductiveWoW_inTableKeys_stringValueInKeys()
	unitTests.ProductiveWoW_inTable_notInTable()
	unitTests.ProductiveWoW_inTable_stringValueIsInTable()
	unitTests.ProductiveWoW_removeByValue_removesExistingValue()
	unitTests.ProductiveWoW_removeByValue_valueNotFound()
	unitTests.ProductiveWoW_removeByValue_removesFirstOnly()
	unitTests.ProductiveWoW_removeByValue_emptyTable()
	unitTests.ProductiveWoW_removeByValue_numericValues()
	unitTests.ProductiveWoW_tableShallowCopy_copiesArray()
	unitTests.ProductiveWoW_tableShallowCopy_copiesKeyedTable()
	unitTests.ProductiveWoW_tableShallowCopy_independentTopLevelValues()
	unitTests.ProductiveWoW_tableShallowCopy_sharedNestedTables()
	unitTests.ProductiveWoW_tableShallowCopy_emptyTable()
	unitTests.ProductiveWoW_getKeys_arrayOnly()
	unitTests.ProductiveWoW_getKeys_keyedOnly()
	unitTests.ProductiveWoW_getKeys_mixedTable()
	unitTests.ProductiveWoW_getKeys_emptyTable()
	unitTests.ProductiveWoW_getKeys_returnIsArray()
	unitTests.ProductiveWoW_mergeTables_concatenatesTwoArrays()
	unitTests.ProductiveWoW_mergeTables_handlesEmptySecond()
	unitTests.ProductiveWoW_mergeTables_handlesEmptyFirst()
	unitTests.ProductiveWoW_mergeTables_bothEmpty()
	unitTests.ProductiveWoW_mergeTables_preservesSecondTable()
	unitTests.ProductiveWoW_mergeTables_worksWithMixedTypes()
	unitTests.ProductiveWoW_getRandomSubsetOfArrayTable_returnsCorrectSize()
	unitTests.ProductiveWoW_getRandomSubsetOfArrayTable_sizeLargerThanTable()
	unitTests.ProductiveWoW_getRandomSubsetOfArrayTable_emptyTable()
	unitTests.ProductiveWoW_getRandomSubsetOfArrayTable_sizeZero()
	unitTests.ProductiveWoW_arrayTablesContainSameElements_sameElementsDifferentOrder()
	unitTests.ProductiveWoW_arrayTablesContainSameElements_differentElements()
	unitTests.ProductiveWoW_arrayTablesContainSameElements_differentLengths()
	unitTests.ProductiveWoW_arrayTablesContainSameElements_identicalTables()
	unitTests.ProductiveWoW_arrayTablesContainSameElements_emptyTables()
	unitTests.ProductiveWoW_stringContainsOnlyWhitespace_spacesOnly()
	unitTests.ProductiveWoW_stringContainsOnlyWhitespace_tabsAndNewlines()
	unitTests.ProductiveWoW_stringContainsOnlyWhitespace_emptyString()
	unitTests.ProductiveWoW_stringContainsOnlyWhitespace_containsVisibleCharacters()
	unitTests.ProductiveWoW_stringContainsOnlyWhitespace_mixedContent()
	unitTests.ProductiveWoW_isNumeric_pureDigits()
	unitTests.ProductiveWoW_isNumeric_leadingZeros()
	unitTests.ProductiveWoW_isNumeric_emptyString()
	unitTests.ProductiveWoW_isNumeric_containsLetters()
	unitTests.ProductiveWoW_isNumeric_negativeSign()
	unitTests.ProductiveWoW_isNumeric_decimalNumber()
	unitTests.ProductiveWoW_isNumeric_whitespaceAroundDigits()
	unitTests.ProductiveWoW_isPercent_wholeNumber()
	unitTests.ProductiveWoW_isPercent_validPercentage()
	unitTests.ProductiveWoW_isPercent_decimalNumber()
	unitTests.ProductiveWoW_isPercent_decimalWithPercent()
	unitTests.ProductiveWoW_isPercent_emptyString()
	unitTests.ProductiveWoW_isPercent_lettersInString()
	unitTests.ProductiveWoW_isPercent_onlyPercentSymbol()
	unitTests.ProductiveWoW_isPercent_percentWithSpaces()
	unitTests.ProductiveWoW_isPercent_multiplePercentSymbols()
	unitTests.ProductiveWoW_numberOfDaysSinceDate_todayIsZero()
	unitTests.ProductiveWoW_numberOfDaysSinceDate_oneDayAgo()
	unitTests.ProductiveWoW_numberOfDaysSinceDate_sevenDaysAgo()
	unitTests.ProductiveWoW_numberOfDaysSinceDate_leapYearCheck()
	unitTests.ProductiveWoW_numberOfDaysSinceDate_futureDate()
	unitTests.ProductiveWoW_getKeyAsString_stringKey()
	unitTests.ProductiveWoW_getKeyAsString_numericKey()
	unitTests.ProductiveWoW_getKeyAsString_valueNotFound()
	unitTests.ProductiveWoW_getKeyAsString_tableAsKey()
	unitTests.ProductiveWoW_getMax_normalCase()
	unitTests.ProductiveWoW_getMax_allNegatives()
	unitTests.ProductiveWoW_getMax_allSame()
	unitTests.ProductiveWoW_getMax_singleElement()
	unitTests.ProductiveWoW_getMax_emptyTable()

	if anyFailed == true then
		print(toRedText("THERE WAS AT LEAST 1 UNIT TEST THAT FAILED."))
	end

end