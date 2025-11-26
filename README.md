<h1>Installing and Using the Addon</h1>
<p>Refer to the addon's Curse page for installation and usage instructions https://www.curseforge.com/wow/addons/productivewow.<p>

<h1>Contributing</h1>
<p>I have tried to write the code as clearly and as organized as I can so reading it should hopefully be almost like reading English, you should immediately know what something does.<br><br>

You should know the basics of how WoW addons are created. This addon uses the following principles:<br><br></p>

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

<h2>Overview of How it Works</h2>
<p></p>
