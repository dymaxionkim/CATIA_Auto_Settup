#########################################################################
# accept all 3d entries in one action
#########################################################################
proc acceptAll3dEntries {} {
	global allDirtyItems
	global notebook
	global title_fields
	global generative_fields
	global sheet_dirty
	
	if {[info exists allDirtyItems]} then {
		foreach widget $allDirtyItems {
			set temp 		[split $widget "§"]
			set change		[lindex $temp 1]
			set field	  	[lindex $temp 2]
			set mode    	[lindex $temp 3]
			set sheetact  	[lindex $temp 4]
			set number  	[lindex $temp 5]

			set frameEntry  [string range [lindex $temp 0] 0 [expr [string length [lindex $temp 0]] - 11]]
			global u_$field
			global def_$field
			if {[getExtFieldDef $field "entry_mode"] != "disabled"} then {


				if {[info exists u_$field]} then {
						set val3D [convUnits $field "1 [subst $[subst def_$field]]" [subst $[subst generative_fields($sheetact\_$field)]]]
				} else {
						set val3D [subst $[subst generative_fields($sheetact\_$field)]]
				}

#			tk_messageBox -message "$widget : $change"
				if {$change == "normal"} {
					setTBData $sheetact $field $val3D
				} else {
					setTBRdata $sheetact $field $number $val3D

				}

				#			reflect dirty flag on tab

				if {[$frameEntry.ent_seq§$change§$field§$mode§$sheetact§$number§$change cget -bg] == "yellow"} then {
					$frameEntry.ent_seq§$change§$field§$mode§$sheetact§$number§$change configure -bg "white"
					if {$sheetact != 0} then {
						set sheet_dirty($sheetact) 0
						$notebook itemconfigure $sheetact -image nothing
					}
				}
			}

		}
	} else {
		tk_messageBox -message [translate {no 3D value mismatch found}]
	}
}


#########################################################################
# show the date selector
#########################################################################

proc date_select {widget x y} {
	global os_type
	global log
	global title_fields
	global active_sheet
	global field
	global date_format
	global changed
	global number
	global revisions
	global sheetact
	global dateUppercase


	set temp 		[split $widget "§"]
	set changed     [lindex $temp 1]
	set field 		[lindex $temp 2]
	set sheetact  	[lindex $temp 3]
	set number		[lindex $temp 4]


	toplevel .date
	putWindowOnTop .date
#	wm overrideredirect .date 1
	wm geometry .date "+$x+$y"
	date::chooser .date.date_canvas
	button .date.but -text "OK" -command {
		set date_selected [clock format $date::a(date) -format $date_format]
		if {$dateUppercase == "Yes"} then {
			set date_selected [string toupper $date_selected]
		}
		if {$changed == "normal"} {
			set title_fields($sheetact\_TitleBlock_Text_$field) $date_selected
		} else {
			set title_fields($sheetact\_RevisionBlock_Text_$field\_$number) $date_selected
		}
		destroy .date
	}
	pack .date.date_canvas .date.but -in .date
	if {$os_type == "windows"} then {
		focus .date
		grab .date
	}
}


#########################################################################
# show 3d master models for the drawing
#########################################################################

proc show_3d_master_models {} {
	global generative_models
	global log
	global background_colour
	global os_type
	set mod_3d [toplevel .mod_3d]
	
	putWindowOnTop $mod_3d 
	if {$os_type == "windows"} then {
		grab $mod_3d
	}

#	grab $mod_3d
	wm title $mod_3d "3d master models used"
	$mod_3d configure -background $background_colour
	set f_upper [frame $mod_3d.f1 -background $background_colour]
	set f_lower [frame $mod_3d.f2 -background $background_colour]
	pack $f_upper $f_lower -in $mod_3d
	set i_model 0
	foreach model $generative_models {
		set f_upper_lab [frame $f_upper.lab_$i_model -background $background_colour]
		set lab [label $f_upper_lab.lab_$i_model -background $background_colour -text $model]
		pack $lab -in $f_upper_lab -anchor w
		pack $f_upper_lab -in $f_upper
		incr i_model
	}
	button $f_lower.but_ok  -image but_ok -height 15 -width 75 -background $background_colour \
			-command { 	destroy .mod_3d  }
	pack $f_lower.but_ok -in $f_lower
}

#########################################################################
# show td1 configuration
#########################################################################

proc show_td1_config {} {
	global log
	global os_type
	global where_am_i
	global background_colour
	set f_td1 [open "$where_am_i/config/td1_config.cfg" r]
	set mod_td1 [toplevel .mod_td1]
	putWindowOnTop $mod_td1 
	if {$os_type == "windows"} then {
		grab $mod_td1
	}
	wm title $mod_td1 "td1 config used"
	$mod_td1 configure -background $background_colour
	set f_upper [frame $mod_td1.f1 -background $background_colour]
	set f_lower [frame $mod_td1.f2 -background $background_colour]
	pack $f_upper $f_lower -in $mod_td1

	text $f_upper.text -width 80
	pack $f_upper.text -in $f_upper

	while {![eof $f_td1]} {
		gets $f_td1 line
		$f_upper.text insert end "$line\n"
	}
	close $f_td1
	button $f_lower.but_ok  -image but_ok -height 15 -width 75 -background $background_colour \
			-command { 	destroy .mod_td1  }
	pack $f_lower.but_ok -in $f_lower

}
