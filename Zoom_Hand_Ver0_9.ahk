;AutoHotKey V2.0 Code
;Note 1- Zoom running full screen with Participant Window Open 
;Note 2- Running on MS Surface Pro. To make the Participant list text large the screen is set to 1680X1050 Scaling set to 175%
;Note 3- Adjusting the scaling from 175% will adjust the hand symbols and the (Me). You'll have to capture the different hand colours with the snipping tool
;Note 4- To improve macro speed decrease the window size used for the ImageSearch. Use WindowsSpy to check the area
;Note 5- The ControlClick uses the Client X&Y by default

MaxItems := 0			;reset the image search count
TimerX := A_TickCount		;real time timer
CoordMode 'Pixel', 'Screen'	;Sets coordinate mode for ImageSearch to Screen. https://www.autohotkey.com/docs/v2/lib/CoordMode.htm

;Setup the on screen GUI

gui1 := Gui('+AlwaysOnTop -Caption')				;GUI on top with no caption box
gui1.SetFont('s' 70)
gui1.BackColor := 'Black'
txt := gui1.AddText('r2 Center ' 'c' "Lime", "Macro is Running")
gui1.Show('x-150 y250 NA') ;'y75')
WinSetTransColor 'Black', gui1.Hwnd

;Main Code Loop

Loop {						
Sleep 1000			;adjust this higher if the CPU is getting swamped 

	if not (PID := ProcessExist("zoom.exe")) 	;Check if Zoom is running
		{
		txt.Text := 'Zoom Not Running'
		gui1.Show('NA')
		Sleep 1000
		txt.Text := ' '
		Sleep 5000
		Continue				;if Zoom isn't running restart the loop

		}

	if not (WinExist("Zoom Meeting")) 		;Check if the Zoom Meeting is Running
		{
		txt.Text := 'Zoom Meeting Not Running'
		gui1.Show('NA')
		Sleep 1000
		txt.Text := ' '
		Sleep 5000
		Continue				;if Zoom Meeting isn't running restart the loop
	
		}

	Found := ImageDirSearchAll('c:\images_me\*.png', 1120, 0, 1679, 950 , "TransWhite")	;ImageSearch for the (Me) to ensure the participant list is at the top
	MaxItems := Found.Capacity
	if (MaxItems < 1)						;if (Me) isn't found then prompt and try to move the list up 
		{
		txt.Text := 'Scroll Participants' . '`nList to the top'
		gui1.Show('NA')
		Sleep 3000
		ControlClick "x1678 y207", "Zoom Meeting"		;click on the top of the right hand participant scrollbar so it's at the top. Adjust to your screen area
		Continue

		}

	Found := ImageDirSearchAll('c:\images_hands\*.png', 1120, 0, 1679, 950) 	;Do an Imagesearch for the hand symbol
	MaxItems := Found.Capacity							;Number of hands found
	;Output := ''
	for Instance, Coord in Found
		Output .= 'Instance ' Instance ' found at: ' Coord.x ',' Coord.y ',' MaxItems '`n'
	;MsgBox Output									;Used for debugging hand locations on screen

	TimerY := Round((A_TickCount - TimerX) / 1000)					;Covert A_TickCount to seconds elapsed

	if (MaxItems > 0 and TimerY <60) 						;Hands>1 Timer less then 60 seconds
	{
		txt.Text := MaxItems . ' Hand(s)' . '`nTime:=' . TimerY			;Show number of hands and timer
		gui1.Show('NA')

	} 
	else if (MaxItems > 0)								;Over 60 Seconds
	{	txt.Text := " "
		Sleep 200								;Blick the GUI on and off to get attention
		txt.Text := MaxItems . ' Hand(s)' . '`nTime:=' . TimerY
		
	}
	else 
	{
		TimerX := A_TickCount							;No hands up reset timer to current time
		gui1.Hide()
		;Continue

	}


}		;End of Main Loop

;ImageSearch funtion is below. Searches for the different virtual hand shades in Zoom and counts them.

ImageDirSearchAll(imageFile, x1:=0, y1:=0, x2:='Screen', y2:='Screen', var:=0) {
	x2 := x2 = 'Screen' ? A_ScreenWidth : x2
	y2 := y2 = 'Screen' ? A_ScreenHeight : y2
	found := []
	y := y1
	Loop Files, imageFile
	loop {
		x := x1
	    lastFoundY := 0
		while f := ImageSearch(&foundX, &foundY, x, y, x2, y2, '*' var ' ' A_LoopFileFullPath) {
			if (lastFoundY = 0 || lastFoundY = foundY) {
				found.Push({x: foundX, y: foundY})
				x := foundX + 1
				lastFoundY := foundY
			} else
				break
		}
		y := lastFoundY + 1
	} until (x = x1) && !f
	return found
}

