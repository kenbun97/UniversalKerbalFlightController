// Name:          Flight Controller Boot File
//
// Author:        Kenny Bunnell
//
// Date:					5 January 2021
//
// Description:   This program will copy all the needed files to the local CPU and run the flight controller.
//                If exited, the flight controller can be reoped simply by rerunning the last line of this file.
//
LOCAL compileFlag TO FALSE.
LOCAL runLocal TO FALSE.

LOCAL codeDir TO "0:/flightController/".
LOCAL targetDir TO "1:/run/".

DECLARE function COMPILE_TO_SHIP {
    PARAMETER file.
    LOCAL compiledFile TO file:REPLACE(".ks", ".ksm").
    COMPILE file TO targetDir+compiledFile.
}

CD(codeDir).

IF NOT EXISTS(targetDir) {
    CREATEDIR(targetDir).
}

IF runLocal {
	IF compileFlag {
		COMPILE_TO_SHIP("flightController.ks").
		COMPILE_TO_SHIP("flightControllerGUI.ks").
		COMPILE_TO_SHIP("tunerUI.ks").
	} ELSE {
		COPYPATH("flightController.ks", targetDir).
		COPYPATH("flightControllerGUI.ks", targetDir).
		COPYPATH("tunerUI.ks", targetDir).
	}
}

IF NOT EXISTS("0:/bin/tabWidget/") {
    CREATEDIR("0:/bin/tabWidget/").

    COMPILE "0:/lib/tabWidget/tabWidget.ks" TO "0:/bin/tabWidget/tabWidget.ksm".
    COPYPATH("0:/lib/tabWidget/back.png", "0:/bin/tabWidget/").
    COPYPATH("0:/lib/tabWidget/front.png", "0:/bin/tabWidget/").
    COPYPATH("0:/lib/tabWidget/panel.png", "0:/bin/tabWidget/").
}

IF runLocal {
	IF EXISTS("tuningData.json") {
	    COPYPATH("tuningData.json", targetDir).
	}
	CD(targetDir).

	IF NOT EXISTS("tuningData.json") {
 	   PRINT "Warning - Not enought space for Flight Controller on local volume. Running code from 0. Based on your KOS settings, the Flight Controller may only work when connected to the KSC.".
 	   CD(codeDir).
	}
}
RUN flightController.