proc checkConsistency {mode} {
	global version
	global background_colour
	global sheet_names
	
	global title_fields
	global numsheets
	global l_global_sequence
	global l_sequence
	global change_enabled
	global revisions
	global num_changes
	global l_change_sequence
	global out
	global out_2
	global TBConfig
	
	#########################################################################
	# check for consistency of input data - missing fields
	#########################################################################

	set missing_list ""
	set missing 0
	set all_fields_list [array names title_fields]
	for {set sheet 1} {$sheet <= $numsheets} {incr sheet} {
		if {[info exists l_global_sequence]} {
			foreach seq $l_global_sequence  {
				if { [lsearch $all_fields_list $sheet\_TitleBlock_Text_$seq] < 0 } then {
					# global parameter from params (0 as sheet number)
					if  { [lsearch $all_fields_list "0_TitleBlock_Text_$seq"] < 0 } then {
						incr missing
						set l_temp ""
						lappend l_temp $sheet
						lappend l_temp TitleBlock_Text_$seq
						lappend missing_list $l_temp
				   }
				}
			}
		}
		foreach seq $l_sequence  {
			if {[lsearch $all_fields_list $sheet\_TitleBlock_Text_$seq] < 0 } then {
				incr missing
				set l_temp ""
				lappend l_temp $sheet
				lappend l_temp TitleBlock_Text_$seq
				lappend missing_list $l_temp
			}
		}
		if {$change_enabled == "true" } {
	        set revision_sequence [lrange $revisions 0 [expr $num_changes - 1]]
	        foreach rev $revision_sequence {
	            foreach seq $l_change_sequence  {
	                if {[lsearch $all_fields_list $sheet\_RevisionBlock_Text_$seq\_$rev] < 0} then {
	                    incr missing
	                    set l_temp ""
	                    lappend l_temp $sheet
	                    lappend l_temp RevisionBlock_Text_$seq\_$rev
	                    lappend missing_list $l_temp
	                }
	            }
	        }
	    }
	}

	if {$mode != "showPanel"} {
		return $missing
	}
	
	if {$missing > 0} {
		wm withdraw .
		set top [toplevel .t]
		putWindowOnTop .t 
		wm title $top "CATIA title block editor $version - error in model"
		$top configure -background $background_colour
		#
		# use a scrolled window, in case of many errors
		#
		set sw  	[ScrolledWindow   $top.sw   -background $background_colour ]
		set sf 		[ScrollableFrame  $top.sf   -background $background_colour -height 25 -width 80]
		$sw setwidget $sf
		pack $sw -in $top

		set top1 $top
		set top [$sf getframe]

		set row 0
		label $top.message -text [translate {Missing elements in Sheet(s)}] -background red
		grid configure $top.message -row $row -column 0
		incr row
		incr row
		set num_lab 0
		foreach item $missing_list {
			set sheet [lindex $item 0]
			set field [lindex $item 1]
			label $top.$num_lab -text "[translate {Missing}] : $sheet_names($sheet)" -background $background_colour
			grid configure $top.$num_lab -row $row -column 0
			incr num_lab

			label $top.$num_lab -text "$field" -background $background_colour
			grid configure $top.$num_lab -row $row -column 1
			incr num_lab
			incr row
		}
	#	image create photo but_ok 		-file  "$where_am_i/icons/pic_ok.gif"
	#	image create photo logo 		-file  "$where_am_i/icons/logo.gif"
		frame $top.buttons

		button $top.buttons.but_can -image but_can   -height 15 -width 75 -background $background_colour -command {
			set f1 [open $out w]
			puts $f1 "work§ko"
			close $f1
			kill_comm_data_set
			tbExit
		}

		button $top.buttons.but_change -image but_change_frame -height 15 -width 75 -background $background_colour -command {
			global TBConfig
			set call_origin "from_gui"
			changer
			tkwait window $top_change

			set f2 [open $out_2 r]
			gets $f2 line

			set frame_new "keep frame"
			if {$line != "cancelled"} {
					set item [file tail $line]
					set frame_new [file rootname $item]
			}
			close $f2

			set f1 [open $out w]
			# cath before puts statements because values may be missing
			if {$frame_new != "keep frame"} {
				puts $f1 "work§change title block"
				for {set sheet 1} {$sheet <= $numsheets} {incr sheet} {
					puts $f1 "cat_sheet§$sheet_names($sheet)§$view_names($sheet)"

					foreach seq $l_sequence {
		   				catch {puts $f1 $catia_names_stored([subst $sheet\_TitleBlock_Text_$seq])§[subst $title_fields([subst $sheet\_TitleBlock_Text_$seq])]}
					}
					foreach seq $l_global_sequence {
		   				catch {puts $f1 "TitleBlock_Text_$seq§[subst $title_fields([subst 0_TitleBlock_Text_$seq])]"}
					}

	#       	process Revisions
					for {set i 0} {$i < $num_changes} {incr i} {
						foreach j  $l_change_sequence {
	                    	   	catch {
	                    	   		set name [subst $sheet\_RevisionBlock_Text_$j\_[lindex $revisions $i]]
	                       			set value [subst $title_fields([subst $name])]
									puts $f1 "$catia_names_stored($name)§$value"
								}
						}
					}
					puts $f1 "cat_sheet_end"
				}

				set f2 		[open $out_2 w]
				set CATIA_TEMPLATES [getValueFromConfig $TBConfig "CATIA_TEMPLATES"]
				puts $f2 	[file nativename "$CATIA_TEMPLATES/$frame_new.CATDrawing"]
				puts $f2 $TBConfig
				close $f2
			} else {
				puts $f1 "work§ok"
			}
			close $f1
			kill_comm_data_set
			tbExit
		}
		pack $top.buttons.but_change $top.buttons.but_can -in $top.buttons
		grid configure $top.buttons 	-row $row -column 1
		label $top.logo -image logo -background $background_colour
		grid configure $top.logo -row $row -column 0

		tkwait window $top
	}
}

proc configGuesser {} {
	global where_am_i
	global TBConfig
	global tcl_platform
	global env
	global fields global_fields change_fields revisions
	global CATIA_TEMPLATES
	global background_colour
	
	# check the current config
	set TBact $TBConfig
#	set match [checkConsistency "configCheck"]
#	if {$match == 0} then {
#		return TBConfig
#	} else {
		# get configs
	set search [file nativename "$where_am_i/config/custom/*"]
	set search [string map {"\\" "/"} $search]
	set configs [glob $search]
	set configs [lsort $configs]

#	}
	
	# loop for all configs
#	tk_messageBox -message $configs
#	tk_messageBox -message $TBConfig

	set lConfig ""
	
	foreach cfg $configs {
		set config [file tail $cfg]
		set TBConfig $config
		
		array unset fields
		array unset global_fields
		if {[info exists CATIA_TEMPLATES]} {unset CATIA_TEMPLATES}
		if {[array exists extDefFields]} {array unset extDefFields}
		if {[array exists change_fields]} {array unset change_fields}
		
		source $where_am_i/config/custom/$config/title_block_config.tcl
		buildInternalLists
		set match [checkConsistency "configCheck"]
		
#		tk_messageBox -message $match
		# consistency found -> set new config

		if {$match ==0} then {
			#if {$TBConfig != $TBact} {
			#	tk_messageBox -message "Switching config from $TBact to $TBConfig"
			#}
			lappend lConfig $TBConfig
			# return $TBConfig
		}
	}
	# nothing found so far
	
	#tk_messageBox -message $lConfig
	
	if {[llength $lConfig] == 0} then {
		# no consistency found, reset old config
		if {[info exists CATIA_TEMPLATES]} {unset CATIA_TEMPLATES}
		array unset fields
		array unset global_fields
	 
		set TBConfig $TBact
		source $where_am_i/config/custom/$TBConfig/title_block_config.tcl
		buildInternalLists
		return $TBConfig
	}
	
	if {[llength $lConfig] == 1} then {
		set TBConfig [lindex $lConfig 0]
		array unset fields
		array unset global_fields
		if {[info exists CATIA_TEMPLATES]} {unset CATIA_TEMPLATES}
		if {[array exists extDefFields]} {array unset extDefFields}
		if {[array exists change_fields]} {array unset change_fields}
		
		source $where_am_i/config/custom/$TBConfig/title_block_config.tcl
		buildInternalLists

		return $TBConfig
	}

	
	# we've got more tahn one config which matches -> user to choose the right one
	set guiConfigs [toplevel .topConfig -background $background_colour]
	wm title $guiConfigs "Select Config"
	wm withdraw .
	putWindowOnTop $guiConfigs 
	
	wm protocol $guiConfigs "WM_DELETE_WINDOW" {
		set TBConfig [getValueFromGeneralConfig DefaultConfig]
		array unset fields
		array unset global_fields
		if {[info exists CATIA_TEMPLATES]} {unset CATIA_TEMPLATES}
		if {[array exists extDefFields]} {array unset extDefFields}
		if {[array exists change_fields]} {array unset change_fields}
		
		source $where_am_i/config/custom/$TBConfig/title_block_config.tcl
		buildInternalLists
		set killGui "killIt"
	}
	
	set labelView [translate "Multiple configs detected"]
	set tFcurFrame [TitleFrame $guiConfigs.fbckview -text $labelView -background $background_colour]
	set curFrame [$tFcurFrame getframe]
	label $curFrame.lab -text [translate "Select desired config"] -background $background_colour
	pack $curFrame.lab -in $curFrame
	foreach config $lConfig {
		set but [button $curFrame.b§$config  -text $config -width 35 -background $background_colour]
		bind $but <ButtonRelease-1> {
						set widget %W
						set TBConfig [lindex [split $widget "§"] 1]
						array unset fields
						array unset global_fields
						if {[info exists CATIA_TEMPLATES]} {unset CATIA_TEMPLATES}
						if {[array exists extDefFields]} {array unset extDefFields}
						if {[array exists change_fields]} {array unset change_fields}
		
						source $where_am_i/config/custom/$TBConfig/title_block_config.tcl
						buildInternalLists
						set killGui "killIt"
						update
					}

		pack $curFrame.b§$config -in $curFrame
	}
	pack $tFcurFrame -in $guiConfigs
	label $guiConfigs.logo -image logo -background $background_colour
	pack $guiConfigs.logo -in $guiConfigs



	tkwait variable killGui
	destroy .topConfig
	update
	return $TBConfig
}