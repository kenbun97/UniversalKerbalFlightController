// Name:          Flight Controller
//
// Author:        Kenny Bunnell
//
// Date:					5 January 2021
//
// Description:   This is the program that runs the basic Multi-tab Flight Controller.
//								This program calls the GUI and is in charge of declaring all the
//								variables needed to run the flight controller.
//
@LAZYGLOBAL off.
CLEARSCREEN.

RUNONCEPATH("flightControllerGUI.ks").

LOCAL DATA_FILE IS "0://flightController/tuningData.json".	// Name of the file where the tunning data is stored
// Declare names to store the tunning variables under inside the json structure
GLOBAL TuneValNames TO LIST("AltTuneVals","PitchTuneVals","HeadingTuneVals","RollTuneVals").
// Declare titles for the tunning GUIs
GLOBAL TuneValTitles TO LIST("Altitude","Pitch","Heading","Roll").
GLOBAL TuneContainsDamper IS LIST (FALSE,TRUE,FALSE,TRUE). // Does the tuner have a damping gain?
GLOBAL MaxBank TO 0.					// The maximum bank the aircraft should achieve
GLOBAL MaxPitch TO 0.					// The maximum pitch the aircraft should achieve
GLOBAL MinPitch TO 0.					// The minimum pitch the aircraft should achieve

// Define the default controller setpoints
GLOBAL AltSetpoint TO 1000.		// The altitude that the aircraft should try to hold
GLOBAL HeadingSetpoint TO 90.	// The heading that the aircraft should try to hold
GLOBAL RollSetpoint TO 0.			// The roll angle that the aircraft should try to hold
GLOBAL PitchSetpoint TO 0.		// The pitch angle that the aircraft should try to hold
LOCAL MIN_LOOP_TIME TO 0.05.

// Initialize the locked variable expressions
// Note: Be careful that the expressions are locked right after declaration. Otherwise,
// 			 strange errors can occur that seem to be related to the changing of these
// 			 variable types from integers to functions.
GLOBAL CurrentBank TO 0.			// The current bank angle of the aircraft
GLOBAL CurrentPitch TO 0.			// The current pitch angle of the aircraft
GLOBAL CurrentAltitude TO 0.	// The current altitude of the aircraft
GLOBAL CurrentHeading TO 0.		// The current heading of the aircraft


// Define variables to hold the airplane structures
// Note: AirplaneData is used to transfer the aircraft tunning information between
//			 this backend controller code and the UI. Any change made to AirplaneData
//			 automatically updates MultiplaneData as well, but the save() function must
//			 be called in order to save MultiplaneData to the DATA_FILE.
LOCAL MultiPlaneData TO LEXICON(). // A structure for all aircraft that have been tuned
GLOBAL AirplaneData TO LEXICON().	 // A structure for the current aircraft.

// Define GUI Aliases and Flags
GLOBAL closeProgram TO FALSE.		// A flag to exit the flight controller
GLOBAL powerOn TO FALSE.				// A flag to toggle the auto pilot of the flight controller
GLOBAL FlyToWayPoint TO FALSE.	// A flag to be set if the user wants to fly to a waypoint
GLOBAL ReachedWayPoint TO FALSE.// A flag to be set if the user reached the waypoint
GLOBAL AltitudeControllerOn TO FALSE.// A flag to be set if the user turned on any of the longitudinal stability controllers
GLOBAL AltitudeControllerActive TO FALSE.// A flag to be set if the user activated the altitude flight controller
GLOBAL HeadingControllerOn TO FALSE.// A flag to be set if the user activated any of the lateral stability controllers
GLOBAL HeadingControllerActive TO False.// A flag to be set if the user activated the heading controller

// Initialize flight control variables
GLOBAL DesiredWaypoint TO 0.		// Holds a LATLNG structure for the currently selected waypoint
GLOBAL ControlStick TO SHIP:CONTROL.// Initialize the control stick variable
LOCAL PreviousBank TO 0.				// The bank angle from the previous iteration
LOCAL PreviousPitch TO 0.				// The pitch angle from the previous iteration
LOCAL PitchRate TO 0.						// The rate of change of the pitch angle
LOCAL RollRate TO 0.						// The rate of change of the roll angle
LOCAL LoopStart TO 0.						// The time that the loop started
LOCAL dt TO 0.0001.							// The time it took for the loop ti execute

// Define some basic waypoints to be chosen from
LOCAL KSC TO LATLNG(-0.0486276256123262, -74.7248342105711). // Location of Runway 9 at KSC
LOCAL ISLAND_AIRFIELD TO LATLNG(-1.51589153348338, -71.855700627401). // Location of Runway 27 at Island Airfield
LOCAL INLAND_SC TO LATLNG(20.657222, -146.420556).
LOCAL northPole TO LATLNG(90,0).

// Set the desired waypoint...in the future, this should be initialized to blank,
// then set by the user
SET DesiredWaypoint TO KSC

// *****************************************************************************
// *  Function: saved						                 															 *
// *****************************************************************************
// Define a function to save the GLOBAL AirplaneData to the DATA_FILE.
// The programmer should ensure that any variable to be saved to the json file is
// recorded to AirplaneData before calling this funciton.
DECLARE function save
{
	// Write any values desired to be saved to AirplaneData before calling function
	IF not (MultiplaneData:HASKEY(SHIP:NAME))
	{
		MultiplaneData:ADD(SHIP:NAME, AirplaneData).
	}
	WRITEJSON(MultiplaneData, DATA_FILE).
	PRINT "Saved Data!".
}.

// Lock variables that will always be set to a specific value.
LOCK CurrentBank to (90 - vectorangle(up:vector, ship:facing:starvector)).
LOCK CurrentPitch to (90 - vectorangle(up:vector, ship:facing:forevector)).
LOCK CurrentAltitude TO ALT:RADAR.
// Update the angular rates of aircraft
LOCK CurrentHeading TO mod(360 - northPole:bearing,360).
LOCK PitchRate TO (CurrentPitch - PreviousPitch) / dt.
LOCK RollRate TO (CurrentBank - PreviousBank) / dt.

// *****************************************************************************
// *	Begin Program
// *****************************************************************************

// First Read the Data JSON File to get Airplane Tuning Data
IF (EXISTS(DATA_FILE))
{
	SET MultiPlaneData TO READJSON(DATA_FILE).
	IF MultiplaneData:HASKEY(SHIP:NAME)
	{
		SET AirplaneData TO MultiplaneData[SHIP:NAME].
		PRINT "Grabbed JSON structure".
	}
	else
	{
		// Add empty airplane structure to the JSON structure to initialize file.
		FROM {LOCAL index IS 0.} UNTIL index = TuneValNames:LENGTH STEP {SET index TO index+1.} DO
	  {
			IF (TuneContainsDamper[index])
			{
				AirplaneData:ADD(TuneValNames[index], LIST(0,0)).
			}
			ELSE
			{
				AirplaneData:ADD(TuneValNames[index], LIST(0)).
			}
		}
		// Add the Aircraft default specifications if no tuning data is found
		AirplaneData:ADD("MaxPitch", 20).
		AirplaneData:ADD("MinPitch", -10).
		AirplaneData:ADD("MaxBank", 30).
		PRINT "Created new JSON Structure".
	}
}
else
{
	// Add empty airplane structure to the JSON structure to initialize file.
	FROM {LOCAL index IS 0.} UNTIL index = TuneValNames:LENGTH STEP {SET index TO index+1.} DO
	{
		IF (TuneContainsDamper[index])
		{
			AirplaneData:ADD(TuneValNames[index], LIST(0,0)).
		}
		ELSE
		{
			AirplaneData:ADD(TuneValNames[index], LIST(0)).
		}
	}
	// Add the Aircraft default specifications if no tuning data is found
	AirplaneData:ADD("MaxPitch", 20).
	AirplaneData:ADD("MinPitch", -10).
	AirplaneData:ADD("MaxBank", 30).
	PRINT "Created new JSON Structure".
}

// Now that AirplaneData is defined, Setup Gain Aliases
LOCK AltGain TO AirPlaneData["AltTuneVals"][0].
LOCK PitchGain TO AirPlaneData["PitchTuneVals"][0].
LOCK PitchDGain TO AirPlaneData["PitchTuneVals"][1].
LOCK HeadingGain TO AirPlaneData["HeadingTuneVals"][0].
LOCK RollGain TO AirPlaneData["RollTuneVals"][0].
LOCK RollDGain TO AirPlaneData["RollTuneVals"][1].
LOCK MaxPitch TO AirplaneData["MaxPitch"].
LOCK MinPitch TO AirplaneData["MinPitch"].
LOCK MaxBank TO AirplaneData["MaxBank"].

createFlightControllerGUI().


// Stay in loop until the user pressed the close button on the main UI
UNTIL (closeProgram)
{
	// Record the start time of the loop so we can determine how long the loop takes
	SET LoopStart TO TIME:SECONDS.

	// Run the main flight controller code when the user turns the power on
	IF (powerOn = TRUE)
	{
		SAS OFF.

		// If one of the longitudinal controllers is on, control the pitch of the aircraft
		IF (AltitudeControllerOn)
		{
			// If Altitude control is being requested, set the pitch setpoint
			IF (AltitudeControllerActive)
			{
				SET	PitchSetpoint TO MIN(MaxPitch, MAX(MinPitch, AltGain * (AltSetpoint - SHIP:ALTITUDE))).
			}
			SET ControlStick:PITCH TO MIN(1, MAX(-1, ControlStick:PITCH + dt / 20 * (ControlStick:PITCH + (PitchSetpoint - PitchGain * CurrentPitch)) + PitchDGain * PitchRate)).
		}

		// If one of the lateral controllers is on, control the roll of the aircraft
		IF (HeadingControllerOn)
		{
			// If Heading control is being requested, set the roll setpoint
			IF (HeadingControllerActive)
			{
				IF (FlyToWayPoint)
				{
					// If the user wants to fly to the waypoint, ignore the user's heading
					// request and head for the waypoint
					SET HeadingSetpoint TO DesiredWaypoint:HEADING.
					// If the plane is at the waypoint, turn off the request to fly to the waypoint
					IF (SQRT(DesiredWaypoint:DISTANCE^2 - CurrentAltitude^2) < 5000)
					{
						SET FlyToWayPoint TO FALSE.
						SET ReachedWayPoint TO TRUE.
					}
				}

				// Since 0 and 360 degrees are the same, we need to program a way to prevent
				// the aircraft from performing a near 360 when it might only need to turn
				// a few degrees
				// If the current heading and the requested heading are within 180 degrees,
				// there is no need for a correction. Clearly, the heading error should never
				// be larger than 180 degrees. If it is, we need a correction performed.
				IF (ABS(HeadingSetpoint - CurrentHeading) < 180)
				{
					SET RollSetpoint TO MIN(MaxBank, MAX(-MaxBank, HeadingGain * (HeadingSetpoint - CurrentHeading))).
				}
				ELSE
				{
					// Now only two scenarios arise. One where the current Heading is larger
					// than 180, and one where the current Heading is smaller. If the current
					// Heading is smaller than 180, we will subtract 360 from the setpoint,
					// else, add 360 to the setpoint.
					// For example, CurrentHeading = 5, HeadingSetpoint = 355. Clearly, the
					// heading error should only be -10 degrees. To get this, we subtract the
					// setpoint by 360 to pretend like the current Heading is -5. This gives
					// us the expected error as a result.
					IF (CurrentHeading < 180)
					{
						SET RollSetpoint TO MIN(MaxBank, MAX(-MaxBank, HeadingGain * ((HeadingSetpoint - 360) - CurrentHeading))).
					}
					ELSE
					{
						SET RollSetpoint TO MIN(MaxBank, MAX(-MaxBank, HeadingGain * ((HeadingSetpoint + 360) - CurrentHeading))).
					}
				}
			}
			SET ControlStick:ROLL TO MIN(1, MAX(-1, ControlStick:ROLL + 15*(RollGain*(RollSetpoint - CurrentBank) - ControlStick:ROLL) * dt) + RollDGain * RollRate).
		}
	}
	ELSE
	{
		SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
		SAS ON.
	}
	// Update the previous aircraft angles so that the rates can be determined
	SET PreviousBank TO CurrentBank.
	SET PreviousPitch TO CurrentPitch.

	// Calculate the loop time
	SET dt TO TIME:SECONDS - LoopStart.

	// Make sure that dt is never negative or 0
	// I set the minimum dt to be relatively high because I noticed an unstable oscillation in the controller with lower dt values
	IF dt < MIN_LOOP_TIME
	{
		SET dt TO MIN_LOOP_TIME.
		WAIT(MIN_LOOP_TIME - dt).
	}
}

// When the user closes the UI setup the ship to be stable and controllable
// In an emergency, this should be the quickest way to gain back manual control
SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
SAS ON.
CLEARGUIS().
