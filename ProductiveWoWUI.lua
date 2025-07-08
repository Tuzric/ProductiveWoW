-- INITIALIZE VARIABLES
-- Variables for all frames
local ProductiveWoW_allFrames = {} -- Keep track of list of all frames
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


-- Main menu frame
local mainMenuFrameName = "MainMenuFrame"
local mainMenuFrameTitle = "ProductiveWoW"

-- Create deck frame
local createDeckFrameName = "CreateDeckFrame"
local createDeckFrameTitle = "Create Deck"

-- Delete deck frame
local deleteDeckFrameName = "DeleteDeckFrame"
local deleteDeckFrameTitle = "Delete Deck"

-- Modify deck frame
local modifyDeckFrameName = "ModifyDeckFrame"
local modifyDeckFrameTitlePrefix = "Modify Deck - " -- Title changes when you navigate to this frame to include the name of the deck
local modifyDeckFrameHeight = 500
local listOfCardsFrameRowHeight = 20
local textMenu -- Reference to right click context menu
local rows = {}
local listOfSelectedCardIDs = {}
local multipleCardsSelected = false
local editCardButtonOnClick -- Function
local deleteCardButtonOnClick -- Function
local unselectAllRows -- Function to unselect all rows
local selectRow -- Function to select a single row
local unselectRow -- Function to unselect a single row

-- Confirmation box that appears when you attempt to delete multiple selected cards
local multipleCardsDeletionConfirmationFrameName = "MultipleCardsDeletionConfirmationFrame"
local multipleCardsDeletionConfirmationFrameTitle = "Confirm Deletion"
local multipleCardsDeletionConfirmationFrameText = "Are you sure you want to delete all the selected cards?"

-- Add card frame
local addCardFrameName = "AddCardFrame"
local addCardFrameTitle = "Add Card"

-- Edit card frame
local editCardFrameName = "EditCardFrame"
local editCardFrameTitle = "Edit Card"
local idOfCardBeingEdited = 0

-- Add and Edit Card frames variables in common
local cardQuestionTextBoxGreyHintText = "Enter question..."
local cardAnswerTextBoxGreyHintText = "Enter answer..."

-- Flashcard frame
local flashcardFrameName = "FlashcardFrame"
local flashcardFrameTitlePrefix = "Deck: " -- Title changes to display deck name when you navigate to this frame

-- Deck settings frame
local deckSettingsFrameName = "DeckSettingsFrame"
local deckSettingsFrameTitlePrefix = "Deck Settings - "

-- FUNCTIONS

-- Function to create a new frame, wraps WoW's CreateFrame() in order to trigger additional functionality such as adding the frame to the list of all frames
local function createFrame(frame_name, parent_frame, frame_title, frame_width, frame_height)
	local newFrame = CreateFrame("Frame", frame_name, parent_frame, "BasicFrameTemplateWithInset")
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
local function createNavigationButton(button_name, parent_frame, button_text, anchor_point, x_offset, y_offset, frame_to_navigate_to, sound, on_click_function)
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
			if sound == nil or sound == "" then
				PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
			else
				PlaySound(sound)
			end
		end
	end)

	return newButton
end	

-- Create a basic text box
local function createTextBox(textbox_name, parent_frame, width, height, anchor_point, x_offset, y_offset, grey_hint_text)
	local newTextBox = CreateFrame("EditBox", textbox_name, parent_frame, "InputBoxTemplate")
	if grey_hint_text == nil then
		grey_hint_text = ""
	end
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

-- Create basic text
local function createText(anchor, parent, parentAnchor, x_offset, y_offset, text)
	local textObject = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	textObject:SetPoint(anchor, parent, parentAnchor, x_offset, y_offset)
	textObject:SetText(text)
	textObject:SetJustifyH("LEFT")
	textObject:SetNonSpaceWrap(false)
	textObject:SetWordWrap(false)
	return textObject
end

-- Get frame by name
local function getFrame(frameName)
	return ProductiveWoW_allFrames[frameName]
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

-- Reposition next frame to position of previous frame, then show it (used for navigating between frames)
local function repositionAndShowFrame(frame)
	frame:ClearAllPoints()
	frame:SetPoint(menuCurrentAnchorPoint, menuCurrentAnchorRelativeTo, menuCurrentRelativePoint, menuCurrentXOffsetFromCenter, menuCurrentYOffsetFromCenter)
	frame:Show()
end

-- Show main menu
function ProductiveWoW_showMainMenu()
	ProductiveWoW_hideAllFrames()
	repositionAndShowFrame(getFrame(mainMenuFrameName))
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN)
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
	local mainmenu = createFrame(mainMenuFrameName, UIParent, mainMenuFrameTitle)
	local createDeckFrame = createFrame(createDeckFrameName, UIParent, createDeckFrameTitle)
	local deleteDeckFrame = createFrame(deleteDeckFrameName, UIParent, deleteDeckFrameTitle)
	local modifyDeckFrame = createFrame(modifyDeckFrameName, UIParent, "", basicFrameWidth, modifyDeckFrameHeight)
	local addCardFrame = createFrame(addCardFrameName, UIParent, addCardFrameTitle)
	local editCardFrame = createFrame(editCardFrameName, UIParent, editCardFrameTitle)
	local flashcardFrame = createFrame(flashcardFrameName, UIParent)
	local multipleCardsDeletionConfirmationFrame = createFrame(multipleCardsDeletionConfirmationFrameName, UIParent, multipleCardsDeletionConfirmationFrameTitle)
	local deckSettingsFrame = createFrame(deckSettingsFrameName, UIParent, "")

	-- MAIN MENU FRAME
	-- Choose deck text
	mainmenu.chooseDeckText = createText("TOPLEFT", mainmenu, "TOPLEFT", 15, -42, "Choose deck:")

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
			modifyDeckFrame.title:SetText(modifyDeckFrameTitlePrefix .. currentDeck)
			return true -- Conditions for navigation passed
		else
			print("No deck is currently selected.")
			return false
		end
	end
	mainmenu.navigateToModifyDeckButton = createNavigationButton("NavigateToModifyDeckButton", mainmenu, "Modify Deck", "TOPLEFT", 230, -32, modifyDeckFrame, nil, navigateToModifyDeckButtonOnClick)

	-- Create button to begin flashcard quiz
	local function navigateToFlashcardFrameButtonOnClick()
		local currentDeckName = ProductiveWoW_getCurrentDeckName() 
		if currentDeckName ~= nil then
			if ProductiveWoW_tableLength(ProductiveWoW_getDeckCards(currentDeckName)) ~= 0 then
				if not ProductiveWoW_isDeckCompletedForToday(currentDeckName) then
					flashcardFrame.title:SetText(flashcardFrameTitlePrefix .. currentDeckName)
					return true -- Conditions for navigation passed
				else
					print("You've already completed this deck today.")
					return false
				end
			else
				print("There are no cards in the selected deck.")
				return false
			end
		else
			print("No deck is currently selected.")
			return false
		end
	end
	mainmenu.navigateToFlashcardFrameButton = createNavigationButton("NavigateToFlashcardFrameButton", mainmenu, "Go", "TOPLEFT", 230, -92, flashcardFrame, nil, navigateToFlashcardFrameButtonOnClick)

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
	createDeckFrame.createDeckButton = createNavigationButton("CreateDeckAndNavigateToMainMenuButton", createDeckFrame, "Create", "CENTER", 0, -40, mainmenu, SOUNDKIT.IG_CHARACTER_INFO_CLOSE, createDeckButtonOnClick)


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
	deleteDeckFrame.deleteDeckButton = createNavigationButton("DeleteDeckAndNavigateToMainMenuButton", deleteDeckFrame, "Delete", "CENTER", 0, -40, mainmenu, SOUNDKIT.IG_CHARACTER_INFO_CLOSE, deleteDeckButtonOnClick)


	-- MODIFY DECK FRAME
	-- "Card List: " Text
	modifyDeckFrame.cardListText = createText("TOPLEFT", modifyDeckFrame, "TOPLEFT", 15, -42, "Card List:")

	-- Navigate to Add Card Button
	modifyDeckFrame.navigateToAddCardButton = createNavigationButton("NavigateToAddCardButton", modifyDeckFrame, "Add Card", "TOPRIGHT", -20, -35, addCardFrame)

	-- Navigate back to main menu button
	modifyDeckFrame.navigateBackToMainMenuButton = createNavigationButton("NavigateBackToMainMenuButtonFromModifyDeckFrame", modifyDeckFrame, "Back", "BOTTOMRIGHT", -20, 20, mainmenu, SOUNDKIT.IG_CHARACTER_INFO_CLOSE)

	-- Navigate to deck settings button
	local function navigateToDeckSettingsFrameOnClick()
		deckSettingsFrame.title:SetText(deckSettingsFrameTitlePrefix .. ProductiveWoW_getCurrentDeckName())
	end
	modifyDeckFrame.navigateToDeckSettingsButton = createNavigationButton("NavigateToDeckSettingsButton", modifyDeckFrame, "Deck Settings", "BOTTOMLEFT", 20, 20, deckSettingsFrame, nil, navigateToDeckSettingsFrameOnClick)

	-- Scrollable list of cards in deck
	modifyDeckFrame.listOfCardsFrame = CreateFrame("ScrollFrame", "ListOfCardsFrame", modifyDeckFrame, "UIPanelScrollFrameTemplate")
	modifyDeckFrame.listOfCardsFrame:SetPoint("TOPLEFT", 10, -90)
	modifyDeckFrame.listOfCardsFrame:SetPoint("BOTTOMRIGHT", -35, 60)
	modifyDeckFrame.listOfCardsFrameContent = CreateFrame("Frame", "ListOfCardsFrameContent", modifyDeckFrame.listOfCardsFrame)
	modifyDeckFrame.listOfCardsFrameContent:SetPoint("TOPLEFT", modifyDeckFrame.listOfCardsFrame, "TOPLEFT", 0, 0)
	modifyDeckFrame.listOfCardsFrameContent:SetSize(1, 1)
	modifyDeckFrame.listOfCardsFrame:SetScrollChild(modifyDeckFrame.listOfCardsFrameContent)
	modifyDeckFrame.listOfCardsFrame:SetVerticalScroll(0)

	-- Multiple cards deletion confirmation frame
	multipleCardsDeletionConfirmationFrame:SetWidth(basicFrameWidth + 40) -- Make it slightly wider to accomodate the text

	-- Confirmation text
	multipleCardsDeletionConfirmationFrame.confirmationText = createText("CENTER", multipleCardsDeletionConfirmationFrame, "CENTER", 0, 15, multipleCardsDeletionConfirmationFrameText)

	-- Yes button
	local function multipleCardsDeletionYesButtonOnClick()
		for i, card_id in ipairs(listOfSelectedCardIDs) do
			deleteCardButtonOnClick(card_id)
		end
		unselectAllRows()
		multipleCardsDeletionConfirmationFrame:Hide()
	end
	multipleCardsDeletionConfirmationFrame.yesButton = createButton("MultipleDeletionConfirmationYesButton", multipleCardsDeletionConfirmationFrame, "Yes", "CENTER", -70, -40, multipleCardsDeletionYesButtonOnClick)

	-- Cancel button
	local function multipleCardsDeletionCancelButtonOnClick()
		unselectAllRows()
		multipleCardsDeletionConfirmationFrame:Hide()
	end
	multipleCardsDeletionConfirmationFrame.cancelButton = createButton("MultipleDeletionConfirmationCancelButton", multipleCardsDeletionConfirmationFrame, "Cancel", "CENTER", 70, -40, multipleCardsDeletionCancelButtonOnClick)

	function unselectAllRows()
		for i, row in ipairs(rows) do
			row.selected = false
			row:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
		end
		multipleCardsSelected = false
		listOfSelectedCardIDs = {}
	end

	function selectRow(row_frame)
		if row_frame.selected == false then
			row_frame.selected = true
			row_frame:SetBackdropColor(0.2, 0.2, 0.7, 0.9)
			table.insert(listOfSelectedCardIDs, row_frame.card_id)
			if ProductiveWoW_tableLength(listOfSelectedCardIDs) > 1 then
				multipleCardsSelected = true
			end
		end
	end

	function unselectRow(row_frame)
		if row_frame.selected == true then
			row_frame.selected = false
			row_frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
			ProductiveWoW_removeByValue(row_frame.card_id, listOfSelectedCardIDs)
			if ProductiveWoW_tableLength(listOfSelectedCardIDs) <= 1 then
				multipleCardsSelected = false
			end
		end
	end

	local function createRow(index)
		local row = CreateFrame("Frame", nil, modifyDeckFrame.listOfCardsFrameContent, "BackdropTemplate")
		row.selected = false
		row:SetSize(modifyDeckFrame:GetWidth() - 45, listOfCardsFrameRowHeight)
		row:SetPoint("TOPLEFT", 0, -((index - 1) * listOfCardsFrameRowHeight))
		row:EnableMouse(true)
		row:SetBackdrop({
			bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
  			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
 			tile     = true, tileSize = 16, edgeSize = 12
		})
		row:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
		row:SetScript("OnEnter", function(self)
			self:SetBackdropColor(0.2, 0.2, 0.7, 0.9)
		end)

		row:SetScript("OnLeave", function(self)
			if row.selected == false then
				self:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
			end
		end)

		row.question = createText("LEFT", row, "LEFT", 10, 0, "")
		row.question:SetWidth((modifyDeckFrame:GetWidth() - 40) / 2)

		row.answer = createText("LEFT", row, "LEFT", (modifyDeckFrame:GetWidth() - 40) / 2 + 20, 0)
		row.answer:SetWidth((modifyDeckFrame:GetWidth() - 100) / 2)

		row:SetScript("OnMouseUp", function(row_frame, button)
			if button == "RightButton" then
				if not row_frame.selected then
					unselectAllRows()
					selectRow(row_frame)
				end
				if not multipleCardsSelected then
			    	contextMenu = MenuUtil.CreateContextMenu(row_frame, function(owner, root)
		      			root:CreateButton("Edit Card", function() editCardButtonOnClick(row_frame.card_id) end)
		      			root:CreateButton("Delete Card", function() deleteCardButtonOnClick(row_frame.card_id) end)
		    		end)
		    		contextMenu:HookScript("OnHide", function()
		    			unselectRow(row_frame)
		    		end)
		    	else
		    		contextMenu = MenuUtil.CreateContextMenu(row_frame, function(owner, root)
		      			root:CreateButton("Delete All Selected Cards", function() 
		      				multipleCardsDeletionConfirmationFrame:ClearAllPoints()
		      				multipleCardsDeletionConfirmationFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		      				multipleCardsDeletionConfirmationFrame:SetFrameLevel(modifyDeckFrame:GetFrameLevel() + 3)
		      				multipleCardsDeletionConfirmationFrame:Show() 
		      			end)
		      		end)
		    	end
	    	elseif button == "LeftButton" then
	    		if not multipleCardsDeletionConfirmationFrame:IsShown() then
					if row.selected == true then
						unselectRow(row_frame)
					else
						selectRow(row_frame)
					end
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				end
			end
		end)

		return row
	end

	-- Unselect all rows when user clicks anywhere
	modifyDeckFrame:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			if not multipleCardsDeletionConfirmationFrame:IsShown() then
				unselectAllRows()
			end
		end
	end)

	-- Column headers
	modifyDeckFrame.questionColumnHeader = createText("TOPLEFT", modifyDeckFrame, "TOPLEFT", 16, -70, "Question")
	modifyDeckFrame.answerColumnHeader = createText("TOPLEFT", modifyDeckFrame, "TOPLEFT", 185, -70, "Answer")
	
	-- Populate rows. This function creates a Frame for each row, since we can't delete frames, everytime it's repopulated when you switch a deck,
	-- we will need to reuse the existing row Frames just changing their text. New row Frames are only created when we have exhausted 
	-- all the existing row Frames. If we switch from Deck A which has 5 rows to Deck B which has 3 rows, we need to set the text of the 2 extra rows to blank
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
			row.card_id = card_id
			row.selected = false
			row:Show()
			table_index = table_index + 1
		end
		-- Set text to blank for additional rows if current deck has fewer rows than the previously selected deck
		local numCardsInCurrentDeck = ProductiveWoW_tableLength(cards)
		for i = numCardsInCurrentDeck + 1, ProductiveWoW_tableLength(rows) do
			rows[i].question:SetText("")
			rows[i].answer:SetText("")
			rows[i]:Hide()
		end
		-- Resize scroll content
		modifyDeckFrame.listOfCardsFrameContent:SetHeight(#rows * listOfCardsFrameRowHeight)
	end
	-- Re-populate rows when frame is shown
	modifyDeckFrame:SetScript("OnShow", function(self)
		populateRows()
	end)

	function editCardButtonOnClick(card_id)
		local deck_name = ProductiveWoWSavedSettings["currently_selected_deck"]
		local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(card_id)
		if ProductiveWoW_cardsToAdd[deck_name] ~= nil then
			if ProductiveWoW_inTableKeys(card.question, ProductiveWoW_cardsToAdd[deck_name]) then
				print("Can't edit this card because it exists in ProductiveWoWDecks.lua and the pre-edit version of it would be re-added when you re-log. Go remove it from the file, re-log, then try to edit the card again through the UI.")
				return
			end
		end
		idOfCardBeingEdited = card_id
		modifyDeckFrame:Hide()
		editCardFrame:ClearAllPoints() -- Frames can have up to 5 anchor points, remove them to prevent errors as we reset its position
		editCardFrame:SetPoint(menuCurrentAnchorPoint, menuCurrentAnchorRelativeTo, menuCurrentRelativePoint, menuCurrentXOffsetFromCenter, menuCurrentYOffsetFromCenter) -- Move the frame to where previous frame was in case user dragged it so that it doesn't appear in a different position when the button is pressed
		editCardFrame:Show()
	end

	-- Full definition of this function is here because populateRows needs to be defined 
	function deleteCardButtonOnClick(card_id)
		local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(card_id)
		local current_deck = ProductiveWoWSavedSettings["currently_selected_deck"]
		if ProductiveWoW_cardsToAdd[current_deck] ~= nil then
			if ProductiveWoW_inTableKeys(card["question"], ProductiveWoW_cardsToAdd[current_deck]) then
				print("\"" .. card["question"] .. "\" could not be deleted since it exists in ProductiveWoWDecks.lua and will be re-added on the next login. Remove it from that file, re-log or type in /reload (important to do this otherwise you'll get the same error), then delete it through the UI.")
				return
			end
		end
		ProductiveWoW_deleteCardByID(current_deck, card_id)
		print("Successfully deleted card: " .. card["question"])
		populateRows()
	end

	
	-- EDIT CARD FRAME
	-- Card Question Text Box
	editCardFrame.cardQuestionTextBox = createTextBox("EditCardCardQuestionTextBox", editCardFrame, 300, 20, "CENTER", 0, 20, cardQuestionTextBoxGreyHintText)

	-- Card Answer Text Box
	editCardFrame.cardAnswerTextBox = createTextBox("EditCardCardAnswerTextBox", editCardFrame, 300, 20, "CENTER", 0, -20, cardAnswerTextBoxGreyHintText)

	-- Save card button
	local function saveCardButtonOnClick()
		local newQuestion = editCardFrame.cardQuestionTextBox:GetText()
		local newAnswer = editCardFrame.cardAnswerTextBox:GetText()
		local deck_name = ProductiveWoWSavedSettings["currently_selected_deck"]
		local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(idOfCardBeingEdited)
		if not ProductiveWoW_stringContainsOnlyWhitespace(newQuestion) and not ProductiveWoW_stringContainsOnlyWhitespace(newAnswer) and newQuestion ~= cardQuestionTextBoxGreyHintText and newAnswer ~= cardAnswerTextBoxGreyHintText then
			if deck_name ~= nil then
				if newQuestion ~= card.question or newAnswer ~= card.answer then
					if ProductiveWoW_getCardByQuestion(deck_name, newQuestion) == nil or newQuestion == card.question then
						if ProductiveWoW_cardsToAdd[deck_name] ~= nil then
							if ProductiveWoW_inTableKeys(ProductiveWoW_cardsToAdd[deck_name], newQuestion) then
								print("Could not save card since the question entered exists in ProductiveWoWDecks.lua cardsToAdd and will be overwritten on the next login. Go to that file and modify the card there or remove it and try again through the UI.")
								return
							elseif ProductiveWoW_cardsToDelete[deck_name] ~= nil then
								if ProductiveWoW_inTableKeys(ProductiveWoW_cardsToDelete[deck_name], newQuestion) then
									print("Could not save card since the question entered exists in ProductiveWoWDecks.lua cardsToDelete and will automatically be deleted on the next login. Go to the file and remove it from cardsToDelete, re-log, and try to edit the card again.")
									return
								end
							end
						end
						card.question = newQuestion
						card.answer = newAnswer
						clearTextBox(editCardFrame.cardQuestionTextBox)
						clearTextBox(editCardFrame.cardAnswerTextBox)
						editCardFrame:Hide()
						modifyDeckFrame:ClearAllPoints() -- Frames can have up to 5 anchor points, remove them to prevent errors as we reset its position
						modifyDeckFrame:SetPoint(menuCurrentAnchorPoint, menuCurrentAnchorRelativeTo, menuCurrentRelativePoint, menuCurrentXOffsetFromCenter, menuCurrentYOffsetFromCenter) -- Move the frame to where previous frame was in case user dragged it so that it doesn't appear in a different position when the button is pressed
						modifyDeckFrame:Show()
						print("Card has been saved.")
					else
						print("Another card with that question already exists.")
					end
				else	
					print("You have not made any changes to the card.")
				end
			else
				print("No deck is selected.")
			end
		else
			print("You have not entered a question or answer.")
		end
	end
	editCardFrame.saveCardButton = createButton("SaveCardButton", editCardFrame, "Save", "CENTER", -100, -50, saveCardButtonOnClick)

	-- Back to Modify Deck frame button
	editCardFrame.navigateBackToModifyDeckFrameButton = createNavigationButton("NavigateBackToModifyDeckFrameButtonFromEditCardFrame", editCardFrame, "Back", "CENTER", 0, -50, modifyDeckFrame, SOUNDKIT.IG_CHARACTER_INFO_CLOSE)

	-- Back to main menu button
	editCardFrame.navigateBackToMainMenuButton = createNavigationButton("NavigateBackToMainMenuButtonFromEditCardFrame", editCardFrame, "Main Menu", "CENTER", 100, -50, mainmenu, SOUNDKIT.IG_CHARACTER_INFO_CLOSE)

	-- Populate textboxes with card's question and answer
	editCardFrame:SetScript("OnShow", function(self) 
		local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(idOfCardBeingEdited)
		editCardFrame.cardQuestionTextBox:SetText(card.question)
		editCardFrame.cardAnswerTextBox:SetText(card.answer)
		editCardFrame.cardQuestionTextBox:SetCursorPosition(0)
		editCardFrame.cardQuestionTextBox:SetTextColor(1, 1, 1)
		editCardFrame.cardAnswerTextBox:SetCursorPosition(0)
		editCardFrame.cardAnswerTextBox:SetTextColor(1, 1, 1)
	end)


	-- ADD CARD FRAME
	-- Card Question Text Box
	addCardFrame.cardQuestionTextBox = createTextBox("CardQuestionTextBox", addCardFrame, 300, 20, "CENTER", 0, 20, cardQuestionTextBoxGreyHintText)

	-- Card Answer Text Box
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
	addCardFrame.navigateBackToModifyDeckFrameButton = createNavigationButton("NavigateBackToModifyDeckFrameButton", addCardFrame, "Back", "CENTER", 0, -50, modifyDeckFrame, SOUNDKIT.IG_CHARACTER_INFO_CLOSE)

	-- Back to main menu button
	addCardFrame.navigateBackToMainMenuButton = createNavigationButton("NavigateBackToMainMenuButtonFromAddCardFrame", addCardFrame, "Main Menu", "CENTER", 100, -50, mainmenu, SOUNDKIT.IG_CHARACTER_INFO_CLOSE)


	-- FLASHCARD FRAME
	flashcardFrame:SetSize(basicFrameWidth + 100, basicFrameHeight + 100)
	-- Add text to display question
	flashcardFrame.displayedText = flashcardFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	flashcardFrame.displayedText:SetPoint("TOPLEFT", flashcardFrame, "TOPLEFT", 15, -10)
	flashcardFrame.displayedText:SetPoint("BOTTOMRIGHT", flashcardFrame, "BOTTOMRIGHT", -15, 20)
	flashcardFrame.displayedText:SetNonSpaceWrap(true)

	local function showNextCard()
		local currentCardID = ProductiveWoW_getCurrentCardID()
		if currentCardID ~= nil then
			local currentQuestion = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(currentCardID)["question"]
			flashcardFrame.displayedText:SetText(currentQuestion)
			ProductiveWoW_viewedCard(currentCardID)
		end
	end

	-- Show answer button
	local function showAnswerButtonOnClick()
		local currentCardID = ProductiveWoW_getCurrentCardID()
		if currentCardID ~= nil then
			local currentAnswer = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(currentCardID)["answer"]
			flashcardFrame.displayedText:SetText(currentAnswer)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
		flashcardFrame.easyDifficultyButton:Show()
		flashcardFrame.mediumDifficultyButton:Show()
		flashcardFrame.hardDifficultyButton:Show()
		flashcardFrame.showAnswerButton:Hide()
	end
	flashcardFrame.showAnswerButton = createButton("ShowAnswerButton", flashcardFrame, "Show", "BOTTOMLEFT", 20, 20, showAnswerButtonOnClick)

	-- Next question
	local function nextQuestion(self)
		self:Hide()
		ProductiveWoW_drawRandomNextCard()
		showNextCard()
		flashcardFrame.showAnswerButton:Show()
		flashcardFrame.easyDifficultyButton:Hide()
		flashcardFrame.mediumDifficultyButton:Hide()
		flashcardFrame.hardDifficultyButton:Hide()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end

	-- Easy difficulty button
	local function easyDifficultyButtonOnClick(self)
		local currentCardID = ProductiveWoW_getCurrentCardID()
		ProductiveWoW_cardEasyDifficultyChosen(currentCardID)
		-- print("DEBUG: Number of times Easy was pressed for this card: " .. ProductiveWoW_getCardByIDForCurrentlySelectedDeck(currentCardID)["number of times easy"])
		nextQuestion(self)
	end
	flashcardFrame.easyDifficultyButton = createButton("EasyDifficultyButton", flashcardFrame, "Easy", "BOTTOMLEFT", 20, 20, easyDifficultyButtonOnClick)
	flashcardFrame.easyDifficultyButton:Hide()

	-- Medium difficulty button
	local function mediumDifficultyButtonOnClick(self)
		local currentCardID = ProductiveWoW_getCurrentCardID()
		ProductiveWoW_cardMediumDifficultyChosen(currentCardID)
		-- print("DEBUG: Number of times Medium was pressed for this card: " .. ProductiveWoW_getCardByIDForCurrentlySelectedDeck(currentCardID)["number of times medium"])
		nextQuestion(self)
	end
	flashcardFrame.mediumDifficultyButton = createButton("MediumDifficultyButton", flashcardFrame, "Medium", "BOTTOMLEFT", 120, 20, mediumDifficultyButtonOnClick)
	flashcardFrame.mediumDifficultyButton:Hide()

	-- Hard difficulty button
	local function hardDifficultyButtonOnClick(self)
		local currentCardID = ProductiveWoW_getCurrentCardID()
		ProductiveWoW_cardHardDifficultyChosen(currentCardID)
		-- print("DEBUG: Number of times Hard was pressed for this card: " .. ProductiveWoW_getCardByIDForCurrentlySelectedDeck(currentCardID)["number of times hard"])
		nextQuestion(self)
	end
	flashcardFrame.hardDifficultyButton = createButton("HardDifficultyButton", flashcardFrame, "Hard", "BOTTOMLEFT", 220, 20, hardDifficultyButtonOnClick)
	flashcardFrame.hardDifficultyButton:Hide()

	
	flashcardFrame.nextQuestionButton = createButton("NextQuestionButton", flashcardFrame, "Next", "BOTTOM", 0, 20, nextQuestionButtonOnClick)
	flashcardFrame.nextQuestionButton:Hide()

	-- Back to main menu from flashcard frame button
	flashcardFrame.navigateBackToMainMenuFromFlashcardFrameButton = createNavigationButton("NavigateBackToMainMenuFromFlashcardFrameButton", flashcardFrame, "Main Menu", "BOTTOMRIGHT", -20, 20, mainmenu, SOUNDKIT.IG_CHARACTER_INFO_CLOSE)

	-- OnShow script to refresh question
	flashcardFrame:SetScript("OnShow", function(self)
		ProductiveWoW_beginQuiz()
		showNextCard()
	end)


	-- DECK SETTINGS FRAME --
	-- Back button
	deckSettingsFrame.navigateBackToModifyDeckFrameFromDeckSettingsFrameButton = createNavigationButton("NavigateBackToModifyDeckFrameFromDeckSettingsFrameButton", deckSettingsFrame, "Back", "BOTTOMRIGHT", -20, 20, modifyDeckFrame, SOUNDKIT.IG_CHARACTER_INFO_CLOSE)

	-- Max cards to be tested per day text
	deckSettingsFrame.maxCardsText = createText("TOPLEFT", deckSettingsFrame, "TOPLEFT", 20, -40, "Max Daily Cards: ")

	-- Max daily cards textbox
	deckSettingsFrame.maxCardsTextBox = createTextBox("MaxCardsTextBox", deckSettingsFrame, 40, 20, "TOPLEFT", 140, -36)

	-- Save button
	local function saveDeckSettingsButtonOnClick()
		local anySettingChanged = false
		local maxDailyCards = deckSettingsFrame.maxCardsTextBox:GetText()
		local currentDeckName = ProductiveWoW_getCurrentDeckName()
		local currentDeck = ProductiveWoW_getCurrentDeck()
		local currentMaxDailyCards = currentDeck["daily number of cards"]
		if not ProductiveWoW_isNumeric(maxDailyCards) then
			print("Max daily cards has to be a number.")
		elseif tonumber(maxDailyCards) <= 0 then
			print("Max daily cards cannot be 0 or less than 0.")
		elseif tonumber(maxDailyCards) == tonumber(currentMaxDailyCards) then
			print("No changes were made so nothing was saved.")
		else
			ProductiveWoW_setMaxDailyCardsForDeck(currentDeckName, tonumber(maxDailyCards))
			ProductiveWoW_setDeckNotPlayedYetToday(currentDeckName) -- When max card limit changes, reset the deck
			anySettingChanged = true
		end
		if anySettingChanged == true then
			print("Settings saved.")
		end
	end
	deckSettingsFrame.saveDeckSettingsButton = createButton("SaveDeckSettingsButton", deckSettingsFrame, "Save", "BOTTOMLEFT", 20, 20, saveDeckSettingsButtonOnClick)

	deckSettingsFrame:SetScript("OnShow", function()
		local maxCards = ProductiveWoW_getCurrentDeck()["daily number of cards"]
		deckSettingsFrame.maxCardsTextBox:SetText(maxCards)
		deckSettingsFrame.maxCardsTextBox:SetTextColor(1, 1, 1)
	end)

end)