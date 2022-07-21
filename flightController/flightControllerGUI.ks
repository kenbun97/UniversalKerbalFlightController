// Name:          Flight Controller GUI
//
// Author:        Kenny Bunnell
//
// Date:					5 January 2021
//
// Description:   This is the program that runs UI of the basic flight controller
//								This program is in charge of creating the UI, updating the UI,
//								and updating flags and other variables on UI events such as button
//								presses and user inputs. Therefore, there should be no global variables
//
@LAZYGLOBAL off.

// Get the tab widget and controller tuner library
RUNONCEPATH("0:/bin/tabWidget/tabWidget").
RUNONCEPATH("tunerUI").

DECLARE function createFlightControllerGUI
{
	// Set a variable to control the heights of the controller rows
	LOCAL tunerRowHeight IS 25.

	// Create the main flight controller UI
	LOCAL gui IS GUI(500,500).
	SET gui:X TO 0.
	SET gui:Y TO 40.
	SET gui:DRAGGABLE TO FALSE.

	// Setup the Header of the displays
	LOCAL boxHeader TO gui:ADDHLAYOUT.
	LOCAL labelStatus TO boxHeader:ADDLABEL("Status: ").
	SET labelStatus:STYLE:WIDTH TO 65.
	SET labelStatus:STYLE:FONTSIZE TO 20.
	LOCAL valueStatus TO boxHeader:ADDLABEL("Booting...").
	SET valueStatus:STYLE:HSTRETCH TO TRUE.
	SET valueStatus:STYLE:FONTSIZE TO 20.
	LOCAL buttonPower TO boxHeader:ADDCHECKBOX("Master Power",FALSE).

	// Add tabs to the main flightControllerGUI
	LOCAL tabwidget IS AddTabWidget(gui).

	// *****************************************************************************
	// *	Create the Minimized View tab																						 *
	// *****************************************************************************
	LOCAL page IS AddTab(tabwidget,"Minimized View").

	// Setup page to display boxes next to each other
	LOCAL box0Data TO page:ADDHBOX.

	// Seperate Data into 6 columns
	LOCAL box0LabelLeft  TO box0Data:ADDVLAYOUT.
	LOCAL box0ValueLeft  TO box0Data:ADDVLAYOUT.
	LOCAL box0LabelMid	 TO box0Data:ADDVLAYOUT.
	LOCAL box0ValueMid	 TO box0Data:ADDVLAYOUT.
	LOCAL box0LabelRight TO box0Data:ADDVLAYOUT.
	LOCAL box0ValueRight TO box0Data:ADDVLAYOUT.

	// Set box widths
	SET box0LabelLeft:STYLE:WIDTH TO 90.
	SET box0ValueLeft:STYLE:WIDTH TO 90.
	SET box0LabelMid:STYLE:WIDTH TO 90.
	SET box0ValueMid:STYLE:WIDTH TO 90.
	SET box0LabelRight:STYLE:WIDTH TO 90.
	SET box0ValueRight:STYLE:WIDTH TO 90.

	// Add Labels to the Data Box
	box0LabelLeft:ADDLABEL("Airspeed:").
	box0LabelLeft:ADDLABEL("Roll:").
	box0LabelMid:ADDLABEL("Pitch:").
	box0LabelMid:ADDLABEL("Heading:").
	box0LabelRight:ADDLABEL("Altitude:").
	box0LabelRight:ADDLABEL("Vert. Speed:").

	// Setup Initial Data Values
	LOCAL value0Speed TO box0valueLeft:ADDLABEL("...").
	LOCAL value0Roll TO box0valueLeft:ADDLABEL("...").
	LOCAL value0Pitch TO box0valueMid:ADDLABEL("...").
	LOCAL value0Heading TO box0valueMid:ADDLABEL("...").
	LOCAL value0Alititude TO box0valueRight:ADDLABEL("...").
	LOCAL value0VertSpeed TO box0valueRIGHT:ADDLABEL("...").

	// *****************************************************************************
	// *	Create the Controller tab																								 *
	// *****************************************************************************

	LOCAL page IS AddTab(tabwidget,"Flight Controller").

	// Setup the labels for the longitudinal and lateral controllers
	LOCAL labelsAltPitch IS LIST("Altitude:","Pitch:","OFF").
	LOCAL labelsHeadingRoll IS LIST("Heading:","Roll:","OFF").

	// Setup the longitudinal controller
	LOCAL box1Long TO page:ADDVBOX.
	LOCAL box1LongSet TO box1Long:ADDHLAYOUT.
	LOCAL box1LongTunePID TO box1Long:ADDHLAYOUT.

	// Setup the lateral controller
	LOCAL box1Lat TO page:ADDVBOX.
	LOCAL box1LatSet TO box1Lat:ADDHLAYOUT.
	LOCAL box1LatTunePID TO box1Lat:ADDHLAYOUT.

	// Setup the altitude controller
	LOCAL checkbox1Altitude TO box1LongSet:ADDRADIOBUTTON(labelsAltPitch[0]).
	LOCAL value1Altitude TO box1LongSet:ADDLABEL("...").
	LOCAL input1Altitude 	TO box1LongSet:ADDTEXTFIELD.

	box1LongTunePID:ADDSPACING(85).
	LOCAL button1Altitude TO box1LongTunePID:ADDBUTTON("Tune Controller").

	SET checkbox1Altitude:STYLE:HEIGHT TO tunerRowHeight.
	SET checkbox1Altitude:STYLE:WIDTH TO 85.
	SET value1Altitude:STYLE:HEIGHT TO tunerRowHeight.
	SET value1Altitude:STYLE:WIDTH TO 60.
	SET input1Altitude:STYLE:HEIGHT TO tunerRowHeight.
	SET input1Altitude:STYLE:WIDTH TO 70.
	SET input1Altitude:TOOLTIP TO "   " + AltSetpoint:TOSTRING.
	SET button1Altitude:STYLE:HEIGHT TO tunerRowHeight.
	SET button1Altitude:STYLE:WIDTH TO 140.
	box1LongSet:ADDSPACING(30).

	// Setup the pitch controller
	LOCAL checkbox1Pitch TO box1LongSet:ADDRADIOBUTTON(labelsAltPitch[1]).
	LOCAL value1Pitch TO box1LongSet:ADDLABEL("...").
	LOCAL label1PitchReadback TO box1LongSet:ADDLABEL("[...]").
	LOCAL input1Pitch		 	TO box1LongSet:ADDTEXTFIELD.
	box1LongSet:ADDSPACING(30).
	LOCAL checkbox1LongOff TO box1LongSet:ADDRADIOBUTTON(labelsAltPitch[2],TRUE).

	box1LongTunePID:ADDSPACING(120).
	LOCAL button1Pitch		TO box1LongTunePID:ADDBUTTON("Tune Controller").

	SET checkbox1Pitch:STYLE:HEIGHT TO tunerRowHeight.
	SET checkbox1Pitch:STYLE:WIDTH TO 70.
	SET value1Pitch:STYLE:HEIGHT TO tunerRowHeight.
	SET value1Pitch:STYLE:WIDTH TO 50.
	SET label1PitchReadback:STYLE:HEIGHT TO tunerRowHeight.
	SET label1PitchReadback:STYLE:WIDTH TO 50.
	SET input1Pitch:STYLE:HEIGHT TO tunerRowHeight.
	SET input1Pitch:STYLE:WIDTH TO 50.
	SET input1Pitch:TOOLTIP TO "   " + PitchSetpoint:TOSTRING.
	SET button1Pitch:STYLE:HEIGHT TO tunerRowHeight.
	SET button1Pitch:STYLE:WIDTH TO 140.
	SET checkbox1LongOff:STYLE:HEIGHT TO tunerRowHeight.


	// Setup the Heading controller
	LOCAL checkbox1Heading TO box1LatSet:ADDRADIOBUTTON(labelsHeadingRoll[0]).
	LOCAL value1Heading TO box1LatSet:ADDLABEL("...").
	LOCAL input1Heading   TO box1LatSet:ADDTEXTFIELD.

	box1LatTunePID:ADDSPACING(85).
	LOCAL button1Heading  TO box1LatTunePID:ADDBUTTON("Tune Controller").

	SET checkbox1Heading:STYLE:HEIGHT TO tunerRowHeight.
	SET checkbox1Heading:STYLE:WIDTH TO 85.
	SET value1Heading:STYLE:HEIGHT TO tunerRowHeight.
	SET value1Heading:STYLE:WIDTH TO 60.
	SET input1Heading:STYLE:HEIGHT TO tunerRowHeight.
	SET input1Heading:STYLE:WIDTH TO 70.
	SET input1Heading:TOOLTIP TO "   " + HeadingSetpoint:TOSTRING.
	SET button1Heading:STYLE:HEIGHT TO tunerRowHeight.
	SET button1Heading:STYLE:WIDTH TO 140.
	box1LatSet:ADDSPACING(30).

	// Setup the roll controller
	LOCAL checkbox1Roll 			TO box1LatSet:ADDRADIOBUTTON(labelsHeadingRoll[1]).
	LOCAL value1Roll 					TO box1LatSet:ADDLABEL("...").
	LOCAL label1RollReadback 	TO box1LatSet:ADDLABEL("[...]").
	LOCAL input1Roll      		TO box1LatSet:ADDTEXTFIELD.
	box1LatSet:ADDSPACING(30).
	LOCAL checkbox1LatOff 		TO box1LatSet:ADDRADIOBUTTON(labelsHeadingRoll[2],TRUE).

	box1LatTunePID:ADDSPACING(120).
	LOCAL button1Roll     		TO box1LatTunePID:ADDBUTTON("Tune Controller").

	SET checkbox1Roll:STYLE:HEIGHT TO tunerRowHeight.
	SET checkbox1Roll:STYLE:WIDTH TO 70.
	SET value1Roll:STYLE:HEIGHT TO tunerRowHeight.
	SET value1Roll:STYLE:WIDTH TO 50.
	SET label1RollReadback:STYLE:HEIGHT TO tunerRowHeight.
	SET label1RollReadback:STYLE:WIDTH TO 50.
	SET input1Roll:STYLE:HEIGHT TO tunerRowHeight.
	SET input1Roll:STYLE:WIDTH TO 50.
	SET input1Roll:TOOLTIP TO "   " + RollSetpoint:TOSTRING.
	SET button1Roll:STYLE:HEIGHT TO tunerRowHeight.
	SET button1Roll:STYLE:WIDTH TO 140.
	SET checkbox1LatOff:STYLE:HEIGHT TO tunerRowHeight.

	// Add a save button to the UI
	LOCAL buttonSave TO page:ADDBUTTON("Save Tuning Values").

	LOCAL box1Info TO page:ADDHBOX.
	LOCAL box1InfoLabelLeft TO box1Info:ADDVLAYOUT.
	LOCAL box1InfoValueLeft TO box1Info:ADDVLAYOUT.
	LOCAL box1InfoLabelRight TO box1Info:ADDVLAYOUT.
	LOCAL box1InfoValueRight TO box1Info:ADDVLAYOUT.

	// Add the Waypoint direction and distance to the UI
	box1InfoLabelLeft:ADDLABEL("Waypoint:").
	box1InfoLabelLeft:ADDLABEL("Waypoint Direction:").
	box1InfoLabelLeft:ADDLABEL("Waypoint Distance:").

	LOCAL value1VORName TO box1InfoValueLeft:ADDLABEL("<None>").
	LOCAL value1VOR TO box1InfoValueLeft:ADDLABEL("...").
	LOCAL value1VORDist TO box1InfoValueLeft:ADDLABEL("...").

	// Add options to fly to the waypoint and to fly a specific heading after the waypoint is passed
	LOCAL checkbox1ToWayPoint TO box1InfoLabelRight:ADDCHECKBOX("Fly To Waypoint").
	LOCAL checkbox1FlyHeading TO box1InfoLabelRight:ADDCHECKBOX("Fly Heading After Waypoint").

	// Any values on this page will be written to AirplaneData before the save button is pressed
	SET buttonSave:ONCLICK TO
	{
		save().
	}.

	// Setup the longitudinal radion button events
	SET box1LongSet:ONRADIOCHANGE TO
	{
		parameter button.
		IF (button:text = labelsAltPitch[0])
		{
			SET AltitudeControllerActive TO TRUE.
			SET AltitudeControllerOn TO TRUE.
			IF (input1Altitude:text = "")
			{
				SET input1Altitude:text TO input1Altitude:TOOLTIP:TRIMSTART.
			}
			SET input1Pitch:text TO "".
			SET input1Pitch:TOOLTIP TO "   " + PitchSetpoint:TOSTRING.
		}
		ELSE IF (button:text = labelsAltPitch[1])
		{
			SET AltitudeControllerActive TO FALSE.
			SET AltitudeControllerOn TO TRUE.
			IF (input1Pitch:text = "")
			{
				SET input1Pitch:text TO input1Pitch:TOOLTIP:TRIMSTART.
			}
			SET input1Altitude:text TO "".
			SET input1Altitude:TOOLTIP TO "   " + AltSetpoint:TOSTRING.
			SET PitchSetpoint TO input1Pitch:text:TONUMBER(PitchSetpoint).
		}
		ELSE
		{
			SET AltitudeControllerOn TO FALSE.
			SET ControlStick:PITCH TO 0.
			IF (input1Pitch:text <> "")
			{
				SET input1Pitch:text TO "".
				SET input1Pitch:TOOLTIP TO "   " + PitchSetpoint:TOSTRING.
			}
			IF (input1Altitude:text <> "")
			{
				SET input1Altitude:text TO "".
				SET input1Altitude:TOOLTIP TO "   " + AltSetpoint:TOSTRING.
			}
		}
	}.

	// Setup the lateral radio button events
	SET box1LatSet:ONRADIOCHANGE TO
	{
		parameter button.
		IF (button:text = labelsHeadingRoll[0])
		{
			SET HeadingControllerActive TO TRUE.
			SET HeadingControllerOn TO TRUE.
			IF (input1Heading:text = "")
			{
				SET input1Heading:text TO input1Heading:TOOLTIP:TRIMSTART.
			}
			IF (input1Roll:text <> "")
			{
				SET input1Roll:text TO "".
				SET input1Roll:TOOLTIP TO "   " + RollSetpoint:TOSTRING.
			}
		}
		ELSE IF (button:text = labelsHeadingRoll[1])
		{
			SET HeadingControllerActive TO FALSE.
			SET HeadingControllerOn TO TRUE.
			IF (input1Roll:text = "")
			{
				SET input1Roll:text TO input1Roll:TOOLTIP:TRIMSTART.
			}
			IF (input1Heading:text <> "")
			{
				SET input1Heading:TOOLTIP TO "   " + input1Heading:text.
				SET input1Heading:text TO "".
			}
			SET RollSetpoint TO input1Roll:text:TONUMBER(RollSetpoint).
		}
		ELSE
		{
			SET HeadingControllerOn TO FALSE.
			SET ControlStick:ROLL TO 0.
			IF (input1Roll:text <> "")
			{
				SET input1Roll:TOOLTIP TO "   " + input1Roll:text.
				SET input1Roll:text TO "".
			}
			IF (input1Heading:text <> "")
			{
				SET input1Heading:TOOLTIP TO "   " + input1Heading:text.
				SET input1Heading:text TO "".
			}
		}
	}.

	// Setup the Altitude input event
	SET input1Altitude:ONCONFIRM TO
	{
		parameter Height.
		SET AltSetpoint TO Height:TONUMBER(AltSetpoint).
	}.

	// Setup the Pitch input event
	SET input1Pitch:ONCONFIRM TO
	{
		parameter Pitch.
		IF (NOT AltitudeControllerActive)
		{
			SET PitchSetpoint TO Pitch:TONUMBER(PitchSetpoint).
		}
	}.

	// Setup the Heading input event
	SET input1Heading:ONCONFIRM TO
	{
		parameter Heading.
		IF (NOT checkbox1ToWayPoint:PRESSED)
		{
			SET HeadingSetpoint TO Heading:TONUMBER(HeadingSetpoint).
		}
	}.

	// Setup the Roll input event
	SET input1Roll:ONCONFIRM TO
	{
		parameter Roll.
		IF (NOT HeadingControllerActive)
		{
			SET RollSetpoint TO Roll:TONUMBER(RollSetpoint).
		}
	}.

	// Setup the To waypoint button event
	SET checkbox1ToWayPoint:ONCLICK TO
	{
		IF (checkbox1ToWayPoint:PRESSED)
		{
			SET FlyToWayPoint TO TRUE.
			// Update Waypoint
			FOR waypoint IN ALLWAYPOINTS() {
				IF waypoint:ISSELECTED {
					SET value1VORName:TEXT TO waypoint:NAME.
					SET DesiredWaypoint TO waypoint:GEOPOSITION.
				}
			}


			WHEN (ReachedWayPoint OR (NOT FlyToWayPoint)) THEN
			{
				SET ReachedWayPoint TO FALSE.
				SET checkbox1ToWayPoint:PRESSED TO FALSE.
				IF (checkbox1FlyHeading:PRESSED)
				{
					SET checkbox1FlyHeading:PRESSED TO FALSE.
					SET input1Heading:CONFIRMED TO TRUE.
				}
				ELSE
				{
					SET input1Heading:text TO ROUND(CurrentHeading,0):TOSTRING.
					SET input1Heading:CONFIRMED TO TRUE.
				}
			}
		}
		ELSE
		{
			SET HeadingSetpoint TO input1Heading:text:TONUMBER(HeadingSetpoint).
			SET FlyToWayPoint TO FALSE.
		}
	}.

	// *****************************************************************************
	// *	Create the Specifications tab																						 *
	// *****************************************************************************
	LOCAL page IS AddTab(tabwidget,"Aircraft Specs").

	// Setup the specification page to display boxes next to each other
	LOCAL box2 TO page:ADDHBOX.

	LOCAL label2Left TO box2:ADDVLAYOUT.
	LOCAL input2Left TO box2:ADDVLAYOUT.
	LOCAL label2Right TO box2:ADDVLAYOUT.
	LOCAL input2Right TO box2:ADDVLAYOUT.

	// Setup the specifications that are able to be controlled in this tab
	label2Left:ADDLABEL("Max Pitch:").
	LOCAL input2MaxPitch TO input2Left:ADDTEXTFIELD.
	label2Right:ADDLABEL("Min Pitch:").
	LOCAL input2MinPitch TO input2Right:ADDTEXTFIELD.
	label2Right:ADDLABEL("Max Bank").
	LOCAL input2MaxBank TO input2Right:ADDTEXTFIELD.

	// Set the text that displays in the text field to be the current settings for the aircraft
	SET input2MaxPitch:TOOLTIP TO "   " + MaxPitch:TOSTRING.
	SET input2MinPitch:TOOLTIP TO "   " + MinPitch:TOSTRING.
	SET input2MaxBank:TOOLTIP TO "   " + MaxBank:TOSTRING.

	// Setup the max pitch input event
	SET input2MaxPitch:ONCONFIRM TO
	{
		parameter pitch.
		SET MaxPitch TO pitch:TONUMBER(MaxPitch).
		SET AirplaneData["MaxPitch"] TO MaxPitch.
		save().
	}.

	// Setup the min pitch input event
	SET input2MinPitch:ONCONFIRM TO
	{
		parameter pitch.
		SET MinPitch TO pitch:TONUMBER(MinPitch).
		SET AirplaneData["MinPitch"] TO MinPitch.
		save().
	}.

	// Setup the max bank input event
	SET input2MaxBank:ONCONFIRM TO
	{
		parameter bank.
		SET MaxBank TO bank:TONUMBER(MaxBank).
		SET AirplaneData["MaxBank"] TO MaxBank.
		save().
	}.

	// Select the tab that is first shown
	ChooseTab(tabwidget,1).

	// Add button to Close UI
	LOCAL close IS gui:ADDBUTTON("Close").
	LOCK closeProgram TO close:ONCLICK.

	// Set the mainpower button event
	SET buttonPower:ONCLICK TO
	{
		IF buttonPower:pressed
		{
			SET powerOn TO TRUE.
			SET valueStatus:text TO "ON".
		}
		else
		{
			SET powerOn TO FALSE.
			SET valueStatus:text TO "OFF".
		}
	}.

	// Setup the close button event
	SET close:ONCLICK TO
	{
		SET closeProgram TO TRUE.
	}.

	// Set the readback values to update whenever frequently
	ON TIME:SECONDS
	{
		IF (tabIndex = 0)
		{
			SET value0Speed:text TO (ROUND(SHIP:AIRSPEED,1):TOSTRING + " m/s").
			SET value0Roll:text TO (ROUND(CurrentBank,1):TOSTRING + "°").
			SET value0Pitch:text TO (ROUND(CurrentPitch,1):TOSTRING + "°").
			SET value0Heading:text TO (ROUND(CurrentHeading,0):TOSTRING + "°").
		  SET value0Alititude:text TO (ROUND(CurrentAltitude,0):TOSTRING + " m").
			SET value0VertSpeed:text TO (ROUND(VERTICALSPEED,1):TOSTRING + " m/s").
		  SET value0Heading:text TO ROUND(CurrentHeading,0):TOSTRING + "°".
		}
		ELSE IF (tabIndex = 1)
		{
		  SET value1Altitude:text TO (ROUND(CurrentAltitude,0)):TOSTRING + " m".
			SET value1Pitch:text TO (ROUND(CurrentPitch,1):TOSTRING + "°").
		  SET value1Heading:text TO (ROUND(CurrentHeading,0):TOSTRING + "°").
		  SET value1Roll:text TO (ROUND(CurrentBank,1):TOSTRING + "°").
			SET value1VOR:text TO (ROUND(DesiredWaypoint:HEADING,0):TOSTRING + "°").
			IF (DesiredWaypoint:DISTANCE > 9999)
			{
				SET value1VORDist:text TO (ROUND(DesiredWaypoint:DISTANCE/1000,1):TOSTRING + " km").
			}
			ELSE
			{
				SET value1VORDist:text TO (ROUND(DesiredWaypoint:DISTANCE,0):TOSTRING + " m").
			}
			IF (AltitudeControllerOn)
			{
				SET label1PitchReadback:TEXT TO "[" + ROUND(PitchSetpoint,1):TOSTRING + "]".
			}
			IF (HeadingControllerOn)
			{
				SET label1RollReadback:TEXT TO "[" + ROUND(RollSetpoint,1):TOSTRING + "]".
			}
		}
		PRESERVE.
	}

	SET valueStatus:text TO "Ready!".
	gui:SHOW().

	// *****************************************************************************
	// *	Create the Controller Tuner popups																			 *
	// *****************************************************************************
	createTunersGUI(LIST(button1Altitude,button1Pitch,button1Heading,button1Roll)).
}
