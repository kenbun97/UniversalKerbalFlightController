DECLARE FUNCTION AddTabWidget
{
        // Any box is allowed
        DECLARE PARAMETER box.

        // See if styles for the TabWidget components (tabs and panels) has
        // already been defined elsewhere. If not, define each one

        IF NOT box:GUI:SKIN:HAS("TabWidgetTab") {

                // The style for tabs is like a button, but it should smoothly connect
                // to the panel below it, especially if it is the current selected tab.

                LOCAL style IS box:GUI:SKIN:ADD("TabWidgetTab",box:GUI:SKIN:BUTTON).

                // Images are stored alongside the code.
                SET style:BG TO "./lib/tabWidget/back.png".
                SET style:ON:BG to "./lib/tabWidget/front.png".
                // Tweak the style.
                SET style:TEXTCOLOR TO RGBA(0.7,0.75,0.7,1).
                SET style:HOVER:BG TO "".
                SET style:HOVER_ON:BG TO "".
                SET style:MARGIN:H TO 0.
                SET style:MARGIN:BOTTOM TO 0.
        }
        IF NOT box:GUI:SKIN:HAS("TabWidgetPanel") {
                LOCAL style IS box:GUI:SKIN:ADD("TabWidgetPanel",box:GUI:SKIN:WINDOW).
                SET style:BG TO "./lib/tabWidget/panel.png".
                SET style:PADDING:TOP to 0.
        }

        // Add a vlayout (in case the box is a HBOX, for example),
        // then add a hlayout for the tabs and a stack to hols all the panels.
        LOCAL vbox IS box:ADDVLAYOUT.
        LOCAL tabs IS vbox:ADDHLAYOUT.
        LOCAL panels IS vbox:ADDSTACK.

        // any other customization of tabs and panels goes here

        // Return the empty TabWidget.
        RETURN vbox.
}

DECLARE FUNCTION AddTab
{
        DECLARE PARAMETER tabwidget. // (the vbox)
        DECLARE PARAMETER tabname. // title for the tab

        // Get back the two widgets we created in AddTabWidget
        LOCAL hboxes IS tabwidget:WIDGETS.
        LOCAL tabs IS hboxes[0]. // the HLAYOUT
        LOCAL panels IS hboxes[1]. // the STACK

        // Add another panel, style it correctly
        LOCAL panel IS panels:ADDVBOX.
        SET panel:STYLE TO panel:GUI:SKIN:GET("TabWidgetPanel").

        // Add another tab, style it correctly
        LOCAL tab IS tabs:ADDBUTTON(tabname).
        SET tab:STYLE TO tab:GUI:SKIN:GET("TabWidgetTab").

        // Set the tab button to be exclusive - when
        // one tab goes up, the others go down.
        SET tab:TOGGLE TO true.
        SET tab:EXCLUSIVE TO true.

        // If this is the first tab, make it start already shown (make the tab presssed)
        // Otherwise, we hide it (even though the STACK will only show the first anyway,
        // but by keeping everything "correct", we can be a little more efficient later.
        IF panels:WIDGETS:LENGTH = 1 {
                SET tab:PRESSED TO true.
                panels:SHOWONLY(panel).
        } else {
                panel:HIDE().
        }


        // Add the tab and its corresponding panel to global variables,
        // in order to handle interaction later.
        TabWidget_alltabs:ADD(tab).
        TabWidget_allpanels:ADD(panel).

        RETURN panel.
}

// Global variables to allow interaction to be done later.
GLOBAL TabWidget_alltabs TO LIST().
GLOBAL TabWidget_allpanels TO LIST().
GLOBAL tabIndex TO -1.

DECLARE FUNCTION ChooseTab
{
        DECLARE PARAMETER tabwidget. // The tab
        DECLARE PARAMETER tabnum. // Which tab to choose (0 is first)
        // Find the tabs hlayout - is is the first of the two we added
        LOCAL hboxes IS tabwidget:WIDGETS.
        LOCAL tabs IS hboxes[0].
        // Find the tab, and set it to be pressed
        SET tabs:WIDGETS[tabnum]:PRESSED TO true.
        SET tabIndex TO tabnum.
}

WHEN True THEN
{
        FROM { LOCAL x IS 0.} UNTIL x >= TabWidget_alltabs:LENGTH STEP { SET x TO x+1.} DO
        {
                // Earlier, we were careful to hide the panels that were not the current
                // one when they were added, so we can test if the panel is VISIBLE
                // to avoid the more expensive call to SHOWONLY every frame.
                IF TabWidget_alltabs[x]:PRESSED AND NOT TabWidget_allpanels[x]:VISIBLE {
                        TabWidget_allpanels[x]:parent:showonly(TabWidget_allpanels[x]).
                        SET tabIndex TO x.
                }
        }
        PRESERVE.
}
