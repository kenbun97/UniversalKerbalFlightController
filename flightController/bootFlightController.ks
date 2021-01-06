// Name:          Flight Controller Boot File
//
// Author:        Kenny Bunnell
//
// Date:					5 January 2021
//
// Description:   This program will copy all the needed files to the local CPU and run the flight controller.
//                If exited, the flight controller can be reoped simply by rerunning the last line of this file.
//
LOCAL codeDir TO "0://flightController/".
COPYPATH(codeDir + "flightController.ks", "flightController.ks").
COPYPATH(codeDir + "flightControllerGUI.ks", "flightControllerGUI.ks").
COPYPATH(codeDir + "tunerUI.ks", "tunerUI.ks").
COPYPATH(codeDir + "tuningData.json", "tuningData.json").
COPYPATH("0://lib/tabWidget/", "/lib/tabWidget").
RUN flightController.ks.
