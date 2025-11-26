<h1>Installing and Using the Addon</h1>
Refer to the addon's Curse page for installation and usage instructions https://www.curseforge.com/wow/addons/productivewow.

<h1>Contributing</h1>
I have tried to write the code as clearly and as organized as I can so reading it should hopefully be almost like reading English, you should immediately know what something does.

You should know the basics of how WoW addons are created. This addon uses the following principles:

1. No dependencies on external libraries (e.g. no using the Ace3 library). You are free to fork and create a version that does use it.
2. Comment nearly everything (except very obvious bits of code).
3. Variable names must be descriptive and accurate even if they end up being super long.
4. Declare most global variables at the top of the file.
5. After variable declarations, declare all the functions.
6. Unit tests at the very bottom of the file in their own section.
7. Consistent formatting everywhere (ALL CAPS for constants, camelCase for other identifiers)
8. Place as much as you can into functions and each function should do only exactly what its name says.
9. Very little hardcoding of values, you'll see every value inside a variable so that if that value ever needs to change for some reason, you can simply change it at the top of the file in the variable and nothing will be missed.
10. You'll see this in the UI file, but there is a limitation on how many local variables can be defined so you will see most variables being added to a parent local variable. (e.g. local variable is mainMenu, its width would be mainMenu.width as opposed to mainMenuWidth).

<h2></h2>
