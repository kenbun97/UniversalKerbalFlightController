// Name:          Flight Controller Tuner UIs
//
// Author:        Kenny Bunnell
//
// Date:					5 January 2021
//
// Description:   This is the program that creates and handles the events for the
//                many tuner UIs. This program is in charge of writing updated tuning
//                values to the AirplaneData structure.
@LAZYGLOBAL off.

DECLARE function createTunersGUI
{
  parameter activatorButtons.

  IF ((NOT (DEFINED AirplaneData)) AND (NOT (DEFINED TuneValNames)))
  {
    // Without these structures, the tune inputs will not know where to write the tune data!!!
    PRINT "Error! AirplaneData or TunerValNames is not defined!".
    RETURN.
  }

  IF ((activatorButtons:LENGTH) <> (TuneValTitles:LENGTH))
  {
    PRINT "Error! Tuner creation was attempted, but names and activatorButtons have different lengths!".
    RETURN.
  }

  // Create a Tuner GUI Structure
  LOCAL guiTuners TO LIST().
  LOCAL guiActivated TO LIST().

  // Loop through and create each Tuner UI
  FROM {LOCAL index IS 0.} UNTIL index = TuneValTitles:LENGTH STEP {SET index TO index+1.} DO
  {
    LOCAL L IS LEXICON().

    L:ADD("gui", GUI(200)).
    LOCAL labelTuner TO L:gui:ADDLABEL(TuneValTitles[index] + " PID Tuner").

    // Setup PID as a Horizontal Box
    LOCAL boxTData TO L:gui:ADDHBOX.

    // Seperate Data into 4 columns
    LOCAL boxTLabelLeft   TO boxTData:ADDVLAYOUT.
    LOCAL boxTValueLeft   TO boxTData:ADDVLAYOUT.
    LOCAL boxTLabelRight  TO boxTData:ADDVLAYOUT.
    LOCAL boxTValueRight  TO boxTData:ADDVLAYOUT.
    L:ADD("buttonTClose", L:gui:ADDBUTTON("Close")).

    // Add a Gain Tuner
    LOCAL labelTP TO boxTLabelLeft:ADDLABEL("Gain:").
    L:ADD("inputGain", boxTValueLeft:ADDTEXTFIELD).

    // Set the Gain tuner to display the current tune value
    SET L:inputGain:TOOLTIP TO " " + AirPlaneData[TuneValNames[index]][0].

    IF (TuneContainsDamper[index])
    {
      // Add a damper Gain Tuner
      LOCAL labelTI TO boxTLabelLeft:ADDLABEL("Daming Gain:").
      L:ADD("inputDGain", boxTValueLeft:ADDTEXTFIELD).

      // Set the Damper Gain tuner to display the current tune value
      SET L:inputDGain:TOOLTIP TO " " + AirPlaneData[TuneValNames[index]][1].
    }
    guiActivated:ADD(FALSE).
    guiTuners:ADD(L).
  }

  // Unfortunately, we have to set up each button/input box seperately because when interacted with,
  // these widgets will attempt to reference a function. If the close buttons for example, were coded
  // inside a function, then each button would point to the same code, but no parameters are available
  // to distinguish which button was pressed. So to make the UI more intuitive, we code each interaction
  // seperately.


  // ***************************************************************************
  // *  Altitude Tuner    Index: 0                                             *
  // ***************************************************************************
  // Set the Tuner to open or close when activatorButton is pushed
  SET activatorButtons[0]:ONCLICK TO
  {
    IF (guiActivated[0])
    {
      guiTuners[0]:gui:HIDE().
    }
    else
    {
      guiTuners[0]:gui:show().
    }
  }.

  // Set the Tuner to close when close is pushed
  SET guiTuners[0]:buttonTClose:ONCLICK TO
  {
    guiTuners[0]:gui:HIDE().
    SET guiActivated[0] TO FALSE.
  }.

  // Setup the Gain Input to write to AirPlaneData Structure
  SET guiTuners[0]:inputGain:ONCONFIRM TO
  {
    parameter Gain.
    SET AirplaneData[TuneValNames[0]][0] TO Gain:TONUMBER(0).
  }.

  IF (TuneContainsDamper[0])
  {
    // Setup the Damper Gain Input to write to AirPlaneData Structure
    SET guiTuners[0]:inputDGain:ONCONFIRM TO
    {
      parameter DamperGain.
      SET AirplaneData[TuneValNames[0]][1] TO DamperGain:TONUMBER(0).
    }.
  }



  // ***************************************************************************
  // *  Pitch Tuner    Index: 1                                                *
  // ***************************************************************************
  // Set the Tuner to open or close when activatorButton is pushed
  SET activatorButtons[1]:ONCLICK TO
  {
    IF (guiActivated[1])
    {
      guiTuners[1]:gui:HIDE().
    }
    else
    {
      guiTuners[1]:gui:show().
    }
  }.

  // Set the Tuner to close when close is pushed
  SET guiTuners[1]:buttonTClose:ONCLICK TO
  {
    guiTuners[1]:gui:HIDE().
    SET guiActivated[1] TO FALSE.
  }.

  // Setup the Gain Input to write to AirPlaneData Structure
  SET guiTuners[1]:inputGain:ONCONFIRM TO
  {
    parameter Gain.
    SET AirplaneData[TuneValNames[1]][0] TO Gain:TONUMBER(0).
  }.

  IF (TuneContainsDamper[1])
  {
    // Setup the Damper Gain Input to write to AirPlaneData Structure
    SET guiTuners[1]:inputDGain:ONCONFIRM TO
    {
      parameter DamperGain.
      SET AirplaneData[TuneValNames[1]][1] TO DamperGain:TONUMBER(0).
    }.
  }



  // ***************************************************************************
  // *  Heading Tuner    Index: 2                                              *
  // ***************************************************************************
  // Set the Tuner to open or close when activatorButton is pushed
  SET activatorButtons[2]:ONCLICK TO
  {
    IF (guiActivated[2])
    {
      guiTuners[2]:gui:HIDE().
    }
    else
    {
      guiTuners[2]:gui:show().
    }
  }.

  // Set the Tuner to close when close is pushed
  SET guiTuners[2]:buttonTClose:ONCLICK TO
  {
    guiTuners[2]:gui:HIDE().
    SET guiActivated[2] TO FALSE.
  }.

  // Setup the Gain Input to write to AirPlaneData Structure
  SET guiTuners[2]:inputGain:ONCONFIRM TO
  {
    parameter Gain.
    SET AirplaneData[TuneValNames[2]][0] TO Gain:TONUMBER(0).
  }.

  IF (TuneContainsDamper[2])
  {
    // Setup the Damper Gain Input to write to AirPlaneData Structure
    SET guiTuners[2]:inputDGain:ONCONFIRM TO
    {
      parameter DamperGain.
      SET AirplaneData[TuneValNames[2]][1] TO DamperGain:TONUMBER(0).
    }.
  }



  // ***************************************************************************
  // *  Roll Tuner    Index: 3                                                 *
  // ***************************************************************************
  // Set the Tuner to open or close when activatorButton is pushed
  SET activatorButtons[3]:ONCLICK TO
  {
    IF (guiActivated[3])
    {
      guiTuners[3]:gui:HIDE().
    }
    else
    {
      guiTuners[3]:gui:show().
    }
  }.

  // Set the Tuner to close when close is pushed
  SET guiTuners[3]:buttonTClose:ONCLICK TO
  {
    guiTuners[3]:gui:HIDE().
    SET guiActivated[3] TO FALSE.
  }.

  // Setup the Gain Input to write to AirPlaneData Structure
  SET guiTuners[3]:inputGain:ONCONFIRM TO
  {
    parameter Gain.
    SET AirplaneData[TuneValNames[3]][0] TO Gain:TONUMBER(0).
  }.

  IF (TuneContainsDamper[3])
  {
    // Setup the Damper Gain Input to write to AirPlaneData Structure
    SET guiTuners[3]:inputDGain:ONCONFIRM TO
    {
      parameter DamperGain.
      SET AirplaneData[TuneValNames[3]][1] TO DamperGain:TONUMBER(0).
    }.
  }
}
