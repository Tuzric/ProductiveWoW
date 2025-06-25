-- LOAD SAVED VARIABLES --
ProductiveWoWSavedSettings = ProductiveWoWSavedSettings or {["currently_selected_deck"] = nil}
ProductiveWoWData = ProductiveWoWData or {["decks"] = {}}


-- INITIALIZE OTHER VARIABLES --
local currentSubsetOfCardsBeingQuizzedIDs = {}
local currentCardID = nil

-- FUNCTION DEFINITIONS --

-- Get current card shown on flashcard frame
function ProductiveWoW_getCurrentCardID()
	return currentCardID
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
		ProductiveWoWData["decks"][deck_name] = {["cards"] = {}, ["next_card_id"] = 1}
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

-- Add a card
function ProductiveWoW_addCard(deck_name, question, answer)
	local next_id = ProductiveWoW_getDeck(deck_name)["next_card_id"]
	ProductiveWoWData["decks"][deck_name]["cards"][next_id] = {["question"] = question, ["answer"] = answer}
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

local function getDeckSubsetForQuiz(deck_name)
	-- For now, selects all cards in the deck, returns array of card IDs
	local cards = ProductiveWoW_getKeys(ProductiveWoW_getDeckCards(deck_name))
	return cards
end

-- Draw random next card
function ProductiveWoW_drawRandomNextCard()
	local numCards = ProductiveWoW_tableLength(currentSubsetOfCardsBeingQuizzedIDs)
	if numCards >= 1 then
		local random_index = math.random(1, numCards)
		currentCardID = currentSubsetOfCardsBeingQuizzedIDs[random_index]
		table.remove(currentSubsetOfCardsBeingQuizzedIDs, random_index)
	else
		ProductiveWoW_showMainMenu()
		print("Congratulations, you completed this deck for today.")
	end
end

-- Begin quiz
function ProductiveWoW_beginQuiz()
	local currentDeck = ProductiveWoWSavedSettings["currently_selected_deck"]
	-- Load the subset of cards to be quizzed on
	currentSubsetOfCardsBeingQuizzedIDs = getDeckSubsetForQuiz(currentDeck)
	ProductiveWoW_drawRandomNextCard()
end

-- Required to run in this block to ensure that saved variables are loaded before this code runs
EventUtil.ContinueOnAddOnLoaded("ProductiveWoW", function()

	-- DEBUG AND DEV ONLY: Uncomment to reset saved variables
	-- ProductiveWoWSavedSettings = {["currently_selected_deck"] = nil}
	-- ProductiveWoWData = {["decks"] = {}}

	-- Import decks from ProductiveWoWDecks.lua
	ProductiveWoW_importDecks()

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