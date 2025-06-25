-- INITIALIZE VARIABLES
local ProductiveWoW_allFrames = {} -- Keep track of list of all frames
local mainMenuFrameName = "MainMenuFrame"
local basicFrameWidth = 350 -- Frame width for most ProductiveWoW frames
local basicFrameHeight = 150 -- Frame height for most ProductiveWoW frames
local menuCurrentXOffsetFromCenter = 200 -- Track position by X offset from center of UIParent. These 2 variables are updated when a user drags the frame so that when they click a button to navigate to another frame, the next frame that opens up is opened in the same position as the previous frame
local menuCurrentYOffsetFromCenter = 200 -- Same as above, but for Y offset
local menuCurrentAnchorPoint = "CENTER"
local menuCurrentAnchorRelativeTo = UIParent
local menuCurrentRelativePoint = "CENTER"
local basicFrameTitleBackgroundHeight = 30
local basicFrameTitleOffsetXFromTopLeft = 5
local basicFrameTitleOffsetYFromTopLeft = -3
local basicButtonWidth = 100
local basicButtonHeight = 30
local listOfCardsFrameRowHeight = 20


-- FUNCTIONS

-- Function to create a new frame, wraps WoW's CreateFrame() in order to trigger additional functionality such as adding the frame to the list of all frames
local function createFrame(frame_type, frame_name, parent_frame, frame_template, frame_title, frame_width, frame_height)
	local newFrame = CreateFrame(frame_type, frame_name, parent_frame, frame_template)
	ProductiveWoW_allFrames[frame_name] = newFrame
	
	-- Default size if no width/height is specified
	frame_width = frame_width or basicFrameWidth
	frame_height = frame_height or basicFrameHeight
	newFrame:SetSize(frame_width, frame_height)
	newFrame:SetPoint("CENTER", parent_frame, "CENTER", menuCurrentXOffsetFromCenter, menuCurrentYOffsetFromCenter)
	newFrame.TitleBg:SetHeight(basicFrameTitleBackgroundHeight)
	newFrame.title = newFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	newFrame.title:SetPoint("TOPLEFT", newFrame.TitleBg, "TOPLEFT", basicFrameTitleOffsetXFromTopLeft, basicFrameTitleOffsetYFromTopLeft)
	newFrame.title:SetText(frame_title)
	newFrame:EnableMouse(true)
	newFrame:SetMovable(true)
	newFrame:SetDontSavePosition(true) -- Disable position tracking by Blizzard's UI manager because we're tracking it using menuCurrentXOffsetFromCenter and menuCurrentYOffsetFromCenter
	newFrame:RegisterForDrag("LeftButton")
	newFrame:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)
	newFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, relativeTo, relativePoint, x, y = newFrame:GetPoint()
		menuCurrentAnchorPoint = point
		menuCurrentAnchorRelativeTo = relativeTo
		menuCurrentRelativePoint = relativePoint
		menuCurrentXOffsetFromCenter = x
		menuCurrentYOffsetFromCenter = y
	end)
	table.insert(UISpecialFrames, frame_name) -- This makes the frame closeable by pressing the Escape key

	return newFrame
end

-- Create a basic button
local function createButton(button_name, parent_frame, button_text, anchor_point, x_offset, y_offset, on_click_function)
	local newButton = CreateFrame("Button", button_name, parent_frame, "UIPanelButtonTemplate")
	newButton:SetSize(basicButtonWidth, basicButtonHeight)
	newButton:SetPoint(anchor_point, parent_frame, anchor_point, x_offset, y_offset)
	newButton:SetText(button_text)
	newButton:SetScript("OnClick", function(...)
		if on_click_function ~= nil then
			on_click_function(...)
		end
	end)

	return newButton
end

-- Create a basic navigation button
local function createNavigationButton(button_name, parent_frame, button_text, anchor_point, x_offset, y_offset, frame_to_navigate_to, on_click_function)
	local newButton = CreateFrame("Button", button_name, parent_frame, "UIPanelButtonTemplate")
	newButton:SetSize(basicButtonWidth, basicButtonHeight)
	newButton:SetPoint(anchor_point, parent_frame, anchor_point, x_offset, y_offset)
	newButton:SetText(button_text)
	newButton:SetScript("OnClick", function(self)
		local navigationConditionsPassed = true -- some on_click_functions may return a Boolean value on whether certain conditions were met to trigger navigation to the next screen
		if on_click_function ~= nil then
			navigationConditionsPassed = on_click_function()
		end
		if navigationConditionsPassed ~= nil and navigationConditionsPassed == false then
			return
		else
			parent_frame:Hide()
			frame_to_navigate_to:ClearAllPoints() -- Frames can have up to 5 anchor points, remove them to prevent errors as we reset its position
			frame_to_navigate_to:SetPoint(menuCurrentAnchorPoint, menuCurrentAnchorRelativeTo, menuCurrentRelativePoint, menuCurrentXOffsetFromCenter, menuCurrentYOffsetFromCenter) -- Move the frame to where previous frame was in case user dragged it so that it doesn't appear in a different position when the button is pressed
			frame_to_navigate_to:Show()
		end
	end)

	return newButton
end	

-- Create a basic text box
local function createTextBox(textbox_name, parent_frame, width, height, anchor_point, x_offset, y_offset, grey_hint_text)
	local newTextBox = CreateFrame("EditBox", textbox_name, parent_frame, "InputBoxTemplate")
	newTextBox.greyHintText = grey_hint_text
	newTextBox:SetSize(width, height)
	newTextBox:SetPoint(anchor_point, parent_frame, anchor_point, x_offset, y_offset)
	newTextBox:SetAutoFocus(false)
	newTextBox:SetText(grey_hint_text)
	newTextBox:SetTextColor(0.5, 0.5, 0.5)
	newTextBox:SetCursorPosition(0)
	newTextBox.hasFocus = false
	newTextBox:SetScript("OnEditFocusGained", function(self)
		self.hasFocus = true
		if self:GetText() == grey_hint_text then
			self:SetText("")
			self:SetTextColor(1, 1, 1)
		end
	end)
	newTextBox:SetScript("OnEditFocusLost", function(self)
		self.hasFocus = false
		if self:GetText() == "" then
			self:SetText(grey_hint_text)
			self:SetTextColor(0.5, 0.5, 0.5)
		end
	end)
	newTextBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
		newTextBox.hasFocus = false
	end)
	parent_frame:SetScript("OnMouseDown", function(self)
		if newTextBox.hasFocus then
			newTextBox:ClearFocus()
			newTextBox.hasFocus = false
		end
	end)

	return newTextBox
end

-- Clear textbox to show hint text
local function clearTextBox(textbox)
	textbox:SetText(textbox.greyHintText)
	textbox:SetTextColor(0.5, 0.5, 0.5)
	if textbox.hasFocus then
			textbox:ClearFocus()
			textbox.hasFocus = false
	end
end

-- Hide all frames
function ProductiveWoW_hideAllFrames()
	for key, frame in pairs(ProductiveWoW_allFrames) do
		frame:Hide()
	end
end

-- Show main menu
function ProductiveWoW_showMainMenu()
	local mainMenuFrame = ProductiveWoW_allFrames[mainMenuFrameName]
	ProductiveWoW_hideAllFrames()
	mainMenuFrame:ClearAllPoints()
	mainMenuFrame:SetPoint(menuCurrentAnchorPoint, menuCurrentAnchorRelativeTo, menuCurrentRelativePoint, menuCurrentXOffsetFromCenter, menuCurrentYOffsetFromCenter)
	mainMenuFrame:Show()
end

-- Are any frames shown?
function ProductiveWoW_anyFrameIsShown()
	for key, frame in pairs(ProductiveWoW_allFrames) do
		if frame:IsShown() then
			return true
		end
	end
	return false
end

-- Get current frame shown
function ProductiveWoW_getCurrentlyShownFrame()
	for key, frame in pairs(ProductiveWoW_allFrames) do
		if frame:IsShown() then
			return frame
		end
	end
	return nil
end


-- Required to run in this block to ensure that saved variables are loaded before this code runs
EventUtil.ContinueOnAddOnLoaded("ProductiveWoW", function()

	-- FRAME INITIALIZATION --
	-- Create all the frames
	local mainmenu = createFrame("Frame", mainMenuFrameName, UIParent, "BasicFrameTemplateWithInset", "ProductiveWoW")
	local createDeckFrame = createFrame("Frame", "CreateDeckFrame", UIParent, "BasicFrameTemplateWithInset", "Create Deck")
	local deleteDeckFrame = createFrame("Frame", "DeleteDeckFrame", UIParent, "BasicFrameTemplateWithInset", "Delete Deck")
	local modifyDeckFrame = createFrame("Frame", "ModifyDeckFrame", UIParent, "BasicFrameTemplateWithInset", "Modify Deck", basicFrameWidth, 500)
	local addCardFrame = createFrame("Frame", "AddCardFrame", UIParent, "BasicFrameTemplateWithInset", "Add Card")
	local flashcardFrame = createFrame("Frame", "FlashcardFrame", UIParent, "BasicFrameTemplateWithInset", "ProductiveWoW")


	-- MAIN MENU FRAME
	-- Choose deck text
	mainmenu.chooseDeckText = mainmenu:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	mainmenu.chooseDeckText:SetPoint("TOPLEFT", mainmenu, "TOPLEFT", 15, -42)
	mainmenu.chooseDeckText:SetText("Choose deck: ")

	-- Choose deck dropdown
	-- Generator function generates the content of the dropdown
	local function chooseDeckDropdownGeneratorFunction(owner, rootDescription)
		owner:SetDefaultText(ProductiveWoWSavedSettings["currently_selected_deck"]) -- Reset to blank if selected deck was just deleted
		-- Grab list of decks from ProductiveWoWData and create a dropdown button for each
		-- Extract keys (which are the deck names) and sort them alphabetically
		local deck_names = {}
		for deck_name in pairs(ProductiveWoWData["decks"]) do
			table.insert(deck_names, deck_name)
		end
		table.sort(deck_names)
		-- Create dropdown buttons for each deck
		for i, deck_name in ipairs(deck_names) do
			rootDescription:CreateButton(deck_name, function(data) 
				-- Function that determines what happens when you click on a deck in the dropdown
				ProductiveWoWSavedSettings["currently_selected_deck"] = deck_name
				mainmenu.chooseDeckDropdown:SetDefaultText(deck_name)
			end)
		end
	end
	mainmenu.chooseDeckDropdown = CreateFrame("DropdownButton", nil, mainmenu, "WowStyle1DropdownTemplate")
	mainmenu.chooseDeckDropdown:SetSize(100, 25)
	mainmenu.chooseDeckDropdown:SetPoint("TOPLEFT", mainmenu, "TOPLEFT", 100, -35)
	mainmenu.chooseDeckDropdown:SetupMenu(chooseDeckDropdownGeneratorFunction)
	mainmenu.chooseDeckDropdown:SetDefaultText(ProductiveWoWSavedSettings["currently_selected_deck"])
	mainmenu.chooseDeckDropdown:SetScript("OnShow", function(self)
		mainmenu.chooseDeckDropdown:GenerateMenu()
	end)

	-- Create new deck button that takes you to create deck frame
	mainmenu.navigateToCreateDeckButton = createNavigationButton("NavigateToCreateDeckButton", mainmenu, "Create Deck", "TOPLEFT", 15, -62, createDeckFrame)

	-- Create delete deck button that takes you to delete deck frame
	mainmenu.navigateToDeleteDeckButton = createNavigationButton("NavigateToDeleteDeckButton", mainmenu, "Delete Deck", "TOPLEFT", 15, -92, deleteDeckFrame)

	-- Create modify deck button that takes you to the modify deck frame
	local function navigateToModifyDeckButtonOnClick()
		local currentDeck = ProductiveWoWSavedSettings["currently_selected_deck"]
		if currentDeck ~= nil then
			-- Set title of Modify Deck frame
			modifyDeckFrame.title:SetText("Modify Deck - " .. currentDeck)
			return true -- Conditions for navigation passed
		else
			print("No deck is currently selected.")
			return false
		end
	end
	mainmenu.navigateToModifyDeckButton = createNavigationButton("NavigateToModifyDeckButton", mainmenu, "Modify Deck", "TOPLEFT", 200, -32, modifyDeckFrame, navigateToModifyDeckButtonOnClick)

	-- Create button to begin flashcard quiz
	local function navigateToFlashcardFrameButtonOnClick()
		local currentDeck = ProductiveWoWSavedSettings["currently_selected_deck"] 
		if currentDeck ~= nil then
			flashcardFrame.title:SetText("Deck: " .. currentDeck)
			return true -- Conditions for navigation passed
		else
			print("No deck is currently selected.")
			return false
		end
	end
	mainmenu.navigateToFlashcardFrameButton = createNavigationButton("NavigateToFlashcardFrameButton", mainmenu, "Go", "TOPLEFT", 200, -62, flashcardFrame, navigateToFlashcardFrameButtonOnClick)

	-- CREATE DECK FRAME
	-- Deck name textbox
	local deckNameTextBoxGreyHintText = "Deck name..."
	createDeckFrame.deckNameTextBox = createTextBox("CreateDeckNameTextBox", createDeckFrame, 200, 25, "CENTER", 0, 0, deckNameTextBoxGreyHintText)

	-- Create deck button
	local function createDeckButtonOnClick()
		local deck_name = createDeckFrame.deckNameTextBox:GetText()
		if ProductiveWoWData["decks"][deck_name] == nil then
			if not ProductiveWoW_stringContainsOnlyWhitespace(deck_name) and deck_name ~= deckNameTextBoxGreyHintText then
				ProductiveWoW_addDeck(deck_name)
			else
				print("Deck name was blank so no deck was created.")
			end
		else
			print("A deck by that name already exists.")
		end	
		createDeckFrame.deckNameTextBox:SetText(deckNameTextBoxGreyHintText)
		createDeckFrame.deckNameTextBox:SetTextColor(0.5, 0.5, 0.5)
	end
	createDeckFrame.createDeckButton = createNavigationButton("CreateDeckAndNavigateToMainMenuButton", createDeckFrame, "Create", "CENTER", 0, -40, mainmenu, createDeckButtonOnClick)


	-- CREATE DECK FRAME
	-- Delete deck by name textbox
	local deleteDeckNameTextBoxGreyHintText = "Enter deck name to delete..."
	deleteDeckFrame.deleteDeckNameTextBox = createTextBox("DeleteDeckNameTextBox", deleteDeckFrame, 200, 25, "CENTER", 0, 0, deleteDeckNameTextBoxGreyHintText)

	-- Delete deck button
	local function deleteDeckButtonOnClick()
		local deck_name = deleteDeckFrame.deleteDeckNameTextBox:GetText()
		if ProductiveWoWData["decks"][deck_name] ~= nil and deck_name ~= deleteDeckNameTextBoxGreyHintText then
			ProductiveWoW_deleteDeck(deck_name)
		else
			print("A deck by that name does not exist.")
		end
		deleteDeckFrame.deleteDeckNameTextBox:SetText(deleteDeckNameTextBoxGreyHintText)
		deleteDeckFrame.deleteDeckNameTextBox:SetTextColor(0.5, 0.5, 0.5)
	end
	deleteDeckFrame.deleteDeckButton = createNavigationButton("DeleteDeckAndNavigateToMainMenuButton", deleteDeckFrame, "Delete", "CENTER", 0, -40, mainmenu, deleteDeckButtonOnClick)


	-- MODIFY DECK FRAME
	-- "Card List: " Text
	modifyDeckFrame.cardListText = modifyDeckFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	modifyDeckFrame.cardListText:SetPoint("TOPLEFT", modifyDeckFrame, "TOPLEFT", 15, -42)
	modifyDeckFrame.cardListText:SetText("Card List:")

	-- Navigate to Add Card Button
	modifyDeckFrame.navigateToAddCardButton = createNavigationButton("NavigateToAddCardButton", modifyDeckFrame, "Add Card", "TOPRIGHT", -20, -35, addCardFrame)

	-- Navigate back to main menu button
	modifyDeckFrame.navigateBackToMainMenuButton = createNavigationButton("NavigateBackToMainMenuButtonFromModifyDeckFrame", modifyDeckFrame, "Back", "BOTTOM", 0, 20, mainmenu)

	-- Scrollable list of cards in deck
	modifyDeckFrame.listOfCardsFrame = CreateFrame("ScrollFrame", "ListOfCardsFrame", modifyDeckFrame, "UIPanelScrollFrameTemplate")
	modifyDeckFrame.listOfCardsFrame:SetPoint("TOPLEFT", 10, -90)
	modifyDeckFrame.listOfCardsFrame:SetPoint("BOTTOMRIGHT", -35, 60)
	modifyDeckFrame.listOfCardsFrameContent = CreateFrame("Frame", "ListOfCardsFrameContent", modifyDeckFrame.listOfCardsFrame)
	modifyDeckFrame.listOfCardsFrameContent:SetPoint("TOPLEFT", modifyDeckFrame.listOfCardsFrame, "TOPLEFT", 0, 0)
	modifyDeckFrame.listOfCardsFrameContent:SetSize(1, 1)
	modifyDeckFrame.listOfCardsFrame:SetScrollChild(modifyDeckFrame.listOfCardsFrameContent)
	modifyDeckFrame.listOfCardsFrame:SetVerticalScroll(0)
	local function createRow(index)
		local row = CreateFrame("Frame", nil, modifyDeckFrame.listOfCardsFrameContent)
		row:SetSize(modifyDeckFrame:GetWidth() - 40, listOfCardsFrameRowHeight)
		row:SetPoint("TOPLEFT", 0, -((index - 1) * listOfCardsFrameRowHeight))

		row.question = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		row.question:SetPoint("LEFT", row, "LEFT", 10, 0)
		row.question:SetWidth((modifyDeckFrame:GetWidth() - 40) / 2)
		row.question:SetJustifyH("LEFT")
		row.question:SetNonSpaceWrap(false)
		row.question:SetWordWrap(false)

		row.answer = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		row.answer:SetPoint("LEFT", row.question, "RIGHT", 10, 0)
		row.answer:SetWidth((modifyDeckFrame:GetWidth() - 40) / 2)
		row.answer:SetJustifyH("LEFT")
		row.answer:SetNonSpaceWrap(false)
		row.answer:SetWordWrap(false)

		return row
	end

	-- Column headers
	modifyDeckFrame.questionColumnHeader = modifyDeckFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	modifyDeckFrame.questionColumnHeader:SetPoint("TOPLEFT", modifyDeckFrame, "TOPLEFT", 20, -70)
	modifyDeckFrame.questionColumnHeader:SetText("Question")
	modifyDeckFrame.answerColumnHeader = modifyDeckFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	modifyDeckFrame.answerColumnHeader:SetPoint("LEFT", modifyDeckFrame.questionColumnHeader, "RIGHT", 150, 0)
	modifyDeckFrame.answerColumnHeader:SetText("Answer")
	
	-- Populate rows. This function creates a Frame for each row, since we can't delete frames, everytime it's repopulated when you switch a deck,
	-- we will need to reuse the existing row Frames just changing their text. New row Frames are only created when we have exhausted 
	-- all the existing row Frames. If we switch from Deck A which has 5 rows to Deck B which has 3 rows, we need to set the text of the 2 extra rows to blank
	local rows = {}
	local function populateRows()
		local cards = ProductiveWoW_getDeckCards(ProductiveWoWSavedSettings["currently_selected_deck"])
		local table_index = 1 -- Need to increment index manually since card_id may not be continuous due to deletion of cards
		for card_id, content in pairs(cards) do
			local row = rows[table_index]
			if row == nil then -- if this row index does not already exist
				row = createRow(table_index)
				rows[table_index] = row
			end
			row.question:SetText(content["question"])
			row.answer:SetText(content["answer"])
			table_index = table_index + 1
		end
		-- Set text to blank for additional rows if current deck has fewer rows than the previously selected deck
		local numCardsInCurrentDeck = ProductiveWoW_tableLength(cards)
		for i = numCardsInCurrentDeck + 1, ProductiveWoW_tableLength(rows) do
			rows[i].question:SetText("")
			rows[i].answer:SetText("")
		end
		-- Resize scroll content
		modifyDeckFrame.listOfCardsFrameContent:SetHeight(#rows * listOfCardsFrameRowHeight)
	end
	-- Re-populate rows when frame is shown
	modifyDeckFrame:SetScript("OnShow", function(self)
		populateRows()
	end)
	


	-- ADD CARD FRAME
	-- Card Question Text Box
	local cardQuestionTextBoxGreyHintText = "Enter question..."
	addCardFrame.cardQuestionTextBox = createTextBox("CardQuestionTextBox", addCardFrame, 300, 20, "CENTER", 0, 20, cardQuestionTextBoxGreyHintText)

	-- Card Answer Text Box
	local cardAnswerTextBoxGreyHintText = "Enter answer..."
	addCardFrame.cardAnswerTextBox = createTextBox("CardAnswerTextBox", addCardFrame, 300, 20, "CENTER", 0, -20, cardAnswerTextBoxGreyHintText)

	-- Add card button
	local function addCardButtonOnClick()
		local question = addCardFrame.cardQuestionTextBox:GetText()
		local answer = addCardFrame.cardAnswerTextBox:GetText()
		if question ~= "" and answer ~= "" and question ~= cardQuestionTextBoxGreyHintText and answer ~= cardAnswerTextBoxGreyHintText then
			local deck_name = ProductiveWoWSavedSettings["currently_selected_deck"]
			if deck_name ~= nil then
				if ProductiveWoW_getCardByQuestion(deck_name, question) == nil then
					ProductiveWoW_addCard(ProductiveWoWSavedSettings["currently_selected_deck"], question, answer)
					clearTextBox(addCardFrame.cardQuestionTextBox)
					clearTextBox(addCardFrame.cardAnswerTextBox)
					print("Card has been added.")
				else	
					print("A card with that question already exists.")
				end
			else
				print("No deck is selected.")
			end
		else
			print("You have not entered a question or answer.")
		end
	end
	addCardFrame.addCardButton = createButton("AddCardButton", addCardFrame, "Add", "CENTER", -100, -50, addCardButtonOnClick)

	-- Back to Modify Deck frame button
	addCardFrame.navigateBackToModifyDeckFrameButton = createNavigationButton("NavigateBackToModifyDeckFrameButton", addCardFrame, "Back", "CENTER", 0, -50, modifyDeckFrame)

	-- Back to main menu button
	addCardFrame.navigateBackToMainMenuButton = createNavigationButton("NavigateBackToMainMenuButtonFromAddCardFrame", addCardFrame, "Main Menu", "CENTER", 100, -50, mainmenu)


	-- FLASHCARD FRAME
	-- Add text to display question
	flashcardFrame.displayedText = flashcardFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	flashcardFrame.displayedText:SetPoint("TOPLEFT", flashcardFrame, "TOPLEFT", 15, -10)
	flashcardFrame.displayedText:SetPoint("BOTTOMRIGHT", flashcardFrame, "BOTTOMRIGHT", -15, 20)
	flashcardFrame.displayedText:SetNonSpaceWrap(false)

	local function showNextCard()
		local currentCardID = ProductiveWoW_getCurrentCardID()
		if currentCardID ~= nil then
			local currentQuestion = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(currentCardID)["question"]
			flashcardFrame.displayedText:SetText(currentQuestion)
		end
	end

	-- Next question button
	local function nextQuestionButtonOnClick(self)
		self:Hide()
		ProductiveWoW_drawRandomNextCard()
		showNextCard()
	end
	flashcardFrame.nextQuestionButton = createButton("NextQuestionButton", flashcardFrame, "Next", "BOTTOM", 0, 20, nextQuestionButtonOnClick)
	flashcardFrame.nextQuestionButton:Hide()

	-- Show answer button
	local function showAnswerButtonOnClick()
		local currentCardID = ProductiveWoW_getCurrentCardID()
		if currentCardID ~= nil then
			local currentAnswer = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(currentCardID)["answer"]
			flashcardFrame.displayedText:SetText(currentAnswer)
		end
		flashcardFrame.nextQuestionButton:Show()
	end
	flashcardFrame.showAnswerButton = createButton("ShowAnswerButton", flashcardFrame, "Show", "BOTTOMLEFT", 20, 20, showAnswerButtonOnClick)

	-- Back to main menu from flashcard frame button
	flashcardFrame.navigateBackToMainMenuFromFlashcardFrameButton = createNavigationButton("NavigateBackToMainMenuFromFlashcardFrameButton", flashcardFrame, "Main Menu", "BOTTOMRIGHT", -20, 20, mainmenu)

	-- OnShow script to refresh question
	flashcardFrame:SetScript("OnShow", function(self)
		ProductiveWoW_beginQuiz()
		showNextCard()
	end)

end)
