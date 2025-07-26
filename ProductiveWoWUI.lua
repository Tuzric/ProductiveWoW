-- v1.3

-- INITIALIZE VARIABLES
--------------------------------------------------------------------------------------------------------------------------------
-- CONSTANTS
-- Frame anchor points
local ANCHOR_POINTS = {}
ANCHOR_POINTS.TOP = "TOP"
ANCHOR_POINTS.TOPLEFT = "TOPLEFT"
ANCHOR_POINTS.TOPRIGHT = "TOPRIGHT"
ANCHOR_POINTS.LEFT = "LEFT"
ANCHOR_POINTS.CENTER = "CENTER"
ANCHOR_POINTS.RIGHT = "RIGHT"
ANCHOR_POINTS.BOTTOM = "BOTTOM"
ANCHOR_POINTS.BOTTOMLEFT = "BOTTOMLEFT"
ANCHOR_POINTS.BOTTOMRIGHT = "BOTTOMRIGHT"
-- Frame types and templates
local FRAME_TYPES = {}
FRAME_TYPES.FRAME = "Frame"
FRAME_TYPES.BUTTON = "Button"
FRAME_TYPES.EDITBOX = "EditBox"
FRAME_TYPES.DROPDOWN_BUTTON = "DropdownButton"
FRAME_TYPES.SCROLL_FRAME = "ScrollFrame"
local FRAME_TEMPLATES = {}
FRAME_TEMPLATES.BASIC_FRAME_TEMPLATE_WITH_INSET = "BasicFrameTemplateWithInset"
FRAME_TEMPLATES.UI_PANEL_BUTTON_TEMPLATE = "UIPanelButtonTemplate"
FRAME_TEMPLATES.INPUT_BOX_TEMPLATE = "InputBoxTemplate"
FRAME_TEMPLATES.WOW_STYLE_1_DROPDOWN_TEMPLATE = "WowStyle1DropdownTemplate"
FRAME_TEMPLATES.UI_PANEL_SCROLL_FRAME_TEMPLATE = "UIPanelScrollFrameTemplate"
FRAME_TEMPLATES.BACKDROP_TEMPLATE = "BackdropTemplate"
-- Text
local TEXT_CONSTANTS = {}
TEXT_CONSTANTS.OVERLAY = "OVERLAY"
TEXT_CONSTANTS.GAME_FONT_NORMAL = "GameFontNormal"
TEXT_CONSTANTS.GAME_FONT_HIGHLIGHT = "GameFontHighlight"
TEXT_CONSTANTS.JUSTIFY_LEFT = "LEFT"
-- Textures
local TEXTURE_TEMPLATES = {}
TEXTURE_TEMPLATES.ARTWORK = "ARTWORK"
-- Colours
local COLOURS = {}
COLOURS.GREY = {0.5, 0.5, 0.5}
COLOURS.WHITE = {1, 1, 1}
-- Mouse/keyboard buttons
local INPUT_BUTTONS = {}
INPUT_BUTTONS.MOUSE_RIGHT = "RightButton"
INPUT_BUTTONS.MOUSE_LEFT = "LeftButton"
-- Events
local EVENTS = {}
EVENTS.ON_MOUSE_DRAG_START = "OnDragStart"
EVENTS.ON_MOUSE_DRAG_STOP = "OnDragStop"
EVENTS.ON_CLICK = "OnClick"
EVENTS.ON_EDIT_FOCUS_GAINED = "OnEditFocusGained"
EVENTS.ON_EDIT_FOCUS_LOST = "OnEditFocusLost"
EVENTS.ON_ENTER_PRESSED = "OnEnterPressed"
EVENTS.ON_MOUSE_DOWN = "OnMouseDown"
EVENTS.ON_MOUSE_UP = "OnMouseUp"
EVENTS.ON_SHOW = "OnShow"
EVENTS.ON_HIDE = "OnHide"
EVENTS.ON_ENTER = "OnEnter" -- When cursor enters the bounds of a frame
EVENTS.ON_LEAVE = "OnLeave" -- When cursor leaves the bounds of a frame


-- Variables for all frames
local ProductiveWoWAllFrames = {} -- Keep track of list of all frames
local commonFrameAttributes = {}
commonFrameAttributes.basicFrameWidth = 350 -- Frame width for most ProductiveWoW frames
commonFrameAttributes.basicFrameHeight = 150 -- Frame height for most ProductiveWoW frames
commonFrameAttributes.menuCurrentXOffsetFromCenter = 200 -- Track position by X offset from center of UIParent. These 2 variables are updated when a user drags the frame so that when they click a button to navigate to another frame, the next frame that opens up is opened in the same position as the previous frame
commonFrameAttributes.menuCurrentYOffsetFromCenter = 200 -- Same as above, but for Y offset
commonFrameAttributes.menuCurrentAnchorPoint = ANCHOR_POINTS.CENTER
commonFrameAttributes.menuCurrentAnchorRelativeTo = UIParent
commonFrameAttributes.menuCurrentRelativePoint = ANCHOR_POINTS.CENTER
commonFrameAttributes.basicFrameTitleBackgroundHeight = 30
commonFrameAttributes.basicFrameTitleOffsetXFromTopLeft = 5
commonFrameAttributes.basicFrameTitleOffsetYFromTopLeft = -5
commonFrameAttributes.basicButtonWidth = 100
commonFrameAttributes.basicButtonHeight = 30

-- Main menu frame
local mainMenu = {}
mainMenu.frameName = "MainMenuFrame"
mainMenu.frameTitle = ProductiveWoW_ADDON_NAME .. " " .. ProductiveWoW_ADDON_VERSION
-- Main menu choose deck text
mainMenu.chooseDeckTextAnchor = ANCHOR_POINTS.TOPLEFT
mainMenu.chooseDeckTextParentAnchor = ANCHOR_POINTS.TOPLEFT
mainMenu.chooseDeckTextXOffset = 15
mainMenu.chooseDeckTextYOffset = -40
mainMenu.chooseDeckTextValue = "Choose deck:"
-- Main menu choose deck dropdown
mainMenu.chooseDeckDropdownName = "ChooseDeckDropdown"
mainMenu.chooseDeckDropdownGeneratorFunction = nil -- Function for generating dropdown contents
mainMenu.chooseDeckDropdownWidth = 100
mainMenu.chooseDeckDropdownHeight = 25
mainMenu.chooseDeckDropdownAnchor = ANCHOR_POINTS.TOPLEFT
mainMenu.chooseDeckDropdownParentAnchor = ANCHOR_POINTS.TOPLEFT
mainMenu.chooseDeckDropdownXOffset = 100
mainMenu.chooseDeckDropdownYOffset = -35
-- Create deck button
mainMenu.navigateToCreateDeckButtonName = "NavigateToCreateDeckFromMainMenu"
mainMenu.navigateToCreateDeckButtonAnchor = ANCHOR_POINTS.TOPLEFT
mainMenu.navigateToCreateDeckButtonXOffset = 15
mainMenu.navigateToCreateDeckButtonYOffset = -60
mainMenu.navigateToCreateDeckButtonText = "Create Deck"
-- Delete deck button
mainMenu.navigateToDeleteDeckButtonName = "NavigateToDeleteDeckFromMainMenu"
mainMenu.navigateToDeleteDeckButtonAnchor = ANCHOR_POINTS.TOPLEFT
mainMenu.navigateToDeleteDeckButtonXOffset = 15
mainMenu.navigateToDeleteDeckButtonYOffset = -90
mainMenu.navigateToDeleteDeckButtonText = "Delete Deck"
-- Modify deck button
mainMenu.navigateToModifyDeckButtonName = "NavigateToModifyDeckFromMainMenu"
mainMenu.navigateToModifyDeckButtonAnchor = ANCHOR_POINTS.TOPLEFT
mainMenu.navigateToModifyDeckButtonXOffset = 230
mainMenu.navigateToModifyDeckButtonYOffset = -32
mainMenu.navigateToModifyDeckButtonText = "Modify Deck"
mainMenu.navigateToModifyDeckButtonNoDeckSelectedMessage = "No deck is currently selected."
mainMenu.navigateToModifyDeckButtonNavigationConditions = nil -- Function that's defined further down
mainMenu.navigateToModifyDeckButtonOnNavigation = nil -- Function that's defined further down
-- Begin quiz "Go" button
mainMenu.navigateToFlashcardFrameButtonName = "NavigateToFlashcardFrameFromMainMenu"
mainMenu.navigateToFlashcardFrameButtonText = "Go"
mainMenu.navigateToFlashcardFrameButtonAnchor = ANCHOR_POINTS.TOPLEFT
mainMenu.navigateToFlashcardFrameButtonXOffset = 230
mainMenu.navigateToFlashcardFrameButtonYOffset = -92
mainMenu.navigateToFlashcardFrameButtonAlreadyCompletedDeckTodayMessage = "You've already completed this deck today. If you would like to play it again, go to Modify Deck > Deck Settings > Change the value of Max Daily Cards."
mainMenu.navigateToFlashcardFrameButtonNoCardsInDeckMessage = "There are no cards in the selected deck."
mainMenu.navigateToFlashcardFrameButtonNoSelectedDeckMessage = "No deck is currently selected."
mainMenu.navigateToFlashcardFrameButtonNavigationConditions = nil -- Function that's defined further down
mainMenu.navigateToFlashcardFrameButtonOnNavigation = nil -- Function that's defined further down

-- Create deck frame
local createDeckFrame = {}
createDeckFrame.frameName = "CreateDeckFrame"
createDeckFrame.frameTitle = "Create Deck"
-- Create deck textbox
createDeckFrame.deckNameTextBoxGreyHintText = "Deck name..."
createDeckFrame.deckNameTextBoxName = "CreateDeckTextBox"
createDeckFrame.deckNameTextBoxAnchor = ANCHOR_POINTS.CENTER
createDeckFrame.deckNameTextBoxXOffset = 0
createDeckFrame.deckNameTextBoxYOffset = 0
createDeckFrame.deckNameTextBoxWidth = 200
createDeckFrame.deckNameTextBoxHeight = 25
createDeckFrame.createDeckButtonBlankNameMessage = "Deck name was blank so no deck was created."
createDeckFrame.createDeckButtonDeckAlreadyExistsMessage = "A deck by that name already exists."
-- Create deck button
createDeckFrame.createDeckButtonName = "CreateDeckButton"
createDeckFrame.createDeckButtonText = "Create"
createDeckFrame.createDeckButtonAnchor = ANCHOR_POINTS.CENTER
createDeckFrame.createDeckButtonXOffset = 0
createDeckFrame.createDeckButtonYOffset = -40
createDeckFrame.createDeckButtonSound = SOUNDKIT.IG_CHARACTER_INFO_CLOSE
createDeckFrame.createDeckButtonOnClick = nil -- Function defined further below

-- Delete deck frame
local deleteDeckFrame = {}
deleteDeckFrame.frameName = "DeleteDeckFrame"
deleteDeckFrame.frameTitle = "Delete Deck"
-- Delete deck textbox
deleteDeckFrame.deckNameTextBoxName = "DeleteDeckTextBox"
deleteDeckFrame.deckNameTextBoxGreyHintText = "Enter deck name to delete..."
deleteDeckFrame.deckNameTextBoxAnchor = ANCHOR_POINTS.CENTER
deleteDeckFrame.deckNameTextBoxXOffset = 0
deleteDeckFrame.deckNameTextBoxYOffset = 0
deleteDeckFrame.deckNameTextBoxWidth = 200
deleteDeckFrame.deckNameTextBoxHeight = 25
deleteDeckFrame.deleteDeckButtonDeckExistsInBulkImportFileMessage = "Cannot delete this deck because it exists in ProductiveWoWDecks.lua and will just be re-added when the addon is reloaded. Remove it from that file first, reload the game by typing /reload, then come back here to delete it."
deleteDeckFrame.deleteDeckButtonDeckDoesNotExistMessage = "A deck by that name does not exist."
-- Delete deck button
deleteDeckFrame.deleteDeckButtonName = "DeleteDeckButton"
deleteDeckFrame.deleteDeckButtonText = "Delete"
deleteDeckFrame.deleteDeckButtonAnchor = ANCHOR_POINTS.CENTER
deleteDeckFrame.deleteDeckButtonXOffset = 0
deleteDeckFrame.deleteDeckButtonYOffset = -40
deleteDeckFrame.deleteDeckButtonSound = SOUNDKIT.IG_CHARACTER_INFO_CLOSE
deleteDeckFrame.deleteDeckButtonOnClick = nil -- Function defined further below

-- Modify deck frame
local modifyDeckFrame = {}
modifyDeckFrame.frameName = "ModifyDeckFrame"
modifyDeckFrame.titlePrefix = "Modify Deck - " -- Title changes when you navigate to this frame to include the name of the deck
modifyDeckFrame.width = 450
modifyDeckFrame.height = 500
-- Card list text
modifyDeckFrame.cardListTextName = "CardListText"
modifyDeckFrame.cardListTextValue = "Card list:"
modifyDeckFrame.cardListTextAnchor = ANCHOR_POINTS.TOPLEFT
modifyDeckFrame.cardListTextParentAnchor = ANCHOR_POINTS.TOPLEFT
modifyDeckFrame.cardListTextXOffset = 15
modifyDeckFrame.cardListTextYOffset = -42
-- Navigate to add card frame button
modifyDeckFrame.navigateToAddCardButtonName = "NavigateToAddCardFromModifyDeckButton"
modifyDeckFrame.navigateToAddCardButtonText = "Add Card"
modifyDeckFrame.navigateToAddCardButtonAnchor = ANCHOR_POINTS.TOPRIGHT
modifyDeckFrame.navigateToAddCardButtonXOffset = -20
modifyDeckFrame.navigateToAddCardButtonYOffset = -33
-- Navigate to main menu button
modifyDeckFrame.navigateToMainMenuButtonName = "NavigateToMainMenuFromModifyDeckButton"
modifyDeckFrame.navigateToMainMenuButtonText = "Back"
modifyDeckFrame.navigateToMainMenuButtonAnchor = ANCHOR_POINTS.BOTTOMRIGHT
modifyDeckFrame.navigateToMainMenuButtonXOffset = -20
modifyDeckFrame.navigateToMainMenuButtonYOffset = 20
modifyDeckFrame.navigateToMainMenuButtonSound = SOUNDKIT.IG_CHARACTER_INFO_CLOSE
-- Navigate to deck settings button
modifyDeckFrame.navigateToDeckSettingsButtonName = "NavigateToDeckSettingsFromModifyDeck"
modifyDeckFrame.navigateToDeckSettingsButtonText = "Deck Settings"
modifyDeckFrame.navigateToDeckSettingsButtonAnchor = ANCHOR_POINTS.BOTTOMLEFT
modifyDeckFrame.navigateToDeckSettingsButtonXOffset = 20
modifyDeckFrame.navigateToDeckSettingsButtonYOffset = 20
modifyDeckFrame.navigateToDeckSettingsFrameOnClick = nil -- Function defined further below
-- Page number text
modifyDeckFrame.currentPageTextAnchor = ANCHOR_POINTS.CENTER
modifyDeckFrame.currentPageTextParentAnchor = ANCHOR_POINTS.BOTTOM
modifyDeckFrame.currentPageTextXOffset = 0
modifyDeckFrame.currentPageTextYOffset = 35
modifyDeckFrame.currentPageTextValue = "1 of 1"
-- List of cards
modifyDeckFrame.pages = {}
modifyDeckFrame.currentPageIndex = 1
modifyDeckFrame.maximumPages = 1
modifyDeckFrame.numberOfRowsPerPage = 100
modifyDeckFrame.questionToCardIdMapping = {}
modifyDeckFrame.sortedQuestions = {}
modifyDeckFrame.rows = {}
modifyDeckFrame.currentNumberOfRowsOnPage = 0 -- Used to keep track when this reaches 0 when a user deletes enough cards, to auto-switch to the previous page
modifyDeckFrame.rowWidthAmountSmallerThanFrameWidth = 45 -- The width of the row is determine by the width of the frame minus this number
modifyDeckFrame.listOfCardsFrameRowHeight = 20
modifyDeckFrame.rowBackdropTexture = "Interface\\Tooltips\\UI-Tooltip-Background"
modifyDeckFrame.rowBorderTexture = "Interface\\Tooltips\\UI-Tooltip-Border"
modifyDeckFrame.rowBackdropColour = {0.1, 0.1, 0.1, 0.8}
modifyDeckFrame.rowBackdropSelectedColour = {0.2, 0.2, 0.7, 0.9}
modifyDeckFrame.rowQuestionTextXOffset = 10
modifyDeckFrame.rowQuestionTextWidthAmountSmallerThanFrameWidth = 40 -- Width of text is equal to modifyDeckFrame width minus this number
modifyDeckFrame.rowAnswerTextWidthAmountSmallerThanFrameWidth = 100 -- Width of text is equal to modifyDeckFrame width minus this number
modifyDeckFrame.rowSelectedSound = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
modifyDeckFrame.singleCardSelectedRightClickMenu = nil
modifyDeckFrame.multipleCardsSelectedRightClickMenu = nil
modifyDeckFrame.listOfSelectedCardIDs = {}
modifyDeckFrame.questionColumnHeaderXOffset = 15 -- From TopLeft anchor point
modifyDeckFrame.questionColumnHeaderYOffset = -70 -- From TopLeft anchor point
modifyDeckFrame.questionColumnHeaderText = "Question"
modifyDeckFrame.answerColumnHeaderXOffset = -(modifyDeckFrame.width / 2) + 10 -- From TopRight anchor point
modifyDeckFrame.answerColumnHeaderYOffset = -70 -- From TopRight anchor point
modifyDeckFrame.answerColumnHeaderText = "Answer"
modifyDeckFrame.createRow = nil -- Function to create a row in the list
modifyDeckFrame.multipleCardsSelected = false
modifyDeckFrame.editCardButtonOnClick = nil -- Function
modifyDeckFrame.editCardButtonOnClickCardInBulkImportFileMessage = "Can't edit this card because it exists in ProductiveWoWDecks.lua and the pre-edit version of it would be re-added when you re-log. Go remove it from the file, re-log or type /reload, then try to edit the card again through the UI."
modifyDeckFrame.deleteCardButtonOnClickCardInBulkImportFileMessage = "\" could not be deleted since it exists in ProductiveWoWDecks.lua and will be re-added on the next login. Remove it from that file, re-log or type in /reload (important to do this otherwise you'll get the same error), then delete it through the UI."
modifyDeckFrame.deleteCardButtonOnClickSuccessfulDeletionMessage = "Successfully deleted card: "
modifyDeckFrame.deleteCardButtonOnClick = nil -- Function
modifyDeckFrame.unselectAllRows = nil -- Function to unselect all rows
modifyDeckFrame.selectRow = nil -- Function to select a single row
modifyDeckFrame.unselectRow = nil -- Function to unselect a single row
modifyDeckFrame.populateRows = nil -- Function to populate rows of cards for the current page
modifyDeckFrame.createPages = nil -- Function to create the pages of cards
modifyDeckFrame.getPage = nil -- Function to get a page by its index
modifyDeckFrame.getCurrentPage = nil -- Function to return current page table
modifyDeckFrame.refreshListOfCards = nil -- Function to refresh the list of cards shown
modifyDeckFrame.cancelSearch = nil -- Function to cancel search
modifyDeckFrame.listOfCardsFrameTopLeftAnchorXOffset = 10
modifyDeckFrame.listOfCardsFrameTopLeftAnchorYOffset = -90
modifyDeckFrame.listOfCardsFrameBottomRightAnchorXOffset = -35
modifyDeckFrame.listOfCardsFrameBottomRightAnchorYOffset = 60
modifyDeckFrame.listOfCardsFrameContentName = "ListOfCards"
modifyDeckFrame.rowRightClickMenuEditCardText = "Edit Card"
modifyDeckFrame.rowRightClickMenuDeleteCardText = "Delete Card"
modifyDeckFrame.rowRightClickMenuMultipleCardsDeletionText = "Delete All Selected Cards"
-- Next page button
modifyDeckFrame.nextPageButtonOnClick = nil -- Function to go to the next page
modifyDeckFrame.nextPageButtonName = "NextPageButton"
modifyDeckFrame.nextPageButtonXOffset = 58
modifyDeckFrame.nextPageButtonYOffset = 20
modifyDeckFrame.nextPageButtonWidth = 30
modifyDeckFrame.nextPageButtonHeight = 30
modifyDeckFrame.nextPageButtonIcon = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up"
modifyDeckFrame.nextPageButtonClickedIcon = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down"
-- Previous page button
modifyDeckFrame.previousPageButtonOnClick = nil -- Function to go to the previous page
modifyDeckFrame.previousPageButtonName = "PreviousPageButton"
modifyDeckFrame.previousPageButtonXOffset = -58
modifyDeckFrame.previousPageButtonYOffset = 20
modifyDeckFrame.previousPageButtonWidth = 30
modifyDeckFrame.previousPageButtonHeight = 30
modifyDeckFrame.previousPageButtonIcon = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up"
modifyDeckFrame.previousPageButtonClickedIcon = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down"
-- Card search bar textbox
modifyDeckFrame.cardSearchBarName = "CardSearchBarTextBox"
modifyDeckFrame.cardSearchBarWidth = modifyDeckFrame.width - 300
modifyDeckFrame.cardSearchBarHeight = 20
modifyDeckFrame.cardSearchBarAnchor = ANCHOR_POINTS.TOPLEFT
modifyDeckFrame.cardSearchBarXOffset = 80
modifyDeckFrame.cardSearchBarYOffset = -38
modifyDeckFrame.cardSearchBarGreyHintText = "Search..."
-- Card search button
modifyDeckFrame.searchActive = false
modifyDeckFrame.searchResultsCardIds = {}
modifyDeckFrame.cardSearchButtonName = "CardSearchButton"
modifyDeckFrame.cardSearchButtonText = "Search"
modifyDeckFrame.cardSearchButtonAnchor = ANCHOR_POINTS.TOPLEFT
modifyDeckFrame.cardSearchButtonXOffset = modifyDeckFrame.cardSearchBarXOffset + modifyDeckFrame.cardSearchBarWidth + 1
modifyDeckFrame.cardSearchButtonYOffset = -33
modifyDeckFrame.cardSearchButtonOnClick = nil -- Function to search for keywords in card question/answer
modifyDeckFrame.showSearchResults = nil -- Function to display the search results
-- Cancel search button
modifyDeckFrame.cancelSearchButtonName = "CancelSearchButton"
modifyDeckFrame.cancelSearchButtonText = "Cancel Search"
modifyDeckFrame.cancelSearchButtonAnchor = ANCHOR_POINTS.BOTTOM
modifyDeckFrame.cancelSearchButtonXOffset = 0
modifyDeckFrame.cancelSearchButtonYOffset = 20
modifyDeckFrame.cancelSearchButtonOnClick = nil -- Function

-- Confirmation box that appears when you attempt to delete multiple selected cards
local multipleCardsDeletionConfirmationFrame = {}
multipleCardsDeletionConfirmationFrame.frameName = "MultipleCardsDeletionConfirmationFrame"
multipleCardsDeletionConfirmationFrame.frameTitle = "Confirm Deletion"
multipleCardsDeletionConfirmationFrame.width = commonFrameAttributes.basicFrameWidth + 40
multipleCardsDeletionConfirmationFrame.confirmationTextAnchor = ANCHOR_POINTS.CENTER
multipleCardsDeletionConfirmationFrame.confirmationTextParentAnchor = ANCHOR_POINTS.CENTER
multipleCardsDeletionConfirmationFrame.confirmationTextXOffset = 0
multipleCardsDeletionConfirmationFrame.confirmationTextYOffset = 15
multipleCardsDeletionConfirmationFrame.confirmationTextValue = "Are you sure you want to delete all the selected cards?"
-- Multiple cards deletion Yes button
multipleCardsDeletionConfirmationFrame.multipleCardsDeletionYesButtonOnClick = nil -- Function when "Yes" button is clicked
multipleCardsDeletionConfirmationFrame.yesButtonName = "MultipleCardsDeletionConfirmationFrameYesButton"
multipleCardsDeletionConfirmationFrame.yesButtonText = "Yes"
multipleCardsDeletionConfirmationFrame.yesButtonAnchor = ANCHOR_POINTS.CENTER
multipleCardsDeletionConfirmationFrame.yesButtonXOffset = -70
multipleCardsDeletionConfirmationFrame.yesButtonYOffset = -40
-- Multiple cards deletion Cancel button
multipleCardsDeletionConfirmationFrame.multipleCardsDeletionCancelButtonOnClick = nil -- Function when "Cancel" button is clicked
multipleCardsDeletionConfirmationFrame.cancelButtonName = "MultipleCardsDeletionConfirmationFrameCancelButton"
multipleCardsDeletionConfirmationFrame.cancelButtonText = "Cancel"
multipleCardsDeletionConfirmationFrame.cancelButtonAnchor = ANCHOR_POINTS.CENTER
multipleCardsDeletionConfirmationFrame.cancelButtonXOffset = 70
multipleCardsDeletionConfirmationFrame.cancelButtonYOffset = -40

-- Add card frame
local addCardFrame = {}
addCardFrame.frameName = "AddCardFrame"
addCardFrame.frameTitle = "Add Card"
-- Question textbox
addCardFrame.questionTextBoxName = "AddCardFrameQuestionTextBox"
addCardFrame.questionTextBoxWidth = 200
addCardFrame.questionTextBoxHeight = 20
addCardFrame.questionTextBoxAnchor = ANCHOR_POINTS.CENTER
addCardFrame.questionTextBoxXOffset = 0
addCardFrame.questionTextBoxYOffset = 20
addCardFrame.questionTextBoxGreyHintText = "Enter question..."
-- Answer textbox
addCardFrame.answerTextBoxName = "AddCardFrameQuestionTextBox"
addCardFrame.answerTextBoxWidth = 200
addCardFrame.answerTextBoxHeight = 20
addCardFrame.answerTextBoxAnchor = ANCHOR_POINTS.CENTER
addCardFrame.answerTextBoxXOffset = 0
addCardFrame.answerTextBoxYOffset = -20
addCardFrame.answerTextBoxGreyHintText = "Enter answer..."
-- Add card button
addCardFrame.addCardButtonName = "AddCardButton"
addCardFrame.addCardButtonText = "Add"
addCardFrame.addCardButtonAnchor = ANCHOR_POINTS.CENTER
addCardFrame.addCardButtonXOffset = -100
addCardFrame.addCardButtonYOffset = -50
addCardFrame.cardAddedMessage = "Card has been added."
addCardFrame.cardAlreadyExistsMessage = "A card with that question already exists."
addCardFrame.noDeckSelectedMessage = "No deck is selected."
addCardFrame.questionOrAnswerIsBlankMessage = "You have not entered a question or answer."
addCardFrame.addCardButtonOnClick = nil -- Function to add a new card
-- Back to modify deck frame button
addCardFrame.navigateBackToModifyDeckFrameButtonName = "NavigateBackToModifyDeckFromAddCard"
addCardFrame.navigateBackToModifyDeckFrameButtonText = "Back"
addCardFrame.navigateBackToModifyDeckFrameButtonAnchor = ANCHOR_POINTS.CENTER
addCardFrame.navigateBackToModifyDeckFrameButtonXOffset = 0
addCardFrame.navigateBackToModifyDeckFrameButtonYOffset = -50
addCardFrame.navigateBackToModifyDeckFrameButtonSound = SOUNDKIT.IG_CHARACTER_INFO_CLOSE
-- Back to main menu button
addCardFrame.navigateBackToMainMenuButtonName = "NavigateBackToMainMenuFromAddCard"
addCardFrame.navigateBackToMainMenuButtonText = "Main Menu"
addCardFrame.navigateBackToMainMenuButtonAnchor = ANCHOR_POINTS.CENTER
addCardFrame.navigateBackToMainMenuButtonXOffset = 100
addCardFrame.navigateBackToMainMenuButtonYOffset = -50
addCardFrame.navigateBackToMainMenuButtonSound = SOUNDKIT.IG_CHARACTER_INFO_CLOSE

-- Edit card frame
local editCardFrame = {}
editCardFrame.frameName = "EditCardFrame"
editCardFrame.frameTitle = "Edit Card"
editCardFrame.idOfCardBeingEdited = 0
-- Question textbox
editCardFrame.questionTextBoxName = "EditCardFrameQuestionTextBox"
editCardFrame.questionTextBoxWidth = 200
editCardFrame.questionTextBoxHeight = 20
editCardFrame.questionTextBoxAnchor = ANCHOR_POINTS.CENTER
editCardFrame.questionTextBoxXOffset = 0
editCardFrame.questionTextBoxYOffset = 20
editCardFrame.questionTextBoxGreyHintText = "Enter question..."
-- Answer textbox
editCardFrame.answerTextBoxName = "EditCardFrameAnswerTextBox"
editCardFrame.answerTextBoxWidth = 200
editCardFrame.answerTextBoxHeight = 20
editCardFrame.answerTextBoxAnchor = ANCHOR_POINTS.CENTER
editCardFrame.answerTextBoxXOffset = 0
editCardFrame.answerTextBoxYOffset = -20
editCardFrame.answerTextBoxGreyHintText = "Enter answer..."
-- Save card button
editCardFrame.saveCardButtonName = "SaveCardButton"
editCardFrame.saveCardButtonText = "Save"
editCardFrame.saveCardButtonAnchor = ANCHOR_POINTS.CENTER
editCardFrame.saveCardButtonXOffset = -100
editCardFrame.saveCardButtonYOffset = -50
editCardFrame.saveCardButtonOnClick = nil -- Function to save the card
editCardFrame.cardExistsInBulkImportFileMessage = "Could not save card since the question entered exists in ProductiveWoWDecks.lua and will be overwritten/deleted on the next login. Go to that file and modify the card there or remove it and try again through the UI."
editCardFrame.cardSavedMessage = "Card has been saved."
editCardFrame.duplicateQuestionMessage = "Another card with that question already exists."
editCardFrame.noChangesMadeMessage = "You have not made any changes to the card."
editCardFrame.noDeckSelectedMessage = "No deck is selected."
editCardFrame.questionOrAnswerIsBlankMessage = "You have not entered a question or answer."
-- Back to modify deck frame button
editCardFrame.navigateBackToModifyDeckFrameButtonName = "NavigateBackToModifyDeckFromEditCard"
editCardFrame.navigateBackToModifyDeckFrameButtonText = "Back"
editCardFrame.navigateBackToModifyDeckFrameButtonAnchor = ANCHOR_POINTS.CENTER
editCardFrame.navigateBackToModifyDeckFrameButtonXOffset = 0
editCardFrame.navigateBackToModifyDeckFrameButtonYOffset = -50
editCardFrame.navigateBackToModifyDeckFrameButtonSound = SOUNDKIT.IG_CHARACTER_INFO_CLOSE
-- Back to main menu button
editCardFrame.navigateBackToMainMenuButtonName = "NavigateBackToMainMenuFromEditCard"
editCardFrame.navigateBackToMainMenuButtonText = "Main Menu"
editCardFrame.navigateBackToMainMenuButtonAnchor = ANCHOR_POINTS.CENTER
editCardFrame.navigateBackToMainMenuButtonXOffset = 100
editCardFrame.navigateBackToMainMenuButtonYOffset = -50
editCardFrame.navigateBackToMainMenuButtonSound = SOUNDKIT.IG_CHARACTER_INFO_CLOSE

-- Flashcard frame
local flashcardFrame = {}
flashcardFrame.frameName = "FlashcardFrame"
flashcardFrame.titlePrefix = "Deck: " -- Title changes to display deck name when you navigate to this frame
flashcardFrame.width = commonFrameAttributes.basicFrameWidth + 100
flashcardFrame.height = commonFrameAttributes.basicFrameHeight + 100
-- Displayed text
flashcardFrame.textTopLeftAnchorXOffset = 15
flashcardFrame.textTopLeftAnchorYOffset = -10
flashcardFrame.textBottomRightAnchorXOffset = -15
flashcardFrame.textBottomRightAnchorYOffset = 20
flashcardFrame.showNextCard = nil -- Function to display next card
flashcardFrame.showAnswerButtonOnClick = nil -- Function that runs when "Show" button is clicked
-- Show answer button
flashcardFrame.showAnswerButtonName = "ShowAnswerButton"
flashcardFrame.showAnswerButtonText = "Show"
flashcardFrame.showAnswerButtonAnchor = ANCHOR_POINTS.BOTTOMLEFT
flashcardFrame.showAnswerButtonXOffset = 20
flashcardFrame.showAnswerButtonYOffset = 20
-- Easy/Medium/Hard Buttons
flashcardFrame.nextQuestion = nil -- Function to go to the next question
flashcardFrame.easyDifficultyButtonOnClick = nil -- Function when Easy button is clicked
flashcardFrame.easyDifficultyButtonName = "EasyDifficultyButton"
flashcardFrame.easyDifficultyButtonText = "Easy"
flashcardFrame.easyDifficultyButtonAnchor = ANCHOR_POINTS.BOTTOMLEFT
flashcardFrame.easyDifficultyButtonXOffset = 20
flashcardFrame.easyDifficultyButtonYOffset = 20
flashcardFrame.mediumDifficultyButtonOnClick = nil -- Function when Medium button is clicked
flashcardFrame.mediumDifficultyButtonName = "MediumDifficultyButton"
flashcardFrame.mediumDifficultyButtonText = "Medium"
flashcardFrame.mediumDifficultyButtonAnchor = ANCHOR_POINTS.BOTTOMLEFT
flashcardFrame.mediumDifficultyButtonXOffset = 120
flashcardFrame.mediumDifficultyButtonYOffset = 20
flashcardFrame.hardDifficultyButtonOnClick = nil -- Function when Hard button is clicked
flashcardFrame.hardDifficultyButtonName = "HardDifficultyButton"
flashcardFrame.hardDifficultyButtonText = "Hard"
flashcardFrame.hardDifficultyButtonAnchor = ANCHOR_POINTS.BOTTOMLEFT
flashcardFrame.hardDifficultyButtonXOffset = 220
flashcardFrame.hardDifficultyButtonYOffset = 20
-- Navigate back to main menu button
flashcardFrame.navigateBackToMainMenuButtonName = "NavigateBackToMainMenuFromFlashcardFrameButton"
flashcardFrame.navigateBackToMainMenuButtonText = "Main Menu"
flashcardFrame.navigateBackToMainMenuButtonAnchor = ANCHOR_POINTS.BOTTOMRIGHT
flashcardFrame.navigateBackToMainMenuButtonXOffset = -20
flashcardFrame.navigateBackToMainMenuButtonYOffset = 20
flashcardFrame.navigateBackToMainMenuButtonSound = SOUNDKIT.IG_CHARACTER_INFO_CLOSE

-- Deck settings frame
local deckSettingsFrame = {}
deckSettingsFrame.frameName = "DeckSettingsFrame"
deckSettingsFrame.titlePrefix = "Deck Settings - "
-- Back to modify deck frame button
deckSettingsFrame.navigateBackToModifyDeckFrameButtonName = "NavigateBackToModifyDeckFromDeckSettings"
deckSettingsFrame.navigateBackToModifyDeckFrameButtonText = "Back"
deckSettingsFrame.navigateBackToModifyDeckFrameButtonAnchor = ANCHOR_POINTS.BOTTOMRIGHT
deckSettingsFrame.navigateBackToModifyDeckFrameButtonXOffset = -20
deckSettingsFrame.navigateBackToModifyDeckFrameButtonYOffset = 20
deckSettingsFrame.navigateBackToModifyDeckFrameButtonSound = SOUNDKIT.IG_CHARACTER_INFO_CLOSE
-- Max daily cards text
deckSettingsFrame.maxCardsTextAnchor = ANCHOR_POINTS.TOPLEFT
deckSettingsFrame.maxCardsTextParentAnchor = ANCHOR_POINTS.TOPLEFT
deckSettingsFrame.maxCardsTextXOffset = 20
deckSettingsFrame.maxCardsTextYOffset = -40
deckSettingsFrame.maxCardsTextValue = "Max daily cards: "
-- Max daily cards textbox
deckSettingsFrame.maxCardsTextBoxName = "MaxDailyCardsTextBox"
deckSettingsFrame.maxCardsTextBoxWidth = 40
deckSettingsFrame.maxCardsTextBoxHeight = 20
deckSettingsFrame.maxCardsTextBoxAnchor = ANCHOR_POINTS.TOPLEFT
deckSettingsFrame.maxCardsTextBoxXOffset = 140
deckSettingsFrame.maxCardsTextBoxYOffset = -36
-- Save settings button
deckSettingsFrame.saveDeckSettingsButtonName = "SaveSettingsButton"
deckSettingsFrame.saveDeckSettingsButtonText = "Save"
deckSettingsFrame.saveDeckSettingsButtonAnchor = ANCHOR_POINTS.BOTTOMLEFT
deckSettingsFrame.saveDeckSettingsButtonXOffset = 20
deckSettingsFrame.saveDeckSettingsButtonYOffset = 20
deckSettingsFrame.saveDeckSettingsButtonOnClick = nil -- Function to save the deck settings
deckSettingsFrame.maxDailyCardsHasToBeNumericMessage = "Max daily cards has to be a number."
deckSettingsFrame.maxDailyCardsCannotBeZeroOrLessMessage = "Max daily cards cannot be 0 or less than 0."
deckSettingsFrame.noChangesMadeMessage = "No changes were made so nothing was saved."
deckSettingsFrame.settingsSavedMessage = "Settings saved."


-- FUNCTIONS
--------------------------------------------------------------------------------------------------------------------------------

-- Get frame by name
local function getFrame(frameName)
	return ProductiveWoWAllFrames[frameName]
end

-- Reposition next frame to position of previous frame, then show it (used for navigating between frames)
local function repositionAndShowFrame(frame)
	frame:ClearAllPoints()
	frame:SetPoint(commonFrameAttributes.menuCurrentAnchorPoint, commonFrameAttributes.menuCurrentAnchorRelativeTo, commonFrameAttributes.menuCurrentRelativePoint, commonFrameAttributes.menuCurrentXOffsetFromCenter, commonFrameAttributes.menuCurrentYOffsetFromCenter)
	frame:Show()
end

-- Function to create a new frame, wraps WoW's CreateFrame() in order to trigger additional functionality such as adding the frame to the list of all frames
local function createFrame(frameName, parentFrame, frameTitle, frameWidth, frameHeight)
	local newFrame = CreateFrame(FRAME_TYPES.FRAME, frameName, parentFrame, FRAME_TEMPLATES.BASIC_FRAME_TEMPLATE_WITH_INSET)
	ProductiveWoWAllFrames[frameName] = newFrame
	-- Default size if no width/height is specified
	frameWidth = frameWidth or commonFrameAttributes.basicFrameWidth
	frameHeight = frameHeight or commonFrameAttributes.basicFrameHeight
	newFrame:SetSize(frameWidth, frameHeight)
	newFrame:SetPoint(ANCHOR_POINTS.CENTER, parentFrame, ANCHOR_POINTS.CENTER, commonFrameAttributes.menuCurrentXOffsetFromCenter, commonFrameAttributes.menuCurrentYOffsetFromCenter)
	newFrame.title = newFrame:CreateFontString(nil, TEXT_CONSTANTS.OVERLAY, TEXT_CONSTANTS.GAME_FONT_NORMAL)
	newFrame.title:SetPoint(ANCHOR_POINTS.TOPLEFT, newFrame, ANCHOR_POINTS.TOPLEFT, commonFrameAttributes.basicFrameTitleOffsetXFromTopLeft, commonFrameAttributes.basicFrameTitleOffsetYFromTopLeft)
	newFrame.title:SetText(frameTitle)
	newFrame:EnableMouse(true)
	newFrame:SetMovable(true)
	newFrame:SetDontSavePosition(true) -- Disable position tracking by Blizzard's UI manager because we're tracking it using menuCurrentXOffsetFromCenter and menuCurrentYOffsetFromCenter
	newFrame:RegisterForDrag(INPUT_BUTTONS.MOUSE_LEFT)
	newFrame:SetScript(EVENTS.ON_MOUSE_DRAG_START, function(self)
		self:StartMoving()
	end)
	newFrame:SetScript(EVENTS.ON_MOUSE_DRAG_STOP, function(self)
		self:StopMovingOrSizing()
		local point, relativeTo, relativePoint, x, y = newFrame:GetPoint()
		commonFrameAttributes.menuCurrentAnchorPoint = point
		commonFrameAttributes.menuCurrentAnchorRelativeTo = relativeTo
		commonFrameAttributes.menuCurrentRelativePoint = relativePoint
		commonFrameAttributes.menuCurrentXOffsetFromCenter = x
		commonFrameAttributes.menuCurrentYOffsetFromCenter = y
	end)
	table.insert(UISpecialFrames, frameName) -- This makes the frame closeable by pressing the Escape key
	return newFrame
end

-- Create a basic button
local function createButton(buttonName, parentFrame, buttonText, anchorPoint, xOffset, yOffset, onClickFunction)
	local newButton = CreateFrame(FRAME_TYPES.BUTTON, buttonName, parentFrame, FRAME_TEMPLATES.UI_PANEL_BUTTON_TEMPLATE)
	local relativeToAnchorPoint = anchorPoint
	newButton:SetSize(commonFrameAttributes.basicButtonWidth, commonFrameAttributes.basicButtonHeight)
	newButton:SetPoint(anchorPoint, parentFrame, relativeToAnchorPoint, xOffset, yOffset)
	newButton:SetText(buttonText)
	newButton:SetScript(EVENTS.ON_CLICK, function(...)
		if onClickFunction ~= nil then
			onClickFunction(...)
		end
	end)
	return newButton
end

-- Create a basic navigation button
local function createNavigationButton(buttonName, parentFrame, buttonText, anchorPoint, xOffset, yOffset, frameToNavigateTo, sound, onClickFunction, navigationConditionsFunction, onNavigationFunction)
	local newButton = CreateFrame(FRAME_TYPES.BUTTON, buttonName, parentFrame, FRAME_TEMPLATES.UI_PANEL_BUTTON_TEMPLATE)
	local relativeToAnchorPoint = anchorPoint
	sound = sound or SOUNDKIT.IG_CHARACTER_INFO_OPEN
	newButton:SetSize(commonFrameAttributes.basicButtonWidth, commonFrameAttributes.basicButtonHeight)
	newButton:SetPoint(anchorPoint, parentFrame, relativeToAnchorPoint, xOffset, yOffset)
	newButton:SetText(buttonText)
	newButton:SetScript(EVENTS.ON_CLICK, function(self)
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
	local newTextBox = CreateFrame(FRAME_TYPES.EDITBOX, textboxName, parentFrame, FRAME_TEMPLATES.INPUT_BOX_TEMPLATE)
	local relativeToAnchorPoint = anchorPoint
	if greyHintText == nil then
		greyHintText = ""
	end
	newTextBox.greyHintText = greyHintText
	newTextBox:SetSize(width, height)
	newTextBox:SetPoint(anchorPoint, parentFrame, relativeToAnchorPoint, xOffset, yOffset)
	newTextBox:SetAutoFocus(false)
	newTextBox:SetText(greyHintText)
	newTextBox:SetTextColor(unpack(COLOURS.GREY))
	newTextBox:SetCursorPosition(0)
	newTextBox.hasFocus = false
	newTextBox:SetScript(EVENTS.ON_EDIT_FOCUS_GAINED, function(self)
		self.hasFocus = true
		if self:GetText() == greyHintText then
			self:SetText("")
			self:SetTextColor(unpack(COLOURS.WHITE))
		end
	end)
	newTextBox:SetScript(EVENTS.ON_EDIT_FOCUS_LOST, function(self)
		self.hasFocus = false
		if self:GetText() == "" then
			self:SetText(greyHintText)
			self:SetTextColor(unpack(COLOURS.GREY))
		end
	end)
	newTextBox:SetScript(EVENTS.ON_ENTER_PRESSED, function(self)
		self:ClearFocus()
		newTextBox.hasFocus = false
	end)
	parentFrame:SetScript(EVENTS.ON_MOUSE_DOWN, function(self)
		if newTextBox.hasFocus then
			newTextBox:ClearFocus()
			newTextBox.hasFocus = false
		end
	end)

	return newTextBox
end

-- Create basic text
local function createText(anchor, parent, parentAnchor, xOffset, yOffset, text)
	local textObject = parent:CreateFontString(nil, TEXT_CONSTANTS.OVERLAY, TEXT_CONSTANTS.GAME_FONT_HIGHLIGHT)
	textObject:SetPoint(anchor, parent, parentAnchor, xOffset, yOffset)
	textObject:SetText(text)
	textObject:SetJustifyH(TEXT_CONSTANTS.JUSTIFY_LEFT)
	textObject:SetNonSpaceWrap(false)
	textObject:SetWordWrap(false)
	return textObject
end

-- Clear textbox to show hint text
local function clearTextBox(textbox)
	textbox:SetText(textbox.greyHintText)
	textbox:SetTextColor(unpack(COLOURS.GREY))
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
	repositionAndShowFrame(getFrame(mainMenu.frameName))
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
	mainMenu.Frame = createFrame(mainMenu.frameName, UIParent, mainMenu.frameTitle)
	createDeckFrame.Frame = createFrame(createDeckFrame.frameName, UIParent, createDeckFrame.frameTitle)
	deleteDeckFrame.Frame = createFrame(deleteDeckFrame.frameName, UIParent, deleteDeckFrame.frameTitle)
	modifyDeckFrame.Frame = createFrame(modifyDeckFrame.frameName, UIParent, "", modifyDeckFrame.width, modifyDeckFrame.height)
	addCardFrame.Frame = createFrame(addCardFrame.frameName, UIParent, addCardFrame.frameTitle)
	editCardFrame.Frame = createFrame(editCardFrame.frameName, UIParent, editCardFrame.frameTitle)
	flashcardFrame.Frame = createFrame(flashcardFrame.frameName, UIParent)
	multipleCardsDeletionConfirmationFrame.Frame = createFrame(multipleCardsDeletionConfirmationFrame.frameName, UIParent, multipleCardsDeletionConfirmationFrame.frameTitle)
	deckSettingsFrame.Frame = createFrame(deckSettingsFrame.frameName, UIParent, "")
end

-- Configure the main menu frame
local function configureMainMenuFrame()
	-- Choose deck text
	mainMenu.chooseDeckText = createText(mainMenu.chooseDeckTextAnchor, mainMenu.Frame, mainMenu.chooseDeckTextParentAnchor, mainMenu.chooseDeckTextXOffset, mainMenu.chooseDeckTextYOffset, mainMenu.chooseDeckTextValue)

	-- Choose deck dropdown
	-- Generator function generates the content of the dropdown
	function mainMenu.chooseDeckDropdownGeneratorFunction(owner, rootDescription)
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
	mainMenu.chooseDeckDropdown = CreateFrame(FRAME_TYPES.DROPDOWN_BUTTON, mainMenu.chooseDeckDropdownName, mainMenu.Frame, FRAME_TEMPLATES.WOW_STYLE_1_DROPDOWN_TEMPLATE)
	mainMenu.chooseDeckDropdown:SetSize(mainMenu.chooseDeckDropdownWidth, mainMenu.chooseDeckDropdownHeight)
	mainMenu.chooseDeckDropdown:SetPoint(mainMenu.chooseDeckDropdownAnchor, mainMenu.Frame, mainMenu.chooseDeckDropdownParentAnchor, mainMenu.chooseDeckDropdownXOffset, mainMenu.chooseDeckDropdownYOffset)
	mainMenu.chooseDeckDropdown:SetupMenu(mainMenu.chooseDeckDropdownGeneratorFunction)
	mainMenu.chooseDeckDropdown:SetDefaultText(ProductiveWoW_getCurrentDeckName())
	mainMenu.chooseDeckDropdown:SetScript(EVENTS.ON_SHOW, function()
		mainMenu.chooseDeckDropdown:GenerateMenu()
	end)

	-- Create new deck button that takes you to create deck frame
	mainMenu.navigateToCreateDeckButton = createNavigationButton(mainMenu.navigateToCreateDeckButtonName, mainMenu.Frame, mainMenu.navigateToCreateDeckButtonText, mainMenu.navigateToCreateDeckButtonAnchor, mainMenu.navigateToCreateDeckButtonXOffset, mainMenu.navigateToCreateDeckButtonYOffset, createDeckFrame.Frame)

	-- Create delete deck button that takes you to delete deck frame
	mainMenu.navigateToDeleteDeckButton = createNavigationButton(mainMenu.navigateToDeleteDeckButtonName, mainMenu.Frame, mainMenu.navigateToDeleteDeckButtonText, mainMenu.navigateToDeleteDeckButtonAnchor, mainMenu.navigateToDeleteDeckButtonXOffset, mainMenu.navigateToDeleteDeckButtonYOffset, deleteDeckFrame.Frame)

	-- Create modify deck button that takes you to the modify deck frame
	function mainMenu.navigateToModifyDeckButtonNavigationConditions()
		local currentDeckName = ProductiveWoW_getCurrentDeckName()
		if currentDeckName ~= nil then
			return true
		else
			print(mainMenu.navigateToModifyDeckButtonNoDeckSelectedMessage)
			return false
		end
	end

	-- Function that runs when navigateToModifyDeckButtonNavigationConditions() returns true and you switch to the modify deck frame
	function mainMenu.navigateToModifyDeckButtonOnNavigation()
		-- Set title of Modify Deck frame
		modifyDeckFrame.Frame.title:SetText(modifyDeckFrame.titlePrefix .. ProductiveWoW_getCurrentDeckName())
	end
	-- Button to navigate to the modify deck frame assuming conditions are met
	mainMenu.navigateToModifyDeckButton = createNavigationButton(mainMenu.navigateToModifyDeckButtonName, mainMenu.Frame, mainMenu.navigateToModifyDeckButtonText, mainMenu.navigateToModifyDeckButtonAnchor, mainMenu.navigateToModifyDeckButtonXOffset, mainMenu.navigateToModifyDeckButtonYOffset, modifyDeckFrame.Frame, nil, nil, mainMenu.navigateToModifyDeckButtonNavigationConditions, mainMenu.navigateToModifyDeckButtonOnNavigation)

	-- Create button to begin flashcard quiz
	function mainMenu.navigateToFlashcardFrameButtonNavigationConditions()
		local currentDeckName = ProductiveWoW_getCurrentDeckName()
		if currentDeckName ~= nil then
			if ProductiveWoW_tableLength(ProductiveWoW_getDeckCards(currentDeckName)) ~= 0 then
				if not ProductiveWoW_isDeckCompletedForToday(currentDeckName) then
					return true
				else
					print(mainMenu.navigateToFlashcardFrameButtonAlreadyCompletedDeckTodayMessage)
					return false
				end
			else
				print(mainMenu.navigateToFlashcardFrameButtonNoCardsInDeckMessage)
				return false
			end
		else
			print(mainMenu.navigateToFlashcardFrameButtonNoSelectedDeckMessage)
			return false
		end
	end
	function mainMenu.navigateToFlashcardFrameButtonOnNavigation()
		flashcardFrame.Frame.title:SetText(flashcardFrame.titlePrefix .. ProductiveWoW_getCurrentDeckName())
		flashcardFrame.easyDifficultyButton:Hide()
		flashcardFrame.mediumDifficultyButton:Hide()
		flashcardFrame.hardDifficultyButton:Hide()
		flashcardFrame.showAnswerButton:Show()
	end
	mainMenu.navigateToFlashcardFrameButton = createNavigationButton(mainMenu.navigateToFlashcardFrameButtonName, mainMenu.Frame, mainMenu.navigateToFlashcardFrameButtonText, mainMenu.navigateToFlashcardFrameButtonAnchor, mainMenu.navigateToFlashcardFrameButtonXOffset, mainMenu.navigateToFlashcardFrameButtonYOffset, flashcardFrame.Frame, nil, nil, mainMenu.navigateToFlashcardFrameButtonNavigationConditions, mainMenu.navigateToFlashcardFrameButtonOnNavigation)
end

-- Configure create deck frame
local function configureCreateDeckFrame()
	-- Deck name textbox
	createDeckFrame.deckNameTextBox = createTextBox(createDeckFrame.deckNameTextBoxName, createDeckFrame.Frame, createDeckFrame.deckNameTextBoxWidth, createDeckFrame.deckNameTextBoxHeight, createDeckFrame.deckNameTextBoxAnchor, createDeckFrame.deckNameTextBoxXOffset, createDeckFrame.deckNameTextBoxYOffset, createDeckFrame.deckNameTextBoxGreyHintText)

	-- Create deck button
	function createDeckFrame.createDeckButtonOnClick()
		local deckName = createDeckFrame.deckNameTextBox:GetText()
		if not ProductiveWoW_deckExists(deckName) then
			if not ProductiveWoW_stringContainsOnlyWhitespace(deckName) and deckName ~= createDeckFrame.deckNameTextBoxGreyHintText then
				ProductiveWoW_addDeck(deckName)
			else
				print(createDeckFrame.createDeckButtonBlankNameMessage)
			end
		else
			print(createDeckFrame.createDeckButtonDeckAlreadyExistsMessage)
		end	
		clearTextBox(createDeckFrame.deckNameTextBox)
	end
	createDeckFrame.createDeckButton = createNavigationButton(createDeckFrame.createDeckButtonName, createDeckFrame.Frame, createDeckFrame.createDeckButtonText, createDeckFrame.createDeckButtonAnchor, createDeckFrame.createDeckButtonXOffset, createDeckFrame.createDeckButtonYOffset, mainMenu.Frame, createDeckFrame.createDeckButtonSound, createDeckFrame.createDeckButtonOnClick)
end

local function configureDeleteDeckFrame()
	-- Delete deck by name textbox
	deleteDeckFrame.deleteDeckNameTextBox = createTextBox(deleteDeckFrame.deckNameTextBoxName, deleteDeckFrame.Frame, deleteDeckFrame.deckNameTextBoxWidth, deleteDeckFrame.deckNameTextBoxHeight, deleteDeckFrame.deckNameTextBoxAnchor, deleteDeckFrame.deckNameTextBoxXOffset, deleteDeckFrame.deckNameTextBoxYOffset, deleteDeckFrame.deckNameTextBoxGreyHintText)

	-- Delete deck button
	function deleteDeckFrame.deleteDeckButtonOnClick()
		local deckName = deleteDeckFrame.deleteDeckNameTextBox:GetText()
		if ProductiveWoW_deckExists(deckName) and deckName ~= deleteDeckFrame.deckNameTextBoxGreyHintText then
			if not ProductiveWoW_deckExistsInBulkImportFile(deckName) then
				ProductiveWoW_deleteDeck(deckName)
			else
				print(deleteDeckFrame.deleteDeckButtonDeckExistsInBulkImportFileMessage)
			end
		else
			print(deleteDeckFrame.deleteDeckButtonDeckDoesNotExistMessage)
		end
		clearTextBox(deleteDeckFrame.deleteDeckNameTextBox)
	end
	deleteDeckFrame.deleteDeckButton = createNavigationButton(deleteDeckFrame.deleteDeckButtonName, deleteDeckFrame.Frame, deleteDeckFrame.deleteDeckButtonText, deleteDeckFrame.deleteDeckButtonAnchor, deleteDeckFrame.deleteDeckButtonXOffset, deleteDeckFrame.deleteDeckButtonYOffset, mainMenu.Frame, deleteDeckFrame.deleteDeckButtonSound, deleteDeckFrame.deleteDeckButtonOnClick)
end

local function configureModifyDeckFrame()
	-- "Card List: " Text
	modifyDeckFrame.cardListText = createText(modifyDeckFrame.cardListTextAnchor, modifyDeckFrame.Frame, modifyDeckFrame.cardListTextParentAnchor, modifyDeckFrame.cardListTextXOffset, modifyDeckFrame.cardListTextYOffset, modifyDeckFrame.cardListTextValue)

	-- Navigate to Add Card Button
	modifyDeckFrame.navigateToAddCardButton = createNavigationButton(modifyDeckFrame.navigateToAddCardButtonName, modifyDeckFrame.Frame, modifyDeckFrame.navigateToAddCardButtonText, modifyDeckFrame.navigateToAddCardButtonAnchor, modifyDeckFrame.navigateToAddCardButtonXOffset, modifyDeckFrame.navigateToAddCardButtonYOffset, addCardFrame.Frame)

	-- Navigate back to main menu button
	modifyDeckFrame.navigateBackToMainMenuButton = createNavigationButton(modifyDeckFrame.navigateToMainMenuButtonName, modifyDeckFrame.Frame, modifyDeckFrame.navigateToMainMenuButtonText, modifyDeckFrame.navigateToMainMenuButtonAnchor, modifyDeckFrame.navigateToMainMenuButtonXOffset, modifyDeckFrame.navigateToMainMenuButtonYOffset, mainMenu.Frame, modifyDeckFrame.navigateToMainMenuButtonSound)

	-- Navigate to deck settings button
	function modifyDeckFrame.navigateToDeckSettingsFrameOnClick()
		deckSettingsFrame.Frame.title:SetText(deckSettingsFrame.titlePrefix .. ProductiveWoW_getCurrentDeckName())
	end
	modifyDeckFrame.navigateToDeckSettingsButton = createNavigationButton(modifyDeckFrame.navigateToDeckSettingsButtonName, modifyDeckFrame.Frame, modifyDeckFrame.navigateToDeckSettingsButtonText, modifyDeckFrame.navigateToDeckSettingsButtonAnchor, modifyDeckFrame.navigateToDeckSettingsButtonXOffset, modifyDeckFrame.navigateToDeckSettingsButtonYOffset, deckSettingsFrame.Frame, nil, modifyDeckFrame.navigateToDeckSettingsFrameOnClick)

	-- Current page text
	modifyDeckFrame.currentPageText = createText(modifyDeckFrame.currentPageTextAnchor, modifyDeckFrame.Frame, modifyDeckFrame.currentPageTextParentAnchor, modifyDeckFrame.currentPageTextXOffset, modifyDeckFrame.currentPageTextYOffset, modifyDeckFrame.currentPageTextValue)

	-- Next page button
	function modifyDeckFrame.nextPageButtonOnClick()
		local nextPageIndex = modifyDeckFrame.currentPageIndex + 1
		if nextPageIndex <= modifyDeckFrame.maximumPages then
			modifyDeckFrame.currentPageIndex = nextPageIndex
			modifyDeckFrame.refreshListOfCards()
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end
	modifyDeckFrame.nextPageButton = createButton(modifyDeckFrame.nextPageButtonName, modifyDeckFrame.Frame, "", ANCHOR_POINTS.BOTTOM, modifyDeckFrame.nextPageButtonXOffset, modifyDeckFrame.nextPageButtonYOffset, modifyDeckFrame.nextPageButtonOnClick)
	modifyDeckFrame.nextPageButton:SetSize(modifyDeckFrame.nextPageButtonWidth, modifyDeckFrame.nextPageButtonHeight)
	modifyDeckFrame.nextPageButton:SetNormalTexture(modifyDeckFrame.nextPageButtonIcon)
	modifyDeckFrame.nextPageButton:SetPushedTexture(modifyDeckFrame.nextPageButtonClickedIcon)

	-- Previous page button
	function modifyDeckFrame.previousPageButtonOnClick()
		local prevPageIndex = modifyDeckFrame.currentPageIndex - 1
		if prevPageIndex >= 1 then
			modifyDeckFrame.currentPageIndex = modifyDeckFrame.currentPageIndex - 1
			modifyDeckFrame.refreshListOfCards()
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end
	modifyDeckFrame.previousPageButton = createButton(modifyDeckFrame.previousPageButtonName, modifyDeckFrame.Frame, "", ANCHOR_POINTS.BOTTOM, modifyDeckFrame.previousPageButtonXOffset, modifyDeckFrame.previousPageButtonYOffset, modifyDeckFrame.previousPageButtonOnClick)
	modifyDeckFrame.previousPageButton:SetSize(modifyDeckFrame.previousPageButtonWidth, modifyDeckFrame.previousPageButtonHeight)
	modifyDeckFrame.previousPageButton:SetNormalTexture(modifyDeckFrame.previousPageButtonIcon)
	modifyDeckFrame.previousPageButton:SetPushedTexture(modifyDeckFrame.previousPageButtonClickedIcon)

	-- Scrollable list of cards in deck
	modifyDeckFrame.listOfCardsFrame = CreateFrame(FRAME_TYPES.SCROLL_FRAME, modifyDeckFrame.listOfCardsFrameName, modifyDeckFrame.Frame, FRAME_TEMPLATES.UI_PANEL_SCROLL_FRAME_TEMPLATE)
	modifyDeckFrame.listOfCardsFrame:SetPoint(ANCHOR_POINTS.TOPLEFT, modifyDeckFrame.listOfCardsFrameTopLeftAnchorXOffset, modifyDeckFrame.listOfCardsFrameTopLeftAnchorYOffset)
	modifyDeckFrame.listOfCardsFrame:SetPoint(ANCHOR_POINTS.BOTTOMRIGHT, modifyDeckFrame.listOfCardsFrameBottomRightAnchorXOffset, modifyDeckFrame.listOfCardsFrameBottomRightAnchorYOffset)
	modifyDeckFrame.listOfCardsFrameContent = CreateFrame(FRAME_TYPES.FRAME, modifyDeckFrame.listOfCardsFrameContentName, modifyDeckFrame.listOfCardsFrame)
	modifyDeckFrame.listOfCardsFrameContent:SetPoint(ANCHOR_POINTS.TOPLEFT, modifyDeckFrame.listOfCardsFrame, ANCHOR_POINTS.TOPLEFT, 0, 0)
	modifyDeckFrame.listOfCardsFrameContent:SetSize(1, 1) -- Required for scroll frames's scroll child
	modifyDeckFrame.listOfCardsFrame:SetScrollChild(modifyDeckFrame.listOfCardsFrameContent)
	modifyDeckFrame.listOfCardsFrame:SetVerticalScroll(0)

	-- Column headers
	modifyDeckFrame.questionColumnHeader = createText(ANCHOR_POINTS.TOPLEFT, modifyDeckFrame.Frame, ANCHOR_POINTS.TOPLEFT, modifyDeckFrame.questionColumnHeaderXOffset, modifyDeckFrame.questionColumnHeaderYOffset, modifyDeckFrame.questionColumnHeaderText)
	modifyDeckFrame.answerColumnHeader = createText(ANCHOR_POINTS.TOPLEFT, modifyDeckFrame.Frame, ANCHOR_POINTS.TOPRIGHT, modifyDeckFrame.answerColumnHeaderXOffset, modifyDeckFrame.answerColumnHeaderYOffset, modifyDeckFrame.answerColumnHeaderText)

	-- Card search bar
	modifyDeckFrame.cardSearchBar = createTextBox(modifyDeckFrame.cardSearchBarName, modifyDeckFrame.Frame, modifyDeckFrame.cardSearchBarWidth, modifyDeckFrame.cardSearchBarHeight, modifyDeckFrame.cardSearchBarAnchor, modifyDeckFrame.cardSearchBarXOffset, modifyDeckFrame.cardSearchBarYOffset, modifyDeckFrame.cardSearchBarGreyHintText)

	-- Card search button
	function modifyDeckFrame.cardSearchButtonOnClick()
		local currentDeckName = ProductiveWoW_getCurrentDeckName()
		local searchSubstring = modifyDeckFrame.cardSearchBar:GetText()
		if not ProductiveWoW_stringContainsOnlyWhitespace(searchSubstring) then
			if searchSubstring ~= modifyDeckFrame.cardSearchBarGreyHintText then
				local cardMatches = ProductiveWoW_getDeckCardsContainingSubstringInQuestionOrAnswer(currentDeckName, searchSubstring)
				-- Sort it alphabetically
				local questionsToCardIdsMapping = {}
				local sortedQuestions = {}
				for cardId, cardTable in pairs(cardMatches) do
					local question = ProductiveWoW_getQuestionFromCardTable(cardTable)
					questionsToCardIdsMapping[question] = cardId
					table.insert(sortedQuestions, question)
				end
				table.sort(sortedQuestions)
				modifyDeckFrame.searchResultsCardIds = {}
				for i, question in ipairs(sortedQuestions) do
					local cardId = questionsToCardIdsMapping[question]
					table.insert(modifyDeckFrame.searchResultsCardIds, cardId)
				end
				modifyDeckFrame.showSearchResults(modifyDeckFrame.searchResultsCardIds)
				modifyDeckFrame.searchActive = true
			end
		else
			clearTextBox(modifyDeckFrame.cardSearchBar)
		end
		modifyDeckFrame.cardSearchBar:ClearFocus()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end
	modifyDeckFrame.cardSearchButton = createButton(modifyDeckFrame.cardSearchButtonName, modifyDeckFrame.Frame, modifyDeckFrame.cardSearchButtonText, modifyDeckFrame.cardSearchButtonAnchor, modifyDeckFrame.cardSearchButtonXOffset, modifyDeckFrame.cardSearchButtonYOffset, modifyDeckFrame.cardSearchButtonOnClick)

	-- Cancel search
	function modifyDeckFrame.cancelSearch()
		modifyDeckFrame.previousPageButton:Show()
		modifyDeckFrame.currentPageText:Show()
		modifyDeckFrame.nextPageButton:Show()
		modifyDeckFrame.cancelSearchButton:Hide()
		clearTextBox(modifyDeckFrame.cardSearchBar)
		modifyDeckFrame.searchResultsCardIds = {}
		modifyDeckFrame.searchActive = false
	end

	-- Cancel search button
	function modifyDeckFrame.cancelSearchButtonOnClick()
		modifyDeckFrame.cancelSearch()
		modifyDeckFrame.createPages()
		modifyDeckFrame.refreshListOfCards()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end
	modifyDeckFrame.cancelSearchButton = createButton(modifyDeckFrame.cancelSearchButtonName, modifyDeckFrame.Frame, modifyDeckFrame.cancelSearchButtonText, modifyDeckFrame.cancelSearchButtonAnchor, modifyDeckFrame.cancelSearchButtonXOffset, modifyDeckFrame.cancelSearchButtonYOffset, modifyDeckFrame.cancelSearchButtonOnClick)
	modifyDeckFrame.cancelSearchButton:Hide()

	function modifyDeckFrame.showSearchResults(searchResults)
		modifyDeckFrame.currentPageIndex = 1
		modifyDeckFrame.maximumPages = 1
		modifyDeckFrame.listOfCardsFrame:SetVerticalScroll(0)
		modifyDeckFrame.previousPageButton:Hide()
		modifyDeckFrame.currentPageText:Hide()
		modifyDeckFrame.nextPageButton:Hide()
		modifyDeckFrame.cancelSearchButton:Show()
		modifyDeckFrame.unselectAllRows()
		modifyDeckFrame.populateRows(modifyDeckFrame.currentPageIndex, searchResults)
	end

	function modifyDeckFrame.unselectAllRows()
		for i, row in ipairs(modifyDeckFrame.rows) do
			row.selected = false
			row:SetBackdropColor(unpack(modifyDeckFrame.rowBackdropColour))
		end
		modifyDeckFrame.multipleCardsSelected = false
		modifyDeckFrame.listOfSelectedCardIDs = {}
	end

	function modifyDeckFrame.selectRow(rowFrame)
		if rowFrame.selected == false then
			rowFrame.selected = true
			rowFrame:SetBackdropColor(unpack(modifyDeckFrame.rowBackdropSelectedColour))
			table.insert(modifyDeckFrame.listOfSelectedCardIDs, rowFrame.cardId)
			if ProductiveWoW_tableLength(modifyDeckFrame.listOfSelectedCardIDs) > 1 then
				modifyDeckFrame.multipleCardsSelected = true
			end
		end
	end

	function modifyDeckFrame.unselectRow(rowFrame)
		if rowFrame.selected == true then
			rowFrame.selected = false
			rowFrame:SetBackdropColor(unpack(modifyDeckFrame.rowBackdropColour))
			ProductiveWoW_removeByValue(rowFrame.cardId, modifyDeckFrame.listOfSelectedCardIDs)
			if ProductiveWoW_tableLength(modifyDeckFrame.listOfSelectedCardIDs) <= 1 then
				modifyDeckFrame.multipleCardsSelected = false
			end
		end
	end

	-- Function that runs when you right click on a row and select "Edit Card"
	function modifyDeckFrame.editCardButtonOnClick(cardId)
		local currentDeckName = ProductiveWoW_getCurrentDeckName()
		local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(cardId)
		if ProductiveWoW_cardExistsInBulkImportFile(currentDeckName, ProductiveWoW_getCardQuestion(currentDeckName, cardId)) then
			print(modifyDeckFrame.editCardButtonOnClickCardInBulkImportFileMessage)
			return
		end
		editCardFrame.idOfCardBeingEdited = cardId
		modifyDeckFrame.Frame:Hide()
		repositionAndShowFrame(editCardFrame.Frame)
	end

	-- Full definition of this function is here because populateRows needs to be defined 
	function modifyDeckFrame.deleteCardButtonOnClick(cardId)
		local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(cardId)
		local currentDeckName = ProductiveWoW_getCurrentDeckName()
		local cardQuestion = ProductiveWoW_getCardQuestion(currentDeckName, cardId)
		if ProductiveWoW_cardExistsInBulkImportFile(currentDeckName, cardQuestion) then
			print("\"" .. cardQuestion .. modifyDeckFrame.deleteCardButtonOnClickCardInBulkImportFileMessage)
			return
		end
		ProductiveWoW_deleteCardByID(currentDeckName, cardId)
		print(modifyDeckFrame.deleteCardButtonOnClickSuccessfulDeletionMessage .. cardQuestion)
		if modifyDeckFrame.searchActive == false then
			modifyDeckFrame.currentNumberOfRowsOnPage = modifyDeckFrame.currentNumberOfRowsOnPage - 1
			if modifyDeckFrame.currentNumberOfRowsOnPage == 0 and ProductiveWoW_tableLength(modifyDeckFrame.pages) >= 2 then
				-- If 2 or more pages, go to previous page
				modifyDeckFrame.previousPageButtonOnClick()
				modifyDeckFrame.unselectAllRows()
			else
				-- If there are still cards remaining on the page, then re-populate the rows
				modifyDeckFrame.createPages()
				modifyDeckFrame.refreshListOfCards()
			end
		elseif modifyDeckFrame.searchActive == true then
			modifyDeckFrame.searchResultsCardIds = ProductiveWoW_removeFromArrayMaintainOrdering(modifyDeckFrame.searchResultsCardIds, cardId)
			modifyDeckFrame.unselectAllRows()
			modifyDeckFrame.populateRows(modifyDeckFrame.currentPageIndex, modifyDeckFrame.searchResultsCardIds)
		end
	end

	-- Function to create a new row in the card list frame
	function modifyDeckFrame.createRow(index)
		local row = CreateFrame(FRAME_TYPES.FRAME, nil, modifyDeckFrame.listOfCardsFrameContent, FRAME_TEMPLATES.BACKDROP_TEMPLATE)
		row.selected = false
		row:SetSize(modifyDeckFrame.Frame:GetWidth() - modifyDeckFrame.rowWidthAmountSmallerThanFrameWidth, modifyDeckFrame.listOfCardsFrameRowHeight)
		row:SetPoint(ANCHOR_POINTS.TOPLEFT, 0, -((index - 1) * modifyDeckFrame.listOfCardsFrameRowHeight))
		row:EnableMouse(true)
		row:SetBackdrop({
			bgFile   = modifyDeckFrame.rowBackdropTexture,
				edgeFile = modifyDeckFrame.rowBorderTexture,
				tile     = true, tileSize = 16, edgeSize = 12
		})
		row:SetBackdropColor(unpack(modifyDeckFrame.rowBackdropColour))
		row:SetScript(EVENTS.ON_ENTER, function(self)
			self:SetBackdropColor(unpack(modifyDeckFrame.rowBackdropSelectedColour))
		end)

		row:SetScript(EVENTS.ON_LEAVE, function(self)
			if row.selected == false then
				self:SetBackdropColor(unpack(modifyDeckFrame.rowBackdropColour))
			end
		end)
		row.question = createText(ANCHOR_POINTS.LEFT, row, ANCHOR_POINTS.LEFT, modifyDeckFrame.rowQuestionTextXOffset, 0, "")
		row.question:SetWidth((modifyDeckFrame.Frame:GetWidth() - modifyDeckFrame.rowQuestionTextWidthAmountSmallerThanFrameWidth) / 2)
		row.answer = createText(ANCHOR_POINTS.LEFT, row, ANCHOR_POINTS.LEFT, modifyDeckFrame.Frame:GetWidth() / 2, 0)
		row.answer:SetWidth((modifyDeckFrame.Frame:GetWidth() - modifyDeckFrame.rowAnswerTextWidthAmountSmallerThanFrameWidth) / 2)
		row:SetScript(EVENTS.ON_MOUSE_UP, function(rowFrame, button)
			if button == INPUT_BUTTONS.MOUSE_RIGHT then
				if not rowFrame.selected then
					modifyDeckFrame.unselectAllRows()
					modifyDeckFrame.selectRow(rowFrame)
				end
				if not modifyDeckFrame.multipleCardsSelected then
			    	modifyDeckFrame.singleCardSelectedRightClickMenu = MenuUtil.CreateContextMenu(rowFrame, function(owner, root)
		      			root:CreateButton(modifyDeckFrame.rowRightClickMenuEditCardText, function() modifyDeckFrame.editCardButtonOnClick(rowFrame.cardId) end)
		      			root:CreateButton(modifyDeckFrame.rowRightClickMenuDeleteCardText, function() modifyDeckFrame.deleteCardButtonOnClick(rowFrame.cardId) end)
		    		end)
		    		modifyDeckFrame.singleCardSelectedRightClickMenu:HookScript(EVENTS.ON_HIDE, function()
		    			modifyDeckFrame.unselectRow(rowFrame)
		    		end)
		    	else
		    		modifyDeckFrame.multipleCardsSelectedRightClickMenu = MenuUtil.CreateContextMenu(rowFrame, function(owner, root)
		      			root:CreateButton(modifyDeckFrame.rowRightClickMenuMultipleCardsDeletionText, function() 
		      				multipleCardsDeletionConfirmationFrame.Frame:ClearAllPoints()
		      				multipleCardsDeletionConfirmationFrame.Frame:SetPoint(ANCHOR_POINTS.CENTER, UIParent, ANCHOR_POINTS.CENTER, 0, 0)
		      				multipleCardsDeletionConfirmationFrame.Frame:SetFrameLevel(modifyDeckFrame.Frame:GetFrameLevel() + 3) -- Make it appear above all other frames
		      				multipleCardsDeletionConfirmationFrame.Frame:Show()
		      			end)
		      		end)
		    	end
	    	elseif button == INPUT_BUTTONS.MOUSE_LEFT then
	    		-- Only select/unselect row if multiple cards selected right click menu or multiple cards deletion confirmation frame are both not shown
	    		if not multipleCardsDeletionConfirmationFrame.Frame:IsShown() then
	    			if modifyDeckFrame.multipleCardsSelectedRightClickMenu ~= nil then
		    			if modifyDeckFrame.multipleCardsSelectedRightClickMenu:IsShown() then
							return
						end
					end
					if row.selected == true then
						modifyDeckFrame.unselectRow(rowFrame)
					else
						modifyDeckFrame.selectRow(rowFrame)
					end
					PlaySound(modifyDeckFrame.rowSelectedSound)
				end
			end
		end)
		return row
	end

	-- Create the pages of cards in case there are so many cards that pages are needed to prevent a performance hit
	function modifyDeckFrame.createPages()
		modifyDeckFrame.pages = {}
		local cards = ProductiveWoW_getDeckCards(ProductiveWoW_getCurrentDeckName())
		local cardCounter = 0
		-- Page contains list of cardIds sorted alphabetically
		local currentPage = {}
		-- Sort cards alphabetically by question. First we get a reverse mapping of questions to cardIds, sort the questions, and use the questions as keys to lookup the cardId
		modifyDeckFrame.questionToCardIdMapping = {}
		modifyDeckFrame.sortedQuestions = {}
		for cardId, cardTable in pairs(cards) do
			local question = ProductiveWoW_getQuestionFromCardTable(cardTable)
			question = string.lower(question)
			modifyDeckFrame.questionToCardIdMapping[question] = cardId
			table.insert(modifyDeckFrame.sortedQuestions, question)
		end
		table.sort(modifyDeckFrame.sortedQuestions)
		for i, question in ipairs(modifyDeckFrame.sortedQuestions) do
			local cardId = modifyDeckFrame.questionToCardIdMapping[question]
			table.insert(currentPage, cardId)
			cardCounter = cardCounter + 1
			if cardCounter % modifyDeckFrame.numberOfRowsPerPage == 0 then
				table.insert(modifyDeckFrame.pages, ProductiveWoW_tableShallowCopy(currentPage))
				currentPage = {}
				cardCounter = 0
			end
		end
		-- Add final page since the loop won't add the final page because the modulo condition is not met if the # of rows < numberOfRowsPerPage for the final page
		if ProductiveWoW_tableLength(currentPage) ~= 0 then
			table.insert(modifyDeckFrame.pages, ProductiveWoW_tableShallowCopy(currentPage))
		end
		-- If there are no cards, there still needs to be 1 empty page
		if ProductiveWoW_tableLength(modifyDeckFrame.pages) == 0 then
			modifyDeckFrame.pages = {{}} -- 1 empty page
		end
		modifyDeckFrame.maximumPages = ProductiveWoW_tableLength(modifyDeckFrame.pages)
		if modifyDeckFrame.maximumPages == 0 then
			modifyDeckFrame.maximumPages = 1
		end
	end

	-- Get page by index
	function modifyDeckFrame.getPage(index)
		return modifyDeckFrame.pages[index]
	end

	-- Get current page
	function modifyDeckFrame.getCurrentPage()
		return modifyDeckFrame.pages[modifyDeckFrame.currentPageIndex]
	end

	-- Populate rows. This function creates a Frame for each row, since we can't delete frames after they're created, everytime it's repopulated when you switch a deck,
	-- we will need to reuse the existing row Frames but just changing their text. New row Frames are only created when we have exhausted 
	-- all the existing row Frames. If we switch from Deck A which has 5 rows to Deck B which has 3 rows, we need to set the text of the 2 extra rows to blank and hide them
	function modifyDeckFrame.populateRows(pageIndex, searchResultsCardIds)
		local currentPageCardIds = {}
		-- Search results is an optional argument, but if provided the keys need to be the list of Card IDs returned from the search
		if searchResultsCardIds ~= nil then
			currentPageCardIds = searchResultsCardIds
		else
			currentPageCardIds = modifyDeckFrame.getPage(pageIndex)
		end
		local currentDeckName = ProductiveWoW_getCurrentDeckName()
		local tableIndex = 1 -- Need to increment index manually since cardId may not be continuous due to deletion of cards
		modifyDeckFrame.currentNumberOfRowsOnPage = 0		
		if currentPageCardIds ~= nil then
			modifyDeckFrame.currentNumberOfRowsOnPage = ProductiveWoW_tableLength(currentPageCardIds)			
			for i, cardId in ipairs(currentPageCardIds) do
				-- Get existing row
				local row = modifyDeckFrame.rows[tableIndex]
				if row == nil then -- if this row index does not already exist, create new row
					row = modifyDeckFrame.createRow(tableIndex)
					modifyDeckFrame.rows[tableIndex] = row
				end
				row.question:SetText(ProductiveWoW_getCardQuestion(currentDeckName, cardId))
				row.answer:SetText(ProductiveWoW_getCardAnswer(currentDeckName, cardId))
				row.cardId = cardId
				row.selected = false
				row:Show()
				tableIndex = tableIndex + 1
			end
		end
		-- Set text to blank for additional rows if current deck has fewer rows than the previously selected deck and hide the row
		-- modifyDeckFrame.rows here is a table of existing row Frames whereas modifyDeckFrame.currentNumberOfRowsOnPage refers
		-- to the number of visible rows (rows showing a card), the number of existing row Frames can exceed the number of visible rows
		for i = modifyDeckFrame.currentNumberOfRowsOnPage + 1, ProductiveWoW_tableLength(modifyDeckFrame.rows) do
			modifyDeckFrame.rows[i].question:SetText("")
			modifyDeckFrame.rows[i].answer:SetText("")
			modifyDeckFrame.rows[i]:Hide()
		end
		-- Resize scroll content
		modifyDeckFrame.listOfCardsFrameContent:SetHeight(ProductiveWoW_tableLength(modifyDeckFrame.rows) * modifyDeckFrame.listOfCardsFrameRowHeight)
	end

	-- Refresh the list of cards
	function modifyDeckFrame.refreshListOfCards()
		modifyDeckFrame.listOfCardsFrame:SetVerticalScroll(0)
		modifyDeckFrame.unselectAllRows()
		modifyDeckFrame.populateRows(modifyDeckFrame.currentPageIndex)
		modifyDeckFrame.currentPageText:SetText(modifyDeckFrame.currentPageIndex .. " of " .. modifyDeckFrame.maximumPages)
	end

	-- Re-populate rows when frame is shown
	modifyDeckFrame.Frame:SetScript(EVENTS.ON_SHOW, function(self)
		modifyDeckFrame.currentPageIndex = 1
		modifyDeckFrame.cancelSearch()
		modifyDeckFrame.createPages()
		modifyDeckFrame.refreshListOfCards()
	end)

	-- Unselect all rows when user clicks anywhere
	modifyDeckFrame.Frame:SetScript(EVENTS.ON_MOUSE_UP, function(self, button)
		if button == INPUT_BUTTONS.MOUSE_LEFT then
			-- If the multiple cards deletion confirmation frame is currently shown, the rows need to remain selected even if the user clicks anywhere
			if not multipleCardsDeletionConfirmationFrame.Frame:IsShown() then
				modifyDeckFrame.unselectAllRows()
			end
		end
	end)

	-- Multiple cards deletion confirmation frame
	multipleCardsDeletionConfirmationFrame.Frame:SetWidth(multipleCardsDeletionConfirmationFrame.width)

	-- Confirmation text
	multipleCardsDeletionConfirmationFrame.confirmationText = createText(multipleCardsDeletionConfirmationFrame.confirmationTextAnchor, multipleCardsDeletionConfirmationFrame.Frame, multipleCardsDeletionConfirmationFrame.confirmationTextParentAnchor, multipleCardsDeletionConfirmationFrame.confirmationTextXOffset, multipleCardsDeletionConfirmationFrame.confirmationTextYOffset, multipleCardsDeletionConfirmationFrame.confirmationTextValue)

	-- Multiple card deletion Yes button
	function multipleCardsDeletionConfirmationFrame.multipleCardsDeletionYesButtonOnClick()
		for i, cardId in ipairs(modifyDeckFrame.listOfSelectedCardIDs) do
			modifyDeckFrame.deleteCardButtonOnClick(cardId)
		end
		modifyDeckFrame.unselectAllRows()
		multipleCardsDeletionConfirmationFrame.Frame:Hide()
	end
	multipleCardsDeletionConfirmationFrame.yesButton = createButton(multipleCardsDeletionConfirmationFrame.yesButtonName, multipleCardsDeletionConfirmationFrame.Frame, multipleCardsDeletionConfirmationFrame.yesButtonText, multipleCardsDeletionConfirmationFrame.yesButtonAnchor, multipleCardsDeletionConfirmationFrame.yesButtonXOffset, multipleCardsDeletionConfirmationFrame.yesButtonYOffset, multipleCardsDeletionConfirmationFrame.multipleCardsDeletionYesButtonOnClick)

	-- Multiple card deletion Cancel button
	function multipleCardsDeletionConfirmationFrame.multipleCardsDeletionCancelButtonOnClick()
		modifyDeckFrame.unselectAllRows()
		multipleCardsDeletionConfirmationFrame.Frame:Hide()
	end
	multipleCardsDeletionConfirmationFrame.cancelButton = createButton(multipleCardsDeletionConfirmationFrame.cancelButtonName, multipleCardsDeletionConfirmationFrame.Frame, multipleCardsDeletionConfirmationFrame.cancelButtonText, multipleCardsDeletionConfirmationFrame.cancelButtonAnchor, multipleCardsDeletionConfirmationFrame.cancelButtonXOffset, multipleCardsDeletionConfirmationFrame.cancelButtonYOffset, multipleCardsDeletionConfirmationFrame.multipleCardsDeletionCancelButtonOnClick)
end

-- Configure add card frame
local function configureAddCardFrame()
	-- Card Question Text Box
	addCardFrame.questionTextBox = createTextBox(addCardFrame.questionTextBoxName, addCardFrame.Frame, addCardFrame.questionTextBoxWidth, addCardFrame.questionTextBoxHeight, addCardFrame.questionTextBoxAnchor, addCardFrame.questionTextBoxXOffset, addCardFrame.questionTextBoxYOffset, addCardFrame.questionTextBoxGreyHintText)

	-- Card Answer Text Box
	addCardFrame.answerTextBox = createTextBox(addCardFrame.answerTextBoxName, addCardFrame.Frame, addCardFrame.answerTextBoxWidth, addCardFrame.answerTextBoxHeight, addCardFrame.answerTextBoxAnchor, addCardFrame.answerTextBoxXOffset, addCardFrame.answerTextBoxYOffset, addCardFrame.answerTextBoxGreyHintText)

	-- Add card button
	function addCardFrame.addCardButtonOnClick()
		local question = addCardFrame.questionTextBox:GetText()
		local answer = addCardFrame.answerTextBox:GetText()
		if question ~= "" and answer ~= "" and question ~= addCardFrame.questionTextBoxGreyHintText and answer ~= addCardFrame.answerTextBoxGreyHintText then
			local deckName = ProductiveWoW_getCurrentDeckName()
			if deckName ~= nil then
				if ProductiveWoW_getCardByQuestion(deckName, question) == nil then
					ProductiveWoW_addCard(deckName, question, answer)
					clearTextBox(addCardFrame.questionTextBox)
					clearTextBox(addCardFrame.answerTextBox)
					print(addCardFrame.cardAddedMessage)
				else	
					print(addCardFrame.cardAlreadyExistsMessage)
				end
			else
				print(addCardFrame.noDeckSelectedMessage)
			end
		else
			print(addCardFrame.questionOrAnswerIsBlankMessage)
		end
	end
	addCardFrame.addCardButton = createButton(addCardFrame.addCardButtonName, addCardFrame.Frame, addCardFrame.addCardButtonText, addCardFrame.addCardButtonAnchor, addCardFrame.addCardButtonXOffset, addCardFrame.addCardButtonYOffset, addCardFrame.addCardButtonOnClick)

	-- Back to Modify Deck frame button
	addCardFrame.navigateBackToModifyDeckFrameButton = createNavigationButton(addCardFrame.navigateBackToModifyDeckFrameButtonName, addCardFrame.Frame, addCardFrame.navigateBackToModifyDeckFrameButtonText, addCardFrame.navigateBackToModifyDeckFrameButtonAnchor, addCardFrame.navigateBackToModifyDeckFrameButtonXOffset, addCardFrame.navigateBackToModifyDeckFrameButtonYOffset, modifyDeckFrame.Frame, addCardFrame.navigateBackToModifyDeckFrameButtonSound)

	-- Back to main menu button
	addCardFrame.navigateBackToMainMenuButton = createNavigationButton(addCardFrame.navigateBackToMainMenuButtonName, addCardFrame.Frame, addCardFrame.navigateBackToMainMenuButtonText, addCardFrame.navigateBackToMainMenuButtonAnchor, addCardFrame.navigateBackToMainMenuButtonXOffset, addCardFrame.navigateBackToMainMenuButtonYOffset, mainMenu.Frame, addCardFrame.navigateBackToMainMenuButtonSound)
end

-- Congigure edit card frame
local function configureEditCardFrame()
	-- Card Question Text Box
	editCardFrame.questionTextBox = createTextBox(editCardFrame.questionTextBoxName, editCardFrame.Frame, editCardFrame.questionTextBoxWidth, editCardFrame.questionTextBoxHeight, editCardFrame.questionTextBoxAnchor, editCardFrame.questionTextBoxXOffset, editCardFrame.questionTextBoxYOffset, editCardFrame.questionTextBoxGreyHintText)

	-- Card Answer Text Box
	editCardFrame.answerTextBox = createTextBox(editCardFrame.answerTextBoxName, editCardFrame.Frame, editCardFrame.answerTextBoxWidth, editCardFrame.answerTextBoxHeight, editCardFrame.answerTextBoxAnchor, editCardFrame.answerTextBoxXOffset, editCardFrame.answerTextBoxYOffset, editCardFrame.answerTextBoxGreyHintText)

	-- Save card button
	function editCardFrame.saveCardButtonOnClick()
		local newQuestion = editCardFrame.questionTextBox:GetText()
		local newAnswer = editCardFrame.answerTextBox:GetText()
		local deckName = ProductiveWoW_getCurrentDeckName()
		local card = ProductiveWoW_getCardByIDForCurrentlySelectedDeck(editCardFrame.idOfCardBeingEdited)
		local existingQuestion = ProductiveWoW_getCardQuestion(deckName, editCardFrame.idOfCardBeingEdited)
		local existingAnswer = ProductiveWoW_getCardAnswer(deckName, editCardFrame.idOfCardBeingEdited)
		if not ProductiveWoW_stringContainsOnlyWhitespace(newQuestion) and not ProductiveWoW_stringContainsOnlyWhitespace(newAnswer) and newQuestion ~= editCardFrame.questionTextBoxGreyHintText and newAnswer ~= editCardFrame.answerTextBoxGreyHintText then
			if deckName ~= nil then
				if newQuestion ~= existingQuestion or newAnswer ~= existingAnswer then
					if ProductiveWoW_getCardByQuestion(deckName, newQuestion) == nil or newQuestion == existingQuestion then
						if ProductiveWoW_cardExistsInBulkImportFile(deckName, newQuestion) then
							print(editCardFrame.cardExistsInBulkImportFileMessage)
							return
						end
						card.question = newQuestion
						card.answer = newAnswer
						clearTextBox(editCardFrame.questionTextBox)
						clearTextBox(editCardFrame.answerTextBox)
						editCardFrame.Frame:Hide()
						repositionAndShowFrame(modifyDeckFrame.Frame)
						print(editCardFrame.cardSavedMessage)
					else
						print(editCardFrame.duplicateQuestionMessage)
					end
				else	
					print(editCardFrame.noChangesMadeMessage)
				end
			else
				print(editCardFrame.noDeckSelectedMessage)
			end
		else
			print(editCardFrame.questionOrAnswerIsBlankMessage)
		end
	end
	editCardFrame.saveCardButton = createButton(editCardFrame.saveCardButtonName, editCardFrame.Frame, editCardFrame.saveCardButtonText, editCardFrame.saveCardButtonAnchor, editCardFrame.saveCardButtonXOffset, editCardFrame.saveCardButtonYOffset, editCardFrame.saveCardButtonOnClick)

	-- Back to Modify Deck frame button
	editCardFrame.navigateBackToModifyDeckFrameButton = createNavigationButton(editCardFrame.navigateBackToModifyDeckFrameButtonName, editCardFrame.Frame, editCardFrame.navigateBackToModifyDeckFrameButtonText, editCardFrame.navigateBackToModifyDeckFrameButtonAnchor, editCardFrame.navigateBackToModifyDeckFrameButtonXOffset, editCardFrame.navigateBackToModifyDeckFrameButtonYOffset, modifyDeckFrame.Frame, editCardFrame.navigateBackToModifyDeckFrameButtonSound)

	-- Back to main menu button
	editCardFrame.navigateBackToMainMenuButton = createNavigationButton(editCardFrame.navigateBackToMainMenuButtonName, editCardFrame.Frame, editCardFrame.navigateBackToMainMenuButtonText, editCardFrame.navigateBackToMainMenuButtonAnchor, editCardFrame.navigateBackToMainMenuButtonXOffset, editCardFrame.navigateBackToMainMenuButtonYOffset, mainMenu.Frame, editCardFrame.navigateBackToMainMenuButtonSound)

	-- Populate textboxes with card's question and answer
	editCardFrame.Frame:SetScript(EVENTS.ON_SHOW, function(self)
		local currentDeckName = ProductiveWoW_getCurrentDeckName()
		local existingQuestion = ProductiveWoW_getCardQuestion(currentDeckName, editCardFrame.idOfCardBeingEdited)
		local existingAnswer = ProductiveWoW_getCardAnswer(currentDeckName, editCardFrame.idOfCardBeingEdited)
		editCardFrame.questionTextBox:SetText(existingQuestion)
		editCardFrame.answerTextBox:SetText(existingAnswer)
		editCardFrame.questionTextBox:SetCursorPosition(0)
		editCardFrame.questionTextBox:SetTextColor(unpack(COLOURS.WHITE))
		editCardFrame.answerTextBox:SetCursorPosition(0)
		editCardFrame.answerTextBox:SetTextColor(unpack(COLOURS.WHITE))
	end)
end

-- Configure deck settings frame
local function configureDeckSettingsFrame()
	-- Back button
	deckSettingsFrame.navigateBackToModifyDeckFrameButton = createNavigationButton(deckSettingsFrame.navigateBackToModifyDeckFrameButtonName, deckSettingsFrame.Frame, deckSettingsFrame.navigateBackToModifyDeckFrameButtonText, deckSettingsFrame.navigateBackToModifyDeckFrameButtonAnchor, deckSettingsFrame.navigateBackToModifyDeckFrameButtonXOffset, deckSettingsFrame.navigateBackToModifyDeckFrameButtonYOffset, modifyDeckFrame.Frame, deckSettingsFrame.navigateBackToModifyDeckFrameButtonSound)

	-- Max cards to be tested per day text
	deckSettingsFrame.maxCardsText = createText(deckSettingsFrame.maxCardsTextAnchor, deckSettingsFrame.Frame, deckSettingsFrame.maxCardsTextParentAnchor, deckSettingsFrame.maxCardsTextXOffset, deckSettingsFrame.maxCardsTextYOffset, deckSettingsFrame.maxCardsTextValue)

	-- Max daily cards textbox
	deckSettingsFrame.maxCardsTextBox = createTextBox(deckSettingsFrame.maxCardsTextBoxName, deckSettingsFrame.Frame, deckSettingsFrame.maxCardsTextBoxWidth, deckSettingsFrame.maxCardsTextBoxHeight, deckSettingsFrame.maxCardsTextBoxAnchor, deckSettingsFrame.maxCardsTextBoxXOffset, deckSettingsFrame.maxCardsTextBoxYOffset)

	-- Save button
	function deckSettingsFrame.saveDeckSettingsButtonOnClick()
		local anySettingChanged = false
		local otherErrorMessageDisplayed = false
		local maxDailyCards = deckSettingsFrame.maxCardsTextBox:GetText()
		local currentDeckName = ProductiveWoW_getCurrentDeckName()
		local currentDeck = ProductiveWoW_getCurrentDeck()
		local currentMaxDailyCards = ProductiveWoW_getDeckDailyNumberOfCards(currentDeckName)
		if not ProductiveWoW_isNumeric(maxDailyCards) then
			print(deckSettingsFrame.maxDailyCardsHasToBeNumericMessage)
			otherErrorMessageDisplayed = true
		elseif tonumber(maxDailyCards) <= 0 then
			print(deckSettingsFrame.maxDailyCardsCannotBeZeroOrLessMessage)
			otherErrorMessageDisplayed = true		
		elseif tonumber(maxDailyCards) ~= currentMaxDailyCards then
			ProductiveWoW_setMaxDailyCardsForDeck(currentDeckName, tonumber(maxDailyCards))
			ProductiveWoW_setDeckNotPlayedYetToday(currentDeckName) -- When max card limit changes, reset the deck
			anySettingChanged = true
		end
		if anySettingChanged == true then
			print(deckSettingsFrame.settingsSavedMessage)
		elseif anySettingChanged == false and otherErrorMessageDisplayed == false then
			print(deckSettingsFrame.noChangesMadeMessage)
		end
	end
	deckSettingsFrame.saveDeckSettingsButton = createButton(deckSettingsFrame.saveDeckSettingsButtonName, deckSettingsFrame.Frame, deckSettingsFrame.saveDeckSettingsButtonText, deckSettingsFrame.saveDeckSettingsButtonAnchor, deckSettingsFrame.saveDeckSettingsButtonXOffset, deckSettingsFrame.saveDeckSettingsButtonYOffset, deckSettingsFrame.saveDeckSettingsButtonOnClick)

	deckSettingsFrame.Frame:SetScript(EVENTS.ON_SHOW, function()
		local maxCards = ProductiveWoW_getDeckDailyNumberOfCards(ProductiveWoW_getCurrentDeckName())
		deckSettingsFrame.maxCardsTextBox:SetText(maxCards)
		deckSettingsFrame.maxCardsTextBox:SetTextColor(unpack(COLOURS.WHITE))
	end)
end

local function configureFlashcardFrame()
	flashcardFrame.Frame:SetSize(flashcardFrame.width, flashcardFrame.height)

	-- Add text to display question
	flashcardFrame.displayedText = flashcardFrame.Frame:CreateFontString(nil, TEXT_CONSTANTS.OVERLAY, TEXT_CONSTANTS.GAME_FONT_HIGHLIGHT)
	flashcardFrame.displayedText:SetPoint(ANCHOR_POINTS.TOPLEFT, flashcardFrame.Frame, ANCHOR_POINTS.TOPLEFT, flashcardFrame.textTopLeftAnchorXOffset, flashcardFrame.textTopLeftAnchorYOffset)
	flashcardFrame.displayedText:SetPoint(ANCHOR_POINTS.BOTTOMRIGHT, flashcardFrame.Frame, ANCHOR_POINTS.BOTTOMRIGHT, flashcardFrame.textBottomRightAnchorXOffset, flashcardFrame.textBottomRightAnchorYOffset)
	flashcardFrame.displayedText:SetNonSpaceWrap(true)

	function flashcardFrame.showNextCard()
		local currentCardID = ProductiveWoW_getCurrentCardID()
		local currentDeckName = ProductiveWoW_getCurrentDeckName()
		if currentCardID ~= nil then
			local currentQuestion = ProductiveWoW_getCardQuestion(currentDeckName, currentCardID)
			flashcardFrame.displayedText:SetText(currentQuestion)
			ProductiveWoW_onViewedCard(currentCardID)
		end
	end

	-- Show answer button
	function flashcardFrame.showAnswerButtonOnClick()
		local currentCardID = ProductiveWoW_getCurrentCardID()
		local currentDeckName = ProductiveWoW_getCurrentDeckName()
		if currentCardID ~= nil then
			local currentAnswer = ProductiveWoW_getCardAnswer(currentDeckName, currentCardID)
			flashcardFrame.displayedText:SetText(currentAnswer)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
		flashcardFrame.easyDifficultyButton:Show()
		flashcardFrame.mediumDifficultyButton:Show()
		flashcardFrame.hardDifficultyButton:Show()
		flashcardFrame.showAnswerButton:Hide()
	end
	flashcardFrame.showAnswerButton = createButton(flashcardFrame.showAnswerButtonName, flashcardFrame.Frame, flashcardFrame.showAnswerButtonText, flashcardFrame.showAnswerButtonAnchor, flashcardFrame.showAnswerButtonXOffset, flashcardFrame.showAnswerButtonYOffset, flashcardFrame.showAnswerButtonOnClick)

	-- Next question
	function flashcardFrame.nextQuestion(self)
		self:Hide()
		ProductiveWoW_drawRandomNextCard()
		flashcardFrame.showNextCard()
		flashcardFrame.showAnswerButton:Show()
		flashcardFrame.easyDifficultyButton:Hide()
		flashcardFrame.mediumDifficultyButton:Hide()
		flashcardFrame.hardDifficultyButton:Hide()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end

	-- Easy difficulty button
	function flashcardFrame.easyDifficultyButtonOnClick(self)
		local currentCardID = ProductiveWoW_getCurrentCardID()
		ProductiveWoW_cardEasyDifficultyChosen(currentCardID)
		flashcardFrame.nextQuestion(self)
	end
	flashcardFrame.easyDifficultyButton = createButton(flashcardFrame.easyDifficultyButtonName, flashcardFrame.Frame, flashcardFrame.easyDifficultyButtonText, flashcardFrame.easyDifficultyButtonAnchor, flashcardFrame.easyDifficultyButtonXOffset, flashcardFrame.easyDifficultyButtonYOffset, flashcardFrame.easyDifficultyButtonOnClick)
	flashcardFrame.easyDifficultyButton:Hide()

	-- Medium difficulty button
	function flashcardFrame.mediumDifficultyButtonOnClick(self)
		local currentCardID = ProductiveWoW_getCurrentCardID()
		ProductiveWoW_cardMediumDifficultyChosen(currentCardID)
		flashcardFrame.nextQuestion(self)
	end
	flashcardFrame.mediumDifficultyButton = createButton(flashcardFrame.mediumDifficultyButtonName, flashcardFrame.Frame, flashcardFrame.mediumDifficultyButtonText, flashcardFrame.mediumDifficultyButtonAnchor, flashcardFrame.mediumDifficultyButtonXOffset, flashcardFrame.mediumDifficultyButtonYOffset, flashcardFrame.mediumDifficultyButtonOnClick)
	flashcardFrame.mediumDifficultyButton:Hide()

	-- Hard difficulty button
	function flashcardFrame.hardDifficultyButtonOnClick(self)
		local currentCardID = ProductiveWoW_getCurrentCardID()
		ProductiveWoW_cardHardDifficultyChosen(currentCardID)
		flashcardFrame.nextQuestion(self)
	end
	flashcardFrame.hardDifficultyButton = createButton(flashcardFrame.hardDifficultyButtonName, flashcardFrame.Frame, flashcardFrame.hardDifficultyButtonText, flashcardFrame.hardDifficultyButtonAnchor, flashcardFrame.hardDifficultyButtonXOffset, flashcardFrame.hardDifficultyButtonYOffset, flashcardFrame.hardDifficultyButtonOnClick)
	flashcardFrame.hardDifficultyButton:Hide()

	-- Back to main menu from flashcard frame button
	flashcardFrame.navigateBackToMainMenuButton = createNavigationButton(flashcardFrame.navigateBackToMainMenuButtonName, flashcardFrame.Frame, flashcardFrame.navigateBackToMainMenuButtonText, flashcardFrame.navigateBackToMainMenuButtonAnchor, flashcardFrame.navigateBackToMainMenuButtonXOffset, flashcardFrame.navigateBackToMainMenuButtonYOffset, mainMenu.Frame, flashcardFrame.navigateBackToMainMenuButtonSound)

	-- OnShow script to refresh question
	flashcardFrame.Frame:SetScript(EVENTS.ON_SHOW, function(self)
		ProductiveWoW_beginQuiz()
		flashcardFrame.showNextCard()
	end)
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
	configureAddCardFrame()
	configureEditCardFrame()	
	configureDeckSettingsFrame()
	configureFlashcardFrame()
		
end)