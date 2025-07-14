-- v1.2

-- INITIALIZE VARIABLES
--------------------------------------------------------------------------------------------------------------------------------
-- CONSTANTS
-- Frame anchor points
local TOP = "TOP"
local TOPLEFT = "TOPLEFT"
local TOPRIGHT = "TOPRIGHT"
local LEFT = "LEFT"
local CENTER = "CENTER"
local RIGHT = "RIGHT"
local BOTTOM = "BOTTOM"
local BOTTOMLEFT = "BOTTOMLEFT"
local BOTTOMRIGHT = "BOTTOMRIGHT"
-- Frame types and templates
local FRAME = "Frame"
local BUTTON = "Button"
local EDITBOX = "EditBox"
local DROPDOWN_BUTTON = "DropdownButton"
local BASIC_FRAME_TEMPLATE_WITH_INSET = "BasicFrameTemplateWithInset"
local UI_PANEL_BUTTON_TEMPLATE = "UIPanelButtonTemplate"
local INPUT_BOX_TEMPLATE = "InputBoxTemplate"
local WOW_STYLE_1_DROPDOWN_TEMPLATE = "WowStyle1DropdownTemplate"
-- Text
local OVERLAY = "OVERLAY"
local GAME_FONT_NORMAL = "GameFontNormal"
local GAME_FONT_HIGHLIGHT = "GameFontHighlight"
local JUSTIFY_LEFT = "LEFT"
local JUSTIFY_RIGHT = "RIGHT"
-- Colours
local GREY = {0.5, 0.5, 0.5}
local WHITE = {1, 1, 1}
-- Mouse/keyboard buttons
local MOUSE_RIGHT = "RightButton"
local MOUSE_LEFT = "LeftButton"
-- Events
local ON_MOUSE_DRAG_START = "OnDragStart"
local ON_MOUSE_DRAG_STOP = "OnDragStop"
local ON_CLICK = "OnClick"
local ON_EDIT_FOCUS_GAINED = "OnEditFocusGained"
local ON_EDIT_FOCUS_LOST = "OnEditFocusLost"
local ON_ENTER_PRESSED = "OnEnterPressed"
local ON_MOUSE_DOWN = "OnMouseDown"
local ON_SHOW = "OnShow"


-- Variables for all frames
local ProductiveWoWAllFrames = {} -- Keep track of list of all frames
local basicFrameWidth = 350 -- Frame width for most ProductiveWoW frames
local basicFrameHeight = 150 -- Frame height for most ProductiveWoW frames
local menuCurrentXOffsetFromCenter = 200 -- Track position by X offset from center of UIParent. These 2 variables are updated when a user drags the frame so that when they click a button to navigate to another frame, the next frame that opens up is opened in the same position as the previous frame
local menuCurrentYOffsetFromCenter = 200 -- Same as above, but for Y offset
local menuCurrentAnchorPoint = CENTER
local menuCurrentAnchorRelativeTo = UIParent
local menuCurrentRelativePoint = CENTER
local basicFrameTitleBackgroundHeight = 30
local basicFrameTitleOffsetXFromTopLeft = 5
local basicFrameTitleOffsetYFromTopLeft = -3
local basicButtonWidth = 100
local basicButtonHeight = 30

-- Main menu frame
local mainMenu
local mainMenuFrameName = "MainMenuFrame"
local mainMenuFrameTitle = ProductiveWoW_ADDON_NAME .. " " .. ProductiveWoW_ADDON_VERSION
-- Main menu choose deck text
local mainMenuChooseDeckTextAnchor = TOPLEFT
local mainMenuChooseDeckTextParentAnchor = TOPLEFT
local mainMenuChooseDeckTextXOffset = 15
local mainMenuChooseDeckTextYOffset = -40
local mainMenuChooseDeckTextValue = "Choose deck:"
-- Main menu choose deck dropdown
local mainMenuChooseDeckDropdownName = "ChooseDeckDropdown"
local chooseDeckDropdownGeneratorFunction -- Function for generating dropdown contents
local mainMenuChooseDeckDropdownWidth = 100
local mainMenuChooseDeckDropdownHeight = 25
local mainMenuChooseDeckDropdownAnchor = TOPLEFT
local mainMenuChooseDeckDropdownParentAnchor = TOPLEFT
local mainMenuChooseDeckDropdownXOffset = 100
local mainMenuChooseDeckDropdownYOffset = -35
-- Create deck button
local mainMenuNavigateToCreateDeckButtonName = "NavigateToCreateDeckFromMainMenu"
local mainMenuNavigateToCreateDeckButtonAnchor = TOPLEFT
local mainMenuNavigateToCreateDeckButtonXOffset = 15
local mainMenuNavigateToCreateDeckButtonYOffset = -60
local mainMenuNavigateToCreateDeckButtonText = "Create Deck"
-- Delete deck button
local mainMenuNavigateToDeleteDeckButtonName = "NavigateToDeleteDeckFromMainMenu"
local mainMenuNavigateToDeleteDeckButtonAnchor = TOPLEFT
local mainMenuNavigateToDeleteDeckButtonXOffset = 15
local mainMenuNavigateToDeleteDeckButtonYOffset = -90
local mainMenuNavigateToDeleteDeckButtonText = "Delete Deck"
-- Modify deck button
local mainMenuNavigateToModifyDeckButtonName = "NavigateToModifyDeckFromMainMenu"
local mainMenuNavigateToModifyDeckButtonAnchor = TOPLEFT
local mainMenuNavigateToModifyDeckButtonXOffset = 230
local mainMenuNavigateToModifyDeckButtonYOffset = -32
local mainMenuNavigateToModifyDeckButtonText = "Modify Deck"
local mainMenuNavigateToModifyDeckButtonNoDeckSelectedMessage = "No deck is currently selected."
-- Begin quiz "Go" button
local mainMenuNavigateToFlashcardFrameButtonName = "NavigateToFlashcardFrameFromMainMenu"
local mainMenuNavigateToFlashcardFrameButtonText = "Go"
local mainMenuNavigateToFlashcardFrameButtonAnchor = TOPLEFT
local mainMenuNavigateToFlashcardFrameButtonXOffset = 230
local mainMenuNavigateToFlashcardFrameButtonYOffset = -92
local mainMenuNavigateToFlashcardFrameButtonAlreadyCompletedDeckTodayMessage = "You've already completed this deck today. If you would like to play it again, go to Modify Deck > Deck Settings > Change the value of Max Daily Cards."
local mainMenuNavigateToFlashcardFrameButtonNoCardsInDeckMessage = "There are no cards in the selected deck."
local mainMenuNavigateToFlashcardFrameButtonNoSelectedDeckMessage = "No deck is currently selected."

-- Create deck frame
local createDeckFrame
local createDeckFrameName = "CreateDeckFrame"
local createDeckFrameTitle = "Create Deck"
-- Create deck textbox
local createDeckFrameDeckNameTextBoxGreyHintText = "Deck name..."
local createDeckFrameDeckNameTextBoxName = "CreateDeckTextBox"
local createDeckFrameDeckNameTextBoxAnchor = CENTER
local createDeckFrameDeckNameTextBoxXOffset = 0
local createDeckFrameDeckNameTextBoxYOffset = 0
local createDeckFrameDeckNameTextBoxWidth = 200
local createDeckFrameDeckNameTextBoxHeight = 25
local createDeckFrameCreateDeckButtonBlankNameMessage = "Deck name was blank so no deck was created."
local createDeckFrameCreateDeckButtonDeckAlreadyExistsMessage = "A deck by that name already exists."
-- Create deck button
local createDeckFrameCreateDeckButtonName = "CreateDeckButton"
local createDeckFrameCreateDeckButtonText = "Create"
local createDeckFrameCreateDeckButtonAnchor = CENTER
local createDeckFrameCreateDeckButtonXOffset = 0
local createDeckFrameCreateDeckButtonYOffset = -40
local createDeckFrameCreateDeckButtonSound = SOUNDKIT.IG_CHARACTER_INFO_CLOSE

-- Delete deck frame
local deleteDeckFrame
local deleteDeckFrameName = "DeleteDeckFrame"
local deleteDeckFrameTitle = "Delete Deck"
-- Delete deck textbox
local deleteDeckFrameDeckNameTextBoxName = "DeleteDeckTextBox"
local deleteDeckFrameDeckNameTextBoxGreyHintText = "Enter deck name to delete..."
local deleteDeckFrameDeckNameTextBoxAnchor = CENTER
local deleteDeckFrameDeckNameTextBoxXOffset = 0
local deleteDeckFrameDeckNameTextBoxYOffset = 0
local deleteDeckFrameDeckNameTextBoxWidth = 200
local deleteDeckFrameDeckNameTextBoxHeight = 25
local deleteDeckFrameDeleteDeckButtonDeckExistsInBulkImportFileMessage = "Cannot delete this deck because it exists in ProductiveWoWDecks.lua and will just be re-added when the addon is reloaded. Remove it from that file first, reload the game by typing /reload, then come back here to delete it."
local deleteDeckFrameDeleteDeckButtonDeckDoesNotExistMessage = "A deck by that name does not exist."
-- Delete deck button
local deleteDeckFrameDeleteDeckButtonName = "DeleteDeckButton"
local deleteDeckFrameDeleteDeckButtonText = "Delete"
local deleteDeckFrameDeleteDeckButtonAnchor = CENTER
local deleteDeckFrameDeleteDeckButtonXOffset = 0
local deleteDeckFrameDeleteDeckButtonYOffset = -40
local deleteDeckFrameDeleteDeckButtonSound = SOUNDKIT.IG_CHARACTER_INFO_CLOSE

-- Modify deck frame
local modifyDeckFrame
local modifyDeckFrameName = "ModifyDeckFrame"
local modifyDeckFrameTitlePrefix = "Modify Deck - " -- Title changes when you navigate to this frame to include the name of the deck
local modifyDeckFrameWidth = 450
local modifyDeckFrameHeight = 500
-- Card list text
local modifyDeckFrameCardListTextName = "CardListText"
local modifyDeckFrameCardListTextValue = "Card list:"
local modifyDeckFrameCardListTextAnchor = TOPLEFT
local modifyDeckFrameCardListTextParentAnchor = TOPLEFT
local modifyDeckFrameCardListTextXOffset = 15
local modifyDeckFrameCardListTextYOffset = -42
-- Navigate to add card frame button
local modifyDeckFrameNavigateToAddCardButtonName = "NavigateToAddCardFromModifyDeckButton"
local modifyDeckFrameNavigateToAddCardButtonText = "Add Card"
local modifyDeckFrameNavigateToAddCardButtonAnchor = TOPRIGHT
local modifyDeckFrameNavigateToAddCardButtonXOffset = -20
local modifyDeckFrameNavigateToAddCardButtonYOffset = -35
-- Navigate to main menu button
local modifyDeckFrameNavigateToMainMenuButtonName = "NavigateToMainMenuFromModifyDeckButton"
local modifyDeckFrameNavigateToMainMenuButtonText = "Back"
local modifyDeckFrameNavigateToMainMenuButtonAnchor = BOTTOMRIGHT
local modifyDeckFrameNavigateToMainMenuButtonXOffset = -20
local modifyDeckFrameNavigateToMainMenuButtonYOffset = 20
local modifyDeckFrameNavigateToMainMenuButtonSound = SOUNDKIT.IG_CHARACTER_INFO_CLOSE

local listOfCardsFrameRowHeight = 20
local textMenu -- Reference to right click context menu
local pages = {}
local currentPageIndex = 1
local maximumPages = 1
local numberOfRowsPerPage = 100
local rows = {}
local currentNumberOfRowsOnPage = 0 -- Used to keep track when this reaches 0 when a user deletes enough cards, to auto-switch to the previous page
local listOfSelectedCardIDs = {}
local multipleCardsSelected = false
local editCardButtonOnClick -- Function
local deleteCardButtonOnClick -- Function
local unselectAllRows -- Function to unselect all rows
local selectRow -- Function to select a single row
local unselectRow -- Function to unselect a single row
local populateRows -- Function to populate rows of cards for the current page
local createPages -- Function to create the pages of cards

-- Confirmation box that appears when you attempt to delete multiple selected cards
local multipleCardsDeletionConfirmationFrame
local multipleCardsDeletionConfirmationFrameName = "MultipleCardsDeletionConfirmationFrame"
local multipleCardsDeletionConfirmationFrameTitle = "Confirm Deletion"
local multipleCardsDeletionConfirmationFrameText = "Are you sure you want to delete all the selected cards?"

-- Add card frame
local addCardFrame
local addCardFrameName = "AddCardFrame"
local addCardFrameTitle = "Add Card"

-- Edit card frame
local editCardFrame
local editCardFrameName = "EditCardFrame"
local editCardFrameTitle = "Edit Card"
local idOfCardBeingEdited = 0

-- Add and Edit Card frames variables in common
local cardQuestionTextBoxGreyHintText = "Enter question..."
local cardAnswerTextBoxGreyHintText = "Enter answer..."

-- Flashcard frame
local flashcardFrame
local flashcardFrameName = "FlashcardFrame"
local flashcardFrameTitlePrefix = "Deck: " -- Title changes to display deck name when you navigate to this frame

-- Deck settings frame
local deckSettingsFrame
local deckSettingsFrameName = "DeckSettingsFrame"
local deckSettingsFrameTitlePrefix = "Deck Settings - "


-- FUNCTIONS
--------------------------------------------------------------------------------------------------------------------------------

-- Get frame by name
local function getFrame(frameName)
	return ProductiveWoWAllFrames[frameName]
end

-- Reposition next frame to position of previous frame, then show it (used for navigating between frames)
local function repositionAndShowFrame(frame)
	frame:ClearAllPoints()
	frame:SetPoint(menuCurrentAnchorPoint, menuCurrentAnchorRelativeTo, menuCurrentRelativePoint, menuCurrentXOffsetFromCenter, menuCurrentYOffsetFromCenter)
	frame:Show()
end

-- Function to create a new frame, wraps WoW's CreateFrame() in order to trigger additional functionality such as adding the frame to the list of all frames
local function createFrame(frameName, parentFrame, frameTitle, frameWidth, frameHeight)
	local newFrame = CreateFrame(FRAME, frameName, parentFrame, BASIC_FRAME_TEMPLATE_WITH_INSET)
	ProductiveWoWAllFrames[frameName] = newFrame
	-- Default size if no width/height is specified
	frameWidth = frameWidth or basicFrameWidth
	frameHeight = frameHeight or basicFrameHeight
	newFrame:SetSize(frameWidth, frameHeight)
	newFrame:SetPoint(CENTER, parentFrame, CENTER, menuCurrentXOffsetFromCenter, menuCurrentYOffsetFromCenter)
	newFrame.TitleBg:SetHeight(basicFrameTitleBackgroundHeight)
	newFrame.title = newFrame:CreateFontString(nil, OVERLAY, GAME_FONT_NORMAL)
	newFrame.title:SetPoint(TOPLEFT, newFrame.TitleBg, TOPLEFT, basicFrameTitleOffsetXFromTopLeft, basicFrameTitleOffsetYFromTopLeft)
	newFrame.title:SetText(frameTitle)
	newFrame:EnableMouse(true)
	newFrame:SetMovable(true)
	newFrame:SetDontSavePosition(true) -- Disable position tracking by Blizzard's UI manager because we're tracking it using menuCurrentXOffsetFromCenter and menuCurrentYOffsetFromCenter
	newFrame:RegisterForDrag(MOUSE_LEFT)
	newFrame:SetScript(ON_MOUSE_DRAG_START, function(self)
		self:StartMoving()
	end)
	newFrame:SetScript(ON_MOUSE_DRAG_STOP, function(self)
		self:StopMovingOrSizing()
		local point, relativeTo, relativePoint, x, y = newFrame:GetPoint()
		menuCurrentAnchorPoint = point
		menuCurrentAnchorRelativeTo = relativeTo
		menuCurrentRelativePoint = relativePoint
		menuCurrentXOffsetFromCenter = x
		menuCurrentYOffsetFromCenter = y
	end)
	table.insert(UISpecialFrames, frameName) -- This makes the frame closeable by pressing the Escape key
	return newFrame
end

-- Create a basic button
local function createButton(buttonName, parentFrame, buttonText, anchorPoint, xOffset, yOffset, onClickFunction)
	local newButton = CreateFrame(BUTTON, buttonName, parentFrame, UI_PANEL_BUTTON_TEMPLATE)
	local relativeToAnchorPoint = anchorPoint
	newButton:SetSize(basicButtonWidth, basicButtonHeight)
	newButton:SetPoint(anchorPoint, parentFrame, relativeToAnchorPoint, xOffset, yOffset)
	newButton:SetText(buttonText)
	newButton:SetScript(ON_CLICK, function(...)
		if onClickFunction ~= nil then
			onClickFunction(...)
		end
	end)
	return newButton
end

-- Create a basic navigation button
local function createNavigationButton(buttonName, parentFrame, buttonText, anchorPoint, xOffset, yOffset, frameToNavigateTo, sound, onClickFunction, navigationConditionsFunction, onNavigationFunction)
	local newButton = CreateFrame(BUTTON, buttonName, parentFrame, UI_PANEL_BUTTON_TEMPLATE)
	local relativeToAnchorPoint = anchorPoint
	sound = sound or SOUNDKIT.IG_CHARACTER_INFO_OPEN
	newButton:SetSize(basicButtonWidth, basicButtonHeight)
	newButton:SetPoint(anchorPoint, parentFrame, relativeToAnchorPoint, xOffset, yOffset)
	newButton:SetText(buttonText)
	newButton:SetScript(ON_CLICK, function(self)
		if onClickFunction ~= nil then
			onClickFunction() -- Run OnClick function regardless of navigation conditions passing or failing
		end
		local navigationConditionsPassed = true
		if navigationConditionsFunction ~= nil then
			navigationConditionsPassed = navigationConditionsFunction() -- Check if conditions passed to navigate to next frame
		end
		if navigationConditionsPassed == false then
			-- Navigation conditions failed
			return
		else
			-- Navigation conditions passed
			if onNavigationFunction	~= nil then
					onNavigationFunction()
			end
			parentFrame:Hide()
			repositionAndShowFrame(frameToNavigateTo)
			PlaySound(sound)
		end
	end)
	return newButton
end	

-- Create a basic text box
local function createTextBox(textboxName, parentFrame, width, height, anchorPoint, xOffset, yOffset, greyHintText)
	local newTextBox = CreateFrame(EDITBOX, textboxName, parentFrame, INPUT_BOX_TEMPLATE)
	local relativeToAnchorPoint = anchorPoint
	if greyHintText == nil then
		greyHintText = ""
	end
	newTextBox.greyHintText = greyHintText
	newTextBox:SetSize(width, height)
	newTextBox:SetPoint(anchorPoint, parentFrame, relativeToAnchorPoint, xOffset, yOffset)
	newTextBox:SetAutoFocus(false)
	newTextBox:SetText(greyHintText)
	newTextBox:SetTextColor(unpack(GREY))
	newTextBox:SetCursorPosition(0)
	newTextBox.hasFocus = false
	newTextBox:SetScript(ON_EDIT_FOCUS_GAINED, function(self)
		self.hasFocus = true
		if self:GetText() == greyHintText then
			self:SetText("")
			self:SetTextColor(unpack(WHITE))
		end
	end)
	newTextBox:SetScript(ON_EDIT_FOCUS_LOST, function(self)
		self.hasFocus = false
		if self:GetText() == "" then
			self:SetText(greyHintText)
			self:SetTextColor(unpack(GREY))
		end
	end)
	newTextBox:SetScript(ON_ENTER_PRESSED, function(self)
		self:ClearFocus()
		newTextBox.hasFocus = false
	end)
	parentFrame:SetScript(ON_MOUSE_DOWN, function(self)
		if newTextBox.hasFocus then
			newTextBox:ClearFocus()
			newTextBox.hasFocus = false
		end
	end)

	return newTextBox
end

-- Create basic text
local function createText(anchor, parent, parentAnchor, xOffset, yOffset, text)
	local textObject = parent:CreateFontString(nil, OVERLAY, GAME_FONT_HIGHLIGHT)
	textObject:SetPoint(anchor, parent, parentAnchor, xOffset, yOffset)
	textObject:SetText(text)
	textObject:SetJustifyH(JUSTIFY_LEFT)
	textObject:SetNonSpaceWrap(false)
	textObject:SetWordWrap(false)
	return textObject
end

-- Clear textbox to show hint text
local function clearTextBox(textbox)
	textbox:SetText(textbox.greyHintText)
	textbox:SetTextColor(unpack(GREY))
	if textbox.hasFocus then
		textbox:ClearFocus()
		textbox.hasFocus = false
	end
end

-- Hide all frames
function ProductiveWoW_hideAllFrames()
	for key, frame in pairs(ProductiveWoWAllFrames) do
		frame:Hide()
	end
end

-- Show main menu
function ProductiveWoW_showMainMenu()
	ProductiveWoW_hideAllFrames()
	repositionAndShowFrame(getFrame(mainMenuFrameName))
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN)
end

-- Are any frames shown?
function ProductiveWoW_anyFrameIsShown()
	for key, frame in pairs(ProductiveWoWAllFrames) do
		if frame:IsShown() then
			return true
		end
	end
	return false
end

-- Get current frame shown
function ProductiveWoW_getCurrentlyShownFrame()
	for key, frame in pairs(ProductiveWoWAllFrames) do
		if frame:IsShown() then
			return frame
		end
	end
	return nil
end

-- Create all the base frames of the addon
local function createAllBaseFrames()
	mainMenu = createFrame(mainMenuFrameName, UIParent, mainMenuFrameTitle)
	createDeckFrame = createFrame(createDeckFrameName, UIParent, createDeckFrameTitle)
	deleteDeckFrame = createFrame(deleteDeckFrameName, UIParent, deleteDeckFrameTitle)
	modifyDeckFrame = createFrame(modifyDeckFrameName, UIParent, "", modifyDeckFrameWidth, modifyDeckFrameHeight)
	addCardFrame = createFrame(addCardFrameName, UIParent, addCardFrameTitle)
	editCardFrame = createFrame(editCardFrameName, UIParent, editCardFrameTitle)
	flashcardFrame = createFrame(flashcardFrameName, UIParent)
	multipleCardsDeletionConfirmationFrame = createFrame(multipleCardsDeletionConfirmationFrameName, UIParent, multipleCardsDeletionConfirmationFrameTitle)
	deckSettingsFrame = createFrame(deckSettingsFrameName, UIParent, "")
end

-- Configure the main menu frame
local function configureMainMenuFrame()
	-- Choose deck text
	mainMenu.chooseDeckText = createText(mainMenuChooseDeckTextAnchor, mainMenu, mainMenuChooseDeckTextParentAnchor, mainMenuChooseDeckTextXOffset, mainMenuChooseDeckTextYOffset, mainMenuChooseDeckTextValue)

	-- Choose deck dropdown
	-- Generator function generates the content of the dropdown
	function chooseDeckDropdownGeneratorFunction(owner, rootDescription)
		owner:SetDefaultText(ProductiveWoW_getCurrentDeckName()) -- Reset to blank if selected deck was just deleted
		-- Grab list of decks from ProductiveWoWData and create a dropdown button for each
		-- Extract keys (which are the deck names) and sort them alphabetically
		local deckNames = ProductiveWoW_getKeys(ProductiveWoW_getAllDecks())
		table.sort(deckNames)
		-- Create dropdown buttons for each deck
		for i, deckName in ipairs(deckNames) do
			rootDescription:CreateButton(deckName, function(data)
				-- Function that determines what happens when you click on a deck in the dropdown
				ProductiveWoW_setCurrentlySelectedDeck(deckName)
				mainMenu.chooseDeckDropdown:SetDefaultText(deckName)
			end)
		end
	end
	mainMenu.chooseDeckDropdown = CreateFrame(DROPDOWN_BUTTON, mainMenuChooseDeckDropdownName, mainMenu, WOW_STYLE_1_DROPDOWN_TEMPLATE)
	mainMenu.chooseDeckDropdown:SetSize(mainMenuChooseDeckDropdownWidth, mainMenuChooseDeckDropdownHeight)
	mainMenu.chooseDeckDropdown:SetPoint(mainMenuChooseDeckDropdownAnchor, mainMenu, mainMenuChooseDeckDropdownParentAnchor, mainMenuChooseDeckDropdownXOffset, mainMenuChooseDeckDropdownYOffset)
	mainMenu.chooseDeckDropdown:SetupMenu(chooseDeckDropdownGeneratorFunction)
	mainMenu.chooseDeckDropdown:SetDefaultText(ProductiveWoW_getCurrentDeckName())
	mainMenu.chooseDeckDropdown:SetScript(ON_SHOW, function()
		mainMenu.chooseDeckDropdown:GenerateMenu()
	end)

	-- Create new deck button that takes you to create deck frame
	mainMenu.navigateToCreateDeckButton = createNavigationButton(mainMenuNavigateToCreateDeckButtonName, mainMenu, mainMenuNavigateToCreateDeckButtonText, mainMenuNavigateToCreateDeckButtonAnchor, mainMenuNavigateToCreateDeckButtonXOffset, mainMenuNavigateToCreateDeckButtonYOffset, createDeckFrame)

	-- Create delete deck button that takes you to delete deck frame
	mainMenu.navigateToDeleteDeckButton = createNavigationButton(mainMenuNavigateToDeleteDeckButtonName, mainMenu, mainMenuNavigateToDeleteDeckButtonText, mainMenuNavigateToDeleteDeckButtonAnchor, mainMenuNavigateToDeleteDeckButtonXOffset, mainMenuNavigateToDeleteDeckButtonYOffset, deleteDeckFrame)

	-- Create modify deck button that takes you to the modify deck frame
	local function navigateToModifyDeckButtonNavigationConditions()
		local currentDeckName = ProductiveWoW_getCurrentDeckName()
		if currentDeckName ~= nil then
			return true
		else
			print(navigateToModifyDeckButtonNoDeckSelectedMessage)
			return false
		end
	end

	-- Function that runs when navigateToModifyDeckButtonNavigationConditions() returns true and you switch to the modify deck frame
	local function navigateToModifyDeckButtonOnNavigation()
		-- Set title of Modify Deck frame
		modifyDeckFrame.title:SetText(modifyDeckFrameTitlePrefix .. ProductiveWoW_getCurrentDeckName())
	end
	-- Button to navigate to the modify deck frame assuming conditions are met
	mainMenu.navigateToModifyDeckButton = createNavigationButton(mainMenuNavigateToModifyDeckButtonName, mainMenu, mainMenuNavigateToModifyDeckButtonText, mainMenuNavigateToModifyDeckButtonAnchor, mainMenuNavigateToModifyDeckButtonXOffset, mainMenuNavigateToModifyDeckButtonYOffset, modifyDeckFrame, nil, nil, navigateToModifyDeckButtonNavigationConditions, navigateToModifyDeckButtonOnNavigation)

	-- Create button to begin flashcard quiz
	local function navigateToFlashcardFrameButtonNavigationConditions()
		local currentDeckName = ProductiveWoW_getCurrentDeckName()
		if currentDeckName ~= nil then
			if ProductiveWoW_tableLength(ProductiveWoW_getDeckCards(currentDeckName)) ~= 0 then
				if not ProductiveWoW_isDeckCompletedForToday(currentDeckName) then
					return true
				else
					print(mainMenuNavigateToFlashcardFrameButtonAlreadyCompletedDeckTodayMessage)
					return false
				end
			else
				print(mainMenuNavigateToFlashcardFrameButtonNoCardsInDeckMessage)
				return false
			end
		else
			print(mainMenuNavigateToFlashcardFrameButtonNoSelectedDeckMessage)
			return false
		end
	end
	local function navigateToFlashcardFrameButtonOnNavigation()
		flashcardFrame.title:SetText(flashcardFrameTitlePrefix .. ProductiveWoW_getCurrentDeckName())
		flashcardFrame.easyDifficultyButton:Hide()
		flashcardFrame.mediumDifficultyButton:Hide()
		flashcardFrame.hardDifficultyButton:Hide()
		flashcardFrame.showAnswerButton:Show()
	end
	mainMenu.navigateToFlashcardFrameButton = createNavigationButton(mainMenuNavigateToFlashcardFrameButtonName, mainMenu, mainMenuNavigateToFlashcardFrameButtonText, mainMenuNavigateToFlashcardFrameButtonAnchor, mainMenuNavigateToFlashcardFrameButtonXOffset, mainMenuNavigateToFlashcardFrameButtonYOffset, flashcardFrame, nil, nil, navigateToFlashcardFrameButtonNavigationConditions, navigateToFlashcardFrameButtonOnNavigation)
end

-- Configure create deck frame
local function configureCreateDeckFrame()
	-- Deck name textbox
	createDeckFrame.deckNameTextBox = createTextBox(createDeckFrameDeckNameTextBoxName, createDeckFrame, createDeckFrameDeckNameTextBoxWidth, createDeckFrameDeckNameTextBoxHeight, createDeckFrameDeckNameTextBoxAnchor, createDeckFrameDeckNameTextBoxXOffset, createDeckFrameDeckNameTextBoxYOffset, createDeckFrameDeckNameTextBoxGreyHintText)

	-- Create deck button
	local function createDeckButtonOnClick()
		local deckName = createDeckFrame.deckNameTextBox:GetText()
		if not ProductiveWoW_deckExists(deckName) then
			if not ProductiveWoW_stringContainsOnlyWhitespace(deckName) and deckName ~= createDeckFrameDeckNameTextBoxGreyHintText then
				ProductiveWoW_addDeck(deckName)
			else
				print(createDeckFrameCreateDeckButtonBlankNameMessage)
			end
		else
			print(createDeckFrameCreateDeckButtonDeckAlreadyExistsMessage)
		end	
		clearTextBox(createDeckFrame.deckNameTextBox)
	end
	createDeckFrame.createDeckButton = createNavigationButton(createDeckFrameCreateDeckButtonName, createDeckFrame, createDeckFrameCreateDeckButtonText, createDeckFrameCreateDeckButtonAnchor, createDeckFrameCreateDeckButtonXOffset, createDeckFrameCreateDeckButtonYOffset, mainMenu, createDeckFrameCreateDeckButtonSound, createDeckButtonOnClick)
end

local function configureDeleteDeckFrame()
	-- Delete deck by name textbox
	deleteDeckFrame.deleteDeckNameTextBox = createTextBox(deleteDeckFrameDeckNameTextBoxName, deleteDeckFrame, deleteDeckFrameDeckNameTextBoxWidth, deleteDeckFrameDeckNameTextBoxHeight, deleteDeckFrameDeckNameTextBoxAnchor, deleteDeckFrameDeckNameTextBoxXOffset, deleteDeckFrameDeckNameTextBoxYOffset, deleteDeckFrameDeckNameTextBoxGreyHintText)

	-- Delete deck button
	local function deleteDeckButtonOnClick()
		local deckName = deleteDeckFrame.deleteDeckNameTextBox:GetText()
		if ProductiveWoW_deckExists(deckName) and deckName ~= deleteDeckFrameDeckNameTextBoxGreyHintText then
			if not ProductiveWoW_deckExistsInBulkImportFile(deckName) then
				ProductiveWoW_deleteDeck(deckName)
			else
				print(deleteDeckFrameDeleteDeckButtonDeckExistsInBulkImportFileMessage)
			end
		else
			print(deleteDeckFrameDeleteDeckButtonDeckDoesNotExistMessage)
		end
		clearTextBox(deleteDeckFrame.deleteDeckNameTextBox)
	end
	deleteDeckFrame.deleteDeckButton = createNavigationButton(deleteDeckFrameDeleteDeckButtonName, deleteDeckFrame, deleteDeckFrameDeleteDeckButtonText, deleteDeckFrameDeleteDeckButtonAnchor, deleteDeckFrameDeleteDeckButtonXOffset, deleteDeckFrameDeleteDeckButtonYOffset, mainMenu, deleteDeckFrameDeleteDeckButtonSound, deleteDeckButtonOnClick)
end

local function configureModifyDeckFrame()
	-- "Card List: " Text
	modifyDeckFrame.cardListText = createText(modifyDeckFrameCardListTextAnchor, modifyDeckFrame, modifyDeckFrameCardListTextParentAnchor, modifyDeckFrameCardListTextXOffset, modifyDeckFrameCardListTextYOffset, modifyDeckFrameCardListTextValue)

	-- Navigate to Add Card Button
	modifyDeckFrame.navigateToAddCardButton = createNavigationButton(modifyDeckFrameNavigateToAddCardButtonName, modifyDeckFrame, modifyDeckFrameNavigateToAddCardButtonText, modifyDeckFrameNavigateToAddCardButtonAnchor, modifyDeckFrameNavigateToAddCardButtonXOffset, modifyDeckFrameNavigateToAddCardButtonYOffset, addCardFrame)

	-- Navigate back to main menu button
	modifyDeckFrame.navigateBackToMainMenuButton = createNavigationButton(modifyDeckFrameNavigateToMainMenuButtonName, modifyDeckFrame, modifyDeckFrameNavigateToMainMenuButtonText, modifyDeckFrameNavigateToMainMenuButtonAnchor, modifyDeckFrameNavigateToMainMenuButtonXOffset, modifyDeckFrameNavigateToMainMenuButtonYOffset, mainMenu, modifyDeckFrameNavigateToMainMenuButtonSound)
end


--------------------------------------------------------------------------------------------------------------------------------


-- Required to run in this block to ensure that saved variables are loaded before this code runs
EventUtil.ContinueOnAddOnLoaded(ProductiveWoW_ADDON_NAME, function()

	-- FRAME INITIALIZATION --
	-- Create all the frames
	createAllBaseFrames()

	-- FRAME CONFIGURATION --
	configureMainMenuFrame()
	configureCreateDeckFrame()
	configureDeleteDeckFrame()
	configureModifyDeckFrame()

	
	-- MODIFY DECK FRAME
	

	-- Navigate to deck settings button
	local function navigateToDeckSettingsFrameOnClick()
		deckSettingsFrame.title:SetText(deckSettingsFrameTitlePrefix .. ProductiveWoW_getCurrentDeckName())
	end
	modifyDeckFrame.navigateToDeckSettingsButton = createNavigationButton("NavigateToDeckSettingsButton", modifyDeckFrame, "Deck Settings", "BOTTOMLEFT", 20, 20, deckSettingsFrame, nil, navigateToDeckSettingsFrameOnClick)

	-- Current page text
	modifyDeckFrame.currentPageText = createText("CENTER", modifyDeckFrame, "BOTTOM", 0, 35, "1 of 1")

	-- Next page button
	local function nextPageButtonOnClick()
		local nextPageIndex = currentPageIndex + 1
		if nextPageIndex <= maximumPages then
			currentPageIndex = nextPageIndex
			createPages()
			populateRows()
			modifyDeckFrame.currentPageText:SetText(currentPageIndex .. " of " .. maximumPages)
			modifyDeckFrame.listOfCardsFrame:SetVerticalScroll(0)
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end
	modifyDeckFrame.nextPageButton = createButton("NextPageButton", modifyDeckFrame, "", "BOTTOM", 58, 20, nextPageButtonOnClick)
	modifyDeckFrame.nextPageButton:SetSize(30, 30)
	modifyDeckFrame.nextPageButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	modifyDeckFrame.nextPageButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")

	-- Previous page button
	local function previousPageButtonOnClick()
		local prevPageIndex = currentPageIndex - 1
		if prevPageIndex >= 1 then
			currentPageIndex = currentPageIndex - 1
			createPages()
			populateRows()
			modifyDeckFrame.currentPageText:SetText(currentPageIndex .. " of " .. maximumPages)
			modifyDeckFrame.listOfCardsFrame:SetVerticalScroll(0)
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end
	modifyDeckFrame.previousPageButton = createButton("PreviousPageButton", modifyDeckFrame, "", "BOTTOM", -58, 20, previousPageButtonOnClick)
	modifyDeckFrame.previousPageButton:SetSize(30, 30)
	modifyDeckFrame.previousPageButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	modifyDeckFrame.previousPageButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")

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
	modifyDeckFrame.answerColumnHeader = createText("TOPLEFT", modifyDeckFrame, "TOPLEFT", 238, -70, "Answer")

	-- Create the pages of cards in case there are so many cards that pages are needed to prevent a performance hit
	function createPages()
		pages = {}
		local cards = ProductiveWoW_getDeckCards(ProductiveWoWSavedSettings["currently_selected_deck"])
		local cardCounter = 0
		local currentPage = {}
		for cardId, card in pairs(cards) do
			currentPage[cardId] = card
			cardCounter = cardCounter + 1
			if cardCounter % numberOfRowsPerPage == 0 then
				table.insert(pages, ProductiveWoW_tableShallowCopy(currentPage))
				currentPage = {}
				cardCounter = 0
			end
		end
		-- Add final page since the loop won't add the final page because the modulo condition is not met if the # of rows < numberOfRowsPerPage for the final page
		if ProductiveWoW_tableLength(currentPage) ~= 0 then
			table.insert(pages, ProductiveWoW_tableShallowCopy(currentPage))
		end
		if ProductiveWoW_tableLength(pages) == 0 then
			pages = {{}}
		end
		maximumPages = ProductiveWoW_tableLength(pages)
	end
	
	-- Populate rows. This function creates a Frame for each row, since we can't delete frames, everytime it's repopulated when you switch a deck,
	-- we will need to reuse the existing row Frames just changing their text. New row Frames are only created when we have exhausted 
	-- all the existing row Frames. If we switch from Deck A which has 5 rows to Deck B which has 3 rows, we need to set the text of the 2 extra rows to blank
	function populateRows()
		local cards = pages[currentPageIndex]
		local table_index = 1 -- Need to increment index manually since card_id may not be continuous due to deletion of cards
		currentNumberOfRowsOnPage = 0
		if cards ~= nil then
			currentNumberOfRowsOnPage = ProductiveWoW_tableLength(cards)
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
		end
		-- Set text to blank for additional rows if current deck has fewer rows than the previously selected deck
		for i = currentNumberOfRowsOnPage + 1, ProductiveWoW_tableLength(rows) do
			rows[i].question:SetText("")
			rows[i].answer:SetText("")
			rows[i]:Hide()
		end
		-- Resize scroll content
		modifyDeckFrame.listOfCardsFrameContent:SetHeight(#rows * listOfCardsFrameRowHeight)
	end
	-- Re-populate rows when frame is shown
	modifyDeckFrame:SetScript("OnShow", function(self)
		currentPageIndex = 1
		createPages()
		populateRows()
		modifyDeckFrame.currentPageText:SetText(currentPageIndex .. " of " .. maximumPages)
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
		currentNumberOfRowsOnPage = currentNumberOfRowsOnPage - 1
		if currentNumberOfRowsOnPage == 0 and ProductiveWoW_tableLength(pages) >= 2 then
			-- If 2 or more pages, go to previous page
			previousPageButtonOnClick()
		else
			unselectAllRows()
			createPages()
			populateRows()
		end
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
	editCardFrame.navigateBackToMainMenuButton = createNavigationButton("NavigateBackToMainMenuButtonFromEditCardFrame", editCardFrame, "Main Menu", "CENTER", 100, -50, mainMenu, SOUNDKIT.IG_CHARACTER_INFO_CLOSE)

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
	addCardFrame.navigateBackToMainMenuButton = createNavigationButton("NavigateBackToMainMenuButtonFromAddCardFrame", addCardFrame, "Main Menu", "CENTER", 100, -50, mainMenu, SOUNDKIT.IG_CHARACTER_INFO_CLOSE)


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
			ProductiveWoW_onViewedCard(currentCardID)
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
	flashcardFrame.navigateBackToMainMenuFromFlashcardFrameButton = createNavigationButton("NavigateBackToMainMenuFromFlashcardFrameButton", flashcardFrame, "Main Menu", "BOTTOMRIGHT", -20, 20, mainMenu, SOUNDKIT.IG_CHARACTER_INFO_CLOSE)

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