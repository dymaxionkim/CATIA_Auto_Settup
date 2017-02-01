#########################################################################
# TBOption Setting
#########################################################################
proc setTBOptions {} {
	global u_Units
	global keepBackgroundViewActive
	global background_colour

	toplevel .topTBSetting -background $background_colour
	putWindowOnTop .topTBSetting
	
#   Activate Background View after leaving macro
	set labelView [translate "Keep Background View active"]
	set tFcurFrame [TitleFrame .topTBSetting.fbckview -text $labelView -background $background_colour]
	set curFrame [$tFcurFrame getframe]
    checkbutton $curFrame.bckview -variable keepBackgroundViewActive -background $background_colour -text $labelView
	pack $curFrame.bckview -in $curFrame
	pack $tFcurFrame -in .topTBSetting

	if {[info exists u_Units]} {
		foreach unit $u_Units {
			global u_$unit
			global def_$unit
			set tFcurFrame [TitleFrame .topTBSetting.f$unit -text $unit -background $background_colour]
			set curFrame [$tFcurFrame getframe]
			foreach l [subst $[subst u_$unit]] {
				set radio [radiobutton $curFrame.r[lindex $l 0] -text [lindex $l 0] -variable def_$unit -value [lindex $l 0] -background $background_colour]
				pack $radio -in $curFrame -side left
			}
			pack $tFcurFrame -in .topTBSetting
		}
	}
	
	button .topTBSetting.but_ok  -image but_ok -height 15 -width 75 -background $background_colour \
			-command {
				destroy .topTBSetting
				set answer [tk_messageBox -message [translate {"Change all data from 3D model?"}] -type yesno -icon question]
				if {$answer == "yes"} then {
					acceptAll3dEntries
				}
			}
	pack .topTBSetting.but_ok -in .topTBSetting

}
proc setTBDefaults {} {
	global u_Units

	if {[info exists u_Units]} {
		foreach unit $u_Units {
			global def_$unit
			global u_$unit
			set def_$unit [lindex [lindex [subst $[subst u_$unit]] 0] 0]
		}
	}
}
