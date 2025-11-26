<h1>Installing and Using the Addon</h1>
<p>Refer to the addon's Curse page for installation and usage instructions https://www.curseforge.com/wow/addons/productivewow.<p>

<h1>Contributing</h1>
<p>I have tried to write the code as clearly and as organized as I can so reading it should hopefully be almost like reading English, you should immediately know what something does.<br>

You should know the basics of how WoW addons are created. This addon uses the following principles:<br></p>

<ol>
<li>No dependencies on external libraries (e.g. no using the Ace3 library). You are free to fork and create a version that does use it.</li>
<li>Comment nearly everything (except very obvious bits of code).</li>
<li>Variable names must be descriptive and accurate even if they end up being super long.</li>
<li>Declare most variables at the top of the file.</li>
<li>Global variables MUST use the prefix "ProductiveWoW_" (e.g. ProductiveWoW_beginQuiz) to avoid coincidentally being the same as a variable from another addon.</li>
<li>After variable declarations, declare all the functions.</li>
<li>Unit tests at the very bottom of the file in their own section.</li>
<li>Consistent formatting everywhere (ALL CAPS for constants, camelCase for other identifiers).</li>
<li>Place as much as you can into functions and each function should do only exactly what its name says.</li>
<li>Very little hardcoding of values, you'll see every value inside a variable so that if that value ever needs to change for some reason, you can simply change it at the top of the file in the variable and nothing will be missed.</li>
<li>You'll see this in the UI file, but there is a limitation on how many local variables can be defined so you will see most variables being added to a parent local variable. (e.g. local variable is mainMenu, its width would be mainMenu.width as opposed to mainMenuWidth).</li>
</ol>
<p><br></p>

<h2>Overview of How it Works</h2>
<p>ProductiveWoW.lua contains most of the flashcard logic and data operations such as drafting a random subset of cards from a deck when a quiz starts.<br>
  
ProductiveWoWUI.lua contains all the code for the creation of the UI, handling button presses, etc.<br>
  
ProductiveWoWUtilities.lua contains miscellaneous function definitions for common operations not specific to this addon such as getting the length of a table, copying a table, etc.<br>
  
ProductiveWoWDecks.lua contains the variables that are modified by users to bulk add/delete cards and to paste their plaintext Anki deck into. It also contains some functions for importing the Anki deck. It also has detailed instructions for the users in the comments.<br>

Most of the code is variable declarations and function definitions. The actual parts that are executed are inside the "EventUtil.ContinueOnAddOnLoaded()" blocks which are a standard way given by Blizzard for ensuring that the code is only executed after the addon's saved variables are loaded first. You can Ctrl+F to find it and see where code execution begins.<br>

Read the [Curse page](https://www.curseforge.com/wow/addons/productivewow) to familiarize yourself with how a user would use the addon.<br>

There are Decks which have deck attributes and a list of Cards under them. Each card has a question and an answer and some other attributes. One of the attributes of a Card is its difficulty which can either be "easy", "medium", or "hard" and this determines how it's prioritized to be shown to you. Hard cards are priotitized over medium and medium over easy so when you play the quiz, you will be shown hard cards first. When a user views the answer to a question, they are asked to click whether they thought the question was hard, medium, or easy and it's this selection which determines the difficulty of the card. Whatever the user selects becomes the new difficulty of the card. Each card begins on the hard difficulty by default.<br></p>

<h2>ProductiveWoW.toc File</h2>
<p>The table of contents file MUST have the lua files listed in the following order:<br>
  
ProductiveWoWUtilities.lua
ProductiveWoWDecks.lua
ProductiveWoW.lua
ProductiveWoWUI.lua<br>

This is so that functions are defined in the proper order.<br></p>

<h2>ProductiveWoW.lua</h2>

<p>The code execution begins by checking if the resetSavedVariables flag at the very top of the file is true or not. This resets the 2 saved variables, ProductiveWoWData and ProductiveWoWSavedSettings, for debugging purposes if you want to delete all decks and cards data and other settings.<br>

Next, it checks the addon version to see if the user recently updated the version since the last login. It knows this because the addon version is part of the ProductiveWoWSavedSettings saved variable so there will be a mismatch between the value in the source code and the user's saved settings.<br>

The table.sort(ProductiveWoW_REMINDERS) sorts the list of reminder types to be alphabetical. This variable is used to list them in the reminder dropdown in the settings frame.<br>

updateSavedSettingsTableWithNewKeys() ensures that if you added new keys/values to the ProductiveWoWSavedSettings saved variable in the newest addon version, that the new keys will be instantiated with default values you defined for them in the savedSettingsTableInitialValues table.</p>

