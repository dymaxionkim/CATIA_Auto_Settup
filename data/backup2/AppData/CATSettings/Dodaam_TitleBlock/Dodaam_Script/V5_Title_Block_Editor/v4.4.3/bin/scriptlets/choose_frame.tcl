proc kill_comm_data_set {} {
	global out_3
	if {[file exists $out_3]} {
		 file delete $out_3
	}
}
proc got_it {item} {
	global out_change
	global top_change
	global call_origin
	global frame_ids
	global where_am_i
	global changer_end
	global TBConfig
	
	set   f1  [open $out_change w]

	if {$item == "KeepFrame"} then {
		puts $f1 "KeepFrame"
	} else {
		puts  $f1 [file nativename $frame_ids($item)]
	}
	puts $f1 $TBConfig
	
	close $f1
	if {$call_origin == "from_catia"} {
		kill_comm_data_set
	}
	destroy $top_change
}

proc changerPopulateList {} {
	global list_of_frames
	global frame_ids
	global CATIA_TEMPLATES
	global sheetPaperSize
	
	
	set frames [glob "[getTemplateDirectory]/*.CATDrawing"]
	# sort the list of frames
	set frames [lsort $frames]
	
	set i 0
	if {[array exists frame_ids]} {
		unset frame_ids
		$list_of_frames delete  [$list_of_frames items]
	}
	
	foreach frame $frames {
    	incr i
		set frame_ids(list_$i) $frame
    	set item [file tail $frame]
    	set pic_name [file rootname $frame].gif
    	if {[file exists $pic_name]} {
			image create photo pic_$i -file  $pic_name
    		$list_of_frames insert end list_$i -text $item -image pic_$i
    	} else {
    		$list_of_frames insert end list_$i -text $item
    	}
	}
	if {![info exists sheetPaperSize]} then {
		set sheetPaperSize ""
	}
		
	# check for papersize, mark and show the correspondig frame
	set cfgFile "[getTemplateDirectory]/paperSizeConfig.cfg"
	if {[file exists $cfgFile]} then {
		set f1 [open $cfgFile r]
		while {![eof $f1]} {
			 gets $f1 line
			 if {[string range $line 0 0] != "#"} then {
				 set line [string trim $line]
				 set temp [split $line ","]
				 set frame "[getTemplateDirectory]/[lindex $temp 0]"
				 set size  [lindex $temp 1]
				 if {$size == $sheetPaperSize} then {
					foreach name [array names frame_ids] {
					    if {$frame_ids($name) == $frame} then {
							$list_of_frames itemconfigure $name -fill green
							$list_of_frames see $name
						}
					}
				 }
			 }
		}
		close $f1
	}
}

proc getValueFromConfig {config parameterName} {
	global where_am_i

	set value "NotFound"
	set configFile "$where_am_i/config/custom/$config/title_block_config.tcl"
	set f1 [open $configFile r]
	while {![eof $f1]} {
		 gets $f1 line
		 set line [string trim $line]
		 set temp [split $line]
		 if {[lindex $temp 0] == "set"} {
			if {[lindex $temp 1] == $parameterName} {
				set value [lindex $temp 2]
			}
		}
	}
#	tk_messageBox -message $value
	set value [string trim $value \" ]
	set value [subst $value]

	return $value
	close $f1
}

proc getValueFromGeneralConfig {parameterName} {
	global where_am_i

	set value "NotFound"
	set configFile "$where_am_i/config/general/basics.cfg"
	set f1 [open $configFile r]
	while {![eof $f1]} {
		 gets $f1 line
		 set line [string trim $line]
		 set temp [split $line "="]
		 if {[string trim [lindex $temp 0]] == $parameterName} then {
			set value [string trim [lindex $temp 1]]
		 }
	}
#	tk_messageBox -message $value
	set value [string trim $value \" ]
	set value [subst $value]
	if {($value == "NotFound") && ($parameterName == "DefaultConfig")} then {
		set value "standard"
	}
	return $value
	close $f1
}


proc changer {} {
	global os_type
	global where_am_i
	global CATIA_TEMPLATES
	global TempFolder
	global out_change
	global out_3
	global frame_ids
	global call_origin
	global top_change
	global changer_end
	global TBConfig TBCfg
	global list_of_frames
	global sheetPaperSize
	global call_origin

	global choosePanelHeight
	global choosePanelWidth
	global choosePanelDeltaY 
	
	if {$os_type == "windows"} then {
		set out_change "$TempFolder\\cat_title_block_2.txt"
		set out_3 "$TempFolder\\cat_title_block_3.txt"

	} else {
   		set out_change "$TempFolder/cat_title_block_2.txt"
   		set out_3 "$TempFolder/cat_title_block_3.txt"

	}


#set log [open "$where_am_i/log.txt" w]

#########################################################################
#
#########################################################################

	image create photo but_can -file  "$where_am_i/icons/pic_can.gif"
	set background_colour "#FFE7BD"

	source $where_am_i/config/general/skin.tcl

	set top_change [toplevel .change_frame ]
	
	#keep the window on top
	putWindowOnTop $top_change
	
	
	$top_change configure -background $background_colour
	set sw  	[ScrolledWindow 	$top_change.top       	-background $background_colour]
	set top 	[ScrollableFrame  	$sw.top    	-background $background_colour]
	set bottom 	[frame           	$top_change.bottom 	-background $background_colour]

	pack $sw $bottom

	set list_of_frames [ListBox $sw.list  \
			-relief groove -borderwidth 0 \
            -width $choosePanelWidth -height $choosePanelHeight -deltay $choosePanelDeltaY \
			-padx 200 -background $background_colour]

	$list_of_frames bindImage <Button-1> got_it
	$list_of_frames bindText  <Button-1> got_it


	$sw setwidget $list_of_frames

	# called when no frame is in the drawing - setting TBConfig to "standard"
	if {![info exists TBConfig]} {
			set TBConfig [getValueFromGeneralConfig DefaultConfig]
	}

	wm title $top_change "Config: $TBConfig"
	
	# check for possible multiple configurations
	
	set search [file nativename "$where_am_i/config/custom/*"]
	set search [string map {"\\" "/"} $search]
	set configs [glob $search]
	set configs [lsort $configs]
	set config_list {"keep config"}
	foreach config $configs {
		set item [file tail $config]
		set item [file rootname $item]
		lappend config_list $item
 	}
	set TBCfg "keep config"
	
	frame $bottom.frame -background $background_colour
	label $bottom.frame.lab -text [translate "Change Configuration"] -background $background_colour
	if {[llength $configs] >1} {
		ComboBox $bottom.frame.combo -values $config_list -textvariable TBCfg \
	                	        -width 18 -dropenabled 1 -dragenabled 1 -modifycmd {
			if {$TBCfg != "keep config"} {
				set TBConfig $TBCfg
				set CATIA_TEMPLATES [getValueFromConfig $TBConfig "CATIA_TEMPLATES"]
				changerPopulateList
			}
		}
		if {$call_origin != "from_catia"} {
			button $bottom.frame.ok -image but_ok -command {
				set TBConfig $TBCfg
				got_it "KeepFrame"
			}
			pack $bottom.frame.lab $bottom.frame.combo $bottom.frame.ok -in $bottom.frame -side left

		} else {
			pack $bottom.frame.lab $bottom.frame.combo -in $bottom.frame -side left

		}

		pack $bottom.frame -in $bottom

	}


	button $bottom.cancel -image but_can -command {
		set   f1  [open $out_change w]
		puts  $f1 "cancelled"
		close $f1
		kill_comm_data_set
		destroy $top_change
#		exit
	}
	
	pack $bottom.cancel -in $bottom

#########################################################################
# populate list with contents of template dir
#########################################################################

	changerPopulateList
}